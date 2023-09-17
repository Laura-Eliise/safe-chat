import 'package:flutter/material.dart';

import '../../utils/basic_user_info.dart';
import '../utils/navigation.dart';
import 'container.dart';

class ConversationList extends StatefulWidget {
  final BasicUserInfo user;
  final bool isPrivate;

  const ConversationList(
    this.user, {
    super.key,
    required this.isPrivate,
  });

  @override
  State<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigate(context, "/chat", args: {
          "arg": [widget.user, widget.isPrivate]
        });
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        height: 60,
        child: RoundedGradientContainer(
          borderSize: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
             const SizedBox(
                width: 20,
              ),
              Text(
                widget.user.name,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(
                height: 6,
              ),
              Text(
                widget.user.lastMessage?.body ?? "",
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: widget.user.lastMessage?.seen ?? true
                        ? FontWeight.bold
                        : FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
      // Text(
      //   widget.user.lastMessage?.date.toString() ?? "",
      //   style: TextStyle(
      //       fontSize: 12,
      //       fontWeight: widget.user.lastMessage?.seen ?? true
      //           ? FontWeight.bold
      //           : FontWeight.normal),
      // ),
    );
  }
}
