import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flitter/pages/viewuser.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flitter/utils/variables.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Future<QuerySnapshot> searchuseresult;
  searchuser(String s) {
    var users =
        usercollection.where('username', isGreaterThanOrEqualTo: s).get();

    setState(() {
      searchuseresult = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.yellowAccent,
          title: TextFormField(
            decoration: InputDecoration(
                filled: true,
                hintText: "Search for users..",
                hintStyle: mystyle(18)),
            onFieldSubmitted: searchuser,
          ),
        ),
        body: searchuseresult == null
            ? Center(
                child: Text(
                  "Search for users....",
                  style: mystyle(30),
                ),
              )
            : FutureBuilder(
                future: searchuseresult,
                builder: (BuildContext context, snapshot) {
                  if (!snapshot.hasData) {
                    Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot user = snapshot.data.docs[index];
                      return Card(
                        elevation: 8.0,
                        child: ListTile(
                          tileColor: Colors.black,
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage:
                                CachedNetworkImageProvider(user.data()['profilepic']),
                          ),
                          title: Text(
                            user.data()['username'],
                            style: mystyle(25,Colors.yellowAccent),
                          ),
                          trailing: InkWell(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ViewUser(user.data()['uid']))),
                            child: Container(
                              width: 90,
                              height: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.yellowAccent),
                              child: Center(
                                child: Text("View", style: mystyle(20)),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ));
  }
}
