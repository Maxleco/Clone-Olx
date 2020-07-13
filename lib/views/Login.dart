import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/Widgets/CustomButton.dart';
import 'package:olx/Widgets/CustomInputText.dart';
import 'package:olx/models/usuario.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _senhaController = TextEditingController();
  bool _isCadastrar = false;
  String _messagemError = "";
  String _textButton = "Entrar";

  bool _isLoading = false;
  void _loading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  _validarCampos() {
    String email = _emailController.text.trim();
    String senha = _senhaController.text.trim();
    setState(() {
      _messagemError = "";
    });
    if (email.isNotEmpty && email.contains("@")) {
      if (senha.isNotEmpty && senha.length > 6) {
        Usuario usuario = Usuario();
        usuario.email = email;
        usuario.senha = senha;
        //Cadastrar ou Logar
        _loading(true);
        if (_isCadastrar) {
          _cadastrarUsuario(usuario);
        } else {
          _logarUsuario(usuario);
        }
      } else {
        setState(() {
          _messagemError = "Preencha a Senha! Digite mais de 6 caracteres.";
        });
      }
    } else {
      setState(() {
        _messagemError = "Preencha o Email válido!";
      });
    }
  }

  //*Cadastrar Usuário
  _cadastrarUsuario(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth
        .createUserWithEmailAndPassword(
      email: usuario.email,
      password: usuario.senha,
    )
        .then((firebaseUser) {
      _loading(false);
      //Redirecionar para Tela Principal
      Navigator.pushNamedAndRemoveUntil(
          context, "/", (Route<dynamic> route) => false);
    }).catchError((e) {
      _loading(false);
      setState(() {
        _messagemError = e.toString();
      });
    });
  }

  //*Logar
  _logarUsuario(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth
        .signInWithEmailAndPassword(
      email: usuario.email,
      password: usuario.senha,
    )
        .then((firebaseUser) {
      _loading(false);
      //Redirecionar para Tela Principal
      Navigator.pushNamedAndRemoveUntil(
          context, "/", (Route<dynamic> route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    "images/logo.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                CustomInputText(
                  controller: _emailController,
                  hint: "E-mail",
                  autofocus: true,
                  inputType: TextInputType.emailAddress,
                ),
                CustomInputText(
                  controller: _senhaController,
                  hint: "Senha",
                  obscure: true,
                  maxLines: 1,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Logar"),
                    Switch(
                      value: _isCadastrar,
                      onChanged: (bool value) {
                        setState(() {
                          _isCadastrar = value;
                          _textButton = "Entrar";
                          if (_isCadastrar) {
                            _textButton = "Cadastrar";
                          }
                        });
                      },
                    ),
                    Text("Cadastrar"),
                  ],
                ),
                // Button
                CustomButton(
                  text: _textButton,
                  onPressed: () {
                    _validarCampos();
                  },
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/");
                  },
                  child: Text(
                    "Ir para anúncios",
                    style: TextStyle(
                      color: Colors.deepPurple[400]
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    _messagemError,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                _isLoading
                    ? Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xff9c27b0)),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
