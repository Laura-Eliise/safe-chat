import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:secure_messenger/utils/navigation.dart';

import '../api/contacts_api.dart';
import '../components/user_field.dart';
import '../provider/provider_manager.dart';
import '../utils/basic_user_info.dart';
import '../utils/user.dart';

class QRScanPage extends StatefulWidget {
  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  late User _currentUser;
  late String username;
  late String email;
  List<BasicUserInfo> contacts = [];
  String _infoText = "Scan a code";

  @override
  void initState() {
    _currentUser = ProviderManager().getUser(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (contacts.isNotEmpty)
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(23, 15, 23, 15),
                      child: UserField(
                        type: "Add",
                        user: ProviderManager().getUser(context),
                        username: username,
                        email: email,
                        resetState: resetState,
                        setErrorState: (String msg) {
                          setState(() {
                            _infoText = msg;
                          });
                        },
                      ),
                    )
                  : Text(_infoText),
            ),
          )
        ],
      ),
    );
  }

  void resetState() {
    contacts.removeWhere((element) => element.name == username);
    setState(() {
      _infoText = "Contact added!";
      navigate(context, "/chat-page");
    });
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      debugPrint(scanData.code);
      username = scanData.code!.split(':')[0];
      email = scanData.code!.split(':')[1];
      contacts = await ContactsApi().getContacts(username, _currentUser);

      setState(() {
        username = username;
        email = email;
        contacts = contacts;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
