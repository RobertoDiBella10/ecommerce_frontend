import 'package:ecommerce_frontend/screen/resi/screen/form_add_reso.dart';
import 'package:flutter/material.dart';
import '../../home/app_bar.dart';

// ignore: must_be_immutable
class AddReso extends StatelessWidget {
  AddReso({required this.numeroOrdine, required this.cfCliente, super.key});

  String numeroOrdine;
  String cfCliente;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SuperAppBar(area: "none", search: ""),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "\nAggiungi motivazione reso",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
                width: 300,
                child: FormAddReso(
                  numeroOrdine: numeroOrdine,
                  cfCliente: cfCliente,
                )),
          ],
        ),
      )),
    );
  }
}
