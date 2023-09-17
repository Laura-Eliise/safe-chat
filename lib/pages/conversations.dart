import 'package:flutter/material.dart';

import '../../api/contacts_api.dart';
import '../../provider/provider_manager.dart';
import '../../utils/basic_user_info.dart';
import '../../utils/colors.dart';

import '../components/bottom_nav_bar.dart';
import '../components/conversation_list.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  bool private = false;
  List<BasicUserInfo>? chatUsers;

  @override
  void initState() {
    _getChatUsers();
    super.initState();
  }

  void _getChatUsers() async {
    var user = ProviderManager().getUser(context);
    chatUsers = await ContactsApi().getFriends(user);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: private ? const Text("Private chat") : const Text("Public chat"),
        actions: <Widget>[_privateChatBtn],
        backgroundColor: primeColor,
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: chatUsers == null
          ? const Center(child: CircularProgressIndicator())
          : chatUsers!.isEmpty
              ? const Center(child: Text("Contacts page is empty!"))
              : ListView.builder(
                  itemCount: chatUsers!.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 16),
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ConversationList(
                      chatUsers![index],
                      isPrivate: private,
                    );
                  },
                ),
      bottomNavigationBar: const BottomNavBar(
        index: 1,
      ),
    );
  }

  Widget get _privateChatBtn {
    return Row(
      children: [
        FittedBox(
          fit: BoxFit.fill,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(0, 4, 10, 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.centerRight,
              splashFactory: NoSplash.splashFactory,
            ),
            onPressed: () => onTap(),
            child: Container(
              decoration: BoxDecoration(
                  color: primeColorDark.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(6.0)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 23.0, vertical: 6.0),
                child: Text(
                  private ? "Public" : "Private",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  void onTap() {
    setState(() => private = !private);
  }
}
