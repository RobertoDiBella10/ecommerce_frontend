import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../access/access.dart';

enum UserType { admin, user, general }

class User {
  late String username, password, codiceFiscale;
  UserType userType = UserType.general;
  String accessToken = "";
  String refreshToken = "";

  void setParam(String username, String password) {
    this.username = username.trim();
    this.password = password.trim();
  }

  String getCodiceFiscale() {
    return codiceFiscale;
  }

  UserType getType() {
    return userType;
  }

  Future<bool> getAccess(BuildContext context) async {
    try {
      final check = await http.get(
        Uri.parse('http://localhost:8080/cliente/checkVisibile/$username'),
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json',
          'Accept': '*/*',
          'Cache-Control': 'no-cache'
        },
      );
      bool isValid = json.decode(check.body);
      if (!isValid && username != "admin") {
        const snackBar = SnackBar(
          backgroundColor: Colors.blue,
          content: Text('Utente non registrato'),
        );
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return false;
      }
      final request = await http.post(
        Uri.parse(
            'http://localhost:8182/realms/ecommerce/protocol/openid-connect/token'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
          'cache-control': 'no-cache'
        },
        body: <String, String>{
          'grant_type': 'password',
          'client_id': 'spring-client',
          'username': username,
          'password': password,
        },
      );
      if (request.statusCode == 200) {
        Map dataResponse = json.decode(request.body);
        accessToken = dataResponse["access_token"];
        refreshToken = dataResponse["refresh_token"];
        final jwt = JWT.decode(accessToken);
        dynamic payload = jwt.payload;

        if (payload.containsKey("resource_access") &&
            payload["resource_access"].containsKey("spring-client")) {
          List<dynamic> roles =
              payload["resource_access"]["spring-client"]["roles"];
          if (roles.contains("role_admin")) {
            userType = UserType.admin;
          } else {
            userType = UserType.user;
          }
        }
        if (payload.containsKey("cf")) {
          codiceFiscale = payload["cf"];
        }
        return true;
      } else if (request.statusCode == 403 || request.statusCode == 401) {
        // ignore: use_build_context_synchronously
        if (!context.mounted) {
          return false;
        }
        const snackBar = SnackBar(
          backgroundColor: Colors.blue,
          content: Text('Utente non registrato'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      const snackBar = SnackBar(
        content: Text('Errore Connessione'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }

    return false;
  }

  void logOut(BuildContext context) async {
    try {
      final request = await http.post(
          Uri.parse(
              'http://localhost:8182/realms/ecommerce/protocol/openid-connect/logout'),
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded',
            'cache-control': 'no-cache'
          },
          body: <String, String>{
            'client_id': 'spring-client',
            'refresh_token': refreshToken,
          });
      if (request.statusCode == 200 || request.statusCode == 204) {
        username = "";
        password = "";
        accessToken = "";
        refreshToken = "";
        codiceFiscale = "";
        userType = UserType.general;
        const snackBar = SnackBar(
          content: Text('Uscita effettuata con successo'),
        );
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // ignore: use_build_context_synchronously
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Access()),
            (route) => false);
      }
    } catch (e) {
      const snackBar = SnackBar(
        content: Text('Errore Connessione'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
