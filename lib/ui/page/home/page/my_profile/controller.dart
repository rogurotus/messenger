// Copyright © 2022-2023 IT ENGINEERING MANAGEMENT INC,
//                       <https://github.com/team113>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU Affero General Public License v3.0 as published by the
// Free Software Foundation, either version 3 of the License, or (at your
// option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License v3.0 for
// more details.
//
// You should have received a copy of the GNU Affero General Public License v3.0
// along with this program. If not, see
// <https://www.gnu.org/licenses/agpl-3.0.html>.

import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:medea_jason/medea_jason.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '/api/backend/schema.dart' show Presence;
import '/domain/model/application_settings.dart';
import '/domain/model/media_settings.dart';
import '/domain/model/mute_duration.dart';
import '/domain/model/my_user.dart';
import '/domain/model/native_file.dart';
import '/domain/model/user.dart';
import '/domain/repository/settings.dart';
import '/domain/repository/user.dart';
import '/domain/service/my_user.dart';
import '/l10n/l10n.dart';
import '/provider/gql/exceptions.dart';
import '/routes.dart';
import '/themes.dart';
import '/ui/worker/cache.dart';
import '/util/media_utils.dart';
import '/util/message_popup.dart';
import '/util/platform_utils.dart';

export 'view.dart';

/// Controller of the [Routes.me] page.
class MyProfileController extends GetxController {
  MyProfileController(this._myUserService, this._settingsRepo);

  /// Status of an [uploadAvatar] or [deleteAvatar] completion.
  ///
  /// May be:
  /// - `status.isEmpty`, meaning no [uploadAvatar]/[deleteAvatar] is executing.
  /// - `status.isLoading`, meaning [uploadAvatar]/[deleteAvatar] is executing.
  final Rx<RxStatus> avatarUpload = Rx(RxStatus.empty());

  /// [ScrollController] to pass to a [Scrollbar].
  final ScrollController scrollController = ScrollController();

  /// [ItemScrollController] of the profile's [ScrollablePositionedList].
  final ItemScrollController itemScrollController = ItemScrollController();

  /// [ItemPositionsListener] of the profile's [ScrollablePositionedList].
  final ItemPositionsListener positionsListener =
      ItemPositionsListener.create();

  /// Index of the initial profile page section to show in a
  /// [ScrollablePositionedList].
  int listInitIndex = 0;

  /// Indicator whether there's an ongoing [toggleMute] happening.
  ///
  /// Used to discard repeated toggling.
  final RxBool isMuting = RxBool(false);

  /// List of [MediaDeviceDetails] of all the available devices.
  final RxList<MediaDeviceDetails> devices = RxList<MediaDeviceDetails>([]);

  /// Index of an item from [ProfileTab] that should be highlighted.
  final RxnInt highlightIndex = RxnInt(null);

  /// Service responsible for [MyUser] management.
  final MyUserService _myUserService;

  /// Settings repository, used to update the [ApplicationSettings].
  final AbstractSettingsRepository _settingsRepo;

  /// Worker to react on [RouterState.profileSection] changes.
  Worker? _profileWorker;

  /// [StreamSubscription] for the [MediaUtils.onDeviceChange] stream updating
  /// the [devices].
  StreamSubscription? _devicesSubscription;

  /// [Duration] of the highlighting.
  static const Duration _highlightTimeout = Duration(seconds: 1);

  /// [Timer] resetting the [highlightIndex] value after the [_highlightTimeout]
  /// has passed.
  Timer? _highlightTimer;

  /// Returns the currently authenticated [MyUser].
  Rx<MyUser?> get myUser => _myUserService.myUser;

  /// Returns the current [ApplicationSettings] value.
  Rx<ApplicationSettings?> get settings => _settingsRepo.applicationSettings;

  /// Returns the current background's [Uint8List] value.
  Rx<Uint8List?> get background => _settingsRepo.background;

  /// Returns the current [MediaSettings] value.
  Rx<MediaSettings?> get media => _settingsRepo.mediaSettings;

  /// Returns the [User]s blacklisted by the authenticated [MyUser].
  RxList<RxUser> get blacklist => _myUserService.blacklist;

  @override
  void onInit() {
    if (!PlatformUtils.isMobile) {
      _devicesSubscription =
          MediaUtils.onDeviceChange.listen((e) => devices.value = e);
      MediaUtils.enumerateDevices().then((e) => devices.value = e);
    }

    listInitIndex = router.profileSection.value?.index ?? 0;

    bool ignoreWorker = false;
    bool ignorePositions = false;

    _profileWorker = ever(
      router.profileSection,
      (ProfileTab? tab) async {
        if (ignoreWorker) {
          ignoreWorker = false;
        } else {
          ignorePositions = true;
          await itemScrollController.scrollTo(
            index: tab?.index ?? 0,
            duration: 200.milliseconds,
            curve: Curves.ease,
          );
          Future.delayed(Duration.zero, () => ignorePositions = false);

          _highlight(tab);
        }
      },
    );

    positionsListener.itemPositions.addListener(() {
      if (!ignorePositions) {
        final ProfileTab tab = ProfileTab
            .values[positionsListener.itemPositions.value.first.index];
        if (router.profileSection.value != tab) {
          ignoreWorker = true;
          router.profileSection.value = tab;
          Future.delayed(Duration.zero, () => ignoreWorker = false);
        }
      }
    });

    super.onInit();
  }

  @override
  void onClose() {
    _profileWorker?.dispose();
    _devicesSubscription?.cancel();
    super.onClose();
  }

  /// Removes the currently set [background].
  Future<void> removeBackground() => _settingsRepo.setBackground(null);

  /// Opens an image choose popup and sets the selected file as a [background].
  Future<void> pickBackground() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
      withReadStream: false,
    );

    if (result != null && result.files.isNotEmpty) {
      _settingsRepo.setBackground(result.files.first.bytes);
    }
  }

  /// Toggles [MyUser.muted] status.
  Future<void> toggleMute(bool enabled) async {
    if (!isMuting.value) {
      isMuting.value = true;

      try {
        await _myUserService.toggleMute(
          enabled ? null : MuteDuration.forever(),
        );
      } on ToggleMyUserMuteException catch (e) {
        MessagePopup.error(e);
      } catch (e) {
        MessagePopup.error(e);
        rethrow;
      } finally {
        isMuting.value = false;
      }
    }
  }

  /// Deletes the [MyUser.avatar] and [MyUser.callCover].
  Future<void> deleteAvatar() async {
    avatarUpload.value = RxStatus.loading();
    try {
      await _updateAvatar(null);
    } finally {
      avatarUpload.value = RxStatus.empty();
    }
  }

  /// Uploads an image and sets it as [MyUser.avatar] and [MyUser.callCover].
  Future<void> uploadAvatar() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result?.files.isNotEmpty == true) {
        avatarUpload.value = RxStatus.loading();
        await _updateAvatar(NativeFile.fromPlatformFile(result!.files.first));
      }
    } finally {
      avatarUpload.value = RxStatus.empty();
    }
  }

  /// Deletes the provided [email] from [MyUser.emails].
  Future<void> deleteEmail(UserEmail email) async {
    try {
      await _myUserService.deleteUserEmail(email);
    } catch (_) {
      MessagePopup.error('err_data_transfer'.l10n);
      rethrow;
    }
  }

  /// Deletes the provided [phone] from [MyUser.phones].
  Future<void> deletePhone(UserPhone phone) async {
    try {
      await _myUserService.deleteUserPhone(phone);
    } catch (_) {
      MessagePopup.error('err_data_transfer'.l10n);
      rethrow;
    }
  }

  /// Deletes [myUser]'s account.
  Future<void> deleteAccount() async {
    try {
      await _myUserService.deleteMyUser();
      router.go(Routes.auth);
      router.tab = HomeTab.chats;
    } catch (_) {
      MessagePopup.error('err_data_transfer'.l10n);
      rethrow;
    }
  }

  /// Sets the [ApplicationSettings.loadImages] value.
  Future<void> setLoadImages(bool enabled) =>
      _settingsRepo.setLoadImages(enabled);

  /// Creates a new [ChatDirectLink] with the specified [ChatDirectLinkSlug] and
  /// deletes the current active [ChatDirectLink] of the authenticated [MyUser]
  /// (if any).
  Future<void> createChatDirectLink(ChatDirectLinkSlug slug) async {
    await _myUserService.createChatDirectLink(slug);
  }

  /// Updates [MyUser.name] field for the authenticated [MyUser].
  ///
  /// If [name] is null, then resets [MyUser.name] field.
  Future<void> updateUserName(UserName? name) async {
    await _myUserService.updateUserName(name);
  }

  /// Updates or resets the [MyUser.status] field of the authenticated
  /// [MyUser].
  Future<void> updateUserStatus(UserTextStatus? status) async {
    await _myUserService.updateUserStatus(status);
  }

  /// Updates [MyUser.login] field for the authenticated [MyUser].
  ///
  /// Throws [UpdateUserLoginException].
  Future<void> updateUserLogin(UserLogin login) async {
    await _myUserService.updateUserLogin(login);
  }

  /// Deletes the cache used by the application.
  Future<void> clearCache() => CacheWorker.instance.clear();

  /// Updates [MyUser.avatar] and [MyUser.callCover] with the provided [file].
  ///
  /// If [file] is `null`, then deletes the [MyUser.avatar] and
  /// [MyUser.callCover].
  Future<void> _updateAvatar(NativeFile? file) async {
    try {
      await Future.wait([
        _myUserService.updateAvatar(file),
        _myUserService.updateCallCover(file)
      ]);
    } on UpdateUserAvatarException catch (e) {
      MessagePopup.error(e);
    } on UpdateUserCallCoverException catch (e) {
      MessagePopup.error(e);
    } catch (e) {
      MessagePopup.error(e);
      rethrow;
    }
  }

  /// Highlights the provided [tab].
  Future<void> _highlight(ProfileTab? tab) async {
    highlightIndex.value = tab?.index;

    _highlightTimer?.cancel();
    _highlightTimer = Timer(_highlightTimeout, () {
      highlightIndex.value = null;
    });
  }
}

/// Extension adding text and [Color] representations of a [Presence] value.
extension PresenceL10n on Presence {
  /// Returns text representation of a current value.
  String? localizedString() {
    switch (this) {
      case Presence.present:
        return 'label_presence_present'.l10n;
      case Presence.away:
        return 'label_presence_away'.l10n;
      case Presence.artemisUnknown:
        return null;
    }
  }

  /// Returns a [Color] representing this [Presence].
  Color? getColor() {
    final Style style = Theme.of(router.context!).style;

    return switch (this) {
      Presence.present => style.colors.acceptAuxiliary,
      Presence.away => style.colors.warning,
      Presence.artemisUnknown => null,
    };
  }
}
