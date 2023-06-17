import 'package:flutter/material.dart';
import '../home/borrower-home.dart';

class BorrowerSuccessTopup extends StatelessWidget {
  const BorrowerSuccessTopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/checkmark.png',
                width: 150,
                height: 150,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  "ISI SALDO BERHASIL!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                "dd mm yyyy - hh:mmm:ss UTC",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return BorrowerPage();
                }));
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: Colors.transparent,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Pindahkan teks ke kanan
                children: [
                  Text(
                    "Lanjutkan",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.black),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
