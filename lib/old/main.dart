import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:tubes/borrower-ajukan-pinjaman.dart';
import 'package:tubes/borrower-isi-saldo.dart';
import 'package:tubes/borrower-pencairan-dana.dart';
import 'package:tubes/borrower-wallet.dart';
import 'package:tubes/data-umkm.dart';
import 'register_borrower.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'borrower-home.dart';

String selectedRole = "Borrower";

class FormBorrowerLogin extends ChangeNotifier {
  String _email = '';
  String _password = '';
  String _validationError = '';
  String _token = "";

  String get email => _email;
  String get password => _password;
  String get validationError => _validationError;

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  bool validateForm() {
    if (_email.isEmpty || _password.isEmpty) {
      _validationError = 'kosong';
    } else {
      _validationError = '';
    }
    notifyListeners();
    return _validationError.isEmpty;
  }

  void fetchUser() async {
    final url = Uri.parse('http://127.0.0.1:8000/borrower/me/');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $_token',
    });

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      print(responseBody);
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void submitForm(void Function() callback) async {
    if (validateForm()) {
      if (selectedRole == "Borrower") {
        // var url = Uri.parse('http://127.0.0.1:8000/borrowers/login/');

        // var response = await http.post(url,
        //     headers: {"Content-Type": "application/json"},
        //     body: json.encode({'email': _email, 'password': _password}));

        // if (response.statusCode == 200) {
        //   print('Login request successful');
        //   print('Response body: ${response.body}');
        //   var data = jsonDecode(response.body);
        //   _id = data["id"];
        // } else {
        //   print('Login request failed');
        //   print('Response status code: ${response.statusCode}');
        //   if (response.statusCode == 404) {
        //     _validationError = 'tidak ada';
        //   } else if (response.statusCode == 405) {
        //     _validationError = 'salah';
        //   }
        // }
        var url = http.MultipartRequest(
            'POST', Uri.parse('http://127.0.0.1:8000/borrower/token/'));

        url.fields['username'] = _email;
        url.fields['password'] = _password;

        var response = await url.send();

        // var response = await http.post(url,
        //     body: json.encode({'username': _email, 'password': _password}));

        if (response.statusCode == 200) {
          print('get token');
          var responseBody = await response.stream.bytesToString();
          var jsonData = json.decode(responseBody);
          _token = jsonData["access_token"];

          await setToken(_token);

          fetchUser();
        } else {
          print('token request failed');
          print('Response status code: ${response.statusCode}');
          _validationError = "salah";
        }
      } else if (selectedRole == "Lender") {
        print("belum ada lender");
      }
    }
    callback();
  }
}

class RoleProvider with ChangeNotifier {
  String _selectedRole = 'Borrower';

  String get selectedRole => _selectedRole;

  set selectedRole(String value) {
    _selectedRole = value;
    notifyListeners();
  }
}

class MyDropdownWidget extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String?> onChanged;

  MyDropdownWidget({
    required this.options,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedOption,
      onChanged: onChanged,
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var formBorrowerLogin = FormBorrowerLogin();
  // Retrieve the token from SharedPreferences
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // String? token = prefs.getString('token');
  String? token = await formBorrowerLogin.getToken();

  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.token}) : super(key: key);
  final String? token;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FormBorrower()),
        ChangeNotifierProvider(create: (context) => FormUmkm()),
        ChangeNotifierProvider(create: (context) => FormBorrowerLogin()),
        ChangeNotifierProvider(create: (context) => SakuProvider()),
        ChangeNotifierProvider(create: (context) => IsiProvider()),
        ChangeNotifierProvider(create: (context) => CairProvider()),
        ChangeNotifierProvider(create: (context) => RoleProvider()),
        ChangeNotifierProvider(create: (context) => BorrowerPageProvider()),
        ChangeNotifierProvider(create: (context) => FormAjukan()),
      ],
      child: Consumer<FormBorrowerLogin>(
        builder: (context, formBorrowerLogin, _) {
          if (token != null) {
            if (JwtDecoder.isExpired(token!)) {
              return MaterialApp(
                home: const HalamanUtama(),
              );
            } else {
              return MaterialApp(
                home: const BorrowerPage(),
              );
            }
          } else {
            // Token is not available, navigate to login/register screen
            return MaterialApp(
              home: const HalamanUtama(),
            );
          }
        },
        // child: const HalamanUtama(),
      ),
    );
  }
}

class HalamanUtama extends StatelessWidget {
  const HalamanUtama({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final formBorrowerLogin =
        Provider.of<FormBorrowerLogin>(context, listen: false);

    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.teal),
        title: "Modal In | Login",
        home: Scaffold(
            body: Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Center(
                child: Text(
              "Modal In",
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            )),
            Center(
                child: Text(
              "Lorem ipsum dolor sit amet.",
              style: TextStyle(fontSize: 25),
            )),
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Center(
                  child: Text(
                "Silahkan login menggunakan akun Modal In anda",
                style: TextStyle(fontSize: 17),
              )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: TextField(
                onChanged: formBorrowerLogin.setEmail,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: TextField(
                obscureText: true,
                onChanged: formBorrowerLogin.setPassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Consumer<RoleProvider>(
                builder: (context, roleProvider, _) {
                  return MyDropdownWidget(
                    options: ['Borrower', 'Lender'],
                    selectedOption: roleProvider.selectedRole,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        roleProvider.selectedRole = newValue;
                        selectedRole = newValue;
                        // print('Selected Role: ${roleProvider.selectedRole}');
                      }
                    },
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    // Add your text click logic here
                  },
                  child: Text(
                    'Lupa password?',
                    style: TextStyle(fontSize: 17, color: Colors.grey),
                  ),
                )),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        formBorrowerLogin.submitForm(() {
                          if (formBorrowerLogin.validationError == 'kosong') {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Warning'),
                                  content: Text('Mohon isi semua data'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                      child: Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                            // final snackBar = SnackBar(
                            //   content: Text('Mohon isi semua data'),
                            //   action: SnackBarAction(
                            //     label: 'Close',
                            //     onPressed: () {
                            //       // Kode yang akan dijalankan saat tombol snackbar ditekan
                            //       ScaffoldMessenger.of(context)
                            //           .hideCurrentSnackBar();
                            //     },
                            //   ),
                            // );
                            // ScaffoldMessenger.of(context)
                            //     .showSnackBar(snackBar);
                          } else if (formBorrowerLogin.validationError ==
                              'tidak ada') {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Warning'),
                                  content: Text(
                                      'Pengguna tidak ditemukan, pastikan anda sudah memiliki akun'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                      child: Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else if (formBorrowerLogin.validationError ==
                              'salah') {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Warning'),
                                  content: Text(
                                      'Gagal melakukan login, pastikan email dan password yang anda input benar'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                      child: Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return BorrowerPage();
                            }));
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          minimumSize: Size(100, 50),
                          backgroundColor: Color.fromRGBO(32, 106, 93, 1),
                          foregroundColor: Colors.white),
                      child: Text(
                        'MASUK',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Center(
                  child: Text(
                "Belum memiliki akun?",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        // Add your button 1 press logic here
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          minimumSize: Size(50, 90),
                          backgroundColor: Color.fromRGBO(32, 106, 93, 1),
                          foregroundColor: Colors.white),
                      child: Column(
                        children: [
                          Text(
                            'Daftar Sebagai',
                            style: TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            'Pendana',
                            style: TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '(Lender)',
                            style: TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.w700),
                          ),
                        ],
                      )),
                  Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return RegisterBorrower();
                          }));
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            minimumSize: Size(50, 90),
                            backgroundColor: Color.fromRGBO(32, 106, 93, 1),
                            foregroundColor: Colors.white),
                        child: Column(
                          children: [
                            Text(
                              'Daftar Sebagai',
                              style: TextStyle(
                                  fontSize: 15.0, fontWeight: FontWeight.w400),
                            ),
                            Text(
                              'Peminjam',
                              style: TextStyle(
                                  fontSize: 15.0, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '(Borrower)',
                              style: TextStyle(
                                  fontSize: 15.0, fontWeight: FontWeight.w700),
                            ),
                          ],
                        )),
                  ),
                ],
              ),
            )
          ]),
        )));
  }
}
