import 'package:cloud_firestore/cloud_firestore.dart';

class Api {
  Future<QuerySnapshot<Object?>> read(String collection) async {
    return await FirebaseFirestore.instance.collection(collection).get();
  }

  Future<DocumentSnapshot<Object?>> readPath({
    required String collection,
    required String path,
  }) async {
    return FirebaseFirestore.instance.collection(collection).doc(path).get();
  }

  Future<void> write({
    required String collection,
    required String path,
    required Map<String, Object?> data,
  }) {
    return FirebaseFirestore.instance
        .collection(collection)
        .doc(path)
        .set(data);
  }

  Future<void> update({
    required String collection,
    required String path,
    required Map<String, Object?> data,
  }) {
    return FirebaseFirestore.instance
        .collection(collection)
        .doc(path)
        .update(data);
  }

  Future<void> delete({
    required String collection,
    required String path,
  }) {
    return FirebaseFirestore.instance.collection(collection).doc(path).delete();
  }

  Stream<DocumentSnapshot<Object?>> getStream(
      {required String collection, String? path}) {
    return FirebaseFirestore.instance
        .collection(collection)
        .doc(path)
        .snapshots();
  }
}
