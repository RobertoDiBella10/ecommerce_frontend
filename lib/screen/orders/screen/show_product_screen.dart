import 'package:ecommerce_frontend/main.dart';
import 'package:ecommerce_frontend/model/user.dart';
import 'package:ecommerce_frontend/screen/orders/screen/order_detail.dart';
import 'package:ecommerce_frontend/screen/orders/screen/table_products.dart';
import 'package:flutter/material.dart';

import '../../home/app_bar.dart';

class ShowProducts extends StatelessWidget {
  const ShowProducts({required this.idOrder, super.key});

  final String idOrder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SuperAppBar(
        area: "none",
        search: "",
      ),
      body: Center(
        child: Stack(children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            width: double.infinity,
            child: Text(
              "Dettaglio ordine #$idOrder",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                (userData.userType == UserType.admin)
                    ? TableProducts(
                        idOrder: idOrder,
                      )
                    : OrderDetailScreen(idOrder: idOrder),
                const SizedBox(
                  height: 25,
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
