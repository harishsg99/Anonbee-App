import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flitter/pages/profile.dart';
import 'package:flitter/pages/search.dart';
import 'package:flitter/pages/tweets.dart';
import 'package:flitter/pages/homeScreen.dart';
import 'package:flitter/utils/variables.dart';
import '../models/userModel.dart';

class HomePage extends StatefulWidget {
 
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int page = 0;
  List a;
  List  pageoptions = [
  TweetsPage(),
  SearchPage(),
  HomeScreen(),
  ProfilePage(),
];
 


  Widget build(BuildContext context) {
    return Scaffold(
      
      body: pageoptions[page],
      bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              page = index;
            });
          },
          backgroundColor:Colors.black ,
          selectedItemColor: Colors.lightBlue,
          unselectedItemColor: Colors.yellowAccent,
          type: BottomNavigationBarType.fixed,
          currentIndex: page,
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  size: 32,
                  color: Colors.yellowAccent,
                  
                ),
                title: Text(
                  "Feeds",
                  style: mystyle(20),
                )),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.search,
                  size: 32,
                  color: Colors.yellowAccent,
                ),
                title: Text(
                  "Search",
                  style: mystyle(20),
                )),
                            BottomNavigationBarItem(
                icon: Icon(
                  Icons.group,
                  size: 32,
                  color: Colors.yellowAccent,
                ),
                title: Text(
                  "Clubs",
                  style: mystyle(20),
                )),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                  size: 32,
                  color: Colors.yellowAccent,
                ),
                title: Text(
                  "Profile",
                  style: mystyle(20),
                ))
          ]),
    );
  }
}
