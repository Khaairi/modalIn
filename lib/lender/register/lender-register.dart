import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'lender-email-verification.dart';

class FormLender extends ChangeNotifier {
  String _name = '';
  String _email = '';
  String _password = '';
  String _telp = '';
  String _ktp = 'foto.jpg';
  int _saku = 0;
  String _validationError = '';
  String _token = "";
  int _id = 0;

  String get name => _name;
  String get email => _email;
  String get password => _password;
  String get telp => _telp;
  String get ktp => _ktp;
  int get saku => _saku;
  String get validationError => _validationError;
  String get token => _token;
  int get id => _id;

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setTelp(String value) {
    _telp = value;
    notifyListeners();
  }

  bool validateForm() {
    if (_name.isEmpty || _email.isEmpty || _password.isEmpty || _telp.isEmpty) {
      _validationError = 'kosong';
    } else {
      _validationError = '';
    }
    notifyListeners();
    return _validationError.isEmpty;
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> setStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('status', status);
  }

  void submitForm(void Function() callback) async {
    if (validateForm()) {
      var url = Uri.parse('http://127.0.0.1:8000/lenders/');

      var response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            'nama': _name,
            'email': _email,
            'password': _password,
            'telp': _telp,
            'ktp': _ktp,
            'saku': _saku,
            'status': "belum"
          }));

      if (response.statusCode == 200) {
        print('Post request successful');
        print('Response body: ${response.body}');
        var jsonData = json.decode(response.body);
        _token = jsonData["access_token"];
        await setToken(_token);
        await setStatus("lender");
      } else {
        print('Post request failed');
        print('Response status code: ${response.statusCode}');
        if (response.statusCode == 400) {
          _validationError = 'dipake';
        }
      }
    }
    callback();
  }
}

class RegisterLender extends StatelessWidget {
  const RegisterLender({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formLender = Provider.of<FormLender>(context, listen: false);
    return MaterialApp(
        title: "Modal In | Register Lender",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.teal),
        home: Scaffold(
            // extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Center(
              child: Container(
                // decoration: const BoxDecoration(
                //   image: const DecorationImage(
                //     image: AssetImage(
                //       "images/background-opacity.png",
                //     ),
                //     fit: BoxFit.cover,
                //   ),
                // ),
                child: SingleChildScrollView(
                  child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                "Daftar Sebagai",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Pendana",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(32, 106, 93, 1),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Row(
                              children: [
                                Text(
                                  "Step 1 of 2",
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Text(
                                  "Lengkapi data diri",
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: TextField(
                              onChanged: formLender.setName,
                              decoration: InputDecoration(
                                hintText: 'Nama',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: TextField(
                              onChanged: formLender.setEmail,
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
                              onChanged: formLender.setPassword,
                              obscureText: true,
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
                            child: Row(
                              children: [
                                Text(
                                  "o Password terdiri dari huruf dan angka",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Row(
                              children: [
                                Text(
                                  "o Password terdiri dari huruf kapital",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Row(
                              children: [
                                Text(
                                  "o Password minimal mengandung 8 karakter",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(top: 15),
                          //   child: TextField(
                          //     obscureText: true,
                          //     decoration: InputDecoration(
                          //       hintText: 'Re-type Password',
                          //       border: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(15.0),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: TextField(
                              onChanged: formLender.setTelp,
                              decoration: InputDecoration(
                                hintText: 'No Telephone',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: GestureDetector(
                              onTap: () {
                                // Navigator.pop(context);
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Icon(Icons.image_outlined),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        'Upload Foto KTP',
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.grey.shade600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(top: 10),
                          //   child: Row(
                          //     children: [
                          //       Checkbox(
                          //           value: _isChecked,
                          //           onChanged: (bool? value) {
                          //             setState(() {
                          //               _isChecked = value!;
                          //             });
                          //           },
                          //           activeColor: Colors.blue),
                          //       RichText(
                          //         text: TextSpan(
                          //           children: [
                          //             TextSpan(
                          //               text: 'Saya menyetujui ',
                          //               style: TextStyle(
                          //                   fontSize: 14, color: Colors.black),
                          //             ),
                          //             TextSpan(
                          //               text: 'syarat dan ketentuan',
                          //               style: TextStyle(
                          //                 fontSize: 14,
                          //                 color: Colors.blue,
                          //                 decoration: TextDecoration.underline,
                          //               ),
                          //               recognizer: TapGestureRecognizer()
                          //                 ..onTap = () {
                          //                   // Aksi yang akan dijalankan ketika link diklik
                          //                   print(
                          //                       'Syarat dan Ketentuan diklik');
                          //                 },
                          //             ),
                          //             TextSpan(
                          //               text: ' yang\nberlaku',
                          //               style: TextStyle(
                          //                   fontSize: 14, color: Colors.black),
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 30),
                            child: Row(
                              children: [
                                Spacer(),
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        formLender.submitForm(() {
                                          if (formLender.validationError ==
                                              'kosong') {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Warning'),
                                                  content: Text(
                                                      'Mohon isi semua data'),
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
                                          } else if (formLender
                                                  .validationError ==
                                              'dipake') {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Warning'),
                                                  content: const Text(
                                                      'Email sudah digunakan'),
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
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return EmailVerificationLender(
                                                email: formLender.email,
                                              );
                                            }));
                                          }
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          minimumSize: Size(100, 50),
                                          backgroundColor:
                                              Color.fromRGBO(32, 106, 93, 1),
                                          foregroundColor: Colors.white),
                                      child: Text(
                                        "DAFTAR",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ))
                              ],
                            ),
                          )
                        ],
                      )),
                ),
              ),
            )));
  }
}

// class _RegisterLenderState extends State<RegisterLender> {
//   bool _isChecked = false;

 
// }
