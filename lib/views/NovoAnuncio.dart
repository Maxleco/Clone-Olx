import 'dart:io';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olx/Widgets/CustomButton.dart';
import 'package:olx/Widgets/CustomInputText.dart';
import 'package:olx/models/Anuncio.dart';
import 'package:olx/util/Configuracoes.dart';
import 'package:validadores/Validador.dart';

class NovoAnuncio extends StatefulWidget {
  @override
  _NovoAnuncioState createState() => _NovoAnuncioState();
}

class _NovoAnuncioState extends State<NovoAnuncio> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  Anuncio _anuncio;
  BuildContext _dialogContext;

  List<File> _listImages = List();
  List<DropdownMenuItem<String>> _listItensDropEstado = List();
  List<DropdownMenuItem<String>> _listItensDropCategorias = List();

  String _itemSelectedEstado;
  String _itemSelectedCategoria;

  _selectImageGaleria() async {
    PickedFile imageSelected =
        await _picker.getImage(source: ImageSource.gallery);
    if (imageSelected != null) {
      setState(() {
        _listImages.add(File(imageSelected.path));
      });
    }
  }

  _openDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Salvando anúncio..."),
              ],
            ),
          );
        });
  }

  _salvarAnuncio() async {
    _openDialog(_dialogContext);
    //Upload de Image no Storage
    await _uploadImages();
    //Salvar Anuncio no FireStore
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    String idUsuario = usuarioLogado.uid;
    Firestore db = Firestore.instance;
    db
        .collection("meus_anuncios")
        .document(idUsuario)
        .collection("anuncios")
        .document(_anuncio.id)
        .setData(_anuncio.toMap())
        .then((_) {
      //Salvar Anúncio Público
      db
          .collection("anuncios")
          .document(_anuncio.id)
          .setData(_anuncio.toMap())
          .then((_) {
        Navigator.pop(_dialogContext);
        Navigator.pop(context);
      });
    });
  }

  Future _uploadImages() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    for (var image in _listImages) {
      String nameImage = DateTime.now().millisecondsSinceEpoch.toString();
      StorageReference arquivo =
          pastaRaiz.child("meus-anuncios").child(_anuncio.id).child(nameImage);
      StorageUploadTask uploadTask = arquivo.putFile(image);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      _anuncio.fotos.add(url);
    }
  }

  _loadingItensDropDown() {
    //ESTADOS
    _listItensDropEstado = Configuracoes.getEstados();

    //CATEGORIAS
    _listItensDropCategorias = Configuracoes.getCategorias();
  }

  @override
  void initState() {
    super.initState();
    _loadingItensDropDown();
    _anuncio = Anuncio.gerarId();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Novo Anúncio"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              FormField<List>(
                initialValue: _listImages,
                validator: (images) {
                  if (images.length == 0) {
                    return "Necessário selecionar uma Imagem!";
                  }
                  return null;
                },
                builder: (FormFieldState<List<dynamic>> state) {
                  return Column(
                    children: <Widget>[
                      Container(
                        height: 100,
                        width: size.width,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _listImages.length + 1,
                          itemBuilder: (context, index) {
                            Widget defaultWidget = Container();
                            if (index == _listImages.length) {
                              defaultWidget = Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    _selectImageGaleria();
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey[400],
                                    radius: 50,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.add_a_photo,
                                          color: Colors.grey[100],
                                          size: 40,
                                        ),
                                        Text(
                                          "Adicionar",
                                          style: TextStyle(
                                            color: Colors.grey[100],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else if (_listImages.length > 0) {
                              defaultWidget = Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Image.file(_listImages[index]),
                                                FlatButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _listImages
                                                          .removeAt(index);
                                                      Navigator.pop(context);
                                                    });
                                                  },
                                                  child: Text("Excluir"),
                                                  textColor: Colors.red,
                                                ),
                                              ],
                                            ),
                                          );
                                        });
                                  },
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage:
                                        FileImage(_listImages[index]),
                                    child: Container(
                                      color: Color.fromRGBO(255, 255, 255, 0.4),
                                      alignment: Alignment.center,
                                      child:
                                          Icon(Icons.delete, color: Colors.red),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return defaultWidget;
                          },
                        ),
                      ),
                      if (state.hasError)
                        Container(
                          child: Text(
                            "[${state.errorText}]",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField(
                          value: _itemSelectedEstado,
                          hint: Text("Estados"),
                          onSaved: (estado) {
                            _anuncio.estado = estado;
                          },
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                          items: _listItensDropEstado,
                          validator: (String value) {
                            return Validador()
                                .add(Validar.OBRIGATORIO,
                                    msg: "Campo Obrigatório")
                                .valido(value);
                          },
                          onChanged: (String value) {
                            setState(() {
                              _itemSelectedEstado = value;
                            });
                          }),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField(
                          value: _itemSelectedCategoria,
                          hint: Text("Categoria"),
                          onSaved: (categoria) {
                            _anuncio.categoria = categoria;
                          },
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                          items: _listItensDropCategorias,
                          validator: (String value) {
                            return Validador()
                                .add(Validar.OBRIGATORIO,
                                    msg: "Campo Obrigatório")
                                .valido(value);
                          },
                          onChanged: (String value) {
                            setState(() {
                              _itemSelectedCategoria = value;
                            });
                          }),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: CustomInputText(
                  hint: "Título",
                  onSaved: (titulo) {
                    _anuncio.titulo = titulo;
                  },
                  validator: (String value) {
                    return Validador()
                        .add(Validar.OBRIGATORIO, msg: "Campo Obrigatório")
                        .valido(value);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: CustomInputText(
                  hint: "Preço",
                  onSaved: (preco) {
                    _anuncio.preco = preco;
                  },
                  inputType: TextInputType.number,
                  inputFormatters: [
                    WhitelistingTextInputFormatter.digitsOnly,
                    RealInputFormatter(centavos: true),
                  ],
                  validator: (String value) {
                    return Validador()
                        .add(Validar.OBRIGATORIO, msg: "Campo Obrigatório")
                        .valido(value);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: CustomInputText(
                  hint: "Telefone",
                  onSaved: (telefone) {
                    _anuncio.telefone = telefone;
                  },
                  inputType: TextInputType.phone,
                  inputFormatters: [
                    WhitelistingTextInputFormatter.digitsOnly,
                    TelefoneInputFormatter(),
                  ],
                  validator: (String value) {
                    return Validador()
                        .add(Validar.OBRIGATORIO, msg: "Campo Obrigatório")
                        .valido(value);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: CustomInputText(
                  hint: "Descrição (200 caracteres)",
                  maxLines: null,
                  onSaved: (descricao) {
                    _anuncio.descricao = descricao;
                  },
                  validator: (String value) {
                    return Validador()
                        .add(Validar.OBRIGATORIO, msg: "Campo Obrigatório")
                        .maxLength(200, msg: "Máximo de 200 caracteres")
                        .valido(value);
                  },
                ),
              ),
              CustomButton(
                text: "Cadastrar Anúncio",
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    //salva campos
                    _formKey.currentState.save();

                    //Configura dialog context
                    _dialogContext = context;

                    //salvar anuncio
                    _salvarAnuncio();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
