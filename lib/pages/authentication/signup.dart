import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/user_api.dart';
import '../../chat_encrypter/chat_encrypter_service.dart';
import '../../api/media_api.dart';
import '../../provider/provider_manager.dart';
import '../../components/border_color.dart';
import '../../components/container.dart';
import '../../components/scaffold.dart';
import '../../utils/media_type.dart';
import '../../utils/colors.dart';
import '../../utils/user.dart';
import '../../utils/navigation.dart';

class SignUp extends StatefulWidget {
  final user = User();
  final double _scaffoldBorderRadius;
  get borderRadius => _scaffoldBorderRadius;
  SignUp({super.key, double scaffoldBorderRadius = 20.0})
      : _scaffoldBorderRadius = scaffoldBorderRadius;
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late SharedPreferences pref;
  final ImagePicker picker = ImagePicker();
  File? image;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _passErrMsg;
  String? _emailErrMsg;
  String? _phoneErrMsg;
  String? _loadingText;
  BorderColor usernameCheck = BorderColor.neutral;
  BorderColor emailCheck = BorderColor.neutral;
  BorderColor phoneCheck = BorderColor.neutral;
  BorderColor passCheck = BorderColor.neutral;
  BorderColor pass2Check = BorderColor.neutral;
  bool _submitLock = false;

  @override
  void initState() {
    _getSharedPreferenceInstance();
    super.initState();
  }

  void _getSharedPreferenceInstance() async {
    try {
      pref = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint("Shared preference error: ${e.toString()}");
    }
  }

  Widget _createInputField(
    String hintText,
    BorderColor checker,
    TextEditingController controller,
    String? Function(String?) validator, {
    String? errorText,
    TextInputType inputType = TextInputType.text,
    bool obscureText = false,
  }) {
    return SizedBox(
        width: 0,
        child: RoundedGradientContainer(
          gradient: checker == BorderColor.error
              ? errorGradient
              : checker == BorderColor.correct
                  ? correctGradient
                  : null,
          child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: checker == BorderColor.error ? 5 : 0,
              ),
              child: TextFormField(
                obscureText: obscureText,
                enableSuggestions: false,
                autocorrect: false,
                controller: controller,
                keyboardType: inputType,
                decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10.0),
                    hintText: hintText,
                    errorText: errorText,
                    border:
                        checker != BorderColor.error ? InputBorder.none : null),
                validator: validator,
              )),
        ));
  }

  Widget get _imageField => GestureDetector(
      onTap: _pickImage,
      child: SizedBox(
        height: 150,
        child: ClipRRect(
          child: AspectRatio(
            aspectRatio: 500 / 500,
            child: image != null
                ? Image.file(
                    image as File,
                    fit: BoxFit.cover,
                  )
                : const RoundedGradientContainer(
                    borderSize: 2,
                    child: Center(
                      child: Text(
                        "Add profile picture",
                        style: TextStyle(fontSize: 22, color: Colors.black54),
                      ),
                    )),
          ),
        ),
      ));
  Widget get _usernameField => _createInputField(
        "Username",
        usernameCheck,
        _usernameController,
        _validateUsernameField,
      );
  Widget get _emailField => _createInputField(
        "Email",
        emailCheck,
        _emailController,
        _validateEmailField,
        inputType: TextInputType.emailAddress,
        errorText: _emailErrMsg,
      );
  Widget get _phoneField => _createInputField(
        "Phone Number",
        phoneCheck,
        _phoneController,
        _validatePhoneField,
        inputType: TextInputType.phone,
        errorText: _phoneErrMsg,
      );
  Widget get _passwordField => _createInputField(
        "Password",
        passCheck,
        _passwordController,
        _validatePasswordField,
        errorText: _passErrMsg,
        obscureText: true,
      );
  Widget get _password2Field => _createInputField(
        "Repeat Password",
        pass2Check,
        _password2Controller,
        _validatePassword2Field,
        obscureText: true,
      );

  void _pickImage() async {
    var newImage = await picker.pickImage(source: ImageSource.gallery);
    if (newImage != null) {
      debugPrint("New Image Picked: ${newImage.path}");
      setState(() => image = File(newImage.path));
    } else {}
  }

  String? _validateUsernameField(String? value) {
    if (value == null || value.isEmpty || value.length < 4) {
      usernameCheck = BorderColor.error;
      return "Username required";
    }
    usernameCheck = BorderColor.correct;
    return null;
  }

  String? _validateEmailField(String? value) {
    if (value == null || value.isEmpty) {
      emailCheck = BorderColor.error;
      return "Email required";
    } else if (!value.contains("@") ||
        !value.contains(".") ||
        value.length < 4) {
      emailCheck = BorderColor.error;
      return "Email is wrong";
    }
    emailCheck = BorderColor.correct;
    return null;
  }

  String? _validatePhoneField(String? value) {
    if (value == null || value.isEmpty) {
      phoneCheck = BorderColor.error;
      return "Phone number required";
    }

    var regexUSA = RegExp(r'^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}$');
    var regexUni = RegExp(r'^(\+|00)[1-9][0-9 \-\(\)\.\/]{7,20}$');
    value = value.trim();
    value = value.replaceAll(RegExp(r' +'), " ");

    if (!regexUSA.hasMatch(value) && !regexUni.hasMatch(value)) {
      phoneCheck = BorderColor.error;
      return "Enter a valid International or USA phone number (+xxx xxxx xxxx or xxx-xxx-xxxx)";
    }
    phoneCheck = BorderColor.correct;
    return null;
  }

  String? _validatePasswordField(String? value) {
    if (value == null ||
        value.isEmpty ||
        value != _password2Controller.value.text) {
      passCheck = BorderColor.error;
      return "Password required";
    }
    passCheck = BorderColor.correct;
    return null;
  }

  String? _validatePassword2Field(String? value) {
    if (value == null ||
        value.isEmpty ||
        value != _passwordController.value.text) {
      pass2Check = BorderColor.error;
      return "Password incorrect or doesn't match";
    }
    pass2Check = BorderColor.correct;
    return null;
  }

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      _removeAllNegativeCheckers();
      setState(() {
        _loadingText = "Validating data...";
        _submitLock = true;
      });

      if (image == null) {
        setState(() {
          _loadingText = "Please pick an image!";
          _submitLock = false;
        });
        return;
      }

      var name = _usernameController.value.text;
      var email = _emailController.value.text;
      var password = _passwordController.value.text;
      var phone = _phoneController.value.text;

      String? resp = await widget.user.registerUser(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      if (resp == null) {
        if (image != null) {
          MediaApi().uploadFile(
            MediaApi().toPath(
              email,
              file: image as File,
              type: MediaType.image,
            ),
            type: MediaType.image,
            file: image as File,
            onUpdate: (String msg, [int? _]) =>
                setState(() => _loadingText = msg),
            onComplete: (
                {required String msg, required String fileLink}) async {
              setState(() => _loadingText = msg);
              UserApi().updateProfilePicture(email: email, link: fileLink);
              await _setUser(email);
              redirect();
            },
            onError: (String msg) {
              setState(() {
                _loadingText = null;
                _submitLock = false;
              });
              debugPrint(msg);
              _handleRejection("image-error");
            },
          );
        } else {
          setState(() {
            _loadingText = "Please upload an image!";
            _submitLock = false;
          });
        }
      } else {
        setState(() {
          _loadingText = null;
          _submitLock = false;
        });
        _handleRejection(resp);
      }
    } else {
      debugPrint("Invalid");
      setState(() {
        _loadingText = null;
        _submitLock = false;
      });
    }
  }

  void _handleRejection(String msg) {
    switch (msg) {
      case 'weak-password':
        passCheck = BorderColor.error;
        pass2Check = BorderColor.error;
        _passErrMsg = 'Password is too weak.';
        break;
      case 'email-already-in-use':
        emailCheck = BorderColor.error;
        _emailErrMsg = 'Account already exists with this email.';
      case 'invalid-email':
        emailCheck = BorderColor.error;
        _emailErrMsg = 'Invalid email address';
        break;
      case 'image-error':
        _loadingText =
            'Error uploading your profile picture, please pick another picture.';
      default:
        _loadingText =
            "Internal server error. Please contact support or try again.";
        usernameCheck = BorderColor.error;
        emailCheck = BorderColor.error;
        phoneCheck = BorderColor.error;
        passCheck = BorderColor.error;
        pass2Check = BorderColor.error;
    }
    setState(() => {});
  }

  Future<void> _setUser(String email) async {
    var user = await UserApi().getUserInfo(email: email);
    if (user == null) {
      throw Exception("Internal server error. Please contact support");
    }
    
    widget.user.key = await ChatEncrypterService().getOrSetKey(email);
    widget.user.image = image as File;

    if (!mounted) throw Exception("App unmounted before user was set");

    ProviderManager().setUser(context, widget.user);
    _saveCredentialsLocally();
  }

  void _saveCredentialsLocally() {
    String email = _emailController.value.text;
    String password = _passwordController.value.text;
    SharedPreferences.getInstance().then((SharedPreferences pref) {
      pref.setString("email", email);
      pref.setString("password", password);
    });
  }

  void _removeAllNegativeCheckers() {
    _passErrMsg = null;
    _emailErrMsg = null;
    _phoneErrMsg = null;
    _loadingText = null;
    usernameCheck = BorderColor.neutral;
    emailCheck = BorderColor.neutral;
    phoneCheck = BorderColor.neutral;
    passCheck = BorderColor.neutral;
    pass2Check = BorderColor.neutral;
  }

  Widget get _loading {
    return _loadingText == null
        ? const SizedBox.shrink()
        : Text(
            _loadingText as String,
            style: const TextStyle(
              color: primeColor,
              fontSize: 17,
            ),
          );
  }

  Widget get _redirectLoginButton {
    return InkWell(
      onTap: () => navigate(context, "/login"),
      child: const Text(
        "Already have an account? Click here!",
        style: TextStyle(
            fontSize: 14, color: primeColor, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget get _submitButton {
    return TextButton(
        onPressed: _submitLock ? () {} : _onSubmit,
        child: Container(
          decoration: BoxDecoration(
              gradient: primeGradient,
              borderRadius: BorderRadius.circular(20.0)),
          child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Text(
                "Submit",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              )),
        ));
  }

  void redirect() {
    navigate(context, "/contacts");
  }

  @override
  Widget build(BuildContext context) {
    return RoundScaffold(
      title: "Stock Market",
      rounding: widget.borderRadius,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 28),
              const Text(
                "Sign Up",
                style: TextStyle(
                    fontSize: 28,
                    color: primeColor,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 28),
              _imageField,
              const SizedBox(height: 20),
              _usernameField,
              const SizedBox(height: 20),
              _emailField,
              const SizedBox(height: 20),
              _phoneField,
              const SizedBox(height: 20),
              _passwordField,
              const SizedBox(height: 20),
              _password2Field,
              SizedBox(height: _loadingText != null ? 20 : 0),
              _loading,
              const SizedBox(height: 20),
              _redirectLoginButton,
              const SizedBox(height: 30),
              _submitButton,
            ],
          ),
        ),
      ),
    );
  }
}
