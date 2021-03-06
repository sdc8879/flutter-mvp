import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_mvp/views/home/home_view.dart';
import 'package:flutter_mvp/views/login/login_contract.dart';
import 'package:flutter_mvp/views/login/login_presenter.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:http/http.dart' as http;

class Login extends StatelessWidget {
  static String routeName = "/Login";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: LoginForm()),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

class LoginFormState extends State<LoginForm> implements LoginContract {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginPresenter _presenter;
  bool isLoggedIn = false;

  Widget createEmailTextField() {
    return Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
            child: TextFormField(
              controller: _emailController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Email cannot be empty';
                } else {
                  return validateEmail(value);
                }
              },
              maxLines: 1,
              decoration: InputDecoration(
                hintText: "Enter your email",
                labelText: "Email",
              ),
            ),
          )
        ]));
  }

  Widget createPasswordField() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
      child: TextFormField(
        controller: _passwordController,
        validator: (value) {
          if (value.isEmpty) {
            return 'Password cannot be empty';
          } else {
            if (value.length < 6) {
              return 'Password length must be at least 6 characters';
            }
          }
        },
        keyboardType: TextInputType.emailAddress,
        maxLines: 1,
        obscureText: true,
        decoration: InputDecoration(
          hintText: "Enter your password",
          labelText: "Password",
        ),
      ),
    );
  }

  Widget createSignInButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
      width: double.infinity,
      child: RaisedButton(
        padding: EdgeInsets.all(12.0),
        child: Text(
          "SIGN IN",
          style: TextStyle(color: Colors.white),
        ),
        color: Colors.blueAccent,
        onPressed: () {
          if (_formKey.currentState.validate()) {
            showLoading();
            _presenter.login(_emailController.text, _passwordController.text);
          }
        },
      ),
    );
  }

  Widget createFacebookLoginButton() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
        width: double.infinity,
        child: SignInButton(
          Buttons.Facebook,
          onPressed: () {
            _handleFacebookLogin();
          },
        ));
  }

  Widget createGoogleSignInButton() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
      width: double.infinity,
      child: SignInButton(
        Buttons.Google,
        onPressed: () {},
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _presenter = LoginPresenter(this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleFacebookLogin() async {
    var facebookLogin = FacebookLogin();
    var facebookLoginResult =
        await facebookLogin.logInWithReadPermissions(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error: ${FacebookLoginStatus.error.toString()}");
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("Cancelled By User");
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn: ${facebookLoginResult.accessToken.token}");

        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${facebookLoginResult.accessToken.token}');
        var profile = json.decode(graphResponse.body);
        print(profile.toString());

        onLoginStatusChanged(true);
        break;
    }
  }

  void onLoginStatusChanged(bool isLoggedIn) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
    });
  }

  void showLoading() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                CircularProgressIndicator(),
                Text("Logging in...", textAlign: TextAlign.center)
              ]));
        });
  }

  @override
  void onLoginSuccess() {
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacementNamed(Home.routeName);
  }

  @override
  void showError(String message) {
    Navigator.of(context).pop();
    print("Error: $message");
  }

  @override
  Widget build(BuildContext context) {
    loginHeader() => Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FlutterLogo(
              size: 80.0,
            ),
            SizedBox(
              height: 30.0,
            ),
            Text(
              "Welcome to Flutter",
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: Colors.blueAccent),
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(
              "Sign in to continue",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        );

    loginFields() => Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              createEmailTextField(),
              createPasswordField(),
              SizedBox(height: 12.0),
              createSignInButton(context),
              createFacebookLoginButton(),
              createGoogleSignInButton(),
              Text(
                "SIGN UP FOR AN ACCOUNT",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );

    loginBody() => SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[loginHeader(), loginFields()],
          ),
        );

    return Form(key: _formKey, child: loginBody());
  }
}

String validateEmail(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value))
    return 'Enter Valid Email';
  else
    return null;
}
