import 'package:absensi_web/homescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController idController = TextEditingController();
  TextEditingController passController = TextEditingController();
  double screenHeight = 0;
  double screenWidth = 0;

  Color primary = Color(0xFF176B87);
  late SharedPreferences sharedPreferences;
  bool obscure = true; // Untuk mengontrol visibilitas password

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: screenHeight / 3,
              width: screenWidth,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(80),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: screenWidth / 4,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: screenHeight / 15,
                bottom: screenHeight / 30,
              ),
              child: Text(
                "Login",
                style: TextStyle(
                  fontSize: screenWidth / 20,
                  fontFamily: "font_1",
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(
                horizontal: screenWidth / 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  fieldTitle("Masukan NIM"),
                  customField("Masukan NIM kamu", idController),
                  fieldTitle("Masukan password"),
                  customPasswordField("Masukan password kamu", passController),
                  GestureDetector(
                    onTap: () async {
                      String id = idController.text.trim();
                      String password = passController.text.trim();

                      if (id.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("NIM tidak boleh kosong"),
                        ));
                      } else if (password.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Password tidak boleh kosong"),
                        ));
                      } else {
                        QuerySnapshot querySnapshot = await FirebaseFirestore
                            .instance
                            .collection("NIM")
                            .where('id', isEqualTo: id)
                            .get();

                        print(
                            "Database Firebase terpanggil: ${querySnapshot.docs.length}");

                        for (var document in querySnapshot.docs) {
                          print(
                              "ID: ${document['id']}, Password: ${document['password']}");
                        }

                        if (querySnapshot.docs.isNotEmpty) {
                          try {
                            var firstDocumentData = querySnapshot.docs[0].data()
                                as Map<String, dynamic>;
                            var hashedPasswordFromDatabase =
                                firstDocumentData['password'];

                            if (password == hashedPasswordFromDatabase) {
                              print("Password cocok, lanjutkan");

                              sharedPreferences =
                                  await SharedPreferences.getInstance();
                              sharedPreferences
                                  .setString("NimId", id)
                                  .then((_) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen()));
                              });
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Periksa kembali password kamu"),
                              ));
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text("Terjadi kesalahan: ${e.toString()}"),
                            ));
                          }
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Periksa lagi Nim kamu"),
                          ));
                        }
                      }
                    },
                    child: Container(
                      height: 60,
                      width: screenWidth,
                      margin: EdgeInsets.only(top: screenHeight / 40),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Center(
                        child: Text(
                          "LOGIN",
                          style: TextStyle(
                            fontFamily: "font_2",
                            fontSize: screenWidth / 26,
                            color: Colors.white,
                            letterSpacing: 2,
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
    );
  }

  Widget fieldTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth / 26,
          fontFamily: "font_2",
        ),
      ),
    );
  }

  Widget customField(String hint, TextEditingController controller) {
    return Container(
      width: screenWidth,
      margin: EdgeInsets.only(bottom: screenHeight / 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth / 7,
            child: Icon(
              Icons.person,
              color: primary,
              size: screenWidth / 15,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth / 12),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight / 30,
                  ),
                  border: InputBorder.none,
                  hintText: hint,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget customPasswordField(String hint, TextEditingController controller) {
    return Container(
      width: screenWidth,
      margin: EdgeInsets.only(bottom: screenHeight / 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth / 7,
            child: Icon(
              Icons.person,
              color: primary,
              size: screenWidth / 15,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth / 12),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight / 30,
                  ),
                  border: InputBorder.none,
                  hintText: hint,
                ),
                maxLines: 1,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  obscure = !obscure;
                });
              },
              child: Container(
                width: 40, // Sesuaikan lebar container
                height: 40, // Sesuaikan tinggi container
                padding: EdgeInsets.all(8), // Sesuaikan padding
                child: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: primary,
                  size: screenWidth / 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
