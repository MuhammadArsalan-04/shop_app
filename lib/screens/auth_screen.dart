import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';

import '../providers/HandlingException.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 60.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Text(
                        'MyShop',
                        softWrap: false,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: const AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  late AnimationController _controller;
  late Animation<Size> heightAnimation;
  late Animation<double> opacityAnimation;
  late Animation<Offset> slideAnimation;

  bool isReversed = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300),
    );

    //Slide Animation
    heightAnimation = Tween<Size>(
      begin: const Size(double.infinity, 270),
      end: const Size(double.infinity, 320),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    //slide animation
    slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      reverseCurve: Curves.easeOut,
      curve: Curves.easeIn,
    ));

    // _controller.addListener(() {
    //   setState(() {});
    // });
  }

  Animation<Offset> getSlideAnimation() {
    return isReversed
        ? Tween<Offset>(
            begin: const Offset(0, 0),
            end: const Offset(0, -0.4),
          ).animate(CurvedAnimation(
            parent: _controller,
            reverseCurve: Curves.easeOut,
            curve: Curves.easeIn,
          ))
        : Tween<Offset>(
            begin: const Offset(0, -0.4),
            end: const Offset(0, 0),
          ).animate(CurvedAnimation(
            parent: _controller,
            reverseCurve: Curves.easeOut,
            curve: Curves.easeIn,
          ));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _showAlertDialogue(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Something Went Wrong'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Okay',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ))
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<AuthProvider>(context, listen: false)
            .signIn(_authData['email']!, _authData['password']!);
      } else {
        await Provider.of<AuthProvider>(context, listen: false)
            .signUp(_authData['email']!, _authData['password']!);
      }
    } on HandlingException catch (error) {
      String errorMessage = 'Could Not Authenticate';
      if (error.message.contains('EMAIL_EXISTS')) {
        errorMessage = 'User Already Registered';
      } else if (error.message.contains('INVALID_EMAIL')) {
        errorMessage = 'Invalid Email Provided';
      } else if (error.message.contains('WEAK_PASSWORD')) {
        errorMessage = 'Your Password is so weak';
      } else if (error.message.contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'The User with the provided email not found';
      } else if (error.message.contains('INVALID_PASSWORD')) {
        errorMessage = 'Entered Wrong Password';
      }

      _showAlertDialogue(errorMessage);
    } catch (_) {
      _showAlertDialogue('Could Not Authenticate!\nPlease Try Again Later');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      isReversed = false;
      setState(() {
        _authMode = AuthMode.Signup;
      });
      slideAnimation = getSlideAnimation();
      _controller.forward();
    } else {
      isReversed = true;
      setState(() {
        _authMode = AuthMode.Login;
      });
      slideAnimation = getSlideAnimation();
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedBuilder(
        animation: heightAnimation,
        builder: (ctx, ch) {
          return Container(
            height: heightAnimation.value.height,
            constraints:
                BoxConstraints(minHeight: heightAnimation.value.height),
            width: deviceSize.width * 0.75,
            padding: const EdgeInsets.all(16.0),
            child: ch,
          );
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                  },
                  onSaved: (value) {
                    _authData['email'] = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value!;
                  },
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),

                  //height: _authMode == AuthMode.Login ? 10 : 100,
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                      maxHeight: _authMode == AuthMode.Signup ? 80 : 0),
                  child: FadeTransition(
                    opacity: opacityAnimation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.Signup,
                        decoration: const InputDecoration(
                            labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match!';
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 8.0),
                      textStyle: TextStyle(
                          color:
                              Theme.of(context).primaryTextTheme.button!.color),
                      primary: Theme.of(context).primaryColor,
                    ),
                  ),
                TextButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  style: ButtonStyle(
                    textStyle: MaterialStateProperty.all(TextStyle(
                      color: Theme.of(context).primaryColor,
                    )),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}