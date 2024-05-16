import 'package:ecommerce_frontend/model/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'access/access.dart';
import 'model/user.dart';

///creazione variabili di tema globale
var kColorScheme = const ColorScheme(
  primary: Colors.blue, //colore primario
  secondary: Color.fromARGB(255, 4, 3, 68), // Colore secondario
  background: Color(0xFFF3F4F6), // Colore di sfondo
  surface: Colors.white, // Colore delle superfici
  error: Colors.red, // Colore per gli errori
  onPrimary: Colors.black, // Colore del testo su sfondo primario
  onSecondary: Colors.white, // Colore del testo su sfondo secondario
  onBackground: Color(0xFF000000), // Colore del testo su sfondo
  onSurface: Color(0xFF000000), // Colore del testo sulle superfici
  onError: Colors.white,
  brightness: Brightness.light,
);

///variabile globale utente
User userData = User();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ClientData()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'E-Commerce',
        theme:
            ThemeData(colorScheme: kColorScheme).copyWith(useMaterial3: true),
        home: const Access(),
      ),
    );
  }
}
