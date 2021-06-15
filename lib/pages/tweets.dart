import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flitter/addtweet.dart';
import 'package:flitter/comment.dart';
import 'package:flitter/utils/variables.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TweetsPage extends StatefulWidget {
  @override
  _TweetsPageState createState() => _TweetsPageState();
}

class _TweetsPageState extends State<TweetsPage> {
  String uid;
  initState() {
    super.initState();
    getcurrentuseruid();
  }

  getcurrentuseruid() async {
    var firebaseuser = FirebaseAuth.instance.currentUser;
    setState(() {
      uid = firebaseuser.uid;
    });
  }

  likepost(String documentid) async {
    var firebaseuser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot doc = await tweetcollection.doc(documentid).get();

    if (doc.data()['likes'].contains(firebaseuser.uid)) {
      tweetcollection.doc(documentid).update({
        'likes': FieldValue.arrayRemove([firebaseuser.uid])
      });
    } else {
      tweetcollection.doc(documentid).update({
        'likes': FieldValue.arrayUnion([firebaseuser.uid])
      });
    }
  }

  sharepost(String documentid, String tweet) async {
    Share.text('Flitter', tweet, 'text/plain');
    DocumentSnapshot doc = await tweetcollection.doc(documentid).get();
    tweetcollection
        .doc(documentid)
        .update({'shares': doc.data()['shares'] + 1});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddTweet())),
          child: Icon(Icons.add, size: 32,color: Colors.yellowAccent,),
        ),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.yellowAccent,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'AnonBee',
                style: mystyle(20, Colors.yellowAccent, FontWeight.w700),
              ),
              SizedBox(
                width: 5.0,
              ),
            ],
          ),
        ),
        body: StreamBuilder(
            stream: tweetcollection.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot tweetdoc = snapshot.data.docs[index];
                    return Card(
                      child: ListTile(
                        tileColor: Colors.black,
                        leading: CircleAvatar(
                          backgroundColor: Colors.black,
                          backgroundImage:
                              CachedNetworkImageProvider(tweetdoc.data()['profilepic']),
                        ),
                        title: Text(
                          tweetdoc.data()['username'],
                          style: mystyle(20, Colors.yellowAccent, FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (tweetdoc.data()['type'] == 1)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  tweetdoc.data()['tweet'],
                                  style: mystyle(
                                      20, Colors.yellowAccent, FontWeight.w400),
                                ),
                              ),
                            if (tweetdoc.data()['type'] == 2)
                              Image(image: CachedNetworkImageProvider(tweetdoc['image'])),
                            if (tweetdoc.data()['type'] == 3)
                              Column(
                                children: [
                                  Text(
                                    tweetdoc.data()['tweet'],
                                    style: mystyle(
                                        20, Colors.yellowAccent, FontWeight.w400),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Image(
                                      image: CachedNetworkImageProvider(
                                          tweetdoc.data()['image'])),
                                ],
                              ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => CommentPage(
                                                  tweetdoc.data()['id']))),
                                      child: Icon(Icons.comment,color: Colors.yellowAccent,),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      tweetdoc
                                          .data()['commentcount']
                                          .toString(),
                                      style: mystyle(18,Colors.yellowAccent),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () =>
                                          likepost(tweetdoc.data()['id']),
                                      child:
                                          tweetdoc.data()['likes'].contains(uid)
                                              ? Icon(
                                                  Icons.favorite,
                                                  color: Colors.yellowAccent,
                                                )
                                              : Icon(
                                                Icons.favorite_border,
                                                color: Colors.yellowAccent,
                                              ),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      tweetdoc
                                          .data()['likes']
                                          .length
                                          .toString(),
                                      style: mystyle(18,Colors.yellowAccent),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () => sharepost(
                                          tweetdoc.data()['id'],
                                          tweetdoc.data()['tweet']),
                                      child: Icon(Icons.share,color: Colors.yellowAccent),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      tweetdoc.data()['shares'].toString(),
                                      style: mystyle(18,Colors.yellowAccent),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  });
            }));
  }
}
