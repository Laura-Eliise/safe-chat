
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../utils/user.dart';
import 'user_provider.dart';

class ProviderManager extends ChangeNotifier {
  /* User */
  User getUser(BuildContext context) {
    return Provider.of<UserDataProvider>(context, listen: false).user;
  }

  void setUser(BuildContext context, User user) {
    Provider.of<UserDataProvider>(context, listen: false).user = user;
  }

  void setImage(BuildContext context, XFile? image) {
    var userProvider = Provider.of<UserDataProvider>(context, listen: false);
    if (image != null) {
      userProvider.xImage = image;
      userProvider.complete = true;
    }
  }

    Future<void> logOut(BuildContext context) async {
    await getUser(context).logOut();
  }
}
