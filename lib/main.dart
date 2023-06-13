import 'package:flutter/material.dart';
import 'package:tubes_riil/borrower/home/borrower-ajukan-pinjaman.dart';
import 'package:tubes_riil/borrower/wallet/borrower-isi-saldo.dart';
import 'package:tubes_riil/borrower/wallet/borrower-pencairan-dana.dart';
import 'package:tubes_riil/borrower/wallet/borrower-wallet.dart';
import 'login-page.dart';
import './lender/register/lender-register.dart';
import './lender/register/lender-email-verification.dart';
import './lender/success-notice/lender-success-account.dart';
import './lender/home/lender-navigation.dart';
import './borrower/register/borrower-register.dart';
import './borrower/register/borrower-email-verification.dart';
import './borrower/register/borrower-form-umkm.dart';
import './borrower/success-notice/borrower-success-account.dart';
import './borrower/home/borrower-home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class MainProvider extends ChangeNotifier {
  String _token = "";

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var mainProvider = MainProvider();
  String? token = await mainProvider.getToken();

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
                home: const LoginPage(),
              );
            } else {
              return MaterialApp(
                home: const BorrowerPage(),
              );
            }
          } else {
            // Token is not available, navigate to login/register screen
            return MaterialApp(
              home: const LoginPage(),
            );
          }
        },
      ),
    );
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: const LoginPage(),
    //   initialRoute: '/loginPage',
    //   routes: {
    //     '/loginPage': (context) => LoginPage(),
    //     /* REGISTER LENDER */
    //     '/registerLender': (context) => RegisterLender(),
    //     '/emailVerifLender': (context) => EmailVerificationLender(),
    //     '/successAccLender': (context) => LenderSuccessAccount(),
    //     /* LENDER HOME */
    //     '/lenderPage': (context) => LenderPage(),
    //     /* REGISTER BORROWER */
    //     '/registerBorrower': (context) => RegisterBorrower(),
    //     // '/emailVerifBorrower': (context) =>
    //     //     EmailVerificationBorrower(email: '', token: token!),
    //     // '/formUMKM': (context) => FormulirUMKM(),
    //     '/successAccBorrower': (context) => BorrowerSuccessAccount(),
    //     /* BORROWER HOME */
    //     '/borrowerPage': (context) => BorrowerPage(),
    //   },
    // );
  }
}
