import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  String name;
  String uid;
  String email;
  String phone;

  UserModel({this.name,this.email,this.uid,this.phone});

  factory UserModel.fromMap(QueryDocumentSnapshot documentSnapshot){
    return UserModel(
      name: documentSnapshot['username'],
      email: documentSnapshot['email'],
      uid: documentSnapshot['uid'],
      phone: documentSnapshot['phone']
    );
  }


  Map<String,dynamic> toMap(UserModel user)=>{
    'name':user.name,
    'uid':user.uid,
    'email':user.email,
    'phone':user.phone,
  };
}