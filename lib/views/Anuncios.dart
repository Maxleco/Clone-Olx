import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/Widgets/ItemAnuncio.dart';
import 'package:olx/main.dart';
import 'package:olx/models/Anuncio.dart';
import 'package:olx/util/Configuracoes.dart';

class Anuncios extends StatefulWidget {
  @override
  _AnunciosState createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {
  final _controller = StreamController<QuerySnapshot>.broadcast();

  List<String> listOpMenu = [];
  String _itemSelecionadoEstado;
  String _itemSelecionadoCategoria;
  List<DropdownMenuItem<String>> _listItensDropEstado = List();
  List<DropdownMenuItem<String>> _listItensDropCategorias = List();

  _loadingItensDropDown() {
    //ESTADOS
    _listItensDropEstado = Configuracoes.getEstados();

    //CATEGORIAS
    _listItensDropCategorias = Configuracoes.getCategorias();
  }

  _selectOpMenu(String op) {
    switch (op) {
      case "Meus Anúncios":
        Navigator.pushNamed(context, "/meus-anuncios");
        break;
      case "Entrar / Cadastrar":
        Navigator.pushNamedAndRemoveUntil(
            context, "/login", (Route<dynamic> route) => false);
        break;
      case "Deslogar":
        _deslogarUsuario();
        break;
    }
  }

  Stream<QuerySnapshot> _filtrarAnuncios() {
    Firestore db = Firestore.instance;
    Query query = db.collection("anuncios");
    if (_itemSelecionadoEstado != null) {
      query = query.where("estado", isEqualTo: _itemSelecionadoEstado);
    }
    if (_itemSelecionadoCategoria != null) {
      query = query.where("categoria", isEqualTo: _itemSelecionadoCategoria);
    }

    Stream<QuerySnapshot> stream = query.snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  Stream<QuerySnapshot> _addListenerAnuncios() {
    Firestore db = Firestore.instance;
    Stream<QuerySnapshot> stream = db.collection("anuncios").snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushNamedAndRemoveUntil(
        context, "/login", (Route<dynamic> route) => false);
  }

  Future _verificarUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    if (usuarioLogado == null) {
      listOpMenu = ["Entrar / Cadastrar"];
    } else {
      listOpMenu = ["Meus Anúncios", "Deslogar"];
    }
  }

  @override
  void initState() {
    super.initState();
    _loadingItensDropDown();
    _verificarUsuarioLogado();
    _addListenerAnuncios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OLX"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _selectOpMenu,
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) {
              return listOpMenu.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            // Filtros
            Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: Center(
                      child: DropdownButton(
                        iconEnabledColor: defaultTheme.primaryColor,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                        ),
                        value: _itemSelecionadoEstado,
                        items: _listItensDropEstado,
                        onChanged: (estado) {
                          setState(() {
                            _itemSelecionadoEstado = estado;
                            _filtrarAnuncios();
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey[200],
                  width: 2,
                  height: 60,
                ),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: Center(
                      child: DropdownButton(
                        iconEnabledColor: defaultTheme.primaryColor,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                        ),
                        value: _itemSelecionadoCategoria,
                        items: _listItensDropCategorias,
                        onChanged: (categoria) {
                          setState(() {
                            _itemSelecionadoCategoria = categoria;
                            _filtrarAnuncios();
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            //Lista de Anuncios
            StreamBuilder<QuerySnapshot>(
              stream: _controller.stream,
              builder: (context, snapshot) {
                Widget defaultWidget;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  defaultWidget = Center(
                    child: Column(
                      children: <Widget>[
                        Text("Carregando Anúncios"),
                        CircularProgressIndicator(),
                      ],
                    ),
                  );
                } else if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasError) {
                    defaultWidget =
                        Center(child: Text("Errro ao carregar dados!"));
                  } else {
                    QuerySnapshot querySnapshot = snapshot.data;
                    // print(_itemSelecionadoCategoria);
                    // print(_itemSelecionadoEstado);
                    // print("--------------------------------");
                    if (querySnapshot.documents.length == 0) {
                      defaultWidget = Container(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "Nenhum Anúncio! :( ",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    } else {
                      defaultWidget = Expanded(
                        child: ListView.builder(
                          itemCount: querySnapshot.documents.length,
                          itemBuilder: (context, index) {
                            List<DocumentSnapshot> anuncios =
                                querySnapshot.documents.toList();
                            DocumentSnapshot documentSnapshot = anuncios[index];
                            Anuncio anuncio =
                                Anuncio.fromDocumentSnapshot(documentSnapshot);

                            return ItemAnuncio(
                              anuncio: anuncio,
                              onTapItem: () {
                                Navigator.pushNamed(
                                  context,
                                  "/detalhes-anuncio",
                                  arguments: anuncio,
                                );
                              },
                            );
                          },
                        ),
                      );
                    }
                  }
                } else {
                  defaultWidget = Container();
                }

                return defaultWidget;
              },
            ),
          ],
        ),
      ),
    );
  }
}
