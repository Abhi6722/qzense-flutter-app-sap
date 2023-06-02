import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qzenesapp/screens/homepage.dart';
import 'package:requests/requests.dart';
import 'package:shared_preferences/shared_preferences.dart';

//creating logic and ui of input decoration for email and password fields

InputDecoration emailInpDec = InputDecoration(
    hintText: 'Email ID',
    filled: true,
    hintStyle: const TextStyle(color: Colors.white, fontSize: 15),
    fillColor: primaryColor);

InputDecoration passInpDec = InputDecoration(
    hintText: 'Password',
    filled: true,
    hintStyle: const TextStyle(color: Colors.white, fontSize: 15),
    fillColor: primaryColor);

//////////////////////////////////////

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loginButtonEnabled = false,
      emailEmpty = true,
      passEmpty = true,
      loading = false,
      obscureText = true;
  String email = '', password = '', loginError = '';

  void _emailRequest() async {
    setState(() {
      loading = true;
    });
    try {

      // POST REQUEST for getting content of access token and refresh
      var res = await Requests.post(
          'http://43.204.133.133:8000/auth/login/',
          body: {
            'email': email,
            'password': password,
          });
      setState(() {
        loading = false;
      });
      Map<String, dynamic> data =
          Map<String, dynamic>.from(json.decode(res.content()));

      if (res.statusCode >= 200 && res.statusCode < 400) {
        debugPrint('Login Successful!');
        debugPrint("AccessToken : ${data['token']['access']}");

        //Store access token and email locally on phone for avoiding logins repeatedly
        final prefs = await SharedPreferences.getInstance();

        // below code will save the data in local storage of mobile
        prefs.setString('token', data['token']['access']);
        prefs.setString('email', email);
        debugPrint("api-email :$data /*['email']*/");

        Navigator.pushNamed((context), '/');
      } else {
        setState(() {
          loginError = 'Invalid';
        });
        debugPrint('Login Unsuccessful');
        debugPrint("Detail : ${data['detail']}");
      }
    } catch (e) {
      loginError = 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                      height: 200,
                      width: 200,
                      child: Image.asset('images/assets/logo.webp')),
                  TextFormField(
                    onChanged: (val) {
                      setState(() {
                        loginError = '';
                        email = val;
                        emailEmpty = val.isNotEmpty ? false : true;
                        loginButtonEnabled =
                            (!emailEmpty && !passEmpty) ? true : false;
                      });
                    },
                    cursorColor: primaryColor,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    style: TextStyle(fontSize: 15, color: primaryColor),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 25.0, horizontal: 25.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    onChanged: (val) {
                      setState(() {
                        loginError = '';
                        password = val;
                        passEmpty = val.isNotEmpty ? false : true;
                        loginButtonEnabled =
                            (!emailEmpty && !passEmpty) ? true : false;
                      });
                    },
                    cursorColor: primaryColor,
                    obscureText: obscureText,
                    autofocus: false,
                    style: TextStyle(fontSize: 15, color: primaryColor),
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                        child: SizedBox(
                          width: 60,
                          child: Center(
                            child: Icon(
                              obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: obscureText ? Colors.grey : Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints.tightFor(),
                      hintText: 'Password',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 25.0, horizontal: 25.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      if (loginButtonEnabled) {
                        _emailRequest();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color:
                              loginButtonEnabled ? primaryColor : Colors.grey),
                      height: 40,
                      child: const Center(
                        child: Text(
                          'Login',
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          debugPrint('Forgot Password!');
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: loading ? true : false,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  Visibility(
                    visible: loginError == 'Invalid' ? true : false,
                    child: const Text(
                      'Invalid ID or Password',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  Visibility(
                    visible: loginError == 'Error' ? true : false,
                    child: const Text(
                      'Server error',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
