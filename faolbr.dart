import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'dart:async';
import 'faolbtf.dart';

class faolbr extends StatefulWidget {
  const faolbr({super.key});

  @override
  State<faolbr> createState() => _faolbrState();
}

class _faolbrState extends State<faolbr> {
  List<Map<String, dynamic>> dart = [];
  List<Map<String, dynamic>> tel = [];
  bool isLoading = true;
  dynamic stafid = "";

  Future<void> dataa() async {
    stafid = await SessionManager().get("Ids");
    try {
      final response = await http.get(Uri.parse(
          'https://dash.vips.uz/api/38/1984/31950?userid=$stafid&status=2'));

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
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    dataa();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: dart.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  faolbtf(productDetails: dart[index]),
                            ));
                      },
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          image: DecorationImage(
                            image: NetworkImage('${dart[index]['bronidrasmi']}'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue[900],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 2, bottom: 2, left: 4, right: 4),
                                  child: Text(
                                    '\$ ${dart[index]['bronidnarx']}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${dart[index]['bronidnomi']}',
                          style: TextStyle(
                              fontSize: 19, fontWeight: FontWeight.w700),
                        ),
                        Spacer(),
                        // Text(
                        //   "Remaining Time",
                        //   style: TextStyle(
                        //       fontSize: 18, fontWeight: FontWeight.w600),
                        // )
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                  ],
                );
              },
            ),
    ));
  }
}
