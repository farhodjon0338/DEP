import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'kirish.dart';

class Remenber extends StatefulWidget {
  const Remenber({Key? key}) : super(key: key);

  @override
  State<Remenber> createState() => _RemenberState();
}

class _RemenberState extends State<Remenber> {
  List<Map<String, dynamic>> dart = [];
  bool isLoading = true;
  dynamic stafid = "";
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      eslat();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> eslat() async {
    stafid = await SessionManager().get("Ids");
    {
      final response = await http.get(
          Uri.parse('https://dash.vips.uz/api/38/1984/29828?userid=$stafid'));

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
    }
  }

  Future<void> postData(
      String nom, String kun, String vaqt, String malumot) async {
    stafid = await SessionManager().get("Ids");
    final String apiUrl = "https://dash.vips.uz/api-in/38/1984/29828";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'apipassword': 'f1234',
          'nomi': nom,
          'kun': kun,
          'soat': vaqt,
          'malumot': malumot,
          'userid': '$stafid'.toString(),
        },
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
      } else {
        print('Failed to post data');
      }
    } catch (error) {
      print('Error posting data: $error');
      print('stafid: $stafid');
    }
  }

  void _showAddReminderDialog() async {
    stafid = await SessionManager().get("Ids");
    if (stafid == null || stafid.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 0, 2, 137),
          content: Text(
            "Iltimos, ro'yxatdan o'ting",
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginIn()),
      );
      return;
    }

    String? nom;
    String? kun;
    String? vaqt;
    String? malumot;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Eslatma qo'shish"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Nom'),
                  onChanged: (value) {
                    nom = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Kun'),
                  onChanged: (value) {
                    kun = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Vaqt'),
                  onChanged: (value) {
                    vaqt = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Malumot'),
                  onChanged: (value) {
                    malumot = value;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Qaytish'),
            ),
            TextButton(
              onPressed: () {
                postData(nom!, kun!, vaqt!, malumot!);
                Navigator.of(context).pop();
              },
              child: Text("Qo'shish"),
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog(Map<String, dynamic> malumot) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("${malumot['nomi']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Batafsil: ${malumot['malumot']}",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Qaytish"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Eslatmalar"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: dart.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _showAddDialog(dart[index]);
                      });
                    },
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("O'chirish"),
                            content: Text(
                                "Haqiqatdan ham bu elementni o'chirmoqchimisiz?"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Bekor qilish"),
                              ),
                              TextButton(
                                onPressed: () {
                                  delet(dart[index]['id']);
                                  setState(() {
                                    dart.removeAt(index);
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Text("O'chirish"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        width: double.infinity,
                        height: 135,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 0, 2, 137),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${dart[index]['nomi']}",
                                style: TextStyle(
                                    fontSize: 21, color: Colors.white),
                              ),
                              Text(
                                "${dart[index]['kun']}",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              Text(
                                "${dart[index]['soat']}",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        child: Icon(Icons.note_add_rounded),
      ),
    );
  }
}

Future<void> delet(String id) async {
  final String apiUrl =
      "https://dash.vips.uz/api-del/38/1984/29828?apipassword=f1234&id=$id";
  try {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      print('Data deleted successfully');
    } else {
      print('Failed to delete data');
    }
  } catch (error) {
    print('Error deleting data: $error');
  }
}
