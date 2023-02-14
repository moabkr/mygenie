import 'package:abo_app/models/cards.dart';
import 'package:abo_app/models/transactions.dart';
import 'package:abo_app/screens/add_transaction.dart';
import 'package:abo_app/screens/full_transactions.dart';
import 'package:abo_app/utils/custom_page_route.dart';
import 'package:abo_app/utils/money_notes.dart';
import 'package:abo_app/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future _addNewTransaction(
    String txTitle,
    double txAmount,
    bool txIncome,
    String txCardID,
  ) async {
    final docUser = FirebaseFirestore.instance.collection('transactions').doc();
    final newTx = TransactionData(
      id: docUser.id,
      title: txTitle,
      amount: txAmount,
      date: DateTime.now(),
      cardDigits: txCardID,
      income: txIncome,
    );
    final json = newTx.toJson();
    await docUser.set(json);
    print("transaction added");
  }

  Stream<List<CardDetails>> readCards() => FirebaseFirestore.instance
      .collection('cards')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => CardDetails.fromJson(doc.data()))
          .toList());

  NumberFormat numberFormat = NumberFormat("#,##0.00", "en_US");
  final _pageViewController = PageController();
  late String cardIdOfficial;

  @override
  void initState() {
    cardIdOfficial = '';
    super.initState();
  }

  Stream<List<TransactionData>> readTransactions() => FirebaseFirestore.instance
      .collection('transactions')
      .where("cardDigits", isEqualTo: cardIdOfficial)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => TransactionData.fromJson(doc.data()))
          .toList());

  @override
  Widget build(BuildContext context) {
    int currentindex = 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Transform(
                transform: Matrix4.skewY(0.2)..rotateZ(-1 / 20.0),
                child: Transform.scale(
                  scale: 1.5,
                  child: Image.asset(
                    "lib/images/2.png",
                    color: const Color.fromARGB(30, 115, 178, 255),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Transform(
                transform: Matrix4.skewY(0.2)..rotateZ(-5 / 20.0),
                child: Transform.scale(
                  scale: 4,
                  child: Image.asset(
                    "lib/images/2.png",
                    color: const Color.fromARGB(20, 96, 168, 255),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.01,
                  left: 20,
                  right: 20),
              child: Column(
                children: [
                  // card widgets
                  ShaderMask(
                    shaderCallback: (Rect rect) {
                      return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Styles.blueColor,
                          Colors.transparent,
                          Colors.transparent,
                          Styles.blueColor
                        ],
                        stops: const [
                          0.0,
                          0.03,
                          0.97,
                          1.3
                        ], // 10% purple, 80% transparent, 10% purple
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstOut,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.27,
                      child: Column(
                        children: [
                          Expanded(
                            child: StreamBuilder(
                                stream: readCards(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return const Text("error");
                                  } else if (snapshot.hasData &&
                                      snapshot.data!.isEmpty) {
                                    return Container(
                                      margin: const EdgeInsets.all(10),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          color:
                                              const Color.fromARGB(50, 0, 0, 0),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Transform.scale(
                                          scale: 1.5,
                                          child: Lottie.asset(
                                              "lib/images/space_animation.json")),
                                    );
                                  } else {
                                    final cards = snapshot.data!;
                                    if (cardIdOfficial == '') {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        setState(() {
                                          cardIdOfficial = snapshot
                                              .data![_pageViewController
                                                  .initialPage]
                                              .id;
                                        });
                                      });
                                    }

                                    return PageView(
                                        padEnds: false,
                                        controller: _pageViewController,
                                        onPageChanged: (value) => {
                                              setState(() {
                                                cardIdOfficial =
                                                    snapshot.data![value].id;
                                              })
                                            },
                                        physics: const ClampingScrollPhysics(),
                                        children:
                                            cards.map(buildCards).toList());
                                  }
                                }),
                          ),
                          Gap(MediaQuery.of(context).size.height * 0.01),
                          FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('cards')
                                .get(),
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
                        ],
                      ),
                    ),
                  ),

                  Gap(MediaQuery.of(context).size.height * 0.01),

                  // action buttons (add expense, add income)

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.02),
                        decoration: BoxDecoration(
                            color: Styles.blueColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Image.asset(
                              "lib/images/card_income.png",
                              height: 25,
                              color: Styles.whiteColor,
                            ),
                            const Gap(10),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) {
                                return AddTransaction(_addNewTransaction);
                              })),
                              child: Text(
                                "Add income",
                                style: Styles.headlineStyle3.copyWith(
                                    color: Styles.whiteColor,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 25),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(MediaQuery.of(context).size.height * 0.01),
                      Container(
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.02),
                        decoration: BoxDecoration(
                            color: Styles.blueColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Image.asset(
                              "lib/images/card_expense.png",
                              height: 25,
                              color: Styles.whiteColor,
                            ),
                            const Gap(10),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) {
                                return AddTransaction(_addNewTransaction);
                              })),
                              child: Text(
                                "Add expense",
                                style: Styles.headlineStyle3.copyWith(
                                    color: Styles.whiteColor,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 25),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap(MediaQuery.of(context).size.height * 0.015),

                  // transactions
                  Container(
                    height: MediaQuery.of(context).size.height * 0.31,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 245, 245, 245),
                        borderRadius: BorderRadius.circular(5)),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.01,
                              left: 25,
                              right: 25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Transactions",
                                style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.w600,
                                    textStyle: Styles.headlineStyle2,
                                    fontSize: 20,
                                    color:
                                        const Color.fromARGB(255, 90, 90, 90)),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(CustomPageRoute(
                                      child: const FullTransaction()));
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

                                if (snapshot.hasData &&
                                    snapshot.data!.isEmpty) {
                                  return const Center(
                                    heightFactor: 10,
                                    child: Text("No transactions available"),
                                  );
                                }
                                return Expanded(
                                  child: ListView(
                                      physics: const ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      children: transactions
                                          .map(buildTransaction)
                                          .toList()),
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            }),
                      ],
                    ),
                  ),

                  Gap(MediaQuery.of(context).size.height * 0.01),

                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.09,
                      child: MoneyStats(cardIdOfficial)),
                ],
              ),
            ),
          ],
        ),
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
                      "+\$${(numberFormat.format(transactions.amount))}",
                      style: Styles.transactionAmount
                          .copyWith(color: Colors.green),
                    )
                  : Text(
                      "-\$${(numberFormat.format(transactions.amount))}",
                      style:
                          Styles.transactionAmount.copyWith(color: Colors.red),
                    ),
            ),
          ),
        ],
      );
}
