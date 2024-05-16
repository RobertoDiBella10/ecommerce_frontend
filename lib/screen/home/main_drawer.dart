import 'package:ecommerce_frontend/screen/products/products_area.dart';
import 'package:ecommerce_frontend/screen/resi/resi_area.dart';
import 'package:ecommerce_frontend/screen/reviews/reviews_area.dart';
import 'package:flutter/material.dart';
import '../category/category_area.dart';
import '../clients/clients_area.dart';
import '../orders/orders_area.dart';

class MainDrawer extends StatelessWidget {
  MainDrawer({super.key});

  final List<String> defaultFilter = [];
  final String defaultSort = "";
  final String search = "default_search";
  final int pageNumber = 0;
  final int pageSize = 10;

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: [
        DrawerHeader(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8)
          ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: Row(
            children: [
              Icon(
                Icons.people,
                size: 48,
                color: Theme.of(context).colorScheme.background,
              ),
              const SizedBox(
                width: 18,
              ),
              Text(
                "Operazioni",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.background,
                    ),
              )
            ],
          ),
        ),
        ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryArea(
                    pageNumber: pageNumber,
                    pageSize: pageSize,
                    search: search,
                    sort: "nome"),
              ),
            );
          },
          leading: Icon(
            Icons.category,
            size: 26,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            "Gestione Categorie",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
          ),
        ),
        ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClientsArea(
                    pageNumber: pageNumber,
                    pageSize: pageSize,
                    search: search,
                    filter: defaultFilter,
                    sort: "CF",
                    seeDeleteProducts: false),
              ),
            );
          },
          leading: Icon(
            Icons.person,
            size: 26,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            "Gestione Clienti",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
          ),
        ),
        ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrdersArea(
                    cfCliente: "",
                    pageNumber: pageNumber,
                    pageSize: pageSize,
                    filter: defaultFilter,
                    sort: "numeroOrdine",
                    search: search),
              ),
            );
          },
          leading: Icon(
            Icons.local_shipping,
            size: 26,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            "Gestione Ordini",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
          ),
        ),
        ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductsArea(
                    cfCliente: "",
                    pageNumber: pageNumber,
                    pageSize: pageSize,
                    search: search,
                    filter: defaultFilter,
                    sort: "id",
                    seeDeleteProducts: false),
              ),
            );
          },
          leading: Icon(
            Icons.trolley,
            size: 26,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            "Gestione Prodotti",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
          ),
        ),
        ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewsArea(
                  cfCliente: "",
                  idProduct: "",
                  sort: "ID",
                  pageNumber: pageNumber,
                  pageSize: pageSize,
                ),
              ),
            );
          },
          leading: Icon(
            Icons.receipt,
            size: 26,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            "Gestione Recensioni",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
          ),
        ),
        ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResiArea(
                  cfCliente: "",
                  pageNumber: pageNumber,
                  pageSize: pageSize,
                  sort: "id",
                ),
              ),
            );
          },
          leading: Icon(
            Icons.report_problem,
            size: 26,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            "Gestione Resi",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
          ),
        )
      ],
    ));
  }
}
