import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mygenie/models/cards.dart';
import 'package:mygenie/models/transactions.dart';
import 'package:mygenie/screens/full_transactions.dart';
import 'package:mygenie/utils/custom_page_route.dart';
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
  late PageController _pageViewController;

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
                            {TransactionList2(snapshot.data![value].id)},
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

class TransactionList2 extends StatefulWidget {
  TransactionList2(this.txCardID, {super.key});
  String txCardID;

  @override
  State<TransactionList2> createState() => _TransactionList2State();
}

class _TransactionList2State extends State<TransactionList2> {
  String cardIdOfficial = "";
  void getCardId() {
    setState(() {
      cardIdOfficial = widget.txCardID;
    });
  }

  Stream<List<TransactionData>> readTransactions() => FirebaseFirestore.instance
      .collection('cards')
      .doc(cardIdOfficial)
      .collection('transactions')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => TransactionData.fromJson(doc.data()))
          .toList());

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width / 1.5,
      width: double.infinity,
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 245, 245, 245),
          borderRadius: BorderRadius.circular(5)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 15, left: 25, right: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Transactions",
                  style: GoogleFonts.openSans(
                      fontWeight: FontWeight.w600,
                      textStyle: Styles.headlineStyle2,
                      fontSize: 20,
                      color: const Color.fromARGB(255, 90, 90, 90)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(CustomPageRoute(child: const FullTransaction()));
                  },
                  child: Text(
                    "See all",
                    style: Styles.headlineStyle3.copyWith(
                        color: Styles.blueColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 17),
                  ),
                ),
              ],
            ),
          ),
          StreamBuilder<List<TransactionData>>(
              stream: readTransactions(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final transactions = snapshot.data!;

                  return Expanded(
                    child: ListView(
                        physics: const ClampingScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: transactions.map(buildTransaction).toList()),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ],
      ),
    );
  }

  Widget buildTransaction(TransactionData transactions) => Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 245, 245, 245),
              border: Border(
                  bottom: BorderSide(
                      width: 1, color: Color.fromARGB(255, 224, 224, 224))),
            ),
            margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              leading: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 250, 250, 250),
                  radius: 25,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: FittedBox(
                        alignment: Alignment.center,
                        child: Image.asset(
                          transactions.income == true
                              ? "lib/images/card_income.png"
                              : "lib/images/card_expense.png",
                          height: 35,
                          width: 35,
                          color: Styles.blackColor,
                        )),
                  )),
              title: Text(
                transactions.title,
                style: Styles.transactionTitle,
              ),
              subtitle: Text(DateFormat.yMMMd().format(transactions.date),
                  style: Styles.transactionDate),
              trailing: transactions.income == true
                  ? Text(
                      "+\$${transactions.amount.toString()}",
                      style: Styles.transactionAmount
                          .copyWith(color: Colors.green),
                    )
                  : Text(
                      "-\$${transactions.amount.toString()}",
                      style:
                          Styles.transactionAmount.copyWith(color: Colors.red),
                    ),
            ),
          ),
        ],
      );
}
