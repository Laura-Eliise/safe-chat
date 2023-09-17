import 'dart:convert';
import 'package:crypto/crypto.dart';

String combineAndHashEmails(String input1, String input2, [String? input3]) {
  String combinedEmails = input1 + input2 + (input3 ?? "");
  var bytes = utf8.encode(combinedEmails); 
  var hash = sha224.convert(bytes);
  return  hash.toString();
}
