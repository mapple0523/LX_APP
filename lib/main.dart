import 'dart:async';

import 'package:dtwms_app/pages/common/splash.dart';
import 'package:dtwms_app/pages/inn/INN0001M.dart';
import 'package:dtwms_app/pages/inn/INN0002M.dart';
import 'package:dtwms_app/pages/inn/INN0003M.dart';
import 'package:dtwms_app/pages/inn/INN0004M.dart';
import 'package:dtwms_app/pages/inn/INN0004MP02.dart';
import 'package:dtwms_app/pages/inn/INN0005M.dart';
import 'package:dtwms_app/pages/inn/INN0005MP02.dart';
import 'package:dtwms_app/pages/inn/INN0006M.dart';
import 'package:dtwms_app/pages/inn/INN0007M.dart';
import 'package:dtwms_app/pages/inn/INN0008M.dart';
import 'package:dtwms_app/pages/inn/OUT0011M.dart';
import 'package:dtwms_app/pages/mdm/MDM0001M.dart';
import 'package:dtwms_app/pages/out/OUT0001M.dart';
import 'package:dtwms_app/pages/out/OUT0001P05.dart';
import 'package:dtwms_app/pages/out/OUT0002M.dart';
import 'package:dtwms_app/pages/out/OUT0004M.dart';
import 'package:dtwms_app/pages/out/OUT0005M.dart';
import 'package:dtwms_app/pages/out/OUT0005P01.dart';
import 'package:dtwms_app/pages/out/OUT0006M.dart';
import 'package:dtwms_app/pages/out/OUT0006P02.dart';
import 'package:dtwms_app/pages/out/OUT0007M.dart';
import 'package:dtwms_app/pages/out/OUT0008M.dart';
import 'package:dtwms_app/pages/out/OUT0009M.dart';
import 'package:dtwms_app/pages/out/OUT0009P02.dart';
import 'package:dtwms_app/pages/out/OUT0010M.dart';
import 'package:dtwms_app/pages/out/OUT0012P01.dart';
// import 'package:dtwms_app/pages/out/OUT0003M.dart';
import 'package:dtwms_app/pages/stk/STK0001M.dart';
import 'package:dtwms_app/pages/stk/STK0002M.dart';
import 'package:dtwms_app/pages/stk/STK0003M.dart';
import 'package:dtwms_app/pages/stk/STK0011M.dart';
import 'package:dtwms_app/pages/stk/STK0004M.dart';
import 'package:dtwms_app/pages/stk/STK0005M.dart';
import 'package:dtwms_app/pages/stk/STK0006M.dart';
import 'package:dtwms_app/pages/stk/STK0012M.dart';
import 'package:dtwms_app/pages/sys/AppLocalizations.dart';
import 'package:dtwms_app/pages/sys/Language_constants.dart';
import 'package:dtwms_app/pages/sys/login.dart';
import 'package:dtwms_app/pages/sys/menu.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'commons/constants/constant.dart';
import 'commons/constants/pageConstant.dart';
import 'models/zebraDataWedgeListener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // easylocalization 초기화!
  await EasyLocalization.ensureInitialized();
  runApp(MyApp());
}
class MyApp extends StatefulWidget  {
  const MyApp({Key key}) : super(key: key);
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  //barcode scanner listener run
  ZebraDataWedgeListener listener = ZebraDataWedgeListener();
  StreamSubscription<dynamic> dataWedge;

   Locale _locale;
   setLocale(Locale locale) {
   setState(() {
   _locale = locale;
   });

   @override
   void didChangeDependencies() {
     getLocale().then((locale) {
       setState(() {
         this._locale = locale;
       });
     });
     super.didChangeDependencies();
   }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    if(dataWedge == null) {
      dataWedge = listener.initDataWedgeListener();
    }

    print("main start");
    return MaterialApp(
        title: Constant.appTitle,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale("en","US"),Locale("ko",""),Locale("zh","CN")],
        locale: _locale,
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: PageConstant.routeNameSplash,
        onGenerateRoute: (settings) {

          switch (settings.name) {
            case PageConstant.routeNameLogin:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: LoginPage()),
                );
              }
              break;
            case PageConstant.routeNameMenu:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: MenuPage()),
                );
              }
              break;
            case PageConstant.routeName_INN0001M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: INN0001M()),
                );
              }
              break;
            case PageConstant.routeName_STK0001M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: STK0001M()),
                );
              }
              break;
            case PageConstant.routeName_STK0002M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: STK0002M()),
                );
              }
              break;
            case PageConstant.routeName_STK0003M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: STK0003M()),
                );
              }
              break;
            case PageConstant.routeName_STK0011M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: STK0011M()),
                );
              }
              break;
            case PageConstant.routeName_STK0004M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: STK0004M()),
                );
              }
              break;
            case PageConstant.routeName_STK0005M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: STK0005M()),
                );
              }
              break;
            case PageConstant.routeName_OUT0001M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: OUT0001P05()),
                );
              }
              break;
            case PageConstant.routeName_INN0002M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: INN0002M()),
                );
              }
              break;
            case PageConstant.routeName_MDM0001M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: MDM0001M()),
                );
              }
              break;
            case PageConstant.routeName_OUT0002M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: OUT0002M()),
                );
              }
              break;
            // case PageConstant.routeName_OUT0003M:
            //   {
            //     return MaterialPageRoute(
            //       builder: (context) =>
            //           SafeArea(child: OUT0003M()),
            //     );
            //   }
            //   break;
            case PageConstant.routeName_STK0006M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: STK0006M()),
                );
              }
              break;

            case PageConstant.routeName_STK0012M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: STK0012M()),
                );
              }
              break;

            case PageConstant.routeName_STK0012M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: STK0012M()),
                );
              }
              break;

            case PageConstant.routeName_INN0003M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: INN0003M()),
                );
              }
              break;

            case PageConstant.routeName_INN0004M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: INN0004MP02()),
                );
              }
              break;

            case PageConstant.routeName_INN0005M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: INN0005MP02()),
                );
              }
              break;

            case PageConstant.routeName_OUT0004M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: OUT0004M()),
                );
              }
              break;

            case PageConstant.routeName_OUT0005M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: OUT0005P01()),
                );
              }
              break;

            case PageConstant.routeName_OUT0006M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: OUT0006P02()),
                );
              }
              break;

            case PageConstant.routeName_OUT0007M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: OUT0007M()),
                );
              }
              break;

            case PageConstant.routeName_INN0006M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: INN0006M()),
                );
              }
              break;

            case PageConstant.routeName_OUT0008M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: OUT0008M()),
                );
              }
              break;

            case PageConstant.routeName_OUT0009M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: OUT0009P02()),
                );
              }
              break;

            case PageConstant.routeName_OUT0010M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: OUT0010M()),
                );
              }
              break;

            case PageConstant.routeName_INN0007M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: INN0007M()),
                );
              }
              break;

            case PageConstant.routeName_OUT0011M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: OUT0011M()),
                );
              }
              break;
            case PageConstant.routeName_INN0008M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: INN0008M()),
                );
              }
              break;

            case PageConstant.routeName_OUT0012M:
              {
                return MaterialPageRoute(
                  builder: (context) =>
                      SafeArea(child: OUT0012P01()),
                );
              }
              break;

            default:
              {
                return MaterialPageRoute(
                  builder: (context) => SafeArea(child: SplashPage()),
                );
              }
              break;
          }
        }
    );
  }
}
