import 'package:flutter/material.dart';

import '../../api/contacts_api.dart';
import '../../components/search_result.dart';
import '../../provider/provider_manager.dart';
import '../../utils/basic_user_info.dart';
import '../components/container.dart';
import '../utils/colors.dart';
import '../utils/user.dart';

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  late User _currentUser;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? user;
  String _infoText = "Search for friends";
  bool _searchLock = false;
  List<BasicUserInfo> contacts = [];

  @override
  void initState() {
    _currentUser = ProviderManager().getUser(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 100, 30, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RoundedGradientContainer(
            gradient: primeGradient,
            borderSize: 2,
            child: Flex(
              direction: Axis.horizontal,
              children: [
                _searchField,
                _searchButton,
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(_infoText),
          const SizedBox(height: 20),
          const Text(
            "Contact list ",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              color: primeColor,
            ),
          ),
          const SizedBox(height: 20),
          _contactList,
        ],
      ),
    );
  }

  void _search() async {
    debugPrint("Search button pressed");
    setState(() => _searchLock = true);
    String input = _searchController.value.text;
    contacts = await ContactsApi().getContacts(input, _currentUser);
    if (contacts.isEmpty) {
      setState(() {
        _searchLock = false;
        _infoText = "No contacts found";
      });
    } else {
      setState(() {
        _searchLock = false;
        _infoText = "Contacts found";
      });
    }
  }

  Widget get _searchButton {
    return TextButton(
        onPressed: _searchLock ? () {} : _search,
        style: TextButton.styleFrom(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            alignment: Alignment.centerRight),
        child: Container(
          decoration: BoxDecoration(
              gradient: primeGradient,
              borderRadius: BorderRadius.circular(5.0)),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 13.5),
            child: Text(
              "Search",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0),
            ),
          ),
        ));
  }

  Widget get _searchField {
    return Expanded(
      flex: 2,
      child: Form(
        key: _formKey,
        child: TextFormField(
          controller: _searchController,
          decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
              hintText: "Search by email",
              border: InputBorder.none),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Input required";
            } else {
              return null;
            }
          },
        ),
      ),
    );
  }

  Widget get _contactList {
    return Column(
      children: contacts
          .map((BasicUserInfo user) => SearchResult(
                email: user.email,
                name: user.name,
                resetState: () {
                  contacts.removeWhere((element) => element == user);
                  setState(() {
                    _infoText = "Contact added!";
                  });
                },
                setErrorState: (String msg) {
                  setState(() {
                    _infoText = msg;
                  });
                },
              ))
          .toList(),
    );
  }
}
