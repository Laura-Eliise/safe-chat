import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/user.dart';

class UserDataProvider with ChangeNotifier {
  late User user;
  late File _image;
  bool complete = false;

  set xImage(XFile image) {
    _image = File(image.path);
  }

  File get image => _image;
}
