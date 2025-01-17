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

import 'package:hive_flutter/hive_flutter.dart';

import '/domain/model/attachment.dart';
import '/domain/model/avatar.dart';
import '/domain/model/chat.dart';
import '/domain/model/chat_call.dart';
import '/domain/model/chat_info.dart';
import '/domain/model/chat_item.dart';
import '/domain/model/chat_item_quote.dart';
import '/domain/model/crop_area.dart';
import '/domain/model/file.dart';
import '/domain/model/mute_duration.dart';
import '/domain/model/native_file.dart';
import '/domain/model/precise_date_time/precise_date_time.dart';
import '/domain/model/sending_status.dart';
import '/domain/model/user.dart';
import '/domain/model_type_id.dart';
import '/store/model/chat.dart';
import '/store/model/chat_item.dart';
import 'base.dart';
import 'chat_item.dart';

part 'chat.g.dart';

/// [Hive] storage for [Chat]s.
class ChatHiveProvider extends HiveLazyProvider<HiveChat>
    implements IterableHiveProvider<HiveChat, ChatId> {
  @override
  Stream<BoxEvent> get boxEvents => box.watch();

  @override
  String get boxName => 'chat';

  @override
  void registerAdapters() {
    Hive.maybeRegisterAdapter(AttachmentIdAdapter());
    Hive.maybeRegisterAdapter(ChatAdapter());
    Hive.maybeRegisterAdapter(ChatAvatarAdapter());
    Hive.maybeRegisterAdapter(ChatCallAdapter());
    Hive.maybeRegisterAdapter(ChatCallMemberAdapter());
    Hive.maybeRegisterAdapter(ChatCallQuoteAdapter());
    Hive.maybeRegisterAdapter(ChatCallRoomJoinLinkAdapter());
    Hive.maybeRegisterAdapter(ChatDirectLinkAdapter());
    Hive.maybeRegisterAdapter(ChatFavoritePositionAdapter());
    Hive.maybeRegisterAdapter(ChatForwardAdapter());
    Hive.maybeRegisterAdapter(ChatIdAdapter());
    Hive.maybeRegisterAdapter(ChatInfoActionAvatarUpdatedAdapter());
    Hive.maybeRegisterAdapter(ChatInfoActionCreatedAdapter());
    Hive.maybeRegisterAdapter(ChatInfoActionMemberAddedAdapter());
    Hive.maybeRegisterAdapter(ChatInfoActionMemberRemovedAdapter());
    Hive.maybeRegisterAdapter(ChatInfoActionNameUpdatedAdapter());
    Hive.maybeRegisterAdapter(ChatInfoAdapter());
    Hive.maybeRegisterAdapter(ChatInfoQuoteAdapter());
    Hive.maybeRegisterAdapter(ChatItemIdAdapter());
    Hive.maybeRegisterAdapter(ChatItemVersionAdapter());
    Hive.maybeRegisterAdapter(ChatItemsCursorAdapter());
    Hive.maybeRegisterAdapter(ChatMemberAdapter());
    Hive.maybeRegisterAdapter(ChatMembersDialedAllAdapter());
    Hive.maybeRegisterAdapter(ChatMembersDialedConcreteAdapter());
    Hive.maybeRegisterAdapter(ChatMessageAdapter());
    Hive.maybeRegisterAdapter(ChatMessageQuoteAdapter());
    Hive.maybeRegisterAdapter(ChatMessageTextAdapter());
    Hive.maybeRegisterAdapter(ChatNameAdapter());
    Hive.maybeRegisterAdapter(ChatVersionAdapter());
    Hive.maybeRegisterAdapter(CropAreaAdapter());
    Hive.maybeRegisterAdapter(FavoriteChatsCursorAdapter());
    Hive.maybeRegisterAdapter(FavoriteChatsListVersionAdapter());
    Hive.maybeRegisterAdapter(FileAttachmentAdapter());
    Hive.maybeRegisterAdapter(HiveChatAdapter());
    Hive.maybeRegisterAdapter(HiveChatCallAdapter());
    Hive.maybeRegisterAdapter(HiveChatForwardAdapter());
    Hive.maybeRegisterAdapter(HiveChatInfoAdapter());
    Hive.maybeRegisterAdapter(HiveChatMessageAdapter());
    Hive.maybeRegisterAdapter(ImageAttachmentAdapter());
    Hive.maybeRegisterAdapter(ImageFileAdapter());
    Hive.maybeRegisterAdapter(LastChatReadAdapter());
    Hive.maybeRegisterAdapter(LocalAttachmentAdapter());
    Hive.maybeRegisterAdapter(MediaTypeAdapter());
    Hive.maybeRegisterAdapter(MuteDurationAdapter());
    Hive.maybeRegisterAdapter(NativeFileAdapter());
    Hive.maybeRegisterAdapter(PlainFileAdapter());
    Hive.maybeRegisterAdapter(PreciseDateTimeAdapter());
    Hive.maybeRegisterAdapter(RecentChatsCursorAdapter());
    Hive.maybeRegisterAdapter(SendingStatusAdapter());
    Hive.maybeRegisterAdapter(UserAdapter());
  }

  @override
  Iterable<ChatId> get keys => keysSafe.map((e) => ChatId(e));

  @override
  Future<Iterable<HiveChat>> get values => valuesSafe;

  @override
  Future<void> put(HiveChat item) => putSafe(item.value.id.val, item);

  @override
  Future<HiveChat?> get(ChatId key) => getSafe(key.val);

  @override
  Future<void> remove(ChatId key) => deleteSafe(key.val);
}

/// Persisted in [Hive] storage [Chat]'s [value].
@HiveType(typeId: ModelTypeId.hiveChat)
class HiveChat extends HiveObject {
  HiveChat(
    this.value,
    this.ver,
    this.lastItemCursor,
    this.lastReadItemCursor,
    this.recentCursor,
    this.favoriteCursor,
  );

  /// Persisted [Chat] model.
  @HiveField(0)
  Chat value;

  /// Version of this [Chat]'s state.
  ///
  /// It increases monotonically, so may be used (and is intended to) for
  /// tracking state's actuality.
  @HiveField(1)
  ChatVersion ver;

  /// Cursor of a [Chat.lastItem].
  @HiveField(2)
  ChatItemsCursor? lastItemCursor;

  /// Cursor of a [Chat.lastReadItem].
  @HiveField(3)
  ChatItemsCursor? lastReadItemCursor;

  /// Cursor of the [value] when paginating through recent [Chat]s.
  @HiveField(4)
  RecentChatsCursor? recentCursor;

  /// Cursor of the [value] when paginating through favorite [Chat]s.
  @HiveField(5)
  FavoriteChatsCursor? favoriteCursor;
}
