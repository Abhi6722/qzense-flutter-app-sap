import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:requests/requests.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color.fromARGB(255, 22, 80, 92);
const Color secondaryColor = Color.fromARGB(255, 229,240,234);

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
        },
      );
      setState(() {
        loading = false;
      });
      Map<String, dynamic> data = Map<String, dynamic>.from(json.decode(res.content()));

      if (res.statusCode >= 200 && res.statusCode < 400) {
        debugPrint('Login Successful!');
        debugPrint("AccessToken : ${data['token']['access']}");

        // Store access token and email locally on phone for avoiding logins repeatedly
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'images/assets/logo.webp',
                      height: 70,
                    ),
                    const SizedBox(height: 70),
                    const Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 34,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Login to your account',
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 50),
                    TextFormField(
                      onChanged: (val) {
                        setState(() {
                          loginError = '';
                          email = val;
                          emailEmpty = val.isNotEmpty ? false : true;
                          loginButtonEnabled = (!emailEmpty && !passEmpty) ? true : false;
                        });
                      },
                      cursorColor: primaryColor,
                      keyboardType: TextInputType.emailAddress,
                      autofocus: true,
                      style: const TextStyle(fontSize: 15, color: primaryColor),
                      decoration: InputDecoration(
                        hintText: 'Email',
                        prefixIcon: const Icon(
                          Icons.email,
                          color: primaryColor,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 25.0,
                          horizontal: 25.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide.none, // Remove the active border line
                        ),
                        filled: true,
                        fillColor: secondaryColor,
                        hintStyle: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold, // Make the placeholder text bold
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      onChanged: (val) {
                        setState(() {
                          loginError = '';
                          password = val;
                          passEmpty = val.isNotEmpty ? false : true;
                          loginButtonEnabled = (!emailEmpty && !passEmpty) ? true : false;
                        });
                      },
                      cursorColor: primaryColor,
                      obscureText: obscureText,
                      autofocus: false,
                      style: const TextStyle(fontSize: 15, color: primaryColor),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: primaryColor,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                          child: Icon(
                            obscureText ? Icons.visibility_off : Icons.visibility,
                            color: primaryColor.withOpacity(0.5),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 25.0,
                          horizontal: 25.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide.none, // Remove the active border line
                        ),
                        filled: true,
                        fillColor: secondaryColor,
                        hintStyle: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold, // Make the placeholder text bold
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        debugPrint('Forgot Password!');
                      },
                      child: const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        if (loginButtonEnabled) {
                          _emailRequest();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: loginButtonEnabled
                              ? primaryColor
                              : primaryColor.withOpacity(0.5),
                        ),
                        height: 45,
                        width: double.infinity,
                        child: const Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
      ),
    );
  }
}
