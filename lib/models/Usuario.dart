

class Usuario{
  String _idUsuario;
  String _nome;
  String _email;
  String _senha;

  Usuario();

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "idUsuario": this.idUsuario,
      "nome": this.nome,
      "email": this.email,
    };
    return map;
  }

  String get idUsuario => this._idUsuario;
  set idUsuario(String value) => this._idUsuario = value;

  String get nome => this._nome;
  set nome(String value) => this._nome = value;

  String get senha => this._senha;
  set senha(String value) => this._senha = value;

  String get email => this._email;
  set email(String value) => this._email = value;
}