import 'package:blog/data/models/AuthenticatedUser.dart';
import 'package:blog/data/services/users_service.dart';
import 'package:blog/screens/home_screen.dart';
import 'package:blog/screens/register_screen.dart';
import 'package:blog/utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _passwordVisible = false;

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  _login(email, password) async {
    setState(() {
      isLoading = true;
    });
    try {
      AuthenticatedUser authenticatedUser = await UserService.authentication(
          {'strategy': 'local', 'email': email, 'password': password});
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(
          Constant.USERNAME_PREF_KEY, authenticatedUser.user!.username!);
      prefs.setString(Constant.EMAIL_PREF_KEY, authenticatedUser.user!.email!);
      prefs.setString(Constant.USER_ID_PREF_KEY, authenticatedUser.user!.id!);
      prefs.setString(Constant.TOKEN_PREF_KEY, authenticatedUser.accessToken!);
      emailController.text = "";
      passwordController.text = "";
      Fluttertoast.showToast(msg: "Connexion effectuée avec succès");

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } on DioError catch (e) {
      Map<String, dynamic> error = e.response?.data;
      if (error != null && error.containsKey('message')) {
        Fluttertoast.showToast(msg: error['message']);
      } else {
        Fluttertoast.showToast(
            msg: "Une erreur est survenue veuillez rééssayer");
      }
      print(e.response);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text("Connexion",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.blue)),
            Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          hintText: "Entrez votre e-mail",
                          labelText: "E-mail",
                          icon: Icon(Icons.alternate_email)),
                      validator: (value) {
                        return value == null || value == ""
                            ? "Ce champs est obligatoire"
                            : null;
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: passwordController,
                      keyboardType: TextInputType.text,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        hintText: "Entrez votre mot de passe",
                        labelText: "Mot de passe",
                        icon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          icon: _passwordVisible
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                        ),
                      ),
                      validator: (value) {
                        return value == null || value == ""
                            ? "Ce champs est obligatoire"
                            : null;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isLoading && formKey.currentState!.validate()) {
                            await _login(
                                emailController.text, passwordController.text);
                          }
                        },
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ))
                            : const Text("Se connecter"))
                  ],
                )),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()));
                },
                child: const Text("Pas de Compte ? Créer un compte",
                    style: TextStyle(fontSize: 17, color: Colors.blue)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
