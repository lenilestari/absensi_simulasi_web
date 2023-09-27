import 'package:absensi_web/model/user.dart';
import 'package:absensi_web/profilescreen.dart';
import 'package:absensi_web/services/location_services.dart';
import 'package:absensi_web/todayscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'calenderscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  Color primary = Color(0xFF176B87);

  int currentIndex = 1;

  List<IconData> navigationIcons = [
    FontAwesomeIcons.calendar,
    FontAwesomeIcons.check,
    FontAwesomeIcons.user,
  ];

  @override
  void initState() {
    super.initState();
    _startLocationServices();
    _createCredentials();
    getId();
  }

  void _createCredentials() async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection("NIM").doc(User.id).get();
    setState(() {
      User.canEdit = doc['canEdit'];
      User.firstName = doc['firstName'];
      User.lastName = doc['lastName'];
      User.birthDate = doc['birtDate'];
      User.address = doc['address'];
    });
  }

  void _startLocationServices() async {
    LocationServices().initialize();

    LocationServices().getLongitude().then((value) {
      setState(() {
        User.long = value!;
      });

      LocationServices().getLatitude().then((value) {
        setState(() {
          User.lat = value!;
        });
      });
    });
  }

  void getId() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("NIM")
        .where('id', isEqualTo: User.usernameId)
        .get();

    setState(() {
      User.id = querySnapshot.docs[0].id;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          new CalenderScreen(),
          new TodayScreen(),
          new ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        margin: const EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: 24,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(const Radius.circular(30)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment
                .spaceEvenly, // Memastikan jarak yang sama antara ikon-ikon
            children: [
              for (int i = 0; i < navigationIcons.length; i++)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = i;
                    });
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.all(8.0), // Menambahkan jarak di sini
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            navigationIcons[i],
                            color: i == currentIndex ? primary : Colors.black26,
                            size: i == currentIndex ? 30 : 26,
                          ),
                          i == currentIndex
                              ? Container(
                                  margin: EdgeInsets.only(top: 6),
                                  height: 3,
                                  width: 20,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(30)),
                                    color: primary,
                                  ),
                                )
                              : const SizedBox()
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
