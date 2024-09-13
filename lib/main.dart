import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/user_state.dart';


void main() {

  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
 

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot)
      {
        if(snapshot.connectionState == ConnectionState.waiting)
        {
          return MaterialApp
          (
            home: Scaffold(
              body: Center(
                child: Text('freelancer App is being initialized',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
                ),
              ),
            ),
          );
        }
        else if(snapshot.hasError)
        {
          return MaterialApp
          (
            home: Scaffold(
              body: Center(
                child: Text('An error has been occured',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Signatra'
                ),
                ),
              ),
            ),
          );
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'freelancer App',
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.black,
            primarySwatch: Colors.blue,
          ),
          home: UserState(),
        );
      }
    );
    
    
  }
}

