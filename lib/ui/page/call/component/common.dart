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

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller.dart';
import '../widget/call_button.dart';
import '../widget/call_title.dart';
import '../widget/round_button.dart';
import '/domain/model/ongoing_call.dart';
import '/l10n/l10n.dart';
import '/routes.dart';
import '/themes.dart';
import '/ui/widget/svg/svg.dart';

/// Button in a [CallView].
///
/// Intended to be placed in a [Dock] to be reordered around.
abstract class CallButton {
  const CallButton(this.c);

  /// [CallController] owning this [CallButton], used for changing the state.
  final CallController c;

  /// Indicates whether this [CallButton] can be removed from the [Dock].
  bool get isRemovable => true;

  /// Returns a text-represented hint for this [CallButton].
  String get hint;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  bool operator ==(Object other) =>
      other is CallButton && runtimeType == other.runtimeType;

  /// Builds the [Widget] representation of this [CallButton].
  Widget build({bool hinted = true});
}

/// [CallButton] toggling a more panel.
class MoreButton extends CallButton {
  const MoreButton(CallController c) : super(c);

  @override
  bool get isRemovable => false;

  @override
  String get hint => 'btn_call_more'.l10n;

  @override
  Widget build({bool hinted = true}) {
    return CallButtonWidget(
      hint: hint,
      asset: SvgIcons.callMore,
      hinted: hinted,
      onPressed: c.toggleMore,
    );
  }
}

/// [CallButton] toggling a local video.
class VideoButton extends CallButton {
  const VideoButton(CallController c) : super(c);

  @override
  String get hint {
    bool isVideo = c.videoState.value == LocalTrackState.enabled ||
        c.videoState.value == LocalTrackState.enabling;
    return isVideo ? 'btn_call_video_off'.l10n : 'btn_call_video_on'.l10n;
  }

  @override
  Widget build({bool hinted = true, bool blur = false}) {
    return Obx(() {
      bool isVideo = c.videoState.value == LocalTrackState.enabled ||
          c.videoState.value == LocalTrackState.enabling;
      return CallButtonWidget(
        hint: hint,
        asset: isVideo ? SvgIcons.callVideoOn : SvgIcons.callVideoOff,
        hinted: hinted,
        withBlur: blur,
        onPressed: c.toggleVideo,
      );
    });
  }
}

/// [CallButton] toggling a local audio.
class AudioButton extends CallButton {
  const AudioButton(CallController c) : super(c);

  @override
  String get hint {
    bool isAudio = c.audioState.value == LocalTrackState.enabled ||
        c.audioState.value == LocalTrackState.enabling;
    return isAudio ? 'btn_call_audio_off'.l10n : 'btn_call_audio_on'.l10n;
  }

  @override
  Widget build({bool hinted = true, bool blur = false}) {
    return Obx(() {
      bool isAudio = c.audioState.value == LocalTrackState.enabled ||
          c.audioState.value == LocalTrackState.enabling;
      return CallButtonWidget(
        hint: hint,
        asset: isAudio ? SvgIcons.callMicrophoneOn : SvgIcons.callMicrophoneOff,
        hinted: hinted,
        withBlur: blur,
        onPressed: c.toggleAudio,
      );
    });
  }
}

/// [CallButton] toggling a local screen-sharing.
class ScreenButton extends CallButton {
  const ScreenButton(CallController c) : super(c);

  @override
  String get hint {
    bool isScreen = c.screenShareState.value == LocalTrackState.enabled ||
        c.screenShareState.value == LocalTrackState.enabling;
    return isScreen ? 'btn_call_screen_off'.l10n : 'btn_call_screen_on'.l10n;
  }

  @override
  Widget build({bool hinted = true}) {
    return Obx(() {
      bool isScreen = c.screenShareState.value == LocalTrackState.enabled ||
          c.screenShareState.value == LocalTrackState.enabling;
      return CallButtonWidget(
        hint: hint,
        asset:
            isScreen ? SvgIcons.callScreenShareOff : SvgIcons.callScreenShareOn,
        hinted: hinted,
        onPressed: () => c.toggleScreenShare(router.context!),
      );
    });
  }
}

/// [CallButton] toggling hand.
class HandButton extends CallButton {
  const HandButton(CallController c) : super(c);

  @override
  String get hint => c.me.isHandRaised.value
      ? 'btn_call_hand_down'.l10n
      : 'btn_call_hand_up'.l10n;

  @override
  Widget build({bool hinted = true}) {
    return Obx(() {
      return CallButtonWidget(
        hint: hint,
        asset: c.me.isHandRaised.value
            ? SvgIcons.callHandDown
            : SvgIcons.callHandUp,
        hinted: hinted,
        onPressed: c.toggleHand,
      );
    });
  }
}

/// [CallButton] invoking the [CallController.openSettings].
class SettingsButton extends CallButton {
  const SettingsButton(CallController c) : super(c);

  @override
  String get hint => 'btn_call_settings'.l10n;

  @override
  Widget build({bool hinted = true}) {
    return CallButtonWidget(
      hint: hint,
      asset: SvgIcons.callSettings,
      hinted: hinted,
      onPressed: () => c.openSettings(router.context!),
    );
  }
}

/// [CallButton] invoking the [CallController.openAddMember].
class ParticipantsButton extends CallButton {
  const ParticipantsButton(CallController c) : super(c);

  @override
  String get hint => 'btn_participants'.l10n;

  @override
  Widget build({bool hinted = true}) {
    return CallButtonWidget(
      hint: hint,
      asset: SvgIcons.callParticipants,
      offset: const Offset(2, 0),
      hinted: hinted,
      onPressed: () => c.openAddMember(router.context!),
    );
  }
}

/// [CallButton] toggling the remote video.
class RemoteVideoButton extends CallButton {
  const RemoteVideoButton(CallController c) : super(c);

  @override
  String get hint => c.isRemoteVideoEnabled.value
      ? 'btn_call_remote_video_off'.l10n
      : 'btn_call_remote_video_on'.l10n;

  @override
  Widget build({bool hinted = true}) {
    return Obx(() {
      return CallButtonWidget(
        hint: hint,
        asset: c.isRemoteVideoEnabled.value
            ? SvgIcons.callIncomingVideoOn
            : SvgIcons.callIncomingVideoOff,
        hinted: hinted,
        onPressed: c.toggleRemoteVideos,
      );
    });
  }
}

/// [CallButton] toggling the remote audio.
class RemoteAudioButton extends CallButton {
  const RemoteAudioButton(CallController c) : super(c);

  @override
  String get hint => c.isRemoteAudioEnabled.value
      ? 'btn_call_remote_audio_off'.l10n
      : 'btn_call_remote_audio_on'.l10n;

  @override
  Widget build({bool hinted = true}) {
    return Obx(() {
      return CallButtonWidget(
        hint: hint,
        asset: c.isRemoteAudioEnabled.value
            ? SvgIcons.callIncomingAudioOn
            : SvgIcons.callIncomingAudioOff,
        hinted: hinted,
        onPressed: c.toggleRemoteAudios,
      );
    });
  }
}

/// [CallButton] accepting a call without video.
class AcceptAudioButton extends CallButton {
  const AcceptAudioButton(super.c, {this.highlight = false});

  /// Indicator whether this [AcceptAudioButton] should be highlighted.
  final bool highlight;

  @override
  String get hint => 'btn_call_answer_with_audio'.l10n;

  @override
  Widget build({bool hinted = true, bool expanded = false}) {
    final style = Theme.of(router.context!).style;

    return CallButtonWidget(
      hint: hint,
      asset:
          expanded ? SvgIcons.acceptAudioCall : SvgIcons.acceptAudioCallSmall,
      color: style.colors.accept,
      hinted: hinted,
      expanded: expanded,
      withBlur: expanded,
      border: highlight
          ? Border.all(color: style.colors.onPrimaryOpacity50, width: 1.5)
          : null,
      onPressed: () => c.join(withVideo: false),
    );
  }
}

/// [RoundFloatingButton] accepting a call with video.
class AcceptVideoButton extends CallButton {
  const AcceptVideoButton(super.c, {this.highlight = false});

  /// Indicator whether this [AcceptVideoButton] should be highlighted.
  final bool highlight;

  @override
  String get hint => 'btn_call_answer_with_video'.l10n;

  @override
  Widget build({bool hinted = true, bool expanded = false}) {
    final style = Theme.of(router.context!).style;

    return CallButtonWidget(
      hint: hint,
      asset: SvgIcons.callVideoOn,
      color: style.colors.accept,
      hinted: hinted,
      expanded: expanded,
      withBlur: expanded,
      border: highlight
          ? Border.all(color: style.colors.onPrimaryOpacity50, width: 1.5)
          : null,
      onPressed: () => c.join(withVideo: true),
    );
  }
}

/// [RoundFloatingButton] declining a call.
class DeclineButton extends CallButton {
  const DeclineButton(CallController c) : super(c);

  @override
  String get hint => 'btn_call_decline'.l10n;

  @override
  Widget build({bool hinted = true, bool expanded = false}) {
    final style = Theme.of(router.context!).style;

    return CallButtonWidget(
      hint: hint,
      asset: SvgIcons.callEndBig,
      color: style.colors.decline,
      hinted: hinted,
      expanded: expanded,
      withBlur: expanded,
      onPressed: c.decline,
    );
  }
}

/// [RoundFloatingButton] dropping a call.
class DropButton extends CallButton {
  const DropButton(CallController c) : super(c);

  @override
  String get hint => 'btn_call_end'.l10n;

  @override
  Widget build({bool hinted = true}) {
    final style = Theme.of(router.context!).style;

    return CallButtonWidget(
      hint: hint,
      asset: SvgIcons.callEndBig,
      color: style.colors.decline,
      hinted: hinted,
      onPressed: c.drop,
    );
  }
}

/// [RoundFloatingButton] canceling an outgoing call.
class CancelButton extends CallButton {
  const CancelButton(CallController c) : super(c);

  @override
  String get hint => 'btn_call_cancel'.l10n;

  @override
  Widget build({bool hinted = true, bool blur = false}) {
    final style = Theme.of(router.context!).style;

    return CallButtonWidget(
      hint: hint,
      asset: SvgIcons.callEndBig,
      color: style.colors.decline,
      hinted: hinted,
      withBlur: blur,
      onPressed: c.drop,
    );
  }
}

/// [CallButton] ending the call.
class EndCallButton extends CallButton {
  const EndCallButton(CallController c) : super(c);

  @override
  bool get isRemovable => false;

  @override
  String get hint => 'btn_call_end'.l10n;

  @override
  Widget build({bool hinted = true}) {
    final style = Theme.of(router.context!).style;

    return CallButtonWidget(
      asset: SvgIcons.callEndBig,
      hint: hint,
      color: style.colors.decline,
      hinted: hinted,
      onPressed: c.drop,
    );
  }
}

/// [RoundFloatingButton] switching a speaker output.
class SpeakerButton extends CallButton {
  const SpeakerButton(CallController c) : super(c);

  @override
  String get hint => 'btn_call_toggle_speaker'.l10n;

  @override
  Widget build({bool hinted = true, bool blur = false}) {
    return Obx(() {
      return CallButtonWidget(
        hint: hint,
        asset: c.isRemoteAudioEnabled.value
            ? SvgIcons.callIncomingAudioOn
            : SvgIcons.callIncomingAudioOff,
        hinted: hinted,
        withBlur: blur,
        onPressed: c.toggleSpeaker,
      );
    });
  }
}

/// [RoundFloatingButton] switching a local video stream.
class SwitchButton extends CallButton {
  const SwitchButton(CallController c) : super(c);

  @override
  String get hint => 'btn_call_switch_camera'.l10n;

  @override
  Widget build({bool hinted = true, bool blur = false}) {
    return Obx(() {
      return CallButtonWidget(
        hint: hint,
        asset: c.cameraSwitched.value
            ? SvgIcons.callCameraFront
            : SvgIcons.callCameraBack,
        hinted: hinted,
        withBlur: blur,
        onPressed: c.switchCamera,
      );
    });
  }
}

/// Returns a [Widget] building the title call information.
Widget callTitle(CallController c) {
  return Obx(() {
    final bool isOutgoing =
        (c.outgoing || c.state.value == OngoingCallState.local) && !c.started;
    final bool isDialog = c.chat.value?.chat.value.isDialog == true;
    final bool withDots = c.state.value != OngoingCallState.active &&
        (c.state.value == OngoingCallState.joining || isOutgoing);

    final Map<String, dynamic> args = {'by': 'x'};
    if (!isOutgoing && !isDialog) {
      args['by'] = c.callerName;
    }

    final String? state = c.state.value == OngoingCallState.active
        ? c.duration.value.toString().split('.').first.padLeft(8, '0')
        : c.state.value == OngoingCallState.joining
            ? 'label_call_joining'.l10n
            : isOutgoing
                ? isDialog
                    ? null
                    : 'label_call_connecting'.l10n
                : c.withVideo == true
                    ? 'label_video_call'.l10nfmt(args)
                    : 'label_audio_call'.l10nfmt(args);

    return CallTitle(
      c.me.id.userId,
      chat: c.chat.value?.chat.value,
      title: c.chat.value?.title.value,
      avatar: c.chat.value?.avatar.value,
      state: state,
      withDots: withDots,
    );
  });
}
