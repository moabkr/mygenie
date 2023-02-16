import 'package:mygenie/models/cards.dart';
import 'package:mygenie/models/transactions.dart';
import 'package:mygenie/screens/full_transactions.dart';
import 'package:mygenie/utils/card_info.dart';
import 'package:mygenie/utils/custom_page_route.dart';
import 'package:mygenie/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  List<String> titleValues = [];
  List<String> idValues = [];
  int analyticsVar = 0;

  Stream<List<TransactionData>> readTransactions() => idValues.isEmpty
      ? FirebaseFirestore.instance
          .collection('transactions')
          .orderBy("date", descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => TransactionData.fromJson(doc.data()))
              .toList())
      : FirebaseFirestore.instance
          .collection('transactions')
          .where("cardDigits", isEqualTo: idValues[currentIndex])
          // .orderBy("date", descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => TransactionData.fromJson(doc.data()))
              .toList());

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    getData().then((value) {
      setState(() {
        idValues = value;
      });
    });
  }

  Future<List<String>> getData() async {
    final collection = FirebaseFirestore.instance.collection("cards");
    List<String> idValues = [];
    QuerySnapshot snapshot = await collection.get();
    for (var doc in snapshot.docs) {
      idValues.add(doc.get("id") as String);
    }
    print(idValues);
    return idValues;
  }

  Future<CardDetails?> readCardDetails() async {
    final docUser = FirebaseFirestore.instance
        .collection('cards')
        .doc(idValues[currentIndex]);
    final snapshot = await docUser.get();
    return CardDetails.fromJson(snapshot.data()!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.whiteColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.height * 0.02,
            vertical: MediaQuery.of(context).size.height * 0.01),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Text("Spendings",
                      style: Styles.headlineStyle1.copyWith(fontSize: 30)),
                ),
                FutureBuilder(
                  future: FirebaseFirestore.instance.collection('cards').get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var len = snapshot.data!.docs.length;
                      if (len > 0) {
                        for (var doc in snapshot.data!.docs) {
                          titleValues.add(doc.data()["title"]);
                        }

                        return InkWell(
                          onTap: () {
                            setState(() {
                              currentIndex =
                                  (currentIndex + 1) % idValues.length;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              titleValues[currentIndex],
                              style: TextStyle(color: Styles.blueColor),
                            ),
                          ),
                        );
                      } else {
                        return const Center(
                          child: Text("No Cards"),
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
            Gap(MediaQuery.of(context).size.height * 0.01),
            SizedBox(
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: MediaQuery.of(context).size.height * 0.01,
                crossAxisSpacing: MediaQuery.of(context).size.height * 0.01,
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(context).size.height * 0.0019,
                shrinkWrap: true,
                children: [
                  CardInfo(
                    title: 'Balance',
                    amount: FutureBuilder<CardDetails?>(
                      future: readCardDetails(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var snapData = snapshot.data!;
                          return Text(
                            "\$${snapData.balance}",
                            style: GoogleFonts.roboto(
                              textStyle: Styles.headlineStyle2,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromARGB(172, 0, 0, 0),
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.018,
                            ),
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                    icon: 'balance',
                    color: Colors.deepPurple.shade300,
                  ),
                  CardInfo(
                    title: 'Income',
                    amount: FutureBuilder<CardDetails?>(
                      future: readCardDetails(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var snapData = snapshot.data!;
                          return Text(
                            "+\$${snapData.balance}",
                            style: GoogleFonts.roboto(
                              textStyle: Styles.headlineStyle2,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromARGB(172, 0, 0, 0),
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.018,
                            ),
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                    icon: 'income',
                    color: Colors.deepOrange.shade300,
                  ),
                  CardInfo(
                    title: 'Expense',
                    amount: FutureBuilder<CardDetails?>(
                      future: readCardDetails(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var snapData = snapshot.data!;
                          return Text(
                            "-\$${snapData.balance}",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: const Color.fromARGB(172, 0, 0, 0),
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.018,
                            ),
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                    icon: 'expense',
                    color: Colors.teal.shade300,
                  ),
                  CardInfo(
                    title: 'Analytics',
                    amount: FutureBuilder<CardDetails?>(
                      future: readCardDetails(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var snapData = snapshot.data!;
                          return const Text(
                            "+10.36%",
                            // style: GoogleFonts.roboto(
                            //   textStyle: Styles.headlineStyle2,
                            //   fontWeight: FontWeight.w700,
                            //   color: Styles.blackColor,
                            //   fontSize:
                            //       MediaQuery.of(context).size.height * 0.03,
                            // ),
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                    icon: 'analytics',
                    color: Colors.blue.shade300,
                  ),
                ],
              ),
            ),
            Gap(MediaQuery.of(context).size.height * 0.01),
            Container(
              height: MediaQuery.of(context).size.height * 0.05,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 227, 227, 227),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  "You have saved over \$$analyticsVar over the last week!",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Gap(MediaQuery.of(context).size.height * 0.01),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 245, 245, 245),
                    borderRadius: BorderRadius.circular(5)),
                child: Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.only(top: 15, left: 25, right: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Transactions",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: Color.fromARGB(255, 90, 90, 90)),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(CustomPageRoute(
                                  child: const FullTransaction()));
                            },
                            child: Text(
                              "See all",
                              style: Styles.headlineStyle3.copyWith(
                                  color: Colors.blue.shade700,
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
                            if (transactions.isEmpty) {
                              return Center(
                                heightFactor:
                                    MediaQuery.of(context).size.height * 0.01,
                                child: const Text("No transactions"),
                              );
                            } else {
                              return Expanded(
                                child: ListView(
                                    physics: const ClampingScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    children: transactions
                                        .map(buildTransaction)
                                        .toList()),
                              );
                            }
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        })
                  ],
                ),
              ),
            )
            // statistics boxes income, outcome, balance, analytics

            // transactions
          ],
        ),
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
