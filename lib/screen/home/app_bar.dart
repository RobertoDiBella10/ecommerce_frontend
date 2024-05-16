import 'package:ecommerce_frontend/model/carrello.dart';
import 'package:ecommerce_frontend/model/category.dart';
import 'package:ecommerce_frontend/model/client.dart';
import 'package:ecommerce_frontend/model/order.dart';
import 'package:ecommerce_frontend/model/product.dart';
import 'package:ecommerce_frontend/screen/carrello/carrello_area.dart';
import 'package:ecommerce_frontend/screen/category/screen/add_category_screen.dart';
import 'package:ecommerce_frontend/screen/clients/clients_area.dart';
import 'package:ecommerce_frontend/screen/clients/screen/add_client_screen.dart';
import 'package:ecommerce_frontend/screen/products/products_area.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../model/user.dart';
import '../clients/screen/filter_clients_screen.dart';
import '../clients/screen/profile_client_screen.dart';
import '../orders/screen/filter_orders_screen.dart';
import '../products/screen/add_products_screen.dart';
import '../products/screen/filter_products_screen.dart';
import 'home_page.dart';

// ignore: must_be_immutable
class SuperAppBar extends StatefulWidget implements PreferredSizeWidget {
  SuperAppBar({required this.area, required this.search, super.key});

  final String area;
  String search;

  @override
  Size get preferredSize => const Size.fromHeight(58);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    if (area == "home_user") {
      return _SuperAppBarUserState();
    } else if (area == "home_admin") {
      return _SuperAppBarAdminState();
    } else {
      return _SuperAppBarProductsState(area: area);
    }
  }
}

class _SuperAppBarUserState extends State<SuperAppBar> {
  late ClientData cliente;

  List<String> categories = ["Tutte le Categorie"];
  String selectedCategory = "Tutte le Categorie";

  Future<void> showCategories() async {
    List<Map<String, dynamic>> categorie =
        await Categoria().data(0, 100000, "nome", "");
    for (var categoria in categorie) {
      categories.add(categoria["nome"]);
    }
  }

  void showProfileMenu(BuildContext context) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(1000.0, 0.0, 0.0, 0.0),
      items: [
        const PopupMenuItem<String>(
          value: "Il mio Account",
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text("Il mio Account"),
          ),
        ),
        const PopupMenuItem<String>(
          value: "Esci",
          child: ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red),
            title: Text("Esci", style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
    ).then((value) {
      if (value == "Il mio Account") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ProfileClientScreen()));
      } else if (value == "Esci") {
        userData.logOut(context);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showCategories();
      setState(() {
        // Aggiornamento dello stato dopo che le categorie sono state caricate
      });
    });
    cliente = Provider.of<ClientData>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.background),
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      title: Row(
        children: [
          const Text('E-Commerce',
              style: TextStyle(color: Colors.white, fontSize: 16.0)),
          const SizedBox(width: 120.0),
          DropdownButton(
            value: selectedCategory,
            onChanged: (String? value) {
              setState(() {
                selectedCategory = value!;
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            (selectedCategory != "Tutte le Categorie")
                                ? HomePage(
                                    userData: userData,
                                    pageNumber: 0,
                                    pageSize: 10,
                                    search: "",
                                    sort: "id",
                                    filter: ["", "", selectedCategory])
                                : HomePage(
                                    userData: userData,
                                    pageNumber: 0,
                                    pageSize: 10,
                                    search: "",
                                    sort: "id",
                                    filter: const [])));
              });
            },
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(
                  category,
                  style: TextStyle(
                    color: category == selectedCategory
                        ? Colors.white
                        : Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              );
            }).toList(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16.0,
            ),
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
            ),
            elevation: 0,
            underline: Container(),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 800,
            child: TextField(
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cerca il prodotto, brand...',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              onSubmitted: (value) {
                widget.search = value;
                Prodotto().searchProduct(value, context);
              },
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.shopping_cart,
            color: Colors.white,
          ),
          onPressed: () async {
            ClientData client =
                await Cliente().getCliente(userData.codiceFiscale, context);
            if (client.cf == null) {
              var snackBar = const SnackBar(
                content: Text("Errore. Prova ad aggiornare la pagina"),
              );
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            } else {
              cliente.updateCliente(
                  client.cf!,
                  client.nome!,
                  client.cognome!,
                  client.citta!,
                  client.provincia!,
                  client.via!,
                  client.cap!,
                  client.telefono!,
                  client.email!,
                  client.username!,
                  CarrelloData(
                      id: client.carrello!.id,
                      totale: client.carrello!.totale));
              String cf = cliente.cf ?? "";
              // ignore: use_build_context_synchronously
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CarrelloArea(cfCliente: cf)));
            }
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.account_circle_sharp,
            color: Colors.white,
          ),
          onPressed: () {
            showProfileMenu(context);
          },
        ),
      ],
    );
  }
}

class _SuperAppBarAdminState extends State<SuperAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.background),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          PopupMenuButton(onSelected: (result) {
            if (result == 0) {
              userData.logOut(context);
            }
          }, itemBuilder: (context) {
            return [
              const PopupMenuItem(value: 0, child: Text("Log out")),
            ];
          })
        ],
        actionsIconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.background));
  }
}

class _SuperAppBarProductsState extends State<SuperAppBar> {
  _SuperAppBarProductsState({required this.area});

  @override
  void initState() {
    super.initState();
    cliente = Provider.of<ClientData>(context, listen: false);
  }

  late ClientData cliente;
  final String area;
  Color color = Colors.red;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.background),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          if (area == 'management_products')
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProductsArea(
                              cfCliente: "",
                              filter: [],
                              pageNumber: 0,
                              pageSize: 10,
                              search: "",
                              sort: "id",
                              seeDeleteProducts: true)));
                },
                icon: const Icon(Icons.restore_from_trash)),
          if (area == 'management_clients')
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ClientsArea(
                              filter: [],
                              pageNumber: 0,
                              pageSize: 10,
                              search: "",
                              sort: "id",
                              seeDeleteProducts: true)));
                },
                icon: const Icon(Icons.restore_from_trash)),
          if (area == 'management_products')
            IconButton(
                onPressed: () {
                  Prodotto().showSortDialog(context);
                },
                icon: const Icon(Icons.sort)),
          if (area == 'management_clients')
            IconButton(
                onPressed: () {
                  Cliente().showSortDialog(context);
                },
                icon: const Icon(Icons.sort)),
          if (area == 'management_orders')
            IconButton(
                onPressed: () {
                  Ordine().showSortDialog(context);
                },
                icon: const Icon(Icons.sort)),
          if (area == 'management_products')
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FilterProducts()));
              },
              icon: const Icon(Icons.filter_alt),
            ),
          if (area == 'management_clients')
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FilterClients()));
              },
              icon: const Icon(Icons.filter_alt),
            ),
          if (area == 'management_orders')
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FilterOrders()));
              },
              icon: const Icon(Icons.filter_alt),
            ),
          if ((area == 'management_products' && cliente.cf != null) ||
              area == "management_cart")
            IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  String cf = cliente.cf ?? "";
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CarrelloArea(cfCliente: cf)));
                }),
          PopupMenuButton(onSelected: (result) {
            if (result == 0) {
              userData.logOut(context);
            }
            if (result == 1) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AddProduct()));
            }
            if (result == 2) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AddClient()));
            }
            if (result == 4) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AddCategory()));
            }
          }, itemBuilder: (context) {
            return [
              if (area == "management_products" &&
                  (userData.getType() == UserType.admin))
                const PopupMenuItem(value: 1, child: Text("Aggiungi prodotto")),
              if (area == "management_clients" &&
                  (userData.getType() == UserType.admin))
                const PopupMenuItem(value: 2, child: Text("Aggiungi cliente")),
              if (area == "management_category" &&
                  (userData.getType() == UserType.admin))
                const PopupMenuItem(
                    value: 4, child: Text("Aggiungi categoria")),
              if (userData.getType() != UserType.general)
                const PopupMenuItem(value: 0, child: Text("Log out")),
            ];
          })
        ],
        actionsIconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.background));
  }
}
