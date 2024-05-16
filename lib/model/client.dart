import 'dart:convert';
import 'dart:io';
import 'package:ecommerce_frontend/access/access.dart';
import 'package:ecommerce_frontend/model/carrello.dart';
import 'package:ecommerce_frontend/model/user.dart';
import 'package:ecommerce_frontend/screen/clients/clients_area.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';

class Cliente {
  int pageNumber = 0;
  int pageSize = 10;
  List<String> filter = ["", "", "", "", ""];
  String sort = "CF";
  String search = "";
  late Uri url;

  Future<List<Map<String, dynamic>>> data(int pageNumber, int pageSize,
      List<String> filter, String sort, String search) async {
    this.pageNumber = pageNumber;
    this.pageSize = pageSize;
    this.sort = sort.trim();
    this.search = search;
    for (int k = 0; k < filter.length; k++) {
      this.filter[k] = filter[k].trim();
    }
    var list = await getData().then((value) {
      return value.map((row) => row.toJson()).toList();
    });
    return list;
  }

  Future<List<Map<String, dynamic>>> dataDeleteClients(
      int pageNumber, int pageSize, String sort, String search) async {
    this.pageNumber = pageNumber;
    this.pageSize = pageSize;
    this.search = search;
    this.sort = sort.trim();
    var list = await getAllClientiEliminati().then((value) {
      return value.map((row) => row.toJson()).toList();
    });
    return list;
  }

  Future<List<ClientData>> getData() async {
    List<ClientData> results = [];

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

    if (search != "" && search != "default_search") {
      url = Uri.parse(
          "http://localhost:8080/cliente/search/$search?pageNumber=$pageNumber&pageSize=$pageSize&sortBy=$sort");
    } else if (filter[0] != "" ||
        filter[1] != "" ||
        filter[2] != "" ||
        filter[3] != "" ||
        filter[4] != "") {
      url = Uri.parse(
          "http://localhost:8080/cliente/filtra?pageNumber=$pageNumber&pageSize=$pageSize&sortBy=$sort&nome=${filter[0]}&cognome=${filter[1]}&citta=${filter[2]}&via=${filter[3]}&cap=${filter[4]}");
    } else {
      url = Uri.parse(
          "http://localhost:8080/cliente/all?pageNumber=$pageNumber&pageSize=$pageSize&sortBy=$sort");
    }

    try {
      final request = await http.get(url, headers: headers);
      if (request.statusCode == 200) {
        final List<dynamic> clienti = json.decode(request.body);
        for (var cliente in clienti) {
          results.add(ClientData.fromJson(cliente));
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }

    return results;
  }

  Future<List<ClientData>> getAllClientiEliminati() async {
    List<ClientData> results = [];

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

    if (search != "" && search != "default_search") {
      url = Uri.parse(
          "http://localhost:8080/cliente/searchDelete/$search?pageNumber=$pageNumber&pageSize=$pageSize&sortBy=$sort");
    } else {
      url = Uri.parse(
          "http://localhost:8080/cliente/all/onlyDelete?pageNumber=$pageNumber&pageSize=$pageSize&sortBy=$sort");
    }

    try {
      final request = await http.get(url, headers: headers);
      if (request.statusCode == 200) {
        final List<dynamic> clientiEliminati = json.decode(request.body);
        for (var cliente in clientiEliminati) {
          results.add(ClientData.fromJson(cliente));
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }

    return results;
  }

  Future<ClientData> getCliente(cf, BuildContext context) async {
    String accessToken = userData.accessToken;
    ClientData result = ClientData();
    try {
      var request = await http
          .get(Uri.parse("http://localhost:8080/cliente/$cf"), headers: {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Authorization': 'Bearer $accessToken',
        'Cache-Control': 'no-cache'
      });
      if (request.statusCode == 200) {
        final dynamic clienteJson = json.decode(request.body);
        return ClientData.fromJson(clienteJson);
      } else {
        // ignore: use_build_context_synchronously
        showResultDialog(request.body, context);
      }
      return result;
    } catch (e) {
      return result;
    }
  }

  Future<bool> addClient(cf, nome, cognome, citta, provincia, via, cap,
      telefono, email, username, password, BuildContext context) async {
    try {
      var request =
          await http.post(Uri.parse("http://localhost:8080/auth/register"),
              headers: {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json',
                'Accept': '*/*',
                'Cache-Control': 'no-cache'
              },
              body: json.encode({
                'cf': cf.trim(),
                'nome': nome.trim(),
                'cognome': cognome.trim(),
                'citta': citta.trim(),
                'provincia': provincia.trim(),
                'via': via.trim(),
                'cap': int.parse(cap),
                'telefono': int.parse(telefono),
                'email': email.trim(),
                'username': username.trim(),
                'password': password.trim()
              }));
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

  Future<bool> updateClient(cf, nome, cognome, citta, provincia, via, cap,
      telefono, email, username, password, BuildContext context) async {
    String accessToken = userData.accessToken;
    try {
      var request =
          await http.post(Uri.parse("http://localhost:8080/cliente/update"),
              headers: {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json',
                'Accept': '*/*',
                'Cache-Control': 'no-cache',
                'Authorization': 'Bearer $accessToken',
              },
              body: json.encode({
                'cf': cf.trim(),
                'nome': nome.trim(),
                'cognome': cognome.trim(),
                'citta': citta.trim(),
                'provincia': provincia.trim(),
                'via': via.trim(),
                'cap': int.parse(cap),
                'telefono': int.parse(telefono),
                'email': email.trim(),
                'username': username.trim(),
                'password': password.trim()
              }));
      if (request.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void deleteClients(List<String> clients, BuildContext context) async {
    String accessToken = userData.accessToken;
    List<String> selectedRowKeys = [];

    for (int i = 0; i < clients.length; i++) {
      selectedRowKeys.add(clients[i]);
    }

    try {
      for (int k = 0; k < selectedRowKeys.length; k++) {
        var request = await http.delete(
          Uri.parse("http://localhost:8080/auth/remove/${selectedRowKeys[k]}"),
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

  void searchClient(search, BuildContext context) {
    this.search = search.trim();
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ClientsArea(
                pageNumber: pageNumber,
                pageSize: pageSize,
                search: search,
                filter: filter,
                sort: sort,
                seeDeleteProducts: false)));
  }

  void searchDeleteClient(search, BuildContext context) {
    this.search = search.trim();
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ClientsArea(
                  pageNumber: pageNumber,
                  pageSize: pageSize,
                  search: search,
                  filter: filter,
                  sort: sort,
                  seeDeleteProducts: true,
                )));
  }

  void recuperaClienteEliminato(
      List<String> clients, BuildContext context) async {
    String accessToken = userData.accessToken;
    List<String> selectedRowKeys = [];

    for (int i = 0; i < clients.length; i++) {
      selectedRowKeys.add(clients[i]);
    }
    try {
      for (int k = 0; k < selectedRowKeys.length; k++) {
        var request = await http.put(
          Uri.parse(
              "http://localhost:8080/auth/recupera/${selectedRowKeys[k]}"),
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
          return;
        }
      }

      var snackBar = const SnackBar(
        content: Text("Recupero effettuato con successo"),
      );
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      var snackBar = const SnackBar(
        content: Text("Connessione internet assente"),
      );
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  showResultDialog(String message, BuildContext context) {
    var snackBar = SnackBar(
      content: Text(message),
    );
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ClientsArea(
                pageNumber: pageNumber,
                pageSize: pageSize,
                search: search,
                filter: filter,
                sort: sort,
                seeDeleteProducts: false)));
  }

  showDeleteResultDialog(String message, BuildContext context) {
    var snackBar = SnackBar(
      content: Text(message),
    );
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    if (userData.userType == UserType.admin) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ClientsArea(
                  pageNumber: pageNumber,
                  pageSize: pageSize,
                  search: search,
                  filter: filter,
                  sort: sort,
                  seeDeleteProducts: false)));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Access()));
    }
  }

  showFilterDialog(String nome, String cognome, citta, String via, String cap,
      BuildContext context) {
    List<String> filterParameters = [
      nome.trim(),
      cognome.trim(),
      citta.trim(),
      via.trim(),
      cap.trim()
    ];
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ClientsArea(
                pageNumber: pageNumber,
                pageSize: pageSize,
                search: search,
                filter: filterParameters,
                sort: sort,
                seeDeleteProducts: false)));
  }

  showSortDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: ((context) {
          return SimpleDialog(
            children: [
              const Text(
                "ORDINAMENTO",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                margin: const EdgeInsets.only(left: 50, right: 50),
                child: ElevatedButton(
                    onPressed: () {
                      sort = "cognome";
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClientsArea(
                                  pageNumber: pageNumber,
                                  pageSize: pageSize,
                                  search: search,
                                  filter: filter,
                                  sort: sort,
                                  seeDeleteProducts: false)));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    child: Text(
                      "cognome",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.background),
                    )),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                  margin: const EdgeInsets.only(left: 50, right: 50),
                  child: ElevatedButton(
                    onPressed: () {
                      sort = "nome";
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClientsArea(
                                  pageNumber: pageNumber,
                                  pageSize: pageSize,
                                  search: search,
                                  filter: filter,
                                  sort: sort,
                                  seeDeleteProducts: false)));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    child: Text(
                      "nome",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.background),
                    ),
                  )),
              const SizedBox(
                height: 20,
              ),
              Container(
                  margin: const EdgeInsets.only(left: 50, right: 50),
                  child: ElevatedButton(
                    onPressed: () {
                      sort = "citta";
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClientsArea(
                                  pageNumber: pageNumber,
                                  pageSize: pageSize,
                                  search: search,
                                  filter: filter,
                                  sort: sort,
                                  seeDeleteProducts: false)));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    child: Text(
                      "Città",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.background),
                    ),
                  )),
              const SizedBox(
                height: 20,
              ),
              Container(
                  margin: const EdgeInsets.only(left: 50, right: 50),
                  child: ElevatedButton(
                    onPressed: () {
                      sort = "provincia";
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClientsArea(
                                  pageNumber: pageNumber,
                                  pageSize: pageSize,
                                  search: search,
                                  filter: filter,
                                  sort: sort,
                                  seeDeleteProducts: false)));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    child: Text(
                      "Provincia",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.background),
                    ),
                  )),
              const SizedBox(
                height: 20,
              ),
              Container(
                  margin: const EdgeInsets.only(left: 50, right: 50),
                  child: ElevatedButton(
                    onPressed: () {
                      sort = "username";
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClientsArea(
                                  pageNumber: pageNumber,
                                  pageSize: pageSize,
                                  search: search,
                                  filter: filter,
                                  sort: sort,
                                  seeDeleteProducts: false)));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    child: Text(
                      "Username",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.background),
                    ),
                  ))
            ],
          );
        }));
  }
}

class ClientData extends ChangeNotifier {
  String? cf;
  String? nome;
  String? cognome;
  String? citta;
  String? provincia;
  String? via;
  int? cap;
  int? telefono;
  String? email;
  String? username;
  String? password;
  CarrelloData? carrello;

  ClientData(
      {this.cf,
      this.nome,
      this.cognome,
      this.citta,
      this.provincia,
      this.via,
      this.cap,
      this.telefono,
      this.email,
      this.username,
      this.password,
      this.carrello});

  factory ClientData.fromJson(Map<String, dynamic> json) {
    return ClientData(
        cf: json["cf"],
        nome: json["nome"],
        cognome: json["cognome"],
        citta: json["citta"],
        provincia: json["provincia"],
        via: json["via"],
        cap: json["cap"],
        telefono: json["telefono"],
        email: json["email"],
        username: json["username"],
        password: json["password"],
        carrello: CarrelloData.fromJson(json["carrello"]));
  }

  Map<String, dynamic> toJson() {
    return {
      'cf': cf,
      'nome': nome,
      'cognome': cognome,
      'citta': citta,
      'provincia': provincia,
      'via': via,
      'cap': cap,
      'telefono': telefono,
      'email': email,
      'username': username,
      'carrello': carrello?.toJson()
    };
  }

  String? getCF() {
    return cf;
  }

  CarrelloData? getCarrello() {
    return carrello;
  }

  void updateCliente(
      String cf,
      String nome,
      String cognome,
      String citta,
      String provincia,
      String via,
      int cap,
      int telefono,
      String email,
      String username,
      CarrelloData carrello) {
    this.cf = cf;
    this.nome = nome;
    this.cognome = cognome;
    this.citta = citta;
    this.provincia = provincia;
    this.via = via;
    this.cap = cap;
    this.telefono = telefono;
    this.email = email;
    this.username = username;
    this.carrello = carrello;
    notifyListeners();
  }

  void updateCarrello(CarrelloData carrello) {
    this.carrello = carrello;
    notifyListeners();
  }
}
