import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bcrypt/bcrypt.dart';
import 'dart:convert';
import 'main.dart';
import 'profiloch.dart';

class LoginIn extends StatefulWidget {
  const LoginIn({Key? key}) : super(key: key);

  @override
  State<LoginIn> createState() => _LoginInState();
}

class _LoginInState extends State<LoginIn> {
  TextEditingController fullnameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool showPassword = false;
  bool showError = false;
  String errorMessage = '';

  // Predefined list of users
  List<Map<String, String>> predefinedUsers = [
    {
      'fullname': 'Farhodjon Murodov',
      'login': 'fr',
      'number': '+998 90 577 45 35'
    }
    // Add other predefined users here
  ];

  @override
  void dispose() {
    fullnameController.dispose();
    phoneController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void navigateToLoginPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Login(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 2, 137),
        title: Text(
          "Ro'yxatdan o'ting",
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            SizedBox(height: 50),
            TextField(
              controller: fullnameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Ism Familya",
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Telefon nomer",
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Foydalanuvchi nom",
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: !showPassword,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Parol",
                suffixIcon: IconButton(
                  icon: Icon(
                    showPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: navigateToLoginPage,
                child: Text(
                  "Eski profildan kirish >",
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 2, 137),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Visibility(
              visible: showError,
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ),
            SizedBox(height: 80),
            GestureDetector(
              onTap: () async {
                if (_areFieldsEmpty()) {
                  setState(() {
                    showError = true;
                    errorMessage = "Iltimos, barcha maydonlarni to'ldiring";
                  });
                } else {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );

                  // Check if user exists locally
                  bool userExistsLocally = _checkUserExistsLocally(
                    fullnameController.text,
                    phoneController.text,
                    usernameController.text,
                  );

                  if (userExistsLocally) {
                    Navigator.of(context).pop();
                    setState(() {
                      showError = true;
                      errorMessage =
                          "Bu ma'lumotlar bilan profil allaqachon yaratilgan, boshqa o'ylab toping";
                    });
                  } else {
                    // Check if user exists remotely
                    bool userExistsRemotely = await checkUserExists(
                      fullnameController.text,
                      phoneController.text,
                      usernameController.text,
                    );

                    Navigator.of(context).pop();

                    if (userExistsRemotely) {
                      setState(() {
                        showError = true;
                        errorMessage =
                            "Bu ma'lumotlar bilan profil allaqachon yaratilgan, boshqa o'ylab toping";
                      });
                    } else {
                      // Post data
                      await postData(
                        fullnameController.text,
                        phoneController.text,
                        usernameController.text,
                        passwordController.text,
                      );
                      final snackBar = SnackBar(
                        content: Text(
                            "Ro'yxatdan o'tish muvaffaqiyatli amalga oshirildi"),
                        backgroundColor: Colors.green,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      navigateToLoginPage();
                    }
                  }
                }
              },
              child: Container(
                width: 120,
                height: 40,
                child: Center(
                  child: Text(
                    "Tasdiqlash",
                    style: TextStyle(fontSize: 19, color: Colors.white),
                  ),
                ),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 0, 2, 137),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => home(),
                    ),
                  );
                },
                child: Text("O'tkazib yuborish >"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _areFieldsEmpty() {
    return fullnameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty;
  }

  bool _checkUserExistsLocally(String fullname, String tel, String username) {
    for (var user in predefinedUsers) {
      if (user['fullname'] == fullname &&
          user['number'] == tel &&
          user['login'] == username) {
        return true;
      }
    }
    return false;
  }

  Future<bool> checkUserExists(
      String fullname, String tel, String username) async {
    final String apiUrl =
        "https://dash.vips.uz/api/38/1984/29837?fullname=$fullname&number=$tel&login=$username";
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        // Check if any existing user matches the provided details
        for (var item in jsonData) {
          String apiFullname = item["fullname"];
          String apiPhone = item["number"];
          String apiUsername = item["login"];
          print(
              "API Fullname: $apiFullname, API Phone: $apiPhone, API Username: $apiUsername");

          if (apiFullname == fullname &&
              apiPhone == tel &&
              apiUsername == username) {
            return true;
          }
        }
        return false;
      } else {
        print('Foydalanuvchini tekshirish muvaffaqiyatsiz bo\'ldi');
        return false;
      }
    } catch (error) {
      print('Foydalanuvchini tekshirishda xatolik: $error');
      return false;
    }
  }

  Future<void> postData(
    String fullname,
    String tel,
    String username,
    String password,
  ) async {
    String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

    final String apiUrl = "https://dash.vips.uz/api-in/38/1984/29837";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'apipassword': 'f1234',
          'fullname': fullname,
          'number': tel,
          'login': username,
          'parol': hashedPassword,
        },
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
      } else {
        print('Failed to post data');
      }
    } catch (error) {
      print('Error posting data: $error');
    }
  }
}
