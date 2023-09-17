import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../api/api.dart';
import '../../utils/combine_and_hash.dart';
import '../../utils/convert.dart';
import '../../utils/media_type.dart';

class MessageApi extends Api {
  String createDocId(String email1, String email2, bool isPrivate) {
    return combineAndHashEmails(
        email1, email2, isPrivate ? "private" : "public");
  }

  Future<List<Map<String, dynamic>>?> getMessages(String docId) async {
    try {
      List<Map<String, dynamic>> messages = [];
      var resp = await readPath(collection: "chats", path: docId);
      if (!resp.exists) return null;
      var data =
          (resp.data() as Map<String, dynamic>)["messages"] as List<dynamic>;

      for (var msg in data) {
        messages.add(msg as Map<String, dynamic>);
      }

      return messages;
    } on FirebaseException catch (e) {
      debugPrint(e.code);
      return null;
    } catch (e) {
      debugPrint("MessageApi: $e");
      return null;
    }
  }

  Future<void> createNewChatRoom(
    String docId,
    String email1,
    String email2, {
    required bool isPrivate,
  }) async {
    try {
      write(collection: "chats", path: docId, data: {
        "messages": [],
        if (!isPrivate) "${Convert.encrypt(email1)}_typing": false,
        if (!isPrivate) "${Convert.encrypt(email2)}_typing": false,
      });
    } catch (e) {
      debugPrint("MessageApi: $e");
    }
  }

  Future<void> sendMessage(
    String docId, {
    required String sender,
    required String body,
    required MediaType type,
    required Timestamp date,
  }) async {
    try {
      update(collection: "chats", path: docId, data: {
        "messages": FieldValue.arrayUnion([
          {
            "sender": Convert.encrypt(sender),
            "body": body,
            "type": type.str,
            "date": date,
            "seen": false,
          }
        ])
      });
    } catch (e) {
      debugPrint("MessageApi: $e");
    }
  }

  Future<void> editMessage({
    required String chatId,
    required int index,
    required String newBody,
    required MediaType newType,
  }) async {
    try {
      List<Map<String, dynamic>>? messages = await getMessages(chatId);
      if (messages == null || messages.length < index) {
        throw Exception("Unable to edit/delete a message at $index");
      }
      messages[index]["body"] = newBody;
      messages[index]["type"] = newType.str;
      await update(
        collection: "chats",
        path: chatId,
        data: {"messages": messages},
      );
    } catch (e) {
      debugPrint("MessageApi: $e");
    }
  }

  Future<void> setSeen({
    required String chatId,
    required int index,
  }) async {
    try {
      List<Map<String, dynamic>>? messages = await getMessages(chatId);
      if (messages == null || messages.length < index) {
        throw Exception("Unable to edit/delete a message at $index");
      }
      messages[index]["seen"] = true;
      await update(
        collection: "chats",
        path: chatId,
        data: {"messages": messages},
      );
    } catch (e) {
      debugPrint("MessageApi: $e");
    }
  }

  Future<void> setSeenAll({
    required String chatId,
    required List<int> indexes,
  }) async {
    try {
      if (indexes.isEmpty) return;
      List<Map<String, dynamic>>? messages = await getMessages(chatId);
      if (messages == null || messages.length < indexes.last) {
        throw Exception("Unable to edit/delete a message at ${indexes.last}");
      }
      for (var i in indexes) {
        messages[i]["seen"] = true;
      }
      await update(
        collection: "chats",
        path: chatId,
        data: {"messages": messages},
      );
    } catch (e) {
      debugPrint("MessageApi: $e");
    }
  }

  Future<void> setTypingStatus(
      {required String chatId,
      required String email,
      required bool isTyping}) async {
    try {
      update(
        collection: "chats",
        path: chatId,
        data: {"${Convert.encrypt(email)}_typing": isTyping},
      );
    } catch (e) {
      debugPrint("MessageApi: $e");
    }
  }

  Future<void> removeChatRoom(String chatId) async {
    try {
      await delete(collection: "chats", path: chatId);
    } catch (e) {
      debugPrint("MessageApi: $e");
    }
  }
}
