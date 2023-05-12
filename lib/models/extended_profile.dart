import 'dart:convert';

import 'package:cookowt/models/app_user.dart';

import 'submodels/height.dart';

class ExtendedProfile {
  int? age;
  int? weight;
  Height? height;
  String? shortBio;
  String? longBio;
  String? userId;
  AppUser? userRef;

  processJsonStringArr(pronounsJson) {
    List<dynamic> pronounList = pronounsJson ?? [];

    List<String> pronounListStr = <String>[];

    for (var element in pronounList) {
      var elementInQuestion = element;

      pronounListStr.add(elementInQuestion);
    }

    return pronounListStr;
  }

  ExtendedProfile(
      {this.age,
      this.height,
      this.weight,
      this.shortBio,
      this.longBio,
      this.userId,
      this.userRef}) {
    age = age;
    height = height;
    weight = weight;
    shortBio = shortBio;
    longBio = longBio;
    userId = userId;
    userRef = userRef;
  }

  ExtendedProfile.fromJson(Map<String, dynamic> json) {
    if (json['age'] != null && json['age'] != "null") {
      if (json['age'] is String) {
        age = double.parse(json["age"]) as int;
      }
      if (json['age'] is int) {
        age = json["age"];
      }
    }
    if (json['weight'] != null && json['weight'] != "null") {
      if (json['weight'] is String) {
        weight = double.parse(json["weight"]) as int;
      }
      if (json['weight'] is int) {
        weight = json["weight"];
      }
    }
    if (json["height"] != null && json["height"] != "null") {
      height = Height.fromJson(json['height']);
    }
    if (json["userRef"] != null && json["userRef"] != "null") {
      userRef = AppUser.fromJson(json['userRef']);
    }

    shortBio = json['shortBio'];
    longBio = json['longBio'];
    userId = json['userId'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['age'] = age;
    data['weight'] = weight;
    data['shortBio'] = shortBio;
    data['longBio'] = longBio;
    data['userId'] = userId;
    data['userRef'] = userRef;
    // data['height'] = height;
    data['height'] = height;
    data['weight'] = weight;
    data['shortBio'] = shortBio;
    data['longBio'] = longBio;
    data['userId'] = userId;
    data['userRef'] = userRef;
    return data;
  }

@override
String toString() {
  return '\n__________Extended Profile_______________\n'
      '\n age:$age '
      '\n weight:$weight '
      '\n height:${height?.feet} ${height?.inches} '
      '\n shortBio:$shortBio '
      '\n longBio:$longBio '
      '\n userId:$userId '
      '\n -----------------------------\n';
}
}
