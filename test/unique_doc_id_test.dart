import 'package:flutter_test/flutter_test.dart';
import 'package:secure_messenger/utils/combine_and_hash.dart';

void main() {
  String laura = "laura@gmail.com";
  String cola = "cola@gmail.com";
  String gukka = "gukka@gmail.com";

  setUp(() {});

  test("creating a unique id", () {
    var chatId1 = combineAndHashEmails(laura, cola);
    expect(chatId1.isNotEmpty, true);
  });
  test("creating a unique id with extra input", () {
    var chatId1 = combineAndHashEmails(laura, cola, "pr");
    expect(chatId1.isNotEmpty, true);
  });

  test("id is still unique when the values are flipped", () {
    var chatId1 = combineAndHashEmails(laura, cola, "pr");
    var chatId2 = combineAndHashEmails(cola, laura, "pr");
    expect(chatId2 != chatId1, true);
  });
  test("id is still unique when the first input value is the same", () {
    var chatId1 = combineAndHashEmails(laura, cola, "pr");
    var chatId2 = combineAndHashEmails(laura, gukka, "pr");
    expect(chatId2 != chatId1, true);
  });
  test("id is still unique when the second input value is the same", () {
    var chatId1 = combineAndHashEmails(cola, gukka, "pr");
    var chatId2 = combineAndHashEmails(laura, gukka, "pr");
    expect(chatId2 != chatId1, true);
  });
  test("id is still unique when the second input value is the same", () {
    var chatId1 = combineAndHashEmails(cola, gukka, "pr");
    var chatId2 = combineAndHashEmails(laura, gukka, "pr");
    expect(chatId2 != chatId1, true);
  });
}
