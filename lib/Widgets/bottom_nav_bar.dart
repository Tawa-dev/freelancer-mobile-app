// ignore_for_file: must_be_immutable, unused_element, unused_local_variable, no_leading_underscores_for_local_identifiers, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/Jobs/jobs_screen.dart';
import 'package:freelancer/Jobs/upload_job.dart';
import 'package:freelancer/Search/profile_company.dart';
import 'package:freelancer/Search/search_companies.dart';
import 'package:freelancer/user_state.dart';

class BottomNavigationBarForApp extends StatelessWidget {

  int indexNum = 0;

  BottomNavigationBarForApp({required this.indexNum});

  void _logout(context)
  {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black54,
          title: Row(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.white, fontSize: 28),
                ),
              ),
            ],
          ),
          content: Text(
            'Do you want to Log Out?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.canPop(context) ? Navigator.pop(context) : null;
              },
              child: Text('No', style: TextStyle(color: Colors.green, fontSize: 18),),
            ),
            TextButton(
              onPressed: () {
                _auth.signOut();
                Navigator.canPop(context) ? Navigator.pop(context) : null;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UserState()));
              },
              child: Text('Yes', style: TextStyle(color: Colors.green, fontSize: 18),),
            ),
          ],
        );
      },
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      color: Colors.deepOrange.shade400,
      backgroundColor: Colors.blueAccent,
      buttonBackgroundColor: Colors.deepOrange.shade300,
      height: 50,
      index: indexNum,
      items: [
        Icon(Icons.list, size: 19, color: Colors.black,),
        Icon(Icons.search, size: 19, color: Colors.black,),
        Icon(Icons.add, size: 19, color: Colors.black,),
        Icon(Icons.person_pin, size: 19, color: Colors.black,),
        Icon(Icons.exit_to_app, size: 19, color: Colors.black,),
        
      ],
      animationDuration: Duration(
        microseconds: 300,
      ),
      animationCurve: Curves.bounceInOut,
      onTap: (index) 
      {
        if(index == 0)
        {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => JobScreen()));
        }
        else if(index == 1)
        {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AllWorkersScreen()));
        }
        else if(index == 2)
        {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UploadJobNow()));
        }
        else if(index == 3)
        {
          final FirebaseAuth _auth = FirebaseAuth.instance;
          final User? user = _auth.currentUser;
          final String uid = user!.uid;
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen(
            userID: uid,
           )));
        }
        else if(index == 4)
        {
           _logout(context);
        }
      },
    );
  }
}