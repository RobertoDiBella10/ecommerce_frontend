import 'package:flutter/material.dart';
import '../../model/user.dart';
import '../products/product_area_user.dart';
import 'main_drawer.dart';
import 'app_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage(
      {required this.userData,
      required this.pageNumber,
      required this.pageSize,
      required this.search,
      required this.sort,
      required this.filter,
      super.key});

  final User userData;
  final int pageNumber;
  final int pageSize;
  final String search;
  final String sort;
  final List<String> filter;

  @override
  Widget build(BuildContext context) {
    if (userData.getType() == UserType.user) {
      return Scaffold(
        appBar: SuperAppBar(
          search: search,
          area: "home_user",
        ),
        body: ProductsAreaUser(
          pageNumber: 0,
          pageSize: 10,
          search: search,
          filter: filter,
          sort: "id",
        ),
      );
    } else {
      return Scaffold(
        appBar: SuperAppBar(area: "home_admin", search: ""),
        drawer: MainDrawer(),
        body: const Center(
          child: Text(
            "Benvenuto Admin",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }
}
