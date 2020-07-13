import 'package:flutter/material.dart';
import 'package:olx/models/Anuncio.dart';

// ignore: must_be_immutable
class ItemAnuncio extends StatelessWidget {
  Anuncio anuncio;
  VoidCallback onTapItem;
  VoidCallback onPressedRemover;

  ItemAnuncio({
    @required this.anuncio,
    this.onTapItem,
    this.onPressedRemover,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.onTapItem,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              // Imagem
              SizedBox(
                width: 120,
                height: 120,
                child: Image.network(
                  this.anuncio.fotos[0],
                  fit: BoxFit.cover,
                ),
              ),
              // Título e Preço
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        this.anuncio.titulo,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("R\$ ${this.anuncio.preco}"),
                    ],
                  ),
                ),
              ),
              // Botão Remover
              if (this.onPressedRemover != null)
                Expanded(
                  flex: 1,
                  child: FlatButton(
                    color: Colors.redAccent,
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.delete, color: Colors.white),
                    onPressed: this.onPressedRemover,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
