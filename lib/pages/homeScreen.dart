import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flitter/main.dart';
import 'package:flitter/pages/createAClub.dart';
import 'package:flitter/pages/myClubs.dart';
import 'package:flitter/pages/profileScreen.dart';
import 'package:flitter/utils/variables.dart';
import 'package:flitter/widgets/ongoing_club.dart';
import 'package:flitter/widgets/upcoming_club.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flitter/signup.dart';

import 'createAClub.dart';
import 'myClubs.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var username;

  var profilepic;

  bool dataisthere;

  @override
  void initState() { 
    getcurrentuserinfo();
    super.initState();
    
  }
    getcurrentuserinfo() async {
    var firebaseuser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userdoc = await usercollection.doc(firebaseuser.uid).get();
    setState(() {
      username = userdoc.data()['username'];
      profilepic = userdoc.data()['profilepic'];
    });
    }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff1efe5),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
          child: Icon(Icons.add),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateAClub()));
          },
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.mic),
              title: Text("My New Clubs"),
              onTap: (){
                  Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context)=>MyClubsScreen()));
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text("Home",style: TextStyle(color: Colors.black),),
        actions: [
          IconButton(icon: Icon(Icons.power_settings_new_outlined), onPressed: ()async{
            FirebaseAuth.instance.signOut().then((value){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignUp()));
            });

          })
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            OngoingClub(),
            SizedBox(height: 10,),
            Text("Upcoming Week",style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),),
            SizedBox(height: 10,),
            Icon(Icons.arrow_circle_down),
            UpcomingClub()



          ],
        ),
      ),
      
    );
  }
}
