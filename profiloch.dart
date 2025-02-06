import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:bcrypt/bcrypt.dart';
import 'main.dart'; // Ensure this imports the correct home page widget

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final stil = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: Color.fromARGB(255, 10, 25, 103));
  final still = TextStyle(fontSize: 12, color: Colors.teal[600]);
  dynamic parol = '';
  var name = "";
  bool isLoading = false;
  bool showAdvertisement = true;

  @override
  void initState() {
    super.initState();
    checkApiOnce();
  }

  void checkApiOnce() async {
    try {
      final response =
          await http.get(Uri.parse('https://dash.vips.uz/api/38/1984/29837'));

      if (response.statusCode == 200) {
        // Process the response if needed
        print('API check successful');
      } else {
        print('Failed to check API');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void login(String user) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse('https://dash.vips.uz/api/38/1984/29837?login=$user'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);

        for (var item in jsonData) {
          parol = (item["parol"]);
          print(parol);
          name = (item["login"]);
          print(name);
          await SessionManager().set("Ids", (item["id"]));
          await SessionManager().set("Ism", (item["fullname"]));
          await SessionManager().set("tel", (item["number"]));
        }

        bool correctPassword = BCrypt.checkpw(_passwordController.text, parol);

        if (correctPassword) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => home()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Foydalanuvchi nom yoki parol hato!"),
            backgroundColor: Colors.blue,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Foydalanuvchi nom yoki parol hato!"),
        ));
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isChecked = false;
  bool showPassword = false;

  void closeAdvertisement() {
    setState(() {
      showAdvertisement = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Kirish",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 0, 2, 137),
        elevation: 5,
        centerTitle: true,
        leading: null,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                child: Column(
                  children: [
                    Text(
                      "Profilingizga kiring",
                      style: stil,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Profilga kirish uchun foydalanuvchi nom va parol kiriting!",
                      style: still,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Foydalanuvchi nom"),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 50,
                            child: TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text("Parol"),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 50,
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                TextField(
                                  controller: _passwordController,
                                  style: TextStyle(fontSize: 15),
                                  obscureText: !showPassword,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    showPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      showPassword = !showPassword;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Checkbox(
                                  activeColor: Color.fromARGB(255, 0, 2, 137),
                                  value: isChecked,
                                  onChanged: (newBool) {
                                    setState(() {
                                      isChecked = !isChecked;
                                    });
                                  }),
                              SizedBox(
                                width: 5,
                              ),
                              Text("Eslab qolish")
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: FittedBox(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(255, 0, 2, 137),
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () => login(
                                          _usernameController.text,
                                        ),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(75, 12, 75, 12),
                                  child: isLoading
                                      ? CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.green))
                                      : Text(
                                          "Kirish",
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: Colors.white),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
