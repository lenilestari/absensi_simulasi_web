import 'dart:async';

import 'package:absensi_web/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({Key? key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  String checkIn = "--/--";
  String checkOut = "--/--";

  String location = " ";

  bool isCheckingIN = true; // ini untuk mengontrol tampilan daily report

  bool Perizinan = true; // ini untuk mengontrol tampilan daily report

  String dailyReportText = ""; // ini untuk nyimpan teks dari daily report

  String PerizinanText = ""; // ini untuk nyimpan teks dari perizinan

  Color primary = Color(0xFF176B87);

  @override
  void initState() {
    super.initState();
    _getRecord();
  }

  void _sendPerizinan() async {
    try {
      // Pertama, dapatkan lokasi saat ini
      await _getLocation();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("NIM")
          .where('id', isEqualTo: User.usernameId)
          .get();

      // Membuat dokumen perizinan dengan tanggal hari ini
      await FirebaseFirestore.instance
          .collection("NIM")
          .doc(querySnapshot.docs[0].id)
          .collection("Perizinan")
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
          .set({
        'date': Timestamp.now(),
        'perizinanText': PerizinanText, // Menyimpan teks perizinan
        'perizinanLocation': location, // Menyimpan lokasi perizinan
      });

      // Mengubah tampilan untuk menampilkan bahwa perizinan telah dikirim
      setState(() {
        Perizinan = false;
      });
    } catch (e) {
      // Handle error jika ada
      print("Error: $e");
    }
  }

  Future<void> _getLocation() async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(User.lat, User.long);

    setState(() {
      location =
          "${placemark[0].street}, ${placemark[0].administrativeArea}, ${placemark[0].postalCode}, ${placemark[0].country}";
      dailyReportText +=
          "\nLocation: $location"; // Menambahkan lokasi ke daily report
    });
  }

  void _getRecord() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("NIM")
          .where('id', isEqualTo: User.usernameId)
          .get();

      DocumentSnapshot querySnapshot2 = await FirebaseFirestore.instance
          .collection("NIM")
          .doc(querySnapshot.docs[0].id)
          .collection("Record")
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
          .get();

      setState(() {
        checkIn = querySnapshot2['checkIn'];
        checkOut = querySnapshot2['checkOut'];
        dailyReportText = querySnapshot2['dailyReportText'] ??
            ""; // Mengambil data daily report jika ada
      });
    } catch (e) {
      setState(() {
        checkIn = "--/--";
        checkOut = "--/--";
      });
    }
    print(checkIn);
    print(checkOut);
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
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(top: 32),
              child: Text(
                "Welcome",
                style: TextStyle(
                  color: Colors.black26,
                  fontFamily: "font_2",
                  fontSize: screenWidth / 15,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                User.usernameId,
                style: TextStyle(
                  fontFamily: "font_2",
                  fontSize: screenWidth / 15,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(top: 28),
              child: Text(
                "Status absen hari ini",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "font_2",
                  fontSize: screenWidth / 18,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15, bottom: 25),
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(2, 2),
                  )
                ],
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Check In",
                          style: TextStyle(
                            fontFamily: "font_2",
                            fontSize: screenWidth / 20,
                            color: Colors.black26,
                          ),
                        ),
                        Text(
                          checkIn,
                          style: TextStyle(
                            fontFamily: "font_2",
                            fontSize: screenWidth / 15,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Check Out",
                          style: TextStyle(
                            fontFamily: "font_2",
                            fontSize: screenWidth / 20,
                            color: Colors.black26,
                          ),
                        ),
                        Text(
                          checkOut,
                          style: TextStyle(
                            fontFamily: "font_2",
                            fontSize: screenWidth / 15,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  text: DateTime.now().day.toString(),
                  style: TextStyle(
                    color: primary,
                    fontSize: screenWidth / 15,
                    fontFamily: "font_2",
                  ),
                  children: [
                    TextSpan(
                      text: DateFormat(' MMMM yyyy').format(DateTime.now()),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth / 15,
                        fontFamily: "font_2",
                      ),
                    ),
                  ],
                ),
              ),
            ),
            StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      DateFormat('hh:mm:ss a').format(DateTime.now()),
                      style: TextStyle(
                        fontFamily: "font_2",
                        fontSize: screenWidth / 20,
                        color: Colors.black26,
                      ),
                    ),
                  );
                }),
            checkOut == "--/--"
                ? Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 12),
                    child: Builder(
                      builder: (context) {
                        final GlobalKey<SlideActionState> key = GlobalKey();

                        return SlideAction(
                            text: checkIn == "--/--"
                                ? "Slide to check in"
                                : "Slide to check out",
                            textStyle: TextStyle(
                              color: Colors.black,
                            ),
                            outerColor: Colors.white,
                            innerColor: primary,
                            key: key,
                            onSubmit: () async {
                              if (User.lat != 0) {
                                _getLocation();

                                print(
                                    DateFormat('hh:mm').format(DateTime.now()));

                                QuerySnapshot querySnapshot =
                                    await FirebaseFirestore.instance
                                        .collection("NIM")
                                        .where('id', isEqualTo: User.usernameId)
                                        .get();

                                print(querySnapshot.docs[0].id);
                                print(DateFormat('dd MMMM yyyy')
                                    .format(DateTime.now()));

                                DocumentSnapshot querySnapshot2 =
                                    await FirebaseFirestore.instance
                                        .collection("NIM")
                                        .doc(querySnapshot.docs[0].id)
                                        .collection("Record")
                                        .doc(DateFormat('dd MMMM yyyy')
                                            .format(DateTime.now()))
                                        .get();

                                try {
                                  // if(querySnapshot2['checkIn']);
                                  String checkIn = querySnapshot2['checkIn'];

                                  setState(() {
                                    checkOut = DateFormat('hh:mm')
                                        .format(DateTime.now());
                                  });

                                  await FirebaseFirestore.instance
                                      .collection("NIM")
                                      .doc(querySnapshot.docs[0].id)
                                      .collection("Record")
                                      .doc(DateFormat('dd MMMM yyyy')
                                          .format(DateTime.now()))
                                      .update({
                                    // 'type' : 'attendance',
                                    'date': Timestamp.now(),
                                    'checkIn': checkIn,
                                    'checkOut': DateFormat('hh:mm')
                                        .format(DateTime.now()),
                                    'CheckInLocation': location,
                                    'dailyReportText':
                                        dailyReportText, // Menyimpan daily report
                                  });
                                } catch (e) {
                                  setState(() {
                                    checkIn = DateFormat('hh:mm')
                                        .format(DateTime.now());
                                  });
                                  await FirebaseFirestore.instance
                                      .collection("NIM")
                                      .doc(querySnapshot.docs[0].id)
                                      .collection("Record")
                                      .doc(DateFormat('dd MMMM yyyy')
                                          .format(DateTime.now()))
                                      .set({
                                    'date': Timestamp.now(),
                                    'checkIn': DateFormat('hh:mm')
                                        .format(DateTime.now()),
                                    'checkOut': "--/--",
                                    'CheckOutLocation': location,
                                    'dailyReportText':
                                        dailyReportText, // Menyimpan daily report
                                  });
                                }

                                print(
                                    "Database Firebase terpanggil: ${querySnapshot.docs.length}");
                                // key.currentState!.reset();

                                // print(querySnapshot2['checkIn']);
                              } else {
                                Timer(Duration(seconds: 3), () async {
                                  _getLocation();

                                  print(DateFormat('hh:mm')
                                      .format(DateTime.now()));

                                  QuerySnapshot querySnapshot =
                                      await FirebaseFirestore.instance
                                          .collection("NIM")
                                          .where('id',
                                              isEqualTo: User.usernameId)
                                          .get();

                                  print(querySnapshot.docs[0].id);
                                  print(DateFormat('dd MMMM yyyy')
                                      .format(DateTime.now()));

                                  DocumentSnapshot querySnapshot2 =
                                      await FirebaseFirestore.instance
                                          .collection("NIM")
                                          .doc(querySnapshot.docs[0].id)
                                          .collection("Record")
                                          .doc(DateFormat('dd MMMM yyyy')
                                              .format(DateTime.now()))
                                          .get();

                                  try {
                                    // if(querySnapshot2['checkIn']);
                                    String checkIn = querySnapshot2['checkIn'];

                                    setState(() {
                                      checkOut = DateFormat('hh:mm')
                                          .format(DateTime.now());
                                    });

                                    await FirebaseFirestore.instance
                                        .collection("NIM")
                                        .doc(querySnapshot.docs[0].id)
                                        .collection("Record")
                                        .doc(DateFormat('dd MMMM yyyy')
                                            .format(DateTime.now()))
                                        .update({
                                      'date': Timestamp.now(),
                                      'checkIn': checkIn,
                                      'checkOut': DateFormat('hh:mm')
                                          .format(DateTime.now()),
                                      'CheckInLocation': location,
                                      'dailyReportText':
                                          dailyReportText, // Menyimpan daily report
                                    });
                                  } catch (e) {
                                    setState(() {
                                      checkIn = DateFormat('hh:mm')
                                          .format(DateTime.now());
                                    });
                                    await FirebaseFirestore.instance
                                        .collection("NIM")
                                        .doc(querySnapshot.docs[0].id)
                                        .collection("Record")
                                        .doc(DateFormat('dd MMMM yyyy')
                                            .format(DateTime.now()))
                                        .set({
                                      'date': Timestamp.now(),
                                      'checkIn': DateFormat('hh:mm')
                                          .format(DateTime.now()),
                                      'checkOut': "--/--",
                                      'CheckOutLocation': location,
                                      'dailyReportText':
                                          dailyReportText, // Menyimpan daily report
                                    });
                                  }

                                  print(
                                      "Database Firebase terpanggil: ${querySnapshot.docs.length}");
                                  key.currentState!.reset();
                                });
                              }

                              // key.currentState!.reset();
                            });
                      },
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.only(top: 30, bottom: 30),
                    child: Text(
                      "You have completed this day",
                      style: TextStyle(
                        fontFamily: "font_2",
                        fontSize: screenWidth / 20,
                        color: Colors.black26,
                      ),
                    ),
                  ),
            location != " "
                ? Text(
                    "Location : " + location,
                  )
                : const SizedBox(),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: isCheckingIN
                  ? Container(
                      // Tampilkan daily report saat check-in
                      child: Column(
                        children: [
                          // Tambahkan konten daily report di sini
                          Text(
                            "Daily Report",
                            style: TextStyle(
                              fontFamily: "font_2",
                              fontSize: screenWidth / 20,
                              color: Colors.black,
                            ),
                          ),

                          SizedBox(height: 10),
                          TextFormField(
                            // Ini adalah input teks untuk daily report
                            decoration: InputDecoration(
                              // labelText: 'Daily Report',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 7,
                            onChanged: (text) {
                              // Mengambil nilai input dan menyimpannya
                              setState(() {
                                dailyReportText = text;
                              });
                            },
                          ),
                        ],
                      ),
                    )
                  : Container(), // Sembunyikan daily report saat check-out
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Perizinan
                  ? Container(
                      // Tampilkan perizinan saat check-in
                      child: Column(
                        children: [
                          // Tambahkan konten perizinan di sini
                          Text(
                            "Perizinan",
                            style: TextStyle(
                              fontFamily: "font_2",
                              fontSize: screenWidth / 20,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            // Ini adalah input teks untuk perizinan
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 2,
                            onChanged: (text) {
                              // Mengambil nilai input dan menyimpannya
                              setState(() {
                                PerizinanText = text;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () async {
                              await _getLocation(); // dapatkan lokasi saat di klik tombol

                              _sendPerizinan(); // kirim data ke firebase
                            },
                            child: Text('Submit Perizinan'),
                          ),
                        ],
                      ),
                    )
                  : Container(), // Sembunyikan perizinan saat check-out
            ),
          ],
        ),
      ),
    );
  }
}
