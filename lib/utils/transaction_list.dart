import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mygenie/models/transactions.dart';
import 'package:mygenie/screens/full_transactions.dart';
import 'package:mygenie/utils/custom_page_route.dart';
import 'package:mygenie/utils/styles.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});
  // String txCardID;

  Stream<List<TransactionData>> readTransactions() => FirebaseFirestore.instance
      .collection('cards')
      .doc("Z5MaPvAse3OOnUPTLfbq")
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
