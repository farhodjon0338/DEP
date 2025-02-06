import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_session_manager/flutter_session_manager.dart';
//import 'package:bcrypt/bcrypt.dart';

class ProfileEdit extends StatefulWidget {
  final Map<String, dynamic> productDetails;
  ProfileEdit({required this.productDetails});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  List<Map<String, dynamic>> dart = [];
  bool isLoading = true;
  dynamic stafid = "";
  int? selectedAvatarId;
  bool isPasswordVisible = false;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController loginController = TextEditingController();
  //final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fullNameController.text = widget.productDetails['fullname'];
    numberController.text = widget.productDetails['number'];
    loginController.text = widget.productDetails['login'];
    dataa();
  }

  Future<void> dataa() async {
    stafid = await SessionManager().get("Ids");
    try {
      final response =
          await http.get(Uri.parse('https://dash.vips.uz/api/38/1984/32534'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          dart =
              jsonData.map((item) => Map<String, dynamic>.from(item)).toList();
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

  Future<void> postData() async {
    // String hashedPassword =
    //     BCrypt.hashpw(passwordController.toString(), BCrypt.gensalt());

    final String apiUrl = "https://dash.vips.uz/api-up/38/1984/29837";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'apipassword': 'f1234',
          'where': 'id:$stafid',
          'rasm':
              selectedAvatarId != null ? dart[selectedAvatarId!]['rasm'] : '',
          'fullname': fullNameController.text,
          'number': numberController.text,
          'login': loginController.text,
          //'parol': hashedPassword,
        },
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color.fromARGB(255, 0, 2, 137),
            content: Text(
              "Profil o'zgartirildi",
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
            "Profilni o'zgartirishda xatolik yuz berdi!",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 0, 2, 137),
        title: Text("Profilni o'zgartirish"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ism familya',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 2, 137),
              ),
            ),
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Telefon nomer',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 2, 137),
              ),
            ),
            TextField(
              controller: numberController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Foydalanuvchi nom',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 2, 137),
              ),
            ),
            TextField(
              controller: loginController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            SizedBox(height: 35),
            Text(
              'Rasmlar',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 2, 137),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: dart.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAvatarId = index;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage:
                              NetworkImage('${dart[index]['rasm']}'),
                          child: selectedAvatarId == index
                              ? Icon(
                                  Icons.check,
                                  color: Colors.green[800],
                                  size: 60,
                                )
                              : null,
                        ),
                        SizedBox(width: 15),
                      ],
                    ),
                  );
                },
              ),
            ),
            Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  postData();
                },
                child: Container(
                  width: 120,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 0, 2, 137),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Center(
                    child: Text(
                      'Saqlash',
                      style: TextStyle(fontSize: 19, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
