import 'dart:convert';
import 'dart:typed_data';

import '../config.dart';

class UserInfo {
  /// The unique ID of this user
  final String id;

  /// The unique login name of this user
  final String username;

  /// This user's display name
  final String? display;

  /// This user's current status
  final String? status;

  /// The Asset ID of this user's profile picture. Use [pfpUrl] to get a URL
  /// that points to the associated image.
  final String? pfpAssetId;

  const UserInfo({
    required this.id,
    required this.username,
    this.display,
    this.status,
    this.pfpAssetId,
  });

  String? get pfpUrl {
    if (pfpAssetId == null) return null;
    return "${Config.backendUri}/asset/$pfpAssetId";
  }

  /// Returns the name that should be displayed for this user.
  ///
  /// Will return the display name if this user has one, and their username
  /// otherwise.
  String getName() {
    return display ?? username;
  }
}

class DeviceInfo {
  /// The unique ID of this device
  final String id;

  /// This device's name, unique among all devices of this user
  final String name;

  /// An integer indicating the type of this device.
  ///
  /// | Numeric value | Device Type            |
  /// |---------------|------------------------|
  /// |             0 | Unknown device type    |
  /// |             1 | Mobile device          |
  /// |             2 | Desktop device         |
  /// |             3 | Command line interface |
  final int type;

  /// The last time this device was used.
  final DateTime lastActivity;

  const DeviceInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.lastActivity,
  });
}

enum MessageDirection { incoming, outgoing }

enum MessageState { sending, sent, failed }

/// The class representing a message in a chat.
class Message {
  /// The unique ID of this message.
  final String id;

  /// The MIME type of this message's content. This will most commonly be
  /// `"text/plain"` for simple text messages.
  final String type;

  /// The current state of this message. Possible values are:
  /// - [MessageState.sending]
  /// - [MessageState.sent]
  /// - [MessageState.failed]
  ///
  /// If this is an incoming message, this value will always be [MessageState.sent].
  final MessageState state;

  /// Whether this message was sent by this user themselves, or recieved from
  /// another user.
  final MessageDirection direction;

  /// The date and time at which this message was sent.
  final DateTime sentAt;

  /// The content of this message, in binary format.
  ///
  /// To get the message's content as a String, see [Message.asString].
  final Uint8List content;

  const Message({
    required this.id,
    required this.type,
    required this.state,
    required this.direction,
    required this.sentAt,
    required this.content,
  });

  /// Returns this message's content interpreted as a UTF-8 string. Consider
  /// checking whether the message's type matches this, as this method will
  /// return garbage otherwise.
  String asString() {
    return utf8.decode(content);
  }
}
