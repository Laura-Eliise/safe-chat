import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../../utils/basic_user_info.dart';
import '../utils/convert.dart';
import '../utils/user.dart';
import 'user_api.dart';
import 'api.dart';

class ContactsApi extends Api {
  Future<List<BasicUserInfo>> getContacts(String input, User user) async {
    try {
      List<BasicUserInfo> contacts = [];

      var data = (await read("users")).docs;

      for (var doc in data) {
        var foundUser = doc.data() as Map<String, dynamic>;
        if (foundUser["email"] != user.email &&
            (foundUser["name"] == input || foundUser["email"] == input)) {
          contacts.add(BasicUserInfo(
            email: foundUser["email"],
            name: foundUser["name"],
            key: foundUser["key"],
          ));
        }
      }

      return contacts;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<List<BasicUserInfo>> getFriends(User user) async {
    try {
      List<BasicUserInfo> friends = [];

      var data = (await readPath(collection: "friends", path: user.email))
          .data() as Map<String, dynamic>?;
      if (data == null) return [];

      for (var entry in data["friends"].entries) {
        var userData =
            await UserApi().getUserInfo(email: Convert.decrypt(entry.key));
        if (userData == null) {
          debugPrint("Couldn't find user info for ${entry.key}");
          continue;
        }
        friends.add(
          BasicUserInfo(
            email: Convert.decrypt(entry.key),
            name: entry.value,
            image: userData["image"],
            key: userData["key"],
          ),
        );
      }

      return friends;
    } catch (e) {
      debugPrint("$e");
      return [];
    }
  }

  Future<String?> addFriend(User user, String email, String name) async {
    try {
      await update(
        collection: "friends",
        path: email,
        data: {"friends.${Convert.encrypt(user.email)}": user.name},
      );
      await update(
          collection: "friends",
          path: user.email,
          data: {"friends.${Convert.encrypt(email)}": name});
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return "Internal server error.\nPlease contact support.";
    }
  }

  Future<String?> removeFriend(User user, String email) async {
    try {
      await update(
        collection: "friends",
        path: user.email,
        data: {"friends.${Convert.encrypt(email)}": FieldValue.delete()},
      );
      await update(
        collection: "friends",
        path: email,
        data: {"friends.${Convert.encrypt(user.email)}": FieldValue.delete()},
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
