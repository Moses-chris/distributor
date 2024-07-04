import 'package:flutter/material.dart';
import '../../main.dart';
import 'authentication.dart';
import 'registration_page.dart';

class LoginPage extends StatefulWidget {
  final Function toggleView;
  LoginPage({required this.toggleView});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String phone = '';
  String password = '';
  String error = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 50.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                          prefixText: '+254 ',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[800],
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (val) => !_auth.isValidPhoneNumber(val!) ? 'Enter a valid Kenyan phone number' : null,
                        onChanged: (val) {
                          setState(() => phone = val);
                        },
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[800],
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        obscureText: true,
                        validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                        onChanged: (val) {
                          setState(() => password = val);
                        },
                      ),
                      SizedBox(height: 30.0),
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.blue)
                          : ElevatedButton(
                              child: Text(
                                'Sign In',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => _isLoading = true);
                                  try {
                                    Map<String, dynamic> result = await _auth.signIn(phone, password);
                                    if (result['success']) {
                                      print('Sign in successful');
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
                                    } else {
                                      setState(() {
                                        error = result['message'];
                                        _isLoading = false;
                                      });
                                    }
                                  } catch (e) {
                                    setState(() {
                                      error = 'An unexpected error occurred: $e';
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                            ),
                      SizedBox(height: 12.0),
                      Text(
                        error,
                        style: TextStyle(color: Colors.red, fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                TextButton(
                  child: Text(
                    'Need an account? Register',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterPage(toggleView: widget.toggleView),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}