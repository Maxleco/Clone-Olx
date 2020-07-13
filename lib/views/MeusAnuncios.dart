import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/Widgets/ItemAnuncio.dart';
import 'package:olx/models/Anuncio.dart';

class MeusAnuncios extends StatefulWidget {
  @override
  _MeusAnunciosState createState() => _MeusAnunciosState();
}

class _MeusAnunciosState extends State<MeusAnuncios> {
  final _controller = StreamController<QuerySnapshot>.broadcast();
  String _idUsuarioLogado;

  _recuperarDadosUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;
  }

  Future<Stream<QuerySnapshot>> _addListenerAnuncios() async {
    await _recuperarDadosUsuarioLogado();

    Firestore db = Firestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("meus_anuncios")
        .document(_idUsuarioLogado)
        .collection("anuncios")
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  Future _removerAnuncio(String idAnuncio) async {
    Firestore db = Firestore.instance;
    await db
        .collection("meus_anuncios")
        .document(_idUsuarioLogado)
        .collection("anuncios")
        .document(idAnuncio)
        .delete()
        .then((_) {
      db.collection("anuncios").document(idAnuncio).delete();
    });
  }

  @override
  void initState() {
    super.initState();
    _addListenerAnuncios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meus Anúncios"),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
              defaultWidget = Center(child: Text("Errro ao carregar dados!"));
            } else {
              QuerySnapshot querySnapshot = snapshot.data;

              defaultWidget = ListView.builder(
                itemCount: querySnapshot.documents.length,
                itemBuilder: (context, index) {
                  List<DocumentSnapshot> anuncios =
                      querySnapshot.documents.toList();
                  DocumentSnapshot documentSnapshot = anuncios[index];
                  Anuncio anuncio =
                      Anuncio.fromDocumentSnapshot(documentSnapshot);

                  return ItemAnuncio(
                    anuncio: anuncio,
                    onPressedRemover: () {
                      bool isLoading = false;
                      showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                                builder: (context, setState) {
                              return AlertDialog(
                                title: Text("Confirmar"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text("Deseja realmente excluir o anúncio?"),
                                    if (isLoading == true)
                                      CircularProgressIndicator(),
                                  ],
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Cancelar",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      setState(() => isLoading = true);
                                      _removerAnuncio(anuncio.id).then((_) {
                                        setState(() => isLoading = false);
                                        Navigator.pop(context);
                                      });
                                    },
                                    color: Colors.redAccent,
                                    child: Text(
                                      "Remover",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              );
                            });
                          });
                    },
                  );
                },
              );
            }
          } else {
            defaultWidget = Container();
          }

          return defaultWidget;
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text("Adicinar"),
        onPressed: () {
          Navigator.pushNamed(context, "/novo-anuncio");
        },
      ),
    );
  }
}
