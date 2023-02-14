import 'package:abo_app/models/cards.dart';
import 'package:abo_app/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoneyStats extends StatefulWidget {
  MoneyStats(this.cardDigits, {super.key});
  String cardDigits;

  @override
  State<MoneyStats> createState() => _MoneyStatsState();
}

class _MoneyStatsState extends State<MoneyStats> {
  int incomeTotal = 0;
  int expenseTotal = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<CardDetails?> readCardDetails() async {
    final docUser =
        FirebaseFirestore.instance.collection('cards').doc(widget.cardDigits);
    final snapshot = await docUser.get();
    return CardDetails.fromJson(snapshot.data()!);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.blue[300],
          ),
          child: Row(children: [
            Container(
              height: double.infinity,
              width: 50,
              margin: const EdgeInsets.all(4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue[500],
              ),
              child: const Icon(
                FluentIcons.money_24_filled,
                size: 30,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.01,
                  horizontal: MediaQuery.of(context).size.height * 0.015),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Income",
                    style: Styles.transactionTitle.copyWith(
                        color: Colors.black54,
                        fontSize: MediaQuery.of(context).size.width / 27,
                        letterSpacing: -0.7),
                  ),
                  FutureBuilder<CardDetails?>(
                      future: readCardDetails(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var snapData = snapshot.data!;
                          return Text(
                            "\$${snapData.incomeTotal}",
                            style: GoogleFonts.roboto(
                              textStyle: Styles.headlineStyle2,
                              fontWeight: FontWeight.w700,
                              color: Styles.blackColor,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.03,
                            ),
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      }),
                ],
              ),
            ),
          ]),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black12,
          ),
          child: Row(children: [
            Container(
              height: double.infinity,
              width: 50,
              margin: const EdgeInsets.all(4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black26,
              ),
              child: const Icon(
                FluentIcons.money_dismiss_24_filled,
                size: 30,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.01,
                  horizontal: MediaQuery.of(context).size.height * 0.015),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Expense",
                    style: Styles.transactionTitle.copyWith(
                        color: Colors.black54,
                        fontSize: MediaQuery.of(context).size.width / 30,
                        letterSpacing: -0.7),
                  ),
                  FutureBuilder<CardDetails?>(
                    future: readCardDetails(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var snapData = snapshot.data!;
                        return Text(
                          "\$${snapData.expenseTotal}",
                          style: GoogleFonts.roboto(
                            textStyle: Styles.headlineStyle2,
                            fontWeight: FontWeight.w700,
                            color: Styles.blackColor,
                            fontSize: MediaQuery.of(context).size.height * 0.03,
                          ),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  )
                ],
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
