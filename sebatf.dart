import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class sevbataf extends StatefulWidget {
  final Map<String, dynamic> productDetails;
  sevbataf({required this.productDetails});

  @override
  State<sevbataf> createState() => _sevbatafState();
}

class _sevbatafState extends State<sevbataf> {
  List<Map<String, dynamic>> ras = [];
  List<Map<String, dynamic>> qulay = [];
  List<Map<String, dynamic>> rey = [];
  bool isLoading = true;
  late DateTime selectedDate;
  String status = '0';
  int selectedRating = 0;
  dynamic stafid = "";

  // Future<void> _showRatingDialog(BuildContext context) async {
  //   return showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             title: Text('Reyting berish'),
  //             content: Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: <Widget>[
  //                 for (int i = 1; i <= 5; i++)
  //                   IconButton(
  //                     onPressed: () {
  //                       setState(() {
  //                         selectedRating = i;
  //                       });
  //                     },
  //                     icon: Icon(
  //                       Icons.star,
  //                       color: selectedRating >= i ? Colors.amber : Colors.grey,
  //                     ),
  //                   ),
  //               ],
  //             ),
  //             actions: <Widget>[
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: Text('Bekor qilish'),
  //               ),
  //               TextButton(
  //                 onPressed: () async {
  //                   await reytber(selectedRating);

  //                   Navigator.of(context).pop();
  //                 },
  //                 child: Text('Yuborish'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  Future<void> reyt() async {
    try {
      final response = await http.get(Uri.parse(
          'https://dash.vips.uz/api/38/1984/29835?bronid=${widget.productDetails['bronid']}'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
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

  Future<void> rasmm() async {
    try {
      final response = await http.get(Uri.parse(
          'https://dash.vips.uz/api/38/1984/29834?bronid=${widget.productDetails['bronid']}'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          for (var item in jsonData) {
            ras.add(Map<String, dynamic>.from(item));
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

  Future<void> qul() async {
    try {
      final response = await http.get(Uri.parse(
          'https://dash.vips.uz/api/38/1984/29833?bronid=${widget.productDetails['bronid']}'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          for (var item in jsonData) {
            qulay.add(Map<String, dynamic>.from(item));
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

  @override
  void initState() {
    super.initState();
    rasmm();
    qul();
    reyt();
  }

  Future<void> _selectDate(BuildContext context, String id) async {
    DateTime? startDate = DateTime.now();
    DateTime? endDate = DateTime.now().add(Duration(days: 19));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: startDate,
      lastDate: endDate,
      selectableDayPredicate: (DateTime day) {
        return day.isAfter(DateTime.now().subtract(Duration(days: 1)));
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });

      await postData(id, status); // Make API call here

      // Show rating dialog after API call is made
     // _showRatingDialog(context);
    }
  }

  Future<void> postData(String id, String status) async {
    stafid = await SessionManager().get("Ids");
    final String apiUrl = "https://dash.vips.uz/api-up/38/1984/29826";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'apipassword': 'f1234',
          'where': 'id:${widget.productDetails['bronid']}',
          'kun': selectedDate.toString(),
          'userid': '$stafid',
          'status': '0',
        },
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color.fromARGB(255, 0, 2, 137),
            content: Text(
              "Mufaqiyatlik bron qilindi",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      } else {
        throw Exception('Failed to post data');
      }
    } catch (error) {
      print('Error posting data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 0, 2, 137),
          content: Text(
            "Bron qilishda xatolik yuz berdi qayta urunib ko'ring",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  // Future<void> reytber(int rating) async {
  //   final String apiUrl = "https://dash.vips.uz/api-in/29/1538/23005";
  //   try {
  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       headers: <String, String>{
  //         'Content-Type': 'application/x-www-form-urlencoded',
  //       },
  //       body: {
  //         'apipassword': 'f1234',
  //         'bronid': '${widget.productDetails['bronid']}',
  //         'reyting': rating.toString(),
  //         'userid': '1',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       print('Rating posted successfully');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           backgroundColor: Color.fromARGB(255, 0, 2, 137),
  //           content: Text(
  //             "Reyting muvaffaqiyatli yuborildi",
  //             style: TextStyle(color: Colors.white),
  //           ),
  //         ),
  //       );
  //     } else {
  //       throw Exception('Failed to post rating');
  //     }
  //   } catch (error) {
  //     print('Error posting rating: $error');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         backgroundColor: Color.fromARGB(255, 0, 2, 137),
  //         content: Text(
  //           "Reyting yuborishda xatolik yuz berdi, iltimos qayta urinib ko'ring",
  //           style: TextStyle(color: Colors.white),
  //         ),
  //       ),
  //     );
  //   }
  // }

  double calculateAverageRating(List<Map<String, dynamic>> reyList) {
    if (reyList.isEmpty) {
      return 0.0; // Return 0 if the list is empty
    }
    double totalRating = 0.0;
    for (var item in reyList) {
      // Convert 'reyting' value to double before adding
      totalRating += double.parse(item['reyting'].toString());
    }
    double averageRating = totalRating / reyList.length;
    // Limit the result to two decimal places
    return double.parse(averageRating.toStringAsFixed(1));
  }

  Widget buildRatingStars(double rating) {
    int numberOfStars = rating.round(); // Reytingni yaxlitlab yuvarlaymiz
    List<Widget> stars = [];

    // Reytingni yulduzlar bilan ko'rsatish
    for (int i = 0; i < 5; i++) {
      if (i < numberOfStars) {
        stars.add(
          Icon(
            Icons.star,
            color: Colors.amber,
          ),
        );
      } else {
        stars.add(
          Icon(
            Icons.star,
            color: Colors.grey,
          ),
        );
      }
    }

    return Row(
      children: stars,
    );
  }

  void _launchMaps(String address) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeFull(address)}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.red,
        title: Text(
          "${widget.productDetails['bronidnomi']}",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Row(children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${widget.productDetails['bronidtavsif']}",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: [
                                  buildRatingStars(calculateAverageRating(
                                      rey)), // Reytingni yulduzlar bilan ko'rsatish
                                  SizedBox(width: 8), // Kichik bo'shliq
                                  Text(
                                    "${calculateAverageRating(rey)}", // O'rtacha reytingni tekst bilan ko'rsatish
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ]),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 20,
                          ),
                          child: Container(
                            width: 80,
                            height: 70,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(
                                        '${widget.productDetails['bronidrasmi']}'),
                                    fit: BoxFit.cover),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Haqida",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${widget.productDetails['bronidmalumot']}",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Qulayliklar",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 25,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: qulay.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Text(
                                "${qulay[index]['nomi']},",
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w500),
                              ),
                            );
                          }),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      height: 300,
                      width: double.infinity,
                      child: PageView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: ras.length,
                        itemBuilder: (context, index) {
                          return isLoading
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Container(
                                    width: 400,
                                    height: 250,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(ras[index]['rasm']),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                    ),
                                  ),
                                );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Manzil",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _launchMaps(widget.productDetails['bronidmanzil']);
                          },
                          child: Text(
                            "${widget.productDetails['bronidmanzil']}",
                            style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                fontSize: 17,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            _launchMaps(widget.productDetails['bronidmanzil']);
                          },
                          child: Icon(
                            Icons.location_on,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: widget.productDetails['bronidnarx'] == null
          ? SizedBox.shrink() // If bronidnarx is null, show an empty widget
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  _selectDate(context, widget.productDetails['id'].toString());
                },
                child: Container(
                  width: double.infinity,
                  height: 55,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Text(
                          "\$ ${widget.productDetails['bronidnarx']}",
                          style: TextStyle(
                              fontSize: 19,
                              color: Colors.black,
                              fontWeight: FontWeight.w700),
                        ),
                        Spacer(),
                        Text(
                          "Bron qilish",
                          style: TextStyle(
                              fontSize: 19,
                              color: Colors.black,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                ),
              ),
            ),
    );
  }
}
