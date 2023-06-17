import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../activity/borrower-activity.dart';
import '../wallet/borrower-wallet.dart';
import '../account/borrower-account.dart';
import 'borrower-ajukan-pinjaman.dart';
import 'borrower-tutorial-pinjaman.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:intl/intl.dart';

// class BorrowerPageProvider extends ChangeNotifier {
//   bool _isDataFetched = false;
//   String? _token = "";
//   String _status = "";
//   int _dana_terkumpul = 0;
//   int _sisa_hari = 0;
//   int _besar_biaya = 0;

//   int get dana_terkumpul => _dana_terkumpul;
//   int get sisa_hari => _sisa_hari;
//   int get besar_biaya => _besar_biaya;

//   String get status => _status;
//   void setDataFetched(bool value) {
//     _isDataFetched = value;
//   }

//   Future<void> logout() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('token');
//     await prefs.remove('status');
//     notifyListeners();
//   }

//   Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }

// Future<void> fetchData() async {
//   if (_isDataFetched) {
//     // Data has already been fetched, no need to fetch again
//     return;
//   }
//   _token = await getToken();
//   final url = Uri.parse('http://127.0.0.1:8000/borrower/me/');
//   final url2 = Uri.parse('http://127.0.0.1:8000/borrower/market/');
//   final url3 = Uri.parse('http://127.0.0.1:8000/borrower/ajuan/');

//   final response = await http.get(url, headers: {
//     'Authorization': 'Bearer $_token',
//   });
//   final response2 = await http.get(url2, headers: {
//     'Authorization': 'Bearer $_token',
//   });
//   final response3 = await http.get(url3, headers: {
//     'Authorization': 'Bearer $_token',
//   });
//   if (response.statusCode == 200 &&
//       response2.statusCode == 200 &&
//       response3.statusCode == 200) {
//     // Parse the response and extract the saku data
//     _isDataFetched = true;
//     final data = json.decode(response.body);
//     final data2 = json.decode(response2.body);
//     final data3 = json.decode(response3.body);

//     _status = data['status'];
//     if (_status == "diterima") {
//       _dana_terkumpul = data2['dana_terkumpul'];
//       String tenggattemp = data2['tenggat_pendanaan'];
//       DateTime tenggat_pendanaan = DateTime.parse(tenggattemp);
//       // print("berhasil market");
//       DateTime currentDate = DateTime.now();
//       Duration jarakhari = tenggat_pendanaan.difference(currentDate);

//       _sisa_hari = jarakhari.inDays;
//       _sisa_hari += 1;

//       _besar_biaya = data3['besar_biaya'];

//       // print(_sisa_hari);
//     }

//     // print(_status);

//     notifyListeners();
//   } else {
//     // Handle error case if needed
//     throw Exception('Failed to fetch saku data');
//   }
// }

//}
class BorrowerPageProvider extends ChangeNotifier {
  bool _isDataFetched = false;
  String? _token = "";
  String _status = "";
  String _nama = "";
  int _dana_terkumpul = 0;
  int _sisa_hari = 0;
  int _besar_biaya = 0;

  int get dana_terkumpul => _dana_terkumpul;
  int get sisa_hari => _sisa_hari;
  int get besar_biaya => _besar_biaya;
  String get status => _status;
  String get nama => _nama;

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
    final url = Uri.parse('http://127.0.0.1:8000/borrower/me/');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $_token',
    });

    if (response.statusCode == 200) {
      // Parse the response and extract the saku data
      print("fetch user");
      final data = json.decode(response.body);
      _status = data['status'];
      _nama = data['nama'];
      _isDataFetched = true;
      if (_status == "diterima") {
        final url2 = Uri.parse('http://127.0.0.1:8000/borrower/market/');
        final response2 = await http.get(url2, headers: {
          'Authorization': 'Bearer $_token',
        });
        if (response2.statusCode == 200) {
          final data2 = json.decode(response2.body);
          _dana_terkumpul = data2['dana_terkumpul'];
          String tenggaltemp = data2['tenggat_pendanaan'];
          DateTime tenggat_pendanaan = DateTime.parse(tenggaltemp);
          // print("berhasil market");
          DateTime currentDate = DateTime.now();
          Duration jarakhari = tenggat_pendanaan.difference(currentDate);

          _sisa_hari = jarakhari.inDays;
          _sisa_hari += 1;
          final url3 = Uri.parse('http://127.0.0.1:8000/borrower/ajuan/');
          final response3 = await http.get(url3, headers: {
            'Authorization': 'Bearer $_token',
          });
          if (response3.statusCode == 200) {
            final data3 = json.decode(response3.body);
            _besar_biaya = data3['besar_biaya'];
          } else {
            print("gagal fetch ajuan");
          }

          // print(_sisa_hari);
        } else {
          print("gagal fetch market");
        }
      }

      // print(_status);

      notifyListeners();
    } else {
      // Handle error case if needed
      throw Exception('Failed to fetch saku data');
    }
  }
}

class BorrowerPage extends StatefulWidget {
  const BorrowerPage({Key? key}) : super(key: key);
  @override
  BorrowerPageState createState() {
    return BorrowerPageState();
  }
}

class BorrowerPageState extends State<BorrowerPage> {
  List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    pages = [
      HomePage(),
      ActivityPage(),
      WalletPage(), // Pass the id value to WalletPage
      AccountPage(),
    ];
  }

  int idx = 0; //index yang aktif
  void onItemTap(int index) {
    var borrowerPageProvider =
        Provider.of<BorrowerPageProvider>(context, listen: false);
    var sakuProvider = Provider.of<SakuProvider>(context, listen: false);
    var borrowerAccountProvider =
        Provider.of<BorrowerAccountProvider>(context, listen: false);

    setState(() {
      borrowerPageProvider.setDataFetched(false);
      sakuProvider.setDataFetched(false);
      borrowerAccountProvider.setDataFetched(false);
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
      routes: {
        '/sec': (context) => AjukanPinjamanPage(),
        '/third': (context) => TutorialPinjaman(),
      },
    );
  }
}

class ButtonNotification extends StatelessWidget {
  const ButtonNotification({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borrowerPageProvider = Provider.of<BorrowerPageProvider>(context);
    return IconButton(
      icon: Icon(Icons.circle_notifications, color: Colors.black, size: 30),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationPage()),
        );
      },
    );
  }
}

class NotificationPage extends StatelessWidget {
  // const NotificationPage({Key? key}) : super(key: key);

  final List<String> notificationImages = [
    'assets/images/checkmark.png',
    'assets/images/profile-image.jpg',
    'assets/notification_image_3.png',
    // 'assets/notification_image_4.png',
    // 'assets/notification_image_5.png',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Page'),
        backgroundColor: Color.fromRGBO(32, 106, 93, 1),
      ),
      body: ListView.builder(
        itemCount: 3, // Jumlah notifikasi dalam daftar
        itemBuilder: (context, index) {
          String notificationTitle = '';
          String notificationDescription = '';
          String jam = '';

          if (index == 0) {
            notificationTitle = 'Pembaruan Pengajuan';
            notificationDescription = 'Berhasil daftar';
          } else if (index == 1) {
            notificationTitle = 'Pemohonan Pengajuan';
            notificationDescription = 'Dalam pengajuan';
          } else if (index == 2) {
            notificationTitle = 'Pengajuan dibatalkan';
            notificationDescription = 'Ditolak';
          } else {
            notificationDescription = 'Deskripsi notifikasi $index';
          }

          return InkWell(
            onTap: () {
              // Arahkan ke halaman lain di sini
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetailPage()),
              );
            },
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(
                      notificationImages[index]), // Gambar notifikasi
                ),
                title: Text(notificationTitle), // Teks notifikasi
                subtitle: Text(notificationDescription), // Deskripsi notifikasi
                trailing: Text(jam), // Jam
              ),
            ),
          );
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Page'),
      ),
      body: Center(
        child: Text('Halaman Detail'),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borrowerPageProvider = Provider.of<BorrowerPageProvider>(context);

    // borrowerPageProvider.fetchData();
    // Provider.of<BorrowerPageProvider>(context, listen: false).fetchData();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: RichText(
          text: TextSpan(
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
                text: '${borrowerPageProvider.nama}',
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
        actions: <Widget>[
          ButtonNotification(),
        ],
      ),
      body: FutureBuilder(
          future: Provider.of<BorrowerPageProvider>(context, listen: false)
              .fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                children: [
                  if (borrowerPageProvider.status != "diterima") ...[
                    // ElevatedButton(
                    //   onPressed: () {
                    //     borrowerPageProvider.setDataFetched(false);
                    //     borrowerPageProvider.logout();
                    //     Navigator.of(context)
                    //         .push(MaterialPageRoute(builder: (context) {
                    //       return LoginPage();
                    //     }));
                    //   },
                    //   child: const Text('Logout'),
                    // ),
                    if (borrowerPageProvider.status == "selesai") ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            // decoration: BoxDecoration(border: Border.all()),
                            padding: EdgeInsets.only(top: 15),
                            child: Text(
                              'Rencanakan',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 15),
                            child: Text(
                              ' Masa',
                              style: TextStyle(
                                  color: Color.fromRGBO(32, 106, 93, 1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 3),
                            child: Text(
                              'depan',
                              style: TextStyle(
                                  color: Color.fromRGBO(32, 106, 93, 1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 3),
                            child: Text(
                              ' Bisnismu',
                              style: TextStyle(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            // decoration: BoxDecoration(border: Border.all()),
                            padding: const EdgeInsets.all(14),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      borrowerPageProvider
                                          .setDataFetched(false);
                                      Navigator.pushNamed(context, '/sec');
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              25), // Mengatur sudut melengkung
                                        ),
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Color.fromRGBO(32, 106, 93, 1)),
                                      minimumSize: MaterialStateProperty.all(
                                          Size(290, 50)),
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.all(17)),
                                    ),
                                    child: Text('AJUKAN PINJAMAN',
                                        style: TextStyle(
                                            fontSize: 17, color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if (borrowerPageProvider.status == "mengajukan") ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            // decoration: BoxDecoration(border: Border.all()),
                            padding: EdgeInsets.only(top: 15),
                            child: Text(
                              'Mohon Tunggu,',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 15),
                            child: Text(
                              ' Ajuanmu',
                              style: TextStyle(
                                  color: Color.fromRGBO(32, 106, 93, 1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 3, bottom: 50),
                            child: Text(
                              ' Sedang Diproses...',
                              style: TextStyle(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30),
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            top: 3,
                            left: 15,
                          ),
                          // decoration: BoxDecoration(border: Border.all()),
                          //  padding: EdgeInsets.all(10),
                          child: Text(
                            'Bingung cara',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 25),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 3, left: 15),
                          // decoration: BoxDecoration(border: Border.all()),
                          //  padding: EdgeInsets.all(10),
                          child: Text(
                            'Memulai pinjaman?',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 25),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 17),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          // decoration: BoxDecoration(border: Border.all()),
                          padding: const EdgeInsets.all(14),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    borrowerPageProvider.setDataFetched(false);

                                    Navigator.pushNamed(context, '/third');
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
                                      Color.fromRGBO(32, 106, 93, 1),
                                    ),
                                    minimumSize: MaterialStateProperty.all(
                                        Size(290, 50)),
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.all(17)),
                                  ),
                                  child: Text('CARA MELAKUKAN PINJAMAN',
                                      style: TextStyle(
                                          fontSize: 17, color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 3, left: 15),
                          // decoration: BoxDecoration(border: Border.all()),
                          //  padding: EdgeInsets.all(10),
                          child: Text(
                            'Apa kata mereka?',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 25),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 150),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 9,
                          itemBuilder: (BuildContext context, int index) {
                            return Center(
                              child: Container(
                                width: 240,
                                height: 240,
                                margin: EdgeInsets.symmetric(horizontal: 15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          const Color.fromARGB(255, 71, 38, 38)
                                              .withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(5, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}/9',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 80),
                  ] else if (borrowerPageProvider.status == "diterima") ...[
                    // ElevatedButton(
                    //   onPressed: () {
                    //     borrowerPageProvider.setDataFetched(false);
                    //     borrowerPageProvider.logout();
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
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Color.fromRGBO(32, 106, 93, 1), width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding:
                                      EdgeInsets.only(bottom: 10, left: 15),
                                  child: Text(
                                    'Dana Terkumpul',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 15, left: 15, right: 15),
                                child: LinearPercentIndicator(
                                  lineHeight: 20,
                                  percent: borrowerPageProvider.dana_terkumpul /
                                      borrowerPageProvider.besar_biaya,
                                  progressColor: Colors.green,
                                  backgroundColor: Colors.grey.shade300,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 15, left: 15, right: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Rp ${borrowerPageProvider.dana_terkumpul}',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color.fromRGBO(0, 177, 71, 1)),
                                  ),
                                  Text(
                                    '${borrowerPageProvider.sisa_hari} hari lagi',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                            // SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                borrowerPageProvider.setDataFetched(false);
                                Navigator.of(context)
                                    .pushNamed("/pencairanDana");
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
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.all(17)),
                              ),
                              child: Text('Cairkan Dana',
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.white)),
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
                            'Sisa Pembayaran',
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
                        child: InkWell(
                          onTap: () {
                            // Navigator.of(context).pushNamed("/detailsMarket");
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(16, 5, 16, 7),
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            // decoration: BoxDecoration(
                            //   border: Border.all(
                            //       color: Color.fromRGBO(32, 106, 93, 1), width: 1),
                            //   borderRadius: BorderRadius.circular(10),
                            // ),
                            child: Row(children: [
                              Icon(
                                Icons.attach_money,
                                color: Color.fromRGBO(32, 106, 93, 1),
                                size: 60,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(
                                      "Rp 2.000.00,00",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.only(left: 20),
                                  //   child: Text(
                                  //     "dd-mm-yyyy",
                                  //     style: TextStyle(
                                  //         color: Colors.black,
                                  //         fontWeight: FontWeight.w100,
                                  //         fontSize: 11),
                                  //   ),
                                  // ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 20, top: 5),
                                    child: Text(
                                      "Sudah membayar Rp 1.200.000,00",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(
                                      "dari total Rp 3.200.000,00",
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
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 3, left: 22),
                          child: Text(
                            'Jadwal Pembayaran',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          width: 370,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 240, 241, 212),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Text(
                                    'Tenggat Bayar Sebelum dd-mm-yyyy',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 19, 95, 22),
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 10),
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Aksi ketika tombol ditekan
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: const Color.fromARGB(
                                        255, 247, 247, 247),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                          color: const Color.fromARGB(
                                              255, 19, 83, 21)),
                                    ),
                                    minimumSize: Size(80, 40),
                                  ),
                                  child: Text(
                                    'Bayar',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ]
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}
