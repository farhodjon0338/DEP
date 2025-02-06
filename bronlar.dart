import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'dart:async';
import 'bronbat.dart';
import 'faolbr.dart';

class Bronlar extends StatefulWidget {
  const Bronlar({super.key});

  @override
  State<Bronlar> createState() => _BronlarState();
}

class _BronlarState extends State<Bronlar> {
  List<Map<String, dynamic>> dart = [];
  List<Map<String, dynamic>> tel = [];
  bool isLoading = true;
  bool isPosting = false; // Add a flag for posting state
  dynamic stafid = "";
  late Timer timer;
  String status = '1';

  Future<void> postData(int index) async {
    final String apiUrl =
        "https://dash.vips.uz/api-del/38/1984/31950?apipassword=f1234&id=${dart[index]['id']}";
    setState(() {
      isPosting = true;
    });
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color.fromARGB(255, 0, 2, 137),
            content: Text(
              "Bron olib tashlandi",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );

        setState(() {
          dart.removeAt(index);
          isPosting = false; // Reset the posting flag
        });
      } else {
        throw Exception('Failed to post data');
      }
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color.fromARGB(255, 0, 2, 137),
          content: Text(
            "Bron qaytarishda xatolik yuz berdi",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      setState(() {
        isPosting = false; // Reset the posting flag
      });
    }
  }

  Future<void> dataa() async {
    stafid = await SessionManager().get("Ids");
    try {
      final response = await http.get(Uri.parse(
          'https://dash.vips.uz/api/38/1984/31950?userid=$stafid&status=1'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          dart.clear();
          for (var item in jsonData) {
            dart.add(Map<String, dynamic>.from(item));
          }
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
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
  void dispose() {
    super.dispose();
  }

  // String calculateRemainingTime(DateTime createdAt) {
  //   final Duration difference = DateTime.now().difference(createdAt);
  //   final int hoursRemaining = 24 - difference.inHours;
  //   final int minutesRemaining = 60 - difference.inMinutes.remainder(60);
  //   return 'Remaining: $hoursRemaining hours and $minutesRemaining minutes';
  // }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Bronlar"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Vaqtincha"),
              Tab(text: "Faol"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildActiveBookings(),
            const faolbr(),
          ],
        ),
      ),
    );
  }

  Widget buildActiveBookings() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: isLoading
          ? const Center(
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
                                  bronbtf(productDetails: dart[index]),
                            ));
                      },
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          image: DecorationImage(
                            image:
                                NetworkImage('${dart[index]['bronidrasmi']}'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
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
                                      const BorderRadius.all(Radius.circular(5)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 2, bottom: 2, left: 4, right: 4),
                                  child: Text(
                                    '\$ ${dart[index]['bronidnarx']}',
                                    style: const TextStyle(
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
                          style: const TextStyle(
                              fontSize: 19, fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        TextButton(
                            onPressed: () {
                              if (!isPosting) {
                                postData(index); // Pass the index correctly
                              }
                            },
                            child: isPosting
                                ? const CircularProgressIndicator()
                                : const Text('Bekor qilish')),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                  ],
                );
              },
            ),
    );
  }
}
