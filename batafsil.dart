import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'kirish.dart';
import 'package:url_launcher/url_launcher.dart';

class Batafsil extends StatefulWidget {
  final Map<String, dynamic> productDetails;
  const Batafsil({super.key, required this.productDetails});

  @override
  State<Batafsil> createState() => _BatafsilState();
}

class _BatafsilState extends State<Batafsil> {
  List<Map<String, dynamic>> ras = [];
  List<Map<String, dynamic>> qulay = [];
  List<Map<String, dynamic>> rey = [];
  bool isLoading = true;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String status = '0';
  int selectedRating = 0;
  dynamic stafid = "";

  Future<void> reyt() async {
    try {
      final response = await http.get(Uri.parse(
          'https://dash.vips.uz/api/38/1984/29835?bronid=${widget.productDetails['id']}'));

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
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> rasmm() async {
    try {
      final response = await http.get(Uri.parse(
          'https://dash.vips.uz/api/38/1984/29834?bronid=${widget.productDetails['id']}'));

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
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> qul() async {
    try {
      final response = await http.get(Uri.parse(
          'https://dash.vips.uz/api/38/1984/29833?bronid=${widget.productDetails['id']}'));

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
    DateTime now = DateTime.now();
    String currentDateTime =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 29)),
      helpText: 'Qachondan',
    );

    if (pickedStartDate != null) {
      DateTime? pickedEndDate = await showDatePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialDate: pickedStartDate.add(const Duration(days: 1)),
        firstDate: pickedStartDate,
        lastDate: DateTime.now().add(const Duration(days: 29)),
        helpText: 'Qachongacha',
      );

      if (pickedEndDate != null) {
        setState(() {
          selectedStartDate = pickedStartDate;
          selectedEndDate = pickedEndDate;
        });

        String formattedStartDate =
            "${selectedStartDate!.year}-${selectedStartDate!.month.toString().padLeft(2, '0')}-${selectedStartDate!.day.toString().padLeft(2, '0')}";
        String formattedEndDate =
            "${selectedEndDate!.year}-${selectedEndDate!.month.toString().padLeft(2, '0')}-${selectedEndDate!.day.toString().padLeft(2, '0')}";

        await postData(
            id, formattedStartDate, formattedEndDate, currentDateTime);
      }
    }
  }

  Future<void> postData(String id, String startDate, String endDate,
      String currentDateTime) async {
    stafid = await SessionManager().get("Ids");
    const String apiUrl = "https://dash.vips.uz/api-in/38/1984/31950";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'apipassword': 'f1234',
          'bronid': '${widget.productDetails['id']}',
          'userid': '$stafid'.toString(),
          'kun': currentDateTime,
          'kunga': startDate,
          'kungacha': endDate,
          'status': '1',
        },
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color.fromARGB(255, 0, 2, 137),
          content: Text(
            "Bron qilishda xatolik yuz berdi qayta urunib ko'ring",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  double calculateAverageRating(List<Map<String, dynamic>> reyList) {
    if (reyList.isEmpty) {
      return 0.0;
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
          const Icon(
            Icons.star,
            color: Colors.amber,
          ),
        );
      } else {
        stars.add(
          const Icon(
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
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _checkAndNavigate() async {
    stafid = await SessionManager().get("Ids");
    if (stafid == null || stafid.toString().isEmpty) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color.fromARGB(255, 0, 2, 137),
          content: Text(
            "Iltimos, ro'yxatdan o'ting",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const LoginIn()),
      );
    } else {
      // ignore: use_build_context_synchronously
      _selectDate(context, widget.productDetails['id'].toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.productDetails['nomi']}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(
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
                                "${widget.productDetails['tavsif']}",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: [
                                  buildRatingStars(calculateAverageRating(rey)),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${calculateAverageRating(rey)}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ]),
                        const Spacer(),
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
                                        '${widget.productDetails['rasmi']}'),
                                    fit: BoxFit.cover),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10))),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Haqida",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${widget.productDetails['malumot']}",
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
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
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w500),
                              ),
                            );
                          }),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: PageView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: ras.length,
                        itemBuilder: (context, index) {
                          return Padding(
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
                                    const BorderRadius.all(Radius.circular(25)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      "Manzil",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              _launchMaps(widget.productDetails['manzil']);
                            },
                            child: Text(
                              "${widget.productDetails['manzil']}",
                              style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500),
                              softWrap: true,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            _launchMaps(widget.productDetails['manzil']);
                          },
                          child: const Icon(
                            Icons.location_on,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            _checkAndNavigate();
          },
          child: Container(
            width: double.infinity,
            height: 55,
            decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Text(
                    "\$ ${widget.productDetails['narx']}",
                    style: const TextStyle(
                        fontSize: 19,
                        color: Colors.black,
                        fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  const Text(
                    "Bron qilish",
                    style: TextStyle(
                        fontSize: 19,
                        color: Colors.black,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
