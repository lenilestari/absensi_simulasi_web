// import 'dart:ffi';
import 'dart:io';

import 'package:absensi_web/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  Color primary = Color(0xFF176B87);
  String birth = "Date of Birth";

  // String downloadUrl; // untul upload foto

  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController addressName = TextEditingController();

  void pickUploadProfilePic() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 90,
    );

    Reference ref = FirebaseStorage.instance
        .ref()
        .child("${User.usernameId.toLowerCase()}_profile.jpg");

    TaskSnapshot uploadedFile = await ref.putFile(File(image!.path));

    if (uploadedFile.state == TaskState.success) {
      String downloadUrl = await ref.getDownloadURL();
      setState(() {
        User.profilePickLink = downloadUrl;
      });
    }

    await FirebaseFirestore.instance.collection("NIM").doc(User.id).update({
      'profilePicture': User.profilePickLink,
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                pickUploadProfilePic();
              },
              child: Container(
                margin: const EdgeInsets.only(top: 80, bottom: 25),
                height: 120,
                width: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: primary,
                ),
                child: Center(
                  child: User.profilePickLink == " "
                      ? const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 80,
                        )
                      : ClipRect(
                          child: Image.network(User.profilePickLink),
                        ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Hai ${User.usernameId}",
                style: const TextStyle(
                  fontFamily: "font_2",
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            User.canEdit
                ? textField("First Name", "Firt Name", firstName)
                : field("First Name", User.firstName),
            User.canEdit
                ? textField("Last Name", "Last Name", lastName)
                : field("Last Name", User.lastName),
            GestureDetector(
              onTap: () {
                showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1945),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: primary,
                            secondary: primary,
                            onSecondary: Colors.white,
                          ),
                          textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                            primary: primary,
                          )),
                          textTheme: const TextTheme(
                            headline4: TextStyle(
                              fontFamily: "font_2",
                            ),
                            overline: TextStyle(
                              fontFamily: "font_2",
                            ),
                            button: TextStyle(
                              fontFamily: "font_2",
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    }).then((value) {
                  setState(() {
                    birth = DateFormat("MM/dd/yyyy").format(value!);
                  });
                });
              },
              child: field("Date of Birth", birth),
            ),
            User.canEdit
                ? textField("Address", "Address", addressName)
                : field("Address", User.address),
            User.canEdit
                ? GestureDetector(
                    onTap: () async {
                      String namaPertama = firstName.text;
                      String namaKedua = lastName.text;
                      String ulangTahun = birth;
                      String Alamat = addressName.text;

                      if (User.canEdit) {
                        if (namaPertama.isEmpty) {
                          showSnackBar("Please enter your first name!");
                        } else if (namaKedua.isEmpty) {
                          showSnackBar("Please enter your last name!");
                        } else if (ulangTahun.isEmpty) {
                          showSnackBar("Please enter your birth date!");
                        } else if (Alamat.isEmpty) {
                          showSnackBar("Please enter your address!");
                        } else {
                          await FirebaseFirestore.instance
                              .collection("NIM")
                              .doc(User.id)
                              .update({
                            'firstName': namaPertama,
                            'lastName': namaKedua,
                            'birtDate': ulangTahun,
                            'address': Alamat,
                            'canEdit': false,
                          }).then((value) {
                            setState(() {
                              User.canEdit = false;
                              User.firstName = namaPertama;
                              User.lastName = namaKedua;
                              User.birthDate = ulangTahun;
                              User.address = Alamat;
                            });
                          });
                        }
                      } else {
                        showSnackBar(
                            "You can't edit anymore, please contact support team");
                      }
                    },
                    child: Container(
                      height: kToolbarHeight,
                      width: screenWidth,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: primary,
                      ),
                      child: const Center(
                        child: Text(
                          "SAVE",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "font_2",
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget field(String title, String text) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "font_2",
              color: Colors.black26,
            ),
          ),
        ),
        Container(
          height: kToolbarHeight,
          width: screenWidth,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Colors.black26,
              )),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black26,
                fontFamily: "font_2",
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget textField(
      String hint, String title, TextEditingController controller) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "font_2",
              color: Colors.black26,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
            bottom: 12,
          ),
          child: TextFormField(
            controller: controller,
            cursorColor: Colors.black26,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Colors.black26,
                fontFamily: "font_2",
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black26,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black26,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          text,
        ),
      ),
    );
  }
}
