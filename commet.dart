import 'dart:async';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'kirish.dart';

class Cemmet extends StatefulWidget {
  final String bronId;

  const Cemmet({Key? key, required this.bronId}) : super(key: key);

  @override
  State<Cemmet> createState() => _CemmetState();
}

class _CemmetState extends State<Cemmet> {
  TextEditingController izohController = TextEditingController();
  List<Map<String, dynamic>> comit = [];
  List<String> postedComments = [];
  bool isLoading = true;
  bool isPosting = false;
  dynamic stafid = "";
  DateTime? lockEndTime;
  late Timer _timer;
  Timer? _lockTimer;

  @override
  void initState() {
    super.initState();
    fetchData(widget.bronId);
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      fetchData(widget.bronId);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _lockTimer?.cancel();
    izohController.dispose();
    super.dispose();
  }

  Future<void> fetchData(String bronId) async {
    stafid = await SessionManager().get("Ids");
    try {
      final response = await http.get(Uri.parse(
          'https://dash.vips.uz/api/38/1984/29827?bronid=$bronId&status=1'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          // Filter out comments with status indicating reports (status != 2)
          comit = jsonData
              .where((comment) => comment['status'] != 2)
              .toList()
              .cast<Map<String, dynamic>>();
          comit = comit.reversed.toList(); // Reverse the list
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> postData(String izoh, String bronId) async {
    final String apiUrl = "https://dash.vips.uz/api-in/38/1984/29827";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'apipassword': 'f1234',
          'kun': DateFormat('yyyy.MMMM.dd EEE').format(DateTime.now()),
          'commetlar': izoh,
          'userid': '$stafid',
          'bronid': bronId,
          'status': '1',
        },
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
      } else {
        print('Failed to post data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error posting data: $error');
    } finally {
      setState(() {
        isPosting = false; // Reset the posting state
      });
    }
  }

  Future<void> delet(String commentId) async {
    final String apiUrl =
        "https://dash.vips.uz/api-del/38/1984/29827?apipassword=f1234&id=$commentId";
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        print('Comment deleted successfully');
        await fetchData(widget.bronId); // Refresh comments list
      } else {
        print('Failed to delete comment');
      }
    } catch (error) {
      print('Error deleting comment: $error');
    }
  }

  Future<void> _checkAndNavigate() async {
    stafid = await SessionManager().get("Ids");
    if (stafid == null || stafid.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 0, 2, 137),
          content: Text(
            "Iltimos, ro'yxatdan o'ting",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginIn()),
      );
    } else {
      final izohText = izohController.text.trim();
      final bronId = widget.bronId;

      // Fetch the latest comments
      await fetchData(bronId);

      // Check for duplicate comments
      bool isDuplicate =
          comit.any((comment) => comment["commetlar"] == izohText);

      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color.fromARGB(255, 255, 0, 0),
            content: Text(
              "Bunday izoh allaqachon mavjud",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      } else if (izohText.isNotEmpty) {
        setState(() {
          isPosting = true; // Set posting state to true
        });
        await postData(izohText, bronId);
        izohController.clear();
        // Add the posted comment to the list
        postedComments.add(izohText);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('rasm/comit3.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_new_outlined,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Izohlar',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : comit.isEmpty
                          ? Center(
                              child: Text(
                                "Hozircha izohlar yo‘q",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black54),
                              ),
                            )
                          : ListView.builder(
                              itemCount: comit.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: CircleAvatar(
                                        radius: 17,
                                        backgroundImage: NetworkImage(
                                            '${comit[index]['useridrasm']}'),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "${comit[index]['useridfullname']}",
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(9),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${comit[index]["commetlar"]}",
                                            style: TextStyle(fontSize: 17),
                                          ),
                                          if (comit[index]['userid'] ==
                                              stafid.toString())
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: IconButton(
                                                icon: Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () {
                                                  delet(comit[index]['id']);
                                                },
                                              ),
                                            ),
                                        ],
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(15),
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        "${comit[index]['kun']}",
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: izohController,
                        decoration: InputDecoration(
                          fillColor: Colors.black,
                          focusColor: Colors.black,
                          border: OutlineInputBorder(),
                          hintText: "Izoh...",
                          hintStyle: TextStyle(color: Colors.black),
                          suffixIcon: IconButton(
                            onPressed: isPosting ? null : _checkAndNavigate,
                            icon: isPosting
                                ? CircularProgressIndicator()
                                : Icon(Icons.send, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
