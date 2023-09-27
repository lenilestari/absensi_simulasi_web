import 'package:absensi_web/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({super.key});

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  Color primary = Color(0xFF176B87);

  String _month = DateFormat('MMMM').format(DateTime.now());

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
              margin: const EdgeInsets.only(top: 35),
              child: Text(
                "My Attendance",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "font_2",
                  fontSize: screenWidth / 15,
                ),
              ),
            ),
            Stack(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 30),
                  child: Text(
                    _month,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: "font_2",
                      fontSize: screenWidth / 18,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(top: 30),
                  child: GestureDetector(
                    onTap: () async {
                      final month = await showMonthYearPicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2100),
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
                          });

                      if (month != null) {
                        setState(() {
                          _month = DateFormat('MMMM').format(month);
                        });
                      }
                    },
                    child: Text(
                      "Pick a Month",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "font_2",
                        fontSize: screenWidth / 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: screenHeight - screenHeight / 5,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("NIM")
                    .doc(User.id)
                    .collection("Record")
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    final snap = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: snap.length,
                      itemBuilder: (context, index) {
                        return DateFormat('MMMM')
                                    .format(snap[index]['date'].toDate()) ==
                                _month
                            ? Container(
                                margin: EdgeInsets.only(
                                    top: index > 0 ? 15 : 0, left: 6, right: 6),
                                height: 150,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(2, 2),
                                    )
                                  ],
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(20)),
                                          color: primary,
                                        ),
                                        child: Center(
                                          child: Text(
                                            DateFormat('EE\ndd').format(
                                                snap[index]['date'].toDate()),
                                            style: TextStyle(
                                              fontFamily: "font_2",
                                              fontSize: screenWidth / 17,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                            snap[index]['checkIn'],
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                            snap[index]['checkOut'],
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
                              )
                            : const SizedBox();
                      },
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
