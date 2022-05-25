import 'dart:convert';
import 'dart:typed_data';

class UserInfo {
  final String id;
  final String username;
  final String? display;

  const UserInfo(this.id, this.username, this.display);

  /// Returns the name that should be displayed for this user.
  ///
  /// Will return the display name if this user has one, and their username
  /// otherwise.
  String getName() {
    return display ?? username;
  }
}

class DeviceInfo {
  final String id;
  final String name;
  final int type;
  final DateTime lastActivity;

  const DeviceInfo(this.id, this.name, this.type, this.lastActivity);
}

enum MessageDirection { incoming, outgoing }

/// The class representing a message in a chat.
class Message {
  /// The MIME type of this message's content. This will most commonly be
  /// `"text/plain"` for simple text messages.
  final String type;

  /// Whether this message was sent by this user themselves, or recieved from
  /// another user.
  final MessageDirection direction;

  /// The date and time at which this message was sent.
  final DateTime sentAt;

  /// The content of this message, in binary format.
  ///
  /// To get the message's content as a String, see [Message.asString].
  final Uint8List content;

  const Message(this.type, this.direction, this.sentAt, this.content);

  /// Returns this message's content interpreted as a UTF-8 string. Consider
  /// checking whether the message's type matches this, as this method will
  /// return garbage otherwise.
  String asString() {
    return utf8.decode(content);
  }
}
