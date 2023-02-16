import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mygenie/models/cards.dart';
import 'package:mygenie/utils/styles.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Cards extends StatefulWidget {
  const Cards({super.key});

  @override
  State<Cards> createState() => _CardsState();
}

class _CardsState extends State<Cards> {
  Stream<List<CardDetails>> readCards() => FirebaseFirestore.instance
      .collection('cards')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => CardDetails.fromJson(doc.data()))
          .toList());
  NumberFormat numberFormat = NumberFormat("#,##0.00", "en_US");
  final _pageViewController = PageController();

  final List cardBg = [
    "lib/images/color_one.png",
    "lib/images/color_four.png",
  ];

  final List cardDesigns = [
    "lib/images/2.png",
    "lib/images/3.png",
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.width / 1.9,
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<CardDetails>>(
                stream: readCards(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text("error");
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return Container(
                      margin: const EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(50, 0, 0, 0),
                          borderRadius: BorderRadius.circular(20)),
                      child: Transform.scale(
                          scale: 1.5,
                          child:
                              Lottie.asset("lib/images/space_animation.json")),
                    );
                  } else {
                    final cards = snapshot.data!;

                    return PageView(
                        padEnds: false,
                        controller: _pageViewController,
                        onPageChanged: (value) =>
                            {print(snapshot.data![value].id)},
                        physics: const ClampingScrollPhysics(),
                        children: cards.map(buildCards).toList());
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('cards').get(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  var len = snapshot.data!.docs.length;

                  if (len > 0) {
                    return SmoothPageIndicator(
                      controller: _pageViewController,
                      count: len,
                      effect: ExpandingDotsEffect(
                          dotColor: Colors.black12,
                          activeDotColor: Styles.blueColor,
                          radius: 5,
                          dotWidth: 20,
                          expansionFactor: 2,
                          strokeWidth: 50,
                          spacing: 10),
                    );
                  } else {
                    return Container(
                      child: const Center(
                        child: Text(
                          "Looks like you haven't added a card yet",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.5),
                        ),
                      ),
                    );
                  }
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCards(CardDetails cardInfo) => Container(
      margin: const EdgeInsets.all(5),
      width: double.infinity,
      decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
                color: Color.fromARGB(255, 146, 146, 146),
                blurRadius: 40,
                spreadRadius: 0,
                blurStyle: BlurStyle.inner),
          ],
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
              image: AssetImage("lib/images/color_four.png"),
              fit: BoxFit.fill)),
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 35.0,
            bottom: 25.0,
            left: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Available balance", style: Styles.headlineStyle3),
                  Text('\$${(numberFormat.format(cardInfo.balance))}',
                      style: Styles.headlineStyle1.copyWith(fontSize: 33)),
                ],
              ),
              SizedBox(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(cardInfo.title,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Styles.blackColor)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Positioned(
            left: 200,
            bottom: -110,
            child: Image.asset(
              'lib/images/3.png',
            ))
      ]));
}
