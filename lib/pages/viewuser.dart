import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flitter/comment.dart';
import 'package:flitter/utils/variables.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ViewUser extends StatefulWidget {
  final String uid;
  ViewUser(this.uid);
  @override
  _ViewUserState createState() => _ViewUserState();
}

class _ViewUserState extends State<ViewUser> {
  String onlineuser;
  Stream userstream;
  String username;
  int following;
  int followers;
  String profilepic;
  bool isfollowing;
  String uid = '';
  bool dataisthere = false;
  initState() {
    super.initState();
    getcurrentuseruid();
    getstream();
    getcurrentuserinfo();
  }

  getcurrentuserinfo() async {
    print(widget.uid);
    var firebaseuser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userdoc =
        await usercollection.doc(widget.uid.trim()).get();
    var followersdocuments =
        await usercollection.doc(widget.uid).collection('followers').get();
    var followngdocuments =
        await usercollection.doc(widget.uid).collection('following').get();
    usercollection
        .doc(widget.uid)
        .collection('followers')
        .doc(firebaseuser.uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          isfollowing = true;
        });
      } else {
        setState(() {
          isfollowing = false;
        });
      }
    });
    setState(() {
      uid = firebaseuser.uid;
      username = userdoc.data()['username'];
      following = followngdocuments.docs.length;
      followers = followersdocuments.docs.length;
      profilepic = userdoc.data()['profilepic'];
      dataisthere = true;
    });
  }

  getstream() async {
    setState(() {
      userstream = tweetcollection
          .where('uid', isEqualTo: widget.uid.trim())
          .snapshots();
    });
  }

  getcurrentuseruid() async {
    var firebaseuser = FirebaseAuth.instance.currentUser;
    setState(() {
      onlineuser = firebaseuser.uid;
    });
  }

  followuser() async {
    var doc = await usercollection
        .doc(widget.uid)
        .collection('followers')
        .doc(onlineuser)
        .get();

    if (!doc.exists) {
      usercollection
          .doc(widget.uid)
          .collection('followers')
          .doc(onlineuser)
          .set({});

      usercollection
          .doc(onlineuser)
          .collection('following')
          .doc(widget.uid)
          .set({});
      setState(() {
        followers++;

        isfollowing = true;
      });
    } else {
      usercollection
          .doc(widget.uid)
          .collection('followers')
          .doc(onlineuser)
          .delete();

      usercollection
          .doc(onlineuser)
          .collection('following')
          .doc(widget.uid)
          .delete();
      setState(() {
        followers--;

        isfollowing = false;
      });
    }
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
        body: dataisthere == true
            ? SingleChildScrollView(
                physics: ScrollPhysics(),
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.lightBlue, Colors.purple]),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 6,
                          left: MediaQuery.of(context).size.width / 2 - 64),
                      child: CircleAvatar(
                        radius: 64,
                        backgroundColor: Colors.white,
                        backgroundImage: CachedNetworkImageProvider(profilepic),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 2.7),
                      child: Column(
                        children: [
                          Text(
                            username,
                            style: mystyle(30, Colors.yellowAccent, FontWeight.w600),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Following",
                                style:
                                    mystyle(20, Colors.yellowAccent, FontWeight.w600),
                              ),
                              Text(
                                "Followers",
                                style:
                                    mystyle(20, Colors.yellowAccent, FontWeight.w600),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                following.toString(),
                                style:
                                    mystyle(20, Colors.yellowAccent, FontWeight.w600),
                              ),
                              Text(
                                followers.toString(),
                                style:
                                    mystyle(20, Colors.yellowAccent, FontWeight.w600),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () => followuser(),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2,
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                      colors: [Colors.blue, Colors.lightBlue])),
                              child: Center(
                                child: Text(
                                  isfollowing == false ? "Follow" : "Unfollow",
                                  style: mystyle(
                                      25, Colors.yellowAccent, FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "User Posts",
                            style: mystyle(25, Colors.yellowAccent, FontWeight.w700),
                          ),
                          StreamBuilder(
                              stream: userstream,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return CircularProgressIndicator();
                                }
                                return ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data.docs.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      DocumentSnapshot tweetdoc =
                                          snapshot.data.docs[index];
                                      return Card(
                                        child: ListTile(
                                          tileColor: Colors.black,
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.white,
                                            backgroundImage: CachedNetworkImageProvider(
                                                tweetdoc.data()['profilepic']),
                                          ),
                                          title: Text(
                                            tweetdoc.data()['username'],
                                            style: mystyle(20, Colors.yellowAccent,
                                                FontWeight.w600),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (tweetdoc.data()['type'] == 1)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    tweetdoc.data()['tweet'],
                                                    style: mystyle(
                                                        20,
                                                        Colors.yellowAccent,
                                                        FontWeight.w400),
                                                  ),
                                                ),
                                              if (tweetdoc.data()['type'] == 2)
                                                Image(
                                                    image: CachedNetworkImageProvider(
                                                        tweetdoc['image'])),
                                              if (tweetdoc.data()['type'] == 3)
                                                Column(
                                                  children: [
                                                    Text(
                                                      tweetdoc.data()['tweet'],
                                                      style: mystyle(
                                                          20,
                                                          Colors.yellowAccent,
                                                          FontWeight.w400),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Image(
                                                        image: CachedNetworkImageProvider(
                                                            tweetdoc.data()[
                                                                'image'])),
                                                  ],
                                                ),
                                              SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      InkWell(
                                                        onTap: () => Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    CommentPage(
                                                                        tweetdoc
                                                                            .data()['id']))),
                                                        child:
                                                            Icon(Icons.comment,
                                                            color:
                                                                    Colors.yellowAccent,),
                                                      ),
                                                      SizedBox(
                                                        width: 10.0,
                                                      ),
                                                      Text(
                                                        tweetdoc
                                                            .data()[
                                                                'commentcount']
                                                            .toString(),
                                                        style: mystyle(18,Colors.yellowAccent),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      InkWell(
                                                        onTap: () => likepost(
                                                            tweetdoc
                                                                .data()['id']),
                                                        child: tweetdoc
                                                                .data()['likes']
                                                                .contains(uid)
                                                            ? Icon(
                                                                Icons.favorite,
                                                                color:
                                                                    Colors.yellowAccent,
                                                              )
                                                            : Icon(
                                                              Icons.favorite_border,
                                                              color:Colors.yellowAccent,
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
                                                            tweetdoc
                                                                .data()['id'],
                                                            tweetdoc.data()[
                                                                'tweet']),
                                                        child:
                                                            Icon(Icons.share,
                                                            color:
                                                                    Colors.yellowAccent,),
                                                      ),
                                                      SizedBox(
                                                        width: 10.0,
                                                      ),
                                                      Text(
                                                        tweetdoc
                                                            .data()['shares']
                                                            .toString(),
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
                              })
                        ],
                      ),
                    )
                  ],
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }
}
