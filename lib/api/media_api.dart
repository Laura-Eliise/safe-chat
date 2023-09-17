import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';

import '../utils/convert.dart';
import '../utils/media_type.dart';

class MediaApi {
  Reference get _storage => FirebaseStorage.instance.ref();

  String toPath(
    String email, {
    required File file,
    required MediaType type,
  }) {
    return "${type.str}s/${Convert.encrypt(email)}/${basename(file.path)}";
  }

  void uploadFile(String link,
      {required File file,
      required MediaType type,
      void Function(String msg, [int? progress])? onUpdate,
      void Function({
        required String msg,
        required String fileLink,
      })? onComplete,
      void Function(String msg)? onError}) {
    var task = _storage.child(link).putFile(file).snapshotEvents;
    _handleUploadProgress(
      task,
      type.str,
      onUpdate: onUpdate,
      onComplete: (String msg) {
        (onComplete ?? ({required String msg, required String fileLink}) {})(
            msg: msg, fileLink: link);
      },
      onError: onError,
    );
  }

  void _handleUploadProgress(Stream<TaskSnapshot> stream, String type,
      {void Function(String msg, [int? progress])? onUpdate,
      void Function(String msg)? onComplete,
      void Function(String msg)? onError}) {
    try {
      stream.listen((taskSnapshot) {
        switch (taskSnapshot.state) {
          case TaskState.running:
            int progress = (100.0 *
                    (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes))
                .round();
            (onUpdate ?? (_, [__]) {})("Uploading $type: $progress%", progress);
            break;
          case TaskState.paused:
            (onUpdate ?? (_) {})("Uploading $type has been paused");
            break;
          case TaskState.success:
            (onComplete ?? (_) {})(
              "$type uploaded successfully.",
            );
            break;
          case TaskState.canceled:
            (onUpdate ?? (_) {})(
                "Uploading $type has been canceled. Please contact support");
            break;
          case TaskState.error:
            (onError ?? (_) {})(taskSnapshot.metadata.toString());
            break;
        }
      });
    } catch (e) {
      (onError ?? (_) {})(e.toString());
    }
  }

  Future<dynamic> fetchFile(
      {required String path,
      required MediaType type,
      bool returnFile = false,
      void Function(String msg, [int? progress])? onUpdate,
      void Function(String msg)? onComplete,
      void Function(String msg)? onError}) async {
    switch (type) {
      case MediaType.image:
        {
          var bytes = await _getDataBytes(path, type, onError: onError);
          if (bytes == null) return null;
          if (returnFile) return File.fromRawPath(bytes);
          return Image.memory(bytes);
        }
      case MediaType.audio:
        {
          return getFileDownloadLink(path);
        }
      case MediaType.video:
        {
          return getFileDownloadLink(path);
        }
      case MediaType.text:
        return throw Exception("Can't fetch text message from storage.");
      case MediaType.deleted:
        return throw Exception("Can't fetch removed messages.");
    }
  }

  Future<Uint8List?> _getDataBytes(String path, MediaType type,
      {void Function(String msg)? onError}) async {
    Uint8List? data = await _storage.child(path).getData(30485760);
    if (data == null) {
      (onError ?? (_) {})("${type.str} has no data");
      return null;
    }
    return data;
  }

  Future<String> getFileDownloadLink(String path) {
    return _storage.child(path).getDownloadURL();
  }
}
