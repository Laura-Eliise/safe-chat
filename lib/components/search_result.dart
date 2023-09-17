import 'package:flutter/cupertino.dart';

import '../../components/user_field.dart';
import '../provider/provider_manager.dart';

class SearchResult extends StatelessWidget {
  final String email;
  final String name;
  final void Function() resetState;
  final void Function(String) setErrorState;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(children: [
        const SizedBox(height: 30),
        UserField(
          type: "Add",
          user: ProviderManager().getUser(context),
          username: name,
          email: email,
          resetState: resetState,
          setErrorState: setErrorState,
        ),
      ]),
    );
  }

  const SearchResult({
    super.key,
    required this.email,
    required this.name,
    required this.resetState,
    required this.setErrorState,
  });
}
