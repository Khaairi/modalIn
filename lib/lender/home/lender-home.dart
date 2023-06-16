import 'package:flutter/material.dart';
import 'package:tubes_riil/lender/wallet/lender-pencairan-dana.dart';
import 'package:tubes_riil/login-page.dart';
import '../activity/lender-activity.dart';
import '../wallet/lender-wallet.dart';
import '../marketplace/lender-marketplace.dart';
import '../account/lender-account.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class LenderPageProvider extends ChangeNotifier {
  bool _isDataFetched = false;
  String? _token = "";
  int _saku = 0;
  String _status = "";

  String get status => _status;
  int get saku => _saku;

  void setSaku(int value) {
    _saku = value;
  }

  void setDataFetched(bool value) {
    _isDataFetched = value;
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('status');
    notifyListeners();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchData() async {
    if (_isDataFetched) {
      // Data has already been fetched, no need to fetch again
      return;
    }
    _token = await getToken();
    final url = Uri.parse('http://127.0.0.1:8000/lender/me/');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $_token',
    });

    if (response.statusCode == 200) {
      // Parse the response and extract the saku data
      final data = json.decode(response.body);
      _status = data['status'];
      _saku = data['saku'];
      _isDataFetched = true;
      // print(_status);

      notifyListeners();
    } else {
      // Handle error case if needed
      throw Exception('Failed to fetch saku data');
    }
  }
}

class LenderPage extends StatefulWidget {
  const LenderPage({Key? key}) : super(key: key);
  @override
  LenderPageState createState() {
    return LenderPageState();
  }
}

class LenderPageState extends State<LenderPage> {
  List<Widget> pages = [
    HomePage(),
    ActivityPage(),
    MarketplacePage(),
    WalletPage(),
    AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  int idx = 0; //index yang aktif
  void onItemTap(int index) {
    setState(() {
      idx = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Borrower',
      home: Scaffold(
        body: pages[idx],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: idx,
          onTap: onItemTap,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.black),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grading_sharp, color: Colors.black),
              label: 'Activity',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.festival_outlined, color: Colors.black),
              label: 'Marketplace',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet, color: Colors.black),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Colors.black),
              label: 'Account',
            ),
          ],
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
        ),
      ),
    );
  }
}

class ButtonNotification extends StatelessWidget {
  const ButtonNotification({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lenderPageProvider = Provider.of<LenderPageProvider>(context);
    return IconButton(
      icon: Icon(Icons.circle_notifications, color: Colors.black, size: 30),
      onPressed: () {
        lenderPageProvider.setDataFetched(false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationPage()),
        );
      },
    );
  }
}

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Notification Page',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: const Center(
        child: Text(
          'Halaman Notifikasi',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lenderPageProvider = Provider.of<LenderPageProvider>(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Halo, ',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                  ),
                ),
                TextSpan(
                  text: 'pendana',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          actions: const <Widget>[
            ButtonNotification(),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "images/background-opacity.png",
                ),
                fit: BoxFit.fitHeight,
              ),
            ),
            child: Column(
              children: [
                // ElevatedButton(
                //   onPressed: () {
                //     lenderPageProvider.setDataFetched(false);
                //     lenderPageProvider.logout();
                //     Navigator.of(context)
                //         .push(MaterialPageRoute(builder: (context) {
                //       return LoginPage();
                //     }));
                //   },
                //   child: const Text('Logout'),
                // ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Color.fromRGBO(32, 106, 93, 1), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Total Aset Saya',
                          style: TextStyle(
                              color: Color.fromRGBO(32, 106, 93, 1),
                              fontWeight: FontWeight.bold,
                              fontSize: 28),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Rp ${lenderPageProvider.saku}',
                          style: TextStyle(
                              color: Color.fromRGBO(0, 177, 71, 1),
                              fontWeight: FontWeight.normal,
                              fontSize: 20),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return PencairanDanaLender();
                            }));
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    25), // Mengatur sudut melengkung
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromRGBO(32, 106, 93, 1)),
                            minimumSize:
                                MaterialStateProperty.all(Size(290, 50)),
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(17)),
                          ),
                          child: Text('Cairkan Dana',
                              style:
                                  TextStyle(fontSize: 17, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 3, left: 22),
                      child: Text(
                        'Daftar Mitra',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
                if (lenderPageProvider.status != "belum") ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    child: Text("Anda belum memiliki mitra yang didanai",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w300,
                            fontSize: 13)),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 3, left: 22),
                        child: Text(
                          'Rekomendasi Mitra untuk Anda',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      child: Row(children: [
                        for (int i = 0; i < 10; i++)
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed("/detailsMarket");
                            },
                            child: Container(
                              // padding: EdgeInsets.only(left: 10, right: 15, top: 10),
                              margin: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                      child: Image.asset(
                                        'images/banner.jpeg',
                                        height: 100,
                                        width: 200,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, top: 5),
                                      child: Text(
                                        "Nama UMKM",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        "Kategori",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w100,
                                            fontSize: 8),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        "Membutuhkan dana",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 11),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, bottom: 10),
                                      child: Text(
                                        "Rp XX.XXX.XXX,00",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17),
                                      ),
                                    ),
                                  ]),
                            ),
                          )
                      ]),
                    ),
                  ),
                ] else if (lenderPageProvider.status == "sudah") ...[
                  Column(
                    children: [
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 3, left: 22),
                            child: Text(
                              'Progress Pendanaan',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(16, 5, 16, 7),
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color.fromRGBO(32, 106, 93, 1),
                                width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PENDANAAN',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15),
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'HASIL DITERIMA\nRp. 0',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'DANA DIMILIKI\nRp. 0',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'TOTAL PENDANAAN AKTIF\nRp. 0',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      for (int i = 0; i < 5; i++)
                        Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed("/detailsMarket");
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.fromLTRB(16, 5, 16, 7),
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color.fromRGBO(32, 106, 93, 1),
                                      width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(children: [
                                  Icon(
                                    Icons.festival_outlined,
                                    color: Color.fromRGBO(32, 106, 93, 1),
                                    size: 60,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Text(
                                          "Nama UMKM",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Text(
                                          "Kategori",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w100,
                                              fontSize: 11),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, top: 5, bottom: 5),
                                        child: Text(
                                          "Total Pinjaman: Rp. xxx.xxx,00",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  )
                                ]),
                              ),
                            )),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    child: Text("Anda telah mencapai akhir daftar mitra Anda",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w300,
                            fontSize: 13)),
                  )
                ]
              ],
            ),
          ),
        ));
  }
}
