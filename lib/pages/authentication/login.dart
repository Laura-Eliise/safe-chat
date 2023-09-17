import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pointycastle/impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/media_api.dart';
import '../../api/user_api.dart';
import '../../chat_encrypter/chat_encrypter_service.dart';
import '../../components/border_color.dart';
import '../../provider/provider_manager.dart';
import '../../components/container.dart';
import '../../components/scaffold.dart';
import '../../utils/media_type.dart';
import '../../utils/user.dart';
import '../../utils/colors.dart';
import '../../utils/navigation.dart';

class LogIn extends StatefulWidget {
  final User user = User();
  LogIn({super.key});
  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  late SharedPreferences pref;
  final LocalAuthentication auth = LocalAuthentication();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  BorderColor emailCheck = BorderColor.neutral;
  BorderColor passCheck = BorderColor.neutral;
  String? _emailErr;
  String? _passErr;
  String? _loadingText;
  bool _submitLock = false;
  bool _enableBio = false;

  /* Initialization */
  @override
  void initState() {
    _enableFingerPrintLogin();
    _getSharedPreferenceInstance();
    super.initState();
  }

  void _enableFingerPrintLogin() async {
    try {
      _enableBio =
          await auth.isDeviceSupported() || await auth.canCheckBiometrics;
      debugPrint("Fingerprint log in available: $_enableBio");
      setState(() {});
    } catch (e) {
      debugPrint("Fingerprint bio check error ${e.toString()}");
    }
  }

  void _getSharedPreferenceInstance() async {
    try {
      pref = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint("Shared preference error: ${e.toString()}");
    }
  }

  /* Email Login Widget */

  Widget _createInputField(
    String hintText,
    BorderColor checker,
    TextEditingController controller,
    String? Function(String?) validator, {
    bool obscureText = false,
    String? errorText,
  }) {
    return RoundedGradientContainer(
      gradient: checker == BorderColor.error
          ? errorGradient
          : checker == BorderColor.correct
              ? correctGradient
              : null,
      child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: checker == BorderColor.error ? 5 : 0),
          child: TextFormField(
            obscureText: obscureText,
            controller: controller,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                hintText: hintText,
                errorText: errorText,
                border: checker != BorderColor.error ? InputBorder.none : null),
            validator: validator,
          )),
    );
  }

  Widget get _title => const Text(
        "Login",
        style: TextStyle(
          fontSize: 28,
          color: primeColor,
          fontWeight: FontWeight.w500,
        ),
      );
  Widget get _emailField => _createInputField(
        "Email",
        emailCheck,
        _emailController,
        _emailValidator,
        errorText: _emailErr,
      );
  Widget get _passField => _createInputField(
        "Password",
        passCheck,
        _passController,
        _passValidator,
        obscureText: true,
        errorText: _passErr,
      );
  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      emailCheck = BorderColor.error;
      return "Email required";
    } else if (!value.contains("@") ||
        !value.contains(".") ||
        value.length < 4) {
      emailCheck = BorderColor.error;
      return "Email is wrong";
    } else {
      emailCheck = BorderColor.correct;
      return null;
    }
  }

  String? _passValidator(String? value) {
    if (value == null || value.isEmpty) {
      passCheck = BorderColor.error;
      return "Password required";
    } else {
      passCheck = BorderColor.correct;
      return null;
    }
  }

  Widget get _redirectButton {
    return InkWell(
      onTap: () => navigate(context, "/signup"),
      child: const Text(
        "Don't have an account? Click here!",
        style: TextStyle(
            fontSize: 14, color: primeColor, fontWeight: FontWeight.w400),
      ),
    );
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

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      _removeAllNegativeCheckers();
      setState(() {
        _loadingText = "Processing data...";
        _submitLock = true;
      });
      await _logInUser();
    } else {
      debugPrint("Invalid");
      setState(() {
        _loadingText = null;
        _submitLock = false;
      });
    }
  }

  /* Fingerprint Log in */

  List<Widget> get _fingerPrint {
    if (!_enableBio) return [];
    return [
      IconButton(
        iconSize: 50,
        onPressed: _checkFingerprint,
        icon: const Icon(
          Icons.fingerprint,
          color: primeColor,
          size: 50,
        ),
      ),
      const SizedBox(height: 10),
    ];
  }

  void _checkFingerprint() async {
    bool authenticated = false;
    try {
      setState(() {
        _submitLock = true;
        _loadingText = 'Authenticating...';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Log in via fingerprint',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      setState(() {
        _submitLock = false;
      });
      debugPrint("authenticate: $authenticated");
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      setState(() {
        _submitLock = false;
        _loadingText = 'Error: ${e.message}';
      });
      return;
    } catch (e) {
      setState(() {
        _submitLock = false;
        _loadingText = 'Error: ${e.toString()}';
      });
      return;
    }

    debugPrint("authenticate: $authenticated");

    if (!mounted) {
      debugPrint("no longer mounted");
      return;
    }

    if (!authenticated) {
      setState(() {
        _loadingText = "Couldn't authenticate via fingerprint";
      });
      return;
    }

    var email = pref.getString("email");
    var password = pref.getString("password");
    if (email != null && password != null) {
      _logInUser(
        email: email,
        password: password,
      );
    } else {
      setState(() {
        _submitLock = false;
        _loadingText =
            "No user assigned to this fingerprint, please log in via email";
      });
    }
  }

  /* Login Functionality */

  Future<void> _logInUser({String? email, String? password}) async {
    String? resp = await widget.user.signInUser(
      email: email ?? _emailController.value.text,
      password: password ?? _passController.value.text,
    );
    if (resp != null) {
      setState(() {
        _loadingText = null;
        _submitLock = false;
      });
      _handleDBRejection(resp);
    } else {
      await _setUser(email ?? _emailController.value.text);
      _redirect();
    }
  }

  void _handleDBRejection(String msg) {
    switch (msg) {
      case "invalid-email":
        emailCheck = BorderColor.error;
        _emailErr = "Not a valid email address.";
      case 'user-not-found':
        emailCheck = BorderColor.error;
        _emailErr = "No user found with this email address.";
      case 'wrong-password':
        passCheck = BorderColor.error;
        _passErr = "Incorrect password.";
      default:
        _loadingText = msg;
        emailCheck = BorderColor.error;
        passCheck = BorderColor.error;
    }
    setState(() {});
  }

  void _removeAllNegativeCheckers() {
    emailCheck = BorderColor.neutral;
    passCheck = BorderColor.neutral;
    _emailErr = null;
    _passErr = null;
    _loadingText = null;
  }

  /* On Successful Login */

  Future<void> _setUser(String email) async {
    var user = await UserApi().getUserInfo(email: email);
    if (user == null) {
      throw Exception("Internal server error. Please contact support");
    }

    var image = await MediaApi().fetchFile(
      path: user["image"] as String,
      type: MediaType.image,
      returnFile: true,
      onUpdate: (_, [__]) {},
      onComplete: (_) {},
      onError: (_) {},
    );

    widget.user.image = image;

    RSAPrivateKey key =
        await ChatEncrypterService().getOrSetKey(email, user["key"]);
    widget.user.key = key;

    if (!mounted) throw Exception("App unmounted before user was set");

    ProviderManager().setUser(context, widget.user);
    _saveCredentialsLocally();
  }

  void _saveCredentialsLocally() {
    String email = _emailController.value.text;
    String password = _passController.value.text;
    if (password.isNotEmpty && email.isNotEmpty) {
      SharedPreferences.getInstance().then((SharedPreferences pref) {
        pref.setString("email", email);
        pref.setString("password", password);
      });
    }
  }

  void _redirect() {
    debugPrint("logged in successfully! redirecting...");
    navigate(context, "/chat-page");
  }

  @override
  Widget build(BuildContext context) {
    return RoundScaffold(
      title: "Stock Market",
      rounding: 20,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          const Spacer(),
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _title,
                const SizedBox(
                  height: 28,
                ),
                _emailField,
                const SizedBox(height: 20),
                _passField,
                SizedBox(height: _loadingText != null ? 20 : 0),
                _loading,
                const SizedBox(height: 20),
                _redirectButton,
                const SizedBox(height: 30),
                _submitButton,
              ],
            ),
          ),
          const Spacer(),
          ..._fingerPrint,
        ]),
      ),
    );
  }
}
