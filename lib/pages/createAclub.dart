import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flitter/models/userModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../variables.dart';


class CreateAClub extends StatefulWidget {


  @override
  _CreateAClubState createState() => _CreateAClubState();
}

class _CreateAClubState extends State<CreateAClub> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _speakerController = TextEditingController();
  List<String> categories = [];
   List<Map> speakers = [];
  DateTime _dateTime;
  String type = "private";
  var username;
  var phone;
  var profilepic;


  @override
  void initState() { 
  fetchCategories();
  getcurrentuserinfo();
    super.initState();
    
  }

  @override
  void dispose() { 
    _titleController.dispose();
    super.dispose();
  }

  Future fetchCategories()async{
    FirebaseFirestore.instance.collection('categories').get().then((value) {
    value.docs.forEach((element) { 
      categories.add(element.data()['title']);
    });

    setState(() {
      
    });

    });
  }


  getcurrentuserinfo() async {
    var firebaseuser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userdoc = await usercollection.doc(firebaseuser.uid).get();
    setState(() {
      username = userdoc.data()['username'];
      profilepic = userdoc.data()['profilepic'];
      phone = userdoc.data()['phone'];
    });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff1efe5),
      appBar: AppBar(
        backgroundColor:Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text("Create your Club",style: TextStyle(color: Colors.black),),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  validator: (value){
                    if(value==''){
                      return "Field is required";
                    }
                    return null;
                  },
                  controller:_titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Discussion Topic/Title"
                  ),
                ),

                
          

                SizedBox(height: 20,),
                Row(
                children: [
                   Expanded(child: TextField(
                      keyboardType: TextInputType.phone,
                      controller: _speakerController,
                      decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Invtite Speakers (optional)",
                      helperText: "eg : +918723****2"
                      ),
                   )),
                   SizedBox(width: 10,),
                   ElevatedButton(onPressed: (){
                        FirebaseFirestore.instance.collection("users").where('phone',isEqualTo:_speakerController.text).get().then((value){
                        
                            if(value.docs.length > 0){
                               print("hey");
                               speakers.add({
                                 'name':value.docs.first.data()['username'],
                                 'phone':_speakerController.text
                               });
                               setState(() {
                                 
                               });
                           
                            }else{
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red,content: Text("No User Found",style: TextStyle(color: Colors.white),)));

                            }
                        });
                    
                    }, child: Text("Add"))
                ],),
                SizedBox(
                height: 30,),
                
          
                ...speakers.map((user){
                  var name = user.values.first;
                  var phone = user.values.last;
                  return ListTile(
                  leading: Icon(Icons.person),
                  title: Text(name),
                  subtitle: Text(phone),
                  );
                }),

                Text("Select Date Time below",style: TextStyle(),),

                SizedBox(
                height: 180,
                  child: CupertinoDatePicker(
                  initialDateTime: DateTime.now(),
                  mode: CupertinoDatePickerMode.dateAndTime,
                  onDateTimeChanged: (DateTime dateTime){
                      if(dateTime == Null){
                          Fluttertoast.showToast(
                                    msg: "Pls select the valid date and time",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white
                                    ,
                                    fontSize: 16.0
                                    );
                      }
                      else{
                      setState(() {
                        _dateTime = dateTime;
                      });
                      }
                  }),
                ),

                SizedBox(height: 15,),
                Row(
                  children: [
                    Text("Discussion Type: "),
                    Radio(value: "private", groupValue: type, onChanged: (value){
                      setState(() {
                        type = value;
                      });
                    }),
                    Text("Private",style: TextStyle(fontSize: 16),),
                      Radio(value: "public", groupValue: type, onChanged: (value){
                      setState(() {
                        type = value;
                      });
                    }),
                    Text("Public",style: TextStyle(fontSize: 16),),
                  ],
                ),

                SizedBox(height: 30,),

                Row(
                  children: [
                    Expanded(child: ElevatedButton(onPressed: ()async{
                      if(_formKey.currentState.validate()){
                        _formKey.currentState.save();
                        print(phone);
                        speakers.insert(0,{
                          'name':username,
                          'phone':phone
                        });

                        await FirebaseFirestore.instance.collection('clubs').add({
                          'title':_titleController.text,
                          'createdBy':phone,
                          'invited':speakers,
                          'createdOn':DateTime.now(),
                          'dateTime':_dateTime,
                          'type':type,
                          'status':'new' // new,ongoing,finished,cancelled
                        });
                        Navigator.pop(context);
                      }
                    }, child: Text("Create"))),
                  ],
                )                      

              ],
            )),
          ),
      ),
      
    );
  }
}