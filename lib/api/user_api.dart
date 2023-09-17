import 'package:flutter/cupertino.dart';
import 'api.dart';

class UserApi extends Api {
  /// Initialize a user in the database
  Future<bool> registerNewUser(
      {required String email,
      required String name,
      required String phone}) async {
    try {
      await write(
        collection: "users",
        path: email,
        data: {
          "email": email,
          "name": name,
          "phone": phone,
          "image": "",
          "key": "",
        },
      );
      await write(
        collection: "friends",
        path: email,
        data: {"friends": {}},
      );

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<String?> getUsername({required String email}) async {
    try {
      var resp = await readPath(collection: "users", path: email);
      return (resp.data() as Map<String, dynamic>)["name"] as String;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserInfo({required String email}) async {
    try {
      return (await readPath(collection: "users", path: email)).data()
          as Map<String, dynamic>;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<void> updateProfilePicture(
      {required String email, required String link}) async {
    update(collection: "users", path: email, data: {"image": link});
  }

  Future<void> updateKey({required String email, required String key}) async {
    update(collection: "users", path: email, data: {"key": key});
  }
}
