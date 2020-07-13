
import 'package:cloud_firestore/cloud_firestore.dart';

class Anuncio{

  String _id;
  String _estado;
  String _categoria;
  String _titulo;
  String _preco;
  String _telefone;
  String _descricao;
  List<String> _fotos;

  Anuncio();

  Anuncio.fromDocumentSnapshot(DocumentSnapshot documentSnapshot){
    this.id = documentSnapshot.documentID;
    this.estado = documentSnapshot["estado"];
    this.categoria = documentSnapshot["categoria"];
    this.titulo = documentSnapshot["titulo"];
    this.preco = documentSnapshot["preco"];
    this.telefone = documentSnapshot["telefone"];
    this.descricao = documentSnapshot["descricao"];
    this.fotos = List<String>.from(documentSnapshot["fotos"]);
  }

  Anuncio.gerarId(){
    Firestore db = Firestore.instance;
    CollectionReference anuncios = db.collection("meus-anuncios");
    this.id = anuncios.document().documentID;
    this.fotos = [];
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "id": this.id,
      "estado": this.estado,
      "categoria": this.categoria,
      "titulo": this.titulo,
      "preco": this.preco,
      "telefone": this.telefone,
      "descricao": this.descricao,
      "fotos": this.fotos,
    };
    return map;
  }

  String get id => this._id;
  set id(String value) => this._id = value;

  String get estado => this._estado;
  set estado(String value) => this._estado = value;

  String get categoria => this._categoria;
  set categoria(String value) => this._categoria = value;

  String get titulo => this._titulo;
  set titulo(String value) => this._titulo = value;

  String get preco => this._preco;
  set preco(String value) => this._preco = value;

  String get telefone => this._telefone;
  set telefone(String value) => this._telefone = value;

  String get descricao => this._descricao;
  set descricao(String value) => this._descricao = value;

  List<String> get fotos => this._fotos;
  set fotos(List<String> value) => this._fotos = value;

}