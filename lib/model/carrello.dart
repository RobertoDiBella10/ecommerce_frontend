import 'package:flutter/material.dart';

class CarrelloData extends ChangeNotifier {
  double totale = 0.0;
  int id;

  CarrelloData({required this.id, required this.totale});

  factory CarrelloData.fromJson(Map<String, dynamic> json) {
    return CarrelloData(id: json["id"], totale: json["totale"]);
  }

  double getTotale() {
    return totale;
  }

  int getId() {
    return id;
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'totale': totale};
  }
}
