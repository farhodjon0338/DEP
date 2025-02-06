import 'dart:async';
import 'package:flutter/material.dart';
import 'batafsil.dart';
import 'bronlar.dart';
import 'commet.dart';
import 'eslatma.dart';
import 'kirish.dart';
import 'profil.dart';
import 'sevimli.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'splashekrn.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: App(),
  ));
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Simulate loading data
    await Future.delayed(Duration(seconds: 4));
    // Call the necessary functions to load data here
    await fetchData();
    // After data is loaded, navigate to HomeScreen
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => home(),
    ));
  }

  Future<void> fetchData() async {
    // Load your data here
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen();
  }
}

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> originalData = [];
  List<Map<String, dynamic>> dart = [];
  List<Map<String, dynamic>> tur = [];
  List<Map<String, dynamic>> rey = [];
  List<Map<String, dynamic>> ism = [];
  bool isLoading = true;
  bool hasError = false;
  bool isLiked = false;
  dynamic stafid = "";
  bool showDialogOnce = false;
  Set<String> bookmarkedItems = Set();
  late Timer _timer;
  bool isPosting = false;

  @override
  void initState() {
    super.initState();
    _checkAndShowProfileDialog();
    turr();
    dataa('2');
    reyt(AutofillHints.addressCity);
    _loadBookmarkedItems();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      _loadBookmarkedItems();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> reyt(String id) async {
    try {
      final response =
          await http.get(Uri.parse('https://dash.vips.uz/api/38/1984/29835'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          rey.clear(); // rey listini tozalaymiz
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

  Future<void> dataa([String selectedCategoryId = '2']) async {
    try {
      // Define the API endpoint URL
      String apiUrl = 'https://dash.vips.uz/api/38/1984/29826';

      // Append the categoryId to the URL if it's not empty
      if (selectedCategoryId.isNotEmpty) {
        apiUrl += '?kategoryid=$selectedCategoryId&status=1';
      }

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          originalData.clear();
          dart.clear();
          for (var item in jsonData) {
            originalData.add(Map<String, dynamic>.from(item));
            dart.add(Map<String, dynamic>.from(item));
          }
          isLoading = false;
        });

        if (jsonData.isNotEmpty) {
          reyt(dart
              .first['id']); // Pass the id of the first item to reyt function
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> turr() async {
    try {
      final response =
          await http.get(Uri.parse('https://dash.vips.uz/api/38/1984/29830'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          tur.clear(); // tur listini tozalaymiz
          for (var item in jsonData) {
            tur.add(Map<String, dynamic>.from(item));
          }
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

  Future<void> addFavorite(String bronId) async {
    dynamic stafid = await SessionManager().get("Ids");
    final String apiUrl = "https://dash.vips.uz/api-in/38/1984/29836";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'apipassword': 'f1234',
          'bronid': bronId,
          'userid': stafid.toString(), // Remove unnecessary string conversion
        },
      );

      if (response.statusCode == 200) {
        print('Added to favorites successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color.fromARGB(255, 0, 2, 137),
            content: Text(
              "Sevimlilarga qo'shildi",
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        throw Exception('Failed to add to favorites: ${response.body}');
      }
    } catch (error) {
      print('Error adding to favorites: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 0, 2, 137),
          content: Text(
            "Sevimlilarga qo'shilgan",
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _loadBookmarkedItems() async {
    try {
      // Load user ID from session manager
      stafid = await SessionManager().get("Ids");

      if (stafid == null || stafid.toString().isEmpty) {
        throw Exception('User ID not found');
      }

      // API call to fetch bookmarked items for the user
      final response = await http.get(
        Uri.parse('https://dash.vips.uz/api/38/1984/29836?userid=$stafid'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          bookmarkedItems.clear();
          for (var item in jsonData) {
            bookmarkedItems.add(item['bronid'].toString());
          }
        });
      } else {
        throw Exception('Failed to load bookmarked items');
      }
    } catch (error) {
      print('Error fetching bookmarked items: $error');
    }
  }

  void _launchTelegram() async {
    const telegramURL = 'https://t.me/muradov_F/';
    try {
      await launch(telegramURL);
    } catch (e) {
      print('Error launching Telegram: $e');
    }
  }

  Future<void> addOrRemoveFavorite(String id) async {
    setState(() {
      isPosting = true;
    });

    try {
      var stafid = await SessionManager().get("Ids");
      if (stafid == null || stafid.toString().isEmpty) {
        // Show Snackbar with message to register/login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color.fromARGB(255, 0, 2, 137),
            content: Text(
              "Iltimos, ro'yxatdan o'ting",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );

        // Navigate to Login screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginIn()),
        );
        return; // Exit the function if not logged in
      }

      if (bookmarkedItems.contains(id)) {
        // If the item is already bookmarked, show a message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color.fromARGB(255, 0, 2, 137),
            content: Text(
              "Bu ma'lumot oldin saqlangan",
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 1),
          ),
        );
        return; // Exit the function if the item is already bookmarked
      }

      // Add the item to favorites
      await addFavorite(id);

      // Update the bookmarked items set
      setState(() {
        bookmarkedItems.add(id);
      });

      // Optionally, you can show a success message here
    } catch (error) {
      print('Xatolik yuz berdi: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Xatolik yuz berdi, iltimos qayta urinib ko'ring",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } finally {
      setState(() {
        isPosting = false;
      });
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

  void filterOrders(String query) {
    setState(() {
      if (query.isEmpty) {
        dart = List.from(originalData);
      } else {
        dart = originalData
            .where((order) =>
                order['nomi'].toLowerCase().contains(query.toLowerCase()) ||
                order['narx'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _navigateBasedOnStafid(BuildContext context) async {
    stafid = await SessionManager().get("Ids");
    if (stafid == null || stafid.toString().isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginIn()),
      );
    }
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Eslatma !',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
          ),
          content: Text(
            'Profilingizni to\'ldiring va unutmang. To\'ldirish uchun "Profilga kirish" tugmasini bosing!',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Keyinroq'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Profilga kirish'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginIn()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshData() async {
    await dataa('2');
    await turr();
    await reyt(AutofillHints.addressCity);
    await _loadBookmarkedItems();
  }

  void _checkAndShowProfileDialog() async {
    stafid = await SessionManager().get("Ids");
    if ((stafid == null || stafid.toString().isEmpty) && !showDialogOnce) {
      showDialogOnce = true; // Set the flag to true after showing dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showProfileDialog(context);
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Orenda",
          style: GoogleFonts.alata(
            textStyle: TextStyle(
                color: Color.fromARGB(255, 0, 2, 137),
                letterSpacing: 2,
                fontSize: 32,
                fontWeight: FontWeight.w700),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                if (stafid == null || stafid.toString().isEmpty) {
                  _navigateBasedOnStafid(context);
                }
              },
              icon: Icon(stafid == null || stafid.toString().isEmpty
                  ? Icons.login
                  : null)),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 0, 2, 137),
                  image: DecorationImage(image: AssetImage(''))),
              child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 25),
                    child: Text(
                      "Orenda",
                      style: GoogleFonts.alata(
                        textStyle: TextStyle(
                            color: Colors.white,
                            letterSpacing: 2,
                            fontSize: 32,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  )),
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: Color.fromARGB(255, 0, 2, 137),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text('Bronlar'),
                ],
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Bronlar(),
                    ));
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.note_outlined,
                    color: Color.fromARGB(255, 0, 2, 137),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text('Eslatmalar'),
                ],
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Remenber(),
                    ));
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    color: Color.fromARGB(255, 0, 2, 137),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text('Saqlangan'),
                ],
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => sevimli(),
                    ));
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings_outlined,
                    color: Color.fromARGB(255, 0, 2, 137),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text('Aloqa'),
                ],
              ),
              onTap: () {
                _launchTelegram();
              },
            ),
            if (stafid != null && stafid.toString().isNotEmpty)
              ListTile(
                title: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: Color.fromARGB(255, 0, 2, 137),
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text('Profil'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => profil(),
                      ));
                },
              ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                filterOrders(value);
              },
              cursorRadius: Radius.circular(8),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                hintText: "Qidiruv...",
                suffixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 5),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tur.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 26),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            String categoryId = tur[index]['id'].toString();
                            dataa(categoryId);
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.scaleDown,
                                image: NetworkImage(
                                  tur[index]['rasm'],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text('${tur[index]['nomi']}'),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : hasError
                      ? Center(
                          child: Text(
                              "Aloqani tekshiring yoki, Vaqtincha ma'lumotlar topilmadi"),
                        )
                      : RefreshIndicator(
                          onRefresh: _refreshData,
                          child: ListView.builder(
                              itemCount: dart.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Batafsil(
                                                  productDetails: dart[index]),
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
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: IconButton(
                                                  onPressed: isPosting
                                                      ? null
                                                      : () {
                                                          addOrRemoveFavorite(
                                                              dart[index]['id']
                                                                  .toString());
                                                        },
                                                  icon: Icon(
                                                    bookmarkedItems.contains(
                                                            dart[index]['id']
                                                                .toString())
                                                        ? Icons
                                                            .bookmark_added_rounded
                                                        : Icons
                                                            .bookmark_outline,
                                                    color: bookmarkedItems
                                                            .contains(
                                                                dart[index]
                                                                        ['id']
                                                                    .toString())
                                                        ? Colors.green
                                                        : Colors.blue,
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.black,
                                                        blurRadius: 3,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                  dart[index]['rasmi'],
                                                ),
                                                fit: BoxFit.cover),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15))),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '${dart[index]['nomi']}',
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600),
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
                                            '${calculateAverageRating(rey.where((item) => item['bronid'] == dart[index]['id']).toList())}')
                                      ],
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          dart[index]['narx'] != null
                                              ? '\$${dart[index]['narx']}'
                                              : '',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700),
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
                                                bronId: dart[index]['id']
                                                    .toString()),
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
                                );
                              }),
                        ),
            )
          ],
        ),
      ),
    );
  }
}
