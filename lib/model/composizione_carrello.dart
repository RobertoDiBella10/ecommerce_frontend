import 'dart:convert';

import 'package:ecommerce_frontend/model/product.dart';
import 'package:ecommerce_frontend/model/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import 'carrello.dart';

class ComposizioneCarrello {
  String cfCliente = "";

  Future<List<Map<String, dynamic>>> data(String cfCliente) async {
    this.cfCliente = cfCliente;
    var list = await visualizzaCarrello(cfCliente).then((value) {
      return value.map((row) => row.toJson()).toList();
    });
    return list;
  }

  Future<bool> addProdottoCarrello(
      prodotto, cliente, quantita, BuildContext context) async {
    String accessToken = userData.accessToken;
    UserType role = userData.getType();
    String cfCliente = userData.getCodiceFiscale();
    String cfDaInserire = (role == UserType.user) ? cfCliente : cliente;
    try {
      var request = await http.post(
        Uri.parse(
            "http://localhost:8080/carrello/addProdotto/$prodotto/$cfDaInserire/$quantita"),
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'Accept': '*/*',
          'Cache-Control': 'no-cache'
        },
      );
      if (request.statusCode == 200) {
        return true;
      } else {
        // ignore: use_build_context_synchronously
        showResultDialog(request.body, context);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<CarrelloData> removeProdottoCarrello(id, BuildContext context) async {
    String accessToken = userData.accessToken;
    CarrelloData result = CarrelloData(id: id, totale: 0.0);
    try {
      var request = await http.delete(
        Uri.parse("http://localhost:8080/carrello/removeProdotto/$id"),
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'Accept': '*/*'
        },
      );

      if (request.statusCode != 200) {
        // ignore: use_build_context_synchronously
        var snackBar = SnackBar(
          content: Text(request.body),
        );
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return result;
      } else {
        final Map<String, dynamic> carrelloJson = json.decode(request.body);
        result = CarrelloData.fromJson(carrelloJson);
        // ignore: use_build_context_synchronously
        showDeleteResultDialog(
            "Eliminazione effettuata con successo!", context);
      }

      return result;
    } catch (e) {
      showDeleteResultDialog("Connessione internet assente", context);
      return result;
    }
  }

  Future<CarrelloData> aggiornaQuantita(
      int id, int quantity, BuildContext context) async {
    CarrelloData result = CarrelloData(id: id, totale: 0.0);
    String accessToken = userData.accessToken;
    try {
      var request = await http.put(
        Uri.parse(
            "http://localhost:8080/carrello/updateQuantita/$id/$quantity"),
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'Accept': '*/*'
        },
      );
      if (request.statusCode == 200) {
        final Map<String, dynamic> carrelloJson = json.decode(request.body);
        result = CarrelloData.fromJson(carrelloJson);
      }
      return result;
    } catch (e) {
      debugPrint(e.toString());
      return result;
    }
  }

  Future<List<ComposizioneCarrelloData>> visualizzaCarrello(
      String cliente) async {
    List<ComposizioneCarrelloData> results = [];
    UserType role = userData.getType();
    String cfCliente = userData.getCodiceFiscale();
    String cfDaInserire = (role == UserType.user) ? cfCliente : cliente;
    await Future.delayed(const Duration(milliseconds: 500));
    String accessToken = userData.accessToken;
    try {
      var request = await http.get(
        Uri.parse("http://localhost:8080/carrello/visualizza/$cfDaInserire"),
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'Accept': '*/*'
        },
      );
      if (request.statusCode == 200) {
        final List<dynamic> prodottiJson = json.decode(request.body);
        List<Map<String, dynamic>> prodotti =
            prodottiJson.map((json) => json as Map<String, dynamic>).toList();
        for (var prodotto in prodotti) {
          results.add(ComposizioneCarrelloData.fromJson(prodotto));
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }

    return results;
  }

  showResultDialog(String message, BuildContext context) {
    var snackBar = SnackBar(
      content: Text(message),
    );
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  showDeleteResultDialog(String message, BuildContext context) {
    var snackBar = SnackBar(
      content: Text(message),
    );
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class ComposizioneCarrelloData {
  final int id;
  final SampleDataRow prodotto;
  final CarrelloData carrello;
  int quantita;
  double subtotale;

  ComposizioneCarrelloData(
      {required this.id,
      required this.prodotto,
      required this.carrello,
      required this.quantita,
      required this.subtotale});

  factory ComposizioneCarrelloData.fromJson(Map<String, dynamic> json) {
    return ComposizioneCarrelloData(
        id: json["id"],
        prodotto: SampleDataRow.fromJson(json["prodotto"]),
        carrello: CarrelloData.fromJson(json["carrello"]),
        quantita: json["quantita"],
        subtotale: json["subtotale"]);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prodotto': prodotto.toJson(),
      'carrello': carrello.toJson(),
      'quantita': quantita,
      'subtotale': subtotale
    };
  }
}
