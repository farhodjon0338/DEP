import 'dart:async';
import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_session_manager/flutter_session_manager.dart';

// ignore: camel_case_types
class cometedit extends StatefulWidget {
  const cometedit({super.key});

  @override
  State<cometedit> createState() => _cometeditState();
}

// ignore: camel_case_types
class _cometeditState extends State<cometedit> {
  List<Map<String, dynamic>> comit = [];
  dynamic stafid = "";
  bool isLoading = true;
  late Timer _timer;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  Future<void> fetchData() async {
    stafid = await SessionManager().get("Ids");
    try {
      final response = await http.get(Uri.parse(
          'https://dash.vips.uz/api/38/1984/29827?userid=$stafid&status=1'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          comit = jsonData.cast<Map<String, dynamic>>().reversed.toList();
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

  Future<void> delet(String id) async {
    final String apiUrl =
        "https://dash.vips.uz/api-del/38/1984/29827?apipassword=f1234&id=$id";
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
      } else {}
      // ignore: empty_catches
    } catch (error) {}
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('O\'chirishni tasdiqlash'),
          content: const Text('Ushbu izohni o\'chirishni xohlaysizmi?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Bekor qilish'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('O\'chirish'),
              onPressed: () async {
                await delet(comit[index]['id']);
                _removeItem(index);
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _removeItem(int index) {
    final removedItem = comit[index];
    setState(() {
      comit.removeAt(index);
    });
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildItem(removedItem, animation, index),
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildItem(
      Map<String, dynamic> item, Animation<double> animation, int index) {
    return SizeTransition(
      sizeFactor: animation,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundImage: NetworkImage('${item['bronidrasmi']}'),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item['bronidnomi']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage('${item['useridrasm']}'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item['useridfullname']}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          ' ${item['commetlar']}',
                          style: const TextStyle(fontSize: 15),
                        ),
                        Row(
                          children: [
                            Text(
                              '${item['kun']}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                _showDeleteConfirmationDialog(index);
                              },
                              icon: Icon(
                                Icons.delete,
                                size: 20,
                                color: Colors.red[400],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      fetchData();
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
        title: Text('Izohlar'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : AnimatedList(
              key: _listKey,
              initialItemCount: comit.length,
              itemBuilder: (context, index, animation) {
                return _buildItem(comit[index], animation, index);
              },
            ),
    );
  }
}
