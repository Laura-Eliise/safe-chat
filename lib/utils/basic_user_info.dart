import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../api/user_api.dart';
import '../../utils/message.dart';

class BasicUserInfo {
  final String _name;
  final String _email;
  String key;
  final String? _imageUrl;
  final Message? _lastMessage;
  late Function update;
  late StreamSubscription<DocumentSnapshot<Object?>> _listener;

  String get name => _name;
  String get email => _email;
  String? get imageUrl => _imageUrl;
  Message? get lastMessage => _lastMessage;

  void dispose() {
    _listener.cancel();
  }

  void listen() {
    _listener =
        UserApi().getStream(collection: "users", path: email).listen((event) {
      if (event.exists) {
        var data = event.data() as Map<String, dynamic>;
        if (data["key"] != key) {
          key = data["key"];
          update();
        }
      }
    });
  }

  BasicUserInfo({
    required String email,
    required String name,
    required this.key,
    String? image,
    Message? lastMessage,
  })  : _email = email,
        _name = name,
        _imageUrl = image,
        _lastMessage = lastMessage {
    update = () {};
  }

  @override
  bool operator ==(Object other) {
    if (other is BasicUserInfo) {
      return other.email == email &&
          other.name == name &&
          other.key == key &&
          other.lastMessage == lastMessage &&
          other.imageUrl == imageUrl;
    }
    return super == other;
  }

  @override
  int get hashCode =>
      _name.hashCode ^
      _email.hashCode ^
      key.hashCode ^
      _lastMessage.hashCode ^
      imageUrl.hashCode;
}
