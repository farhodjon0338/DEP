import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

// ignore: camel_case_types
class bronbtf extends StatefulWidget {
  final Map<String, dynamic> productDetails;
  const bronbtf({super.key, required this.productDetails});

  @override
  State<bronbtf> createState() => _bronbtfState();
}

// ignore: camel_case_types
class _bronbtfState extends State<bronbtf> {
  List<Map<String, dynamic>> tel = [];
  List<Map<String, dynamic>> teleg = [];
  bool isLoading = true;
  dynamic stafid = "";

  @override
  void initState() {
    super.initState();
    tell();
    tele();
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
      setState(() {
        isLoading = false;
      });
    }
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

  void _launchTelegram(int index) async {
    if (index >= 0 && index < tel.length) {
      final telegramUsername = tel[index]['telegrm'];
      final telegramURL = 'https://t.me/$telegramUsername';

      try {
        // ignore: deprecated_member_use
        await launch(telegramURL);
      // ignore: empty_catches
      } catch (e) {
      }
    } else {
    }
  }

  void _launchPhone(String phoneNumber) async {
    final phoneUrl = 'tel:$phoneNumber';
    // ignore: deprecated_member_use
    if (await canLaunch(phoneUrl)) {
      // ignore: deprecated_member_use
      await launch(phoneUrl);
    } else {
      throw 'Could not launch $phoneUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Batafsil'),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Malumot',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Narxi: \$ ${widget.productDetails['bronidnarx']}',
                      style:
                          const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      'Band qilingan kun: ${widget.productDetails['kun']}',
                      style:
                          const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      'Muddat: ${widget.productDetails['kunga']} dan, ${widget.productDetails['kungacha']} gacha',
                      style:
                          const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              _launchMaps(
                                  widget.productDetails['bronidmanzil']);
                            },
                            child: Text(
                              'Manzili: ${widget.productDetails['bronidmanzil']}',
                              style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600),
                              softWrap: true,
                            ),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              _launchMaps(
                                  widget.productDetails['bronidmanzil']);
                            },
                            icon: const Icon(
                              Icons.location_on,
                              color: Colors.black87,
                            ))
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      'Telefon raqamlar',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 80,
                      width: double.infinity,
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
                                        style: const TextStyle(
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
                                        icon: const Icon(
                                          Icons.call,
                                          color: Colors.green,
                                        ))
                                  ],
                                ),
                              ],
                            );
                          }),
                    ),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ListView.builder(
                          itemCount: teleg.length,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _launchTelegram(index);
                                  },
                                  child: const Text(
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
                                    icon: const Icon(
                                      Icons.telegram_outlined,
                                      color: Colors.blue,
                                    ))
                              ],
                            );
                          }),
                    ),
                  ],
                ),
              ));
  }
}
