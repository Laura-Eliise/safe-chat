import 'package:flutter/material.dart';

import '../../utils/navigation.dart';
import '../components/bottom_nav_bar.dart';
import '../screens/contacts.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBarInfo,
        automaticallyImplyLeading: false,
      ),
      body: const Contacts(),
      bottomNavigationBar: const BottomNavBar(
        index: 0,
      ),
    );
  }

  Widget get _appBarInfo {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Contacts"),
        IconButton(
          onPressed: scanQR,
          icon: const Icon(
            Icons.qr_code_scanner,
          ),
        ),
      ],
    );
  }

  void scanQR() {
    navigate(context, "/scan-qr");
  }
}
