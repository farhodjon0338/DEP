// ignore_for_file: unused_field

import 'dart:async';

import 'comet_edit.dart';
import 'kirish.dart';
import 'profiledit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_session_manager/flutter_session_manager.dart';

class profil extends StatefulWidget {
  const profil({super.key});

  @override
  State<profil> createState() => _profilState();
}

class _profilState extends State<profil> {
  List<Map<String, dynamic>> dart = [];
  bool isLoading = true;
  dynamic stafid = "";
  late Timer _timer;

  Future<void> dataa() async {
    stafid = await SessionManager().get("Ids");
    try {
      final response = await http
          .get(Uri.parse('https://dash.vips.uz/api/38/1984/29837?id=$stafid'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          dart.clear();
          for (var item in jsonData) {
            dart.add(Map<String, dynamic>.from(item));
          }
          isLoading = false;
        });
      } else {}
    } catch (error) {
      print('Error fetching rasm: $error');
      // setState(() {
      //   isLoading = false;
      // });
    }
  }

  void logout(BuildContext context) async {
    await SessionManager().remove("Ids");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginIn()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    dataa();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      dataa();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 0, 2, 137),
        title: Text(
          "Profil",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: dart.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 0, 2, 137),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundImage:
                                NetworkImage('${dart[index]['rasm']}'),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${dart[index]['fullname']}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProfileEdit(
                                              productDetails: dart[index]),
                                        ));
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    size: 23,
                                    color: Colors.white,
                                  ))
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${dart[index]['number']}',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => cometedit(),
                                  ));
                            },
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: Card(
                                elevation: 4,
                                shadowColor: Colors.black,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Icon(Icons.chat_bubble_outline),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Izohlar',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Spacer(),
                                    Icon(Icons.keyboard_arrow_right_rounded),
                                    SizedBox(
                                      width: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Tizimdan chiqish"),
                                    content: Text(
                                        "Haqiqatdan tizimdan chiqib ketmoqchimisz?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Yo'q"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          logout(context);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Ha"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: Card(
                                elevation: 4,
                                shadowColor: Colors.black,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Icon(Icons.exit_to_app_outlined),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Tizimdan chiqish',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Spacer(),
                                    Icon(Icons.keyboard_arrow_right_rounded),
                                    SizedBox(
                                      width: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
    );
  }
}
