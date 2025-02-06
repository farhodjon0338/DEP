import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'commet.dart';
import 'sebatf.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';

class sevimli extends StatefulWidget {
  const sevimli({Key? key}) : super(key: key);

  @override
  State<sevimli> createState() => _sevimliState();
}

class _sevimliState extends State<sevimli> {
  List<Map<String, dynamic>> dart = [];
  List<Map<String, dynamic>> rey = [];
  bool isLoading = true;
  bool isLiked = false;
  dynamic stafid = "";

  Future<void> reyt(String id) async {
    try {
      final response =
          await http.get(Uri.parse('https://dash.vips.uz/api/38/1984/29835'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          //  rey.clear(); // rey listini tozalaymiz
          for (var item in jsonData) {
            rey.add(Map<String, dynamic>.from(item));
          }
          isLoading = false;
        });
      } else {
        throw Exception('Ma\'lumotlarni yuklashda xatolik yuz berdi');
      }
    } catch (error) {
      print('Ma\'lumotlarni yuklashda xatolik yuz berdi: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> bron() async {
    stafid = await SessionManager().get("Ids");
    try {
      final response = await http.get(
          Uri.parse('https://dash.vips.uz/api/38/1984/29836?userid=$stafid'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          for (var item in jsonData) {
            dart.add(Map<String, dynamic>.from(item));
          }
          isLoading = false;
        });
      } else {
        throw Exception('Ma\'lumotlarni yuklashda xatolik yuz berdi');
      }
    } catch (error) {
      print('Ma\'lumotlarni yuklashda xatolik yuz berdi: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> delet(String id) async {
    final String apiUrl =
        "https://dash.vips.uz/api-del/38/1984/29836?apipassword=f1234&id=$id";
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        print('Data deleted successfully');
        // Sevimlilardan olib tashlandi xabari chiqariladi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color.fromARGB(255, 0, 2, 137),
            content: Text(
              "Sevimlilardan olib tashlandi",
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        print('Failed to delete data');
      }
    } catch (error) {
      print('Error deleting data: $error');
    }
  }

  double calculateAverageRating(List<Map<String, dynamic>> reyList) {
    if (reyList.isEmpty) {
      return 0.0;
    }
    double totalRating = 0.0;
    for (var item in reyList) {
      totalRating += double.parse(item['reyting'].toString());
    }
    double averageRating = totalRating / reyList.length;
    return double.parse(averageRating.toStringAsFixed(1));
  }

  @override
  void initState() {
    super.initState();
    bron();
    reyt(AutofillHints.addressCity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Saqlangan"),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: dart.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    sevbataf(productDetails: dart[index]),
                              ));
                        },
                        child: Container(
                          width: double.infinity,
                          height: 280,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        delet(dart[index]['id']);
                                        dart.removeAt(index);
                                      });
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(
                                    dart[index]['bronidrasmi'],
                                  ),
                                  fit: BoxFit.cover),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                        ),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          Text(
                            '${dart[index]['bronidnomi']}',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                          Spacer(),
                          Icon(
                            Icons.star,
                            size: 15,
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                              '${calculateAverageRating(rey.where((item) => item['bronid'] == dart[index]['bronid']).toList())}')
                        ],
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Row(
                        children: [
                          Text(
                            dart[index]['bronidnarx'] != null
                                ? '\$${dart[index]['bronidnarx']}'
                                : '',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),

                          SizedBox(
                            width: 3,
                          ),
                          //Text('kun')
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Cemmet(
                                  bronId: dart[index]['bronid'].toString()),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 20,
                        ),
                      ),
                      SizedBox(
                        height: 28,
                      ),
                    ],
                  ),
                );
              }),
    );
  }
}
