import 'package:ecommerce_frontend/screen/clients/screen/form_add_client.dart';
import 'package:flutter/material.dart';
import '../../home/app_bar.dart';

// ignore: must_be_immutable
class AddClient extends StatelessWidget {
  const AddClient({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SuperAppBar(area: "none", search: ""),
      body: const Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "\nRegistrazione Cliente",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 300, child: FormAddClient()),
          ],
        ),
      )),
    );
  }
}
