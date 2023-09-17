import 'package:flutter/material.dart';

import '../components/bottom_nav_bar.dart';
import '../provider/provider_manager.dart';
import '../screens/profile.dart';
import '../utils/navigation.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Profile"),
            IconButton(
              onPressed: logOut,
              icon: const Icon(
                Icons.logout,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: const Profile(),
      bottomNavigationBar: const BottomNavBar(
        index: 2,
      ),
    );
  }

  void logOut() async {
    await ProviderManager().logOut(context);
    if (!mounted) return;
    navigate(context, "/login");
  }
}
