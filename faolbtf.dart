import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class faolbtf extends StatefulWidget {
  final Map<String, dynamic> productDetails;
  faolbtf({required this.productDetails});

  @override
  State<faolbtf> createState() => _faolbtfState();
}

class _faolbtfState extends State<faolbtf> {
  List<Map<String, dynamic>> tel = [];
  List<Map<String, dynamic>> teleg = [];
  bool isLoading = true;
  bool hasRated = false;
  int selectedRating = 0;
  dynamic stafid = "";

  @override
  void initState() {
    super.initState();
    tell();
    tele();
    _initializeRatingStatus();
  }

  Future<void> _initializeRatingStatus() async {
    stafid = await SessionManager().get("Ids");
    hasRated = await checkRatingStatus(widget.productDetails['bronid'], stafid);
    setState(() {});
  }

  Future<void> tell() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://dash.vips.uz/api/38/1984/29824?bronid=${widget.productDetails['bronid']}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          for (var item in jsonData) {
            tel.add(Map<String, dynamic>.from(item));
          }
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> tele() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://dash.vips.uz/api/38/1984/29825?bronid=${widget.productDetails['bronid']}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          for (var item in jsonData) {
            teleg.add(Map<String, dynamic>.from(item));
          }
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> reytber(int rating) async {
    stafid = await SessionManager().get("Ids");
    final String apiUrl = "https://dash.vips.uz/api-in/38/1984/29835";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'apipassword': 'f1234',
          'bronid': '${widget.productDetails['bronid']}',
          'reyting': rating.toString(),
          'userid': '$stafid',
        },
      );

      if (response.statusCode == 200) {
        print('Rating posted successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color.fromARGB(255, 0, 2, 137),
            content: Text(
              "Reyting muvaffaqiyatli yuborildi",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        setState(() {
          hasRated = true;
        });

        // Store rating status locally
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool(
            'rated_${widget.productDetails['bronid']}_$stafid', true);
      } else {
        throw Exception('Failed to post rating');
      }
    } catch (error) {
      print('Error posting rating: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 0, 2, 137),
          content: Text(
            "Reyting yuborishda xatolik yuz berdi, iltimos qayta urinib ko'ring",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<bool> checkRatingStatus(String bronid, dynamic stafid) async {
    // Check stored rating status
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('rated_${bronid}_$stafid') ?? false;
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

  void _launchTelegram(int index) async {
    if (index >= 0 && index < teleg.length) {
      final telegramUsername = teleg[index]['havola'];
      final telegramURL = 'https://t.me/$telegramUsername';

      try {
        await launch(telegramURL);
      } catch (e) {
        print('Error launching Telegram: $e');
      }
    } else {
      print('Invalid index or tel list is empty');
    }
  }

  void _launchPhone(String phoneNumber) async {
    final phoneUrl = 'tel:$phoneNumber';
    if (await canLaunch(phoneUrl)) {
      await launch(phoneUrl);
    } else {
      throw 'Could not launch $phoneUrl';
    }
  }

  void _submitRating() async {
    stafid = await SessionManager().get("Ids");
    bool alreadyRated =
        await checkRatingStatus(widget.productDetails['bronid'], stafid);
    if (!alreadyRated) {
      await reytber(selectedRating);
      setState(() {
        selectedRating = 0;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 0, 2, 137),
          content: Text(
            "Siz allaqachon reyting bergansiz",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  void _cancelRating() {
    setState(() {
      selectedRating = 0;
    });
  }

  String _getEmojiForRating(int rating) {
    if (rating == 1 || rating == 2) {
      return '😞'; // Sad face
    } else if (rating == 3) {
      return '😐'; // Neutral face
    } else if (rating == 4 || rating == 5) {
      return '😊'; // Happy face
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Batafsil'),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Malumot',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Narxi: \$ ${widget.productDetails['bronidnarx']}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      'Band qilingan kun: ${widget.productDetails['kun']}',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      'Muddat: ${widget.productDetails['kunga']} dan, ${widget.productDetails['kungacha']} gacha',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () => _launchMaps(
                                widget.productDetails['bronidmanzil']),
                            child: Text(
                              'Manzil: ${widget.productDetails['bronidmanzil']}',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline),
                              softWrap: true,
                            ),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              _launchMaps(
                                  widget.productDetails['bronidmanzil']);
                            },
                            icon: Icon(
                              Icons.location_on,
                              color: Colors.black87,
                            ))
                      ],
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Telefon raqamlar',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                          itemCount: tel.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _launchPhone(tel[index]['nomer']);
                                      },
                                      child: Text(
                                        '${tel[index]['nomer']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          _launchPhone(tel[index]['nomer']);
                                        },
                                        icon: Icon(
                                          Icons.call,
                                          color: Colors.green,
                                        ))
                                  ],
                                ),
                              ],
                            );
                          }),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: teleg.length,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _launchTelegram(index);
                                  },
                                  child: Text(
                                    'Telegram',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {
                                      _launchTelegram(index);
                                    },
                                    icon: Icon(
                                      Icons.telegram_outlined,
                                      color: Colors.blue,
                                    ))
                              ],
                            );
                          }),
                    ),
                    if (!hasRated)
                      Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Reyting berish',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    _getEmojiForRating(selectedRating),
                                    style: TextStyle(fontSize: 30),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  for (int i = 1; i <= 5; i++)
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedRating = i;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.star,
                                        color: selectedRating >= i
                                            ? Colors.amber
                                            : Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: _cancelRating,
                                    child: Text('Bekor qilish'),
                                  ),
                                  TextButton(
                                    onPressed: _submitRating,
                                    child: Text('Yuborish'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ));
  }
}
