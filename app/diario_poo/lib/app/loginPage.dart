import 'package:flutter/material.dart';
import '../services/auth.dart';

class LoginPage extends StatelessWidget {
  LoginPage({@required this.auth});
  final AuthBase auth;

  Future<void> _signInAnonymously() async {
    try {
      await auth.signInAnonymously();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      await auth.signInWithGoogle();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diario', style: TextStyle(color: Color(0xffd89d62)),),
        backgroundColor: Colors.orange[200],
        elevation: 2.0,
      ),
      body: _buildContent(),
      backgroundColor: Color(0xffffe4c7),
    );
  }

  Widget _buildContent() {

    AssetImage logo = AssetImage('assets/images/fullres.png');

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Image(image: logo, height: 200,),
          Text(
            'Digitário',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xffd89d62),
              fontFamily: 'Poppins',
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 48.0),
          CustomButton(
            text: "Login",
            color: Colors.orange[300],
            borderRadius: 50,
            textColor: Colors.black87,
            onPressed: _signInWithGoogle,
          ),
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  CustomButton({
    this.text,
    this.color,
    this.textColor,
    this.borderRadius: 2.0,
    this.height: 50.0,
    this.onPressed,
  }) : assert(borderRadius != null);

  final String text;
  final Color color;
  final Color textColor;
  final double borderRadius;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: RaisedButton(
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 15.0),
        ),
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
