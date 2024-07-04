import 'package:flutter/material.dart';
import '../../main.dart';
import 'authentication.dart';

class RegisterPage extends StatefulWidget {
  final Function toggleView;
  RegisterPage({required this.toggleView});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String name = '';
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
                  'Create Account',
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
                          hintText: 'Name',
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
                        validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                        onChanged: (val) {
                          setState(() => name = val);
                        },
                      ),
                      SizedBox(height: 20.0),
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
                                'Register',
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
                                    Map<String, dynamic> result = await _auth.register(name, phone, password);
                                    if (result['success']) {
                                      print('Registration successful');
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
                    'Already have an account? Sign In',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: () {
                    widget.toggleView();
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