import 'package:compromised_password/sql_helper.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password check',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Password check'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = true;
  String errorMessage = "No error yet";

  String _hashPassword(String plainPassword) {
    final digest = sha1.convert(utf8.encode(plainPassword));
    return digest.toString().toUpperCase();
  }

  Future<List<Map<String, dynamic>>> _getPassword(String password) async {
    List<Map<String, dynamic>> results =
        await SQLHelper.getPwnedPassword(_hashPassword(password));
    print(results);

    setState(() {
      _isLoading = false;
    });
    return results;
  }

  @override
  void initState() async {
    super.initState();
    if ((await File("/storage/745F-D902/Download/haveibeenpawned.sqlite"))
            .exists() !=
        true) {
      errorMessage = "Database not found";
    }
  }

  final TextEditingController _passwordController = TextEditingController();
  bool passwordvisible = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              errorMessage,
            ),
            const Text(
              'Enter the password you want to check and press enter:',
            ),
            Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _passwordController,
                      autofocus: true,
                      obscureText: passwordvisible,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Password',
                          suffix: IconButton(
                              onPressed: () {
                                setState(() {
                                  if (passwordvisible) {
                                    passwordvisible = false;
                                  } else {
                                    passwordvisible = true;
                                  }
                                });
                              },
                              icon: Icon(passwordvisible == true
                                  ? Icons.remove_red_eye
                                  : Icons.password))),
                    ))),
            ElevatedButton(
              onPressed: () async {
                List<Map<String, dynamic>> results =
                    await _getPassword(_passwordController.text);
                var route;
                if (results.isEmpty) {
                  route = const HappyRoute();
                } else {
                  route = ResultsRoute(results[0]['prevalence'].toString());
                }
                _passwordController.text = "";
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => route),
                );
              },
              child: const Text("Check password"),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultsRoute extends StatelessWidget {
  const ResultsRoute(this.prevalence);
  final String prevalence;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password analysis results'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                "Unfortunately your password has been compromised $prevalence times."),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Reset application'),
            ),
          ],
        ),
      ),
    );
  }
}

class HappyRoute extends StatelessWidget {
  const HappyRoute();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password analysis results'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Awesome, your password seems safe."),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Reset application'),
            ),
          ],
        ),
      ),
    );
  }
}
