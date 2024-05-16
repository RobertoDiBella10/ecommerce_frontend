import 'dart:convert';
import 'package:ecommerce_frontend/model/product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import 'order.dart';

class Associato {
  String numeroOrdine = "";

  Future<List<Map<String, dynamic>>> data(String numeroOrdine) async {
    this.numeroOrdine = numeroOrdine;
    var list = await visualizzaDettagliOrdine(numeroOrdine).then((value) {
      return value.map((row) => row.toJson()).toList();
    });
    return list;
  }

  Future<List<AssociatoData>> visualizzaDettagliOrdine(
      String numeroOrdine) async {
    List<AssociatoData> results = [];
    await Future.delayed(const Duration(milliseconds: 500));
    String accessToken = userData.accessToken;
    try {
      var request = await http.get(
        Uri.parse("http://localhost:8080/ordine/details/$numeroOrdine"),
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'Accept': '*/*'
        },
      );
      if (request.statusCode == 200) {
        final List<dynamic> prodotti = json.decode(request.body);
        for (var prodotto in prodotti) {
          results.add(AssociatoData.fromJson(prodotto));
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
}

class AssociatoData {
  final int id;
  final SampleDataRow prodotto;
  final OrdineData ordine;
  int quantita;
  double subtotale;

  AssociatoData(
      {required this.id,
      required this.prodotto,
      required this.ordine,
      required this.quantita,
      required this.subtotale});

  factory AssociatoData.fromJson(Map<String, dynamic> json) {
    return AssociatoData(
        id: json["id"],
        prodotto: SampleDataRow.fromJson(json["prodotto"]),
        ordine: OrdineData.fromJson(json["ordine"]),
        quantita: json["quantita"],
        subtotale: json["subtotale"]);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prodotto': prodotto.toJson(),
      'ordine': ordine.toJson(),
      'quantita': quantita,
      'subtotale': subtotale
    };
  }
}
