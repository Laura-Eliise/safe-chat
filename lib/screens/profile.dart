import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../components/container.dart';
import '../provider/provider_manager.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late String name;
  late String email;
  @override
  void initState() {
    name = ProviderManager().getUser(context).name;
    email = ProviderManager().getUser(context).email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 100, 10, 100),
      child: Center(
        child: RoundedGradientContainer(
          borderSize: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _qrCode,
              _infoField("Username \n", name),
              _infoField("Email \n", email),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _qrCode {
    return SizedBox(
      height: 210.0,
      width: 210.0,
      child: QrImageView(
        data: '$name:$email',
        version: QrVersions.auto,
        size: 210.0,
      ),
    );
  }

  Widget _infoField(title, data) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(17, 0, 17, 15),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.black,
            ),
            children: <TextSpan>[
              TextSpan(text: title),
              TextSpan(
                  text: data,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ));
  }
}
