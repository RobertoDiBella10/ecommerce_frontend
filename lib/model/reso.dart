import 'dart:convert';
import 'dart:io';
import 'package:ecommerce_frontend/model/user.dart';
import 'package:ecommerce_frontend/screen/clients/screen/my_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../screen/clients/screen/my_reso_screen.dart';
import '../screen/resi/resi_area.dart';
import 'client.dart';
import 'order.dart';

class Reso {
  int pageNumber = 0;
  int pageSize = 10;
  String sort = "id";
  late Uri url;
  String cfCliente = "";

  Future<List<Map<String, dynamic>>> data(
      int pageNumber, int pageSize, String sort, String cliente) async {
    this.pageNumber = pageNumber;
    this.pageSize = pageSize;
    this.sort = sort.trim();
    cfCliente = cliente;
    var list = await getData().then((value) {
      return value.map((row) => row.toJson()).toList();
    });
    return list;
  }

  Future<List<Map<String, dynamic>>> dataResiCliente(
      int pageNumber, int pageSize, String sort, String cliente) async {
    this.pageNumber = pageNumber;
    this.pageSize = pageSize;
    this.sort = sort.trim();
    cfCliente = cliente;
    var list = await getAllResiCliente(cliente).then((value) {
      return value.map((row) => row.toJson()).toList();
    });
    return list;
  }

  Future<List<ResoData>> getData() async {
    List<ResoData> results = [];

    await Future.delayed(const Duration(milliseconds: 500));

    var contentType = "application/json;charset=utf-8";
    String accessToken = userData.accessToken;
    Map<String, String> headers = {};
    headers[HttpHeaders.contentTypeHeader] = contentType;
    headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';
    headers[HttpHeaders.acceptHeader] = "application/json";
    headers[HttpHeaders.accessControlAllowOriginHeader] = "*";
    headers[HttpHeaders.accessControlAllowMethodsHeader] = "POST, GET, DELETE";
    headers[HttpHeaders.accessControlAllowHeadersHeader] = "Content-Type";

    url = Uri.parse(
        "http://localhost:8080/reso/all?pageNumber=$pageNumber&pageSize=$pageSize&sortBy=$sort");

    try {
      final request = await http.get(url, headers: headers);
      if (request.statusCode == 200) {
        final List<dynamic> resi = json.decode(request.body);
        for (var reso in resi) {
          results.add(ResoData.fromJson(reso));
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }

    return results;
  }

  Future<bool> addReso(
      cliente, ordine, motivazione, BuildContext context) async {
    String accessToken = userData.accessToken;
    UserType role = userData.getType();
    String cfCliente = userData.getCodiceFiscale();
    String cfDaInserire = (role == UserType.user) ? cfCliente : cliente;
    try {
      var request = await http.post(
        Uri.parse("http://localhost:8080/reso/add"),
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'Accept': '*/*',
          'Cache-Control': 'no-cache'
        },
        body: json.encode({
          'cliente': {'cf': cfDaInserire.trim()},
          'motivazione': motivazione.trim(),
          'ordine': {'id': ordine.trim()}
        }),
      );

      if (request.statusCode == 200) {
        // ignore: use_build_context_synchronously
        showResultDialog(request.body, context);
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

  void deleteReso(List<String> resi, BuildContext context) async {
    String accessToken = userData.accessToken;
    List<String> selectedRowKeys = [];

    for (int i = 0; i < resi.length; i++) {
      selectedRowKeys.add(resi[i]);
    }
    try {
      for (int k = 0; k < selectedRowKeys.length; k++) {
        var request = await http.delete(
          Uri.parse("http://localhost:8080/reso/remove/${selectedRowKeys[k]}"),
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
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
          return;
        }
      }
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      showDeleteResultDialog("Eliminazione effettuata con successo!", context);
    } catch (e) {
      showDeleteResultDialog("Connessione internet assente", context);
    }
  }

  Future<List<ResoData>> getAllResiCliente(String cfCliente) async {
    List<ResoData> results = [];
    await Future.delayed(const Duration(milliseconds: 500));

    String accessToken = userData.accessToken;
    try {
      var request = await http.get(
        Uri.parse(
            "http://localhost:8080/reso/$cfCliente/all?pageNumber=$pageNumber&pageSize=$pageSize&sortBy=$sort"),
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'Accept': '*/*'
        },
      );

      if (request.statusCode == 200) {
        final List<dynamic> resi = json.decode(request.body);
        for (var reso in resi) {
          results.add(ResoData.fromJson(reso));
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

    // ignore: use_build_context_synchronously
    if (userData.userType == UserType.admin) {
      Navigator.pop(context);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ResiArea(
                  cfCliente: "",
                  pageNumber: pageNumber,
                  pageSize: pageSize,
                  sort: sort)));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MyOrdersScreen(
                  cfCliente: userData.codiceFiscale,
                  pageNumber: pageNumber,
                  pageSize: pageSize,
                  filter: const [],
                  search: "",
                  sort: sort)));
    }
  }

  showDeleteResultDialog(String message, BuildContext context) {
    var snackBar = SnackBar(
      content: Text(message),
    );
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    // ignore: use_build_context_synchronously
    // ignore: use_build_context_synchronously
    if (userData.userType == UserType.admin) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ResiArea(
                  cfCliente: "",
                  pageNumber: pageNumber,
                  pageSize: pageSize,
                  sort: sort)));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MyResoScreen(
                  cfCliente: userData.codiceFiscale,
                  pageNumber: pageNumber,
                  pageSize: pageSize,
                  filter: const [],
                  search: "",
                  sort: sort)));
    }
  }
}

class ResoData {
  final double id;
  final String motivazione;
  final OrdineData ordine;
  final ClientData cliente;

  ResoData(
      {required this.id,
      required this.ordine,
      required this.cliente,
      required this.motivazione});

  factory ResoData.fromJson(Map<String, dynamic> json) {
    return ResoData(
        id: json["id"],
        motivazione: json["motivazione"],
        ordine: OrdineData.fromJson(json["ordine"]),
        cliente: ClientData.fromJson(json["cliente"]));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motivazione': motivazione,
      'ordine': ordine.toJson(),
      'cliente': cliente.cf
    };
  }
}
