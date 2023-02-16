import 'package:mygenie/models/transactions.dart';
import 'package:mygenie/screens/bottom_nav_bar.dart';
import 'package:mygenie/utils/custom_page_route.dart';
import 'package:mygenie/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class FullTransaction extends StatefulWidget {
  const FullTransaction({super.key});

  @override
  State<FullTransaction> createState() => _FullTransactionState();
}

class _FullTransactionState extends State<FullTransaction> {
  List<String> titleValues = [];
  List<String> idValues = [];
  NumberFormat numberFormat = NumberFormat("#,##0.00", "en_US");

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

  Future<void> deleteDocumentById(String documentId) async {
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(documentId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: MediaQuery.of(context).size.height * 0.05,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(30)),
                  child: GestureDetector(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_back_ios),
                        Text(
                          "Go Back",
                          style: Styles.headlineStyle3.copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      Navigator.of(context)
                          .push(CustomPageRoute(child: const BottomNavBar(2)));
                    },
                  ),
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
            const Gap(10),
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
                        children: const [
                          Text(
                            "Transactions",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: Color.fromARGB(255, 90, 90, 90)),
                          ),
                          // GestureDetector(
                          //   onTap: () {
                          //     Navigator.of(context).push(CustomPageRoute(
                          //         child: const FullTransaction()));
                          //   },
                          //   child: Text(
                          //     "Delete",
                          //     style: Styles.headlineStyle3.copyWith(
                          //         color: Colors.red.shade700,
                          //         fontWeight: FontWeight.w500,
                          //         fontSize: 17),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    StreamBuilder<List<TransactionData>>(
                        stream: readTransactions(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final transactions = snapshot.data!;
                            if (idValues.isEmpty) {
                              return Center(
                                heightFactor:
                                    MediaQuery.of(context).size.height * 0.01,
                                child:
                                    const Text("You have no cards added yet."),
                              );
                            }
                            if (snapshot.data!.isEmpty) {
                              return Center(
                                heightFactor:
                                    MediaQuery.of(context).size.height * 0.01,
                                child: const Text("No transactions available"),
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
            )
          ],
        ),
      ),
    );
  }

  Future<bool> promptUser(TransactionData transactions) async {
    return await showCupertinoDialog<bool>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            content: Column(
              children: [
                const Text("Are you sure you want to delete this transaction?"),
                Gap(MediaQuery.of(context).size.height * 0.01),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.01),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 1, color: Colors.black12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Center(child: Text(transactions.title)),
                      Center(
                          child: Text(
                              "-\$${(numberFormat.format(transactions.amount))}")),
                    ],
                  ),
                )
              ],
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text("Ok"),
                onPressed: () {
                  setState(() {
                    deleteDocumentById(transactions.id);
                  });
                  Navigator.of(context).pop(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Deleted ${transactions.title}')));
                },
              ),
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () {
                  // Dismiss the dialog but don't
                  // dismiss the swiped item
                  return Navigator.of(context).pop(false);
                },
              )
            ],
          ),
        ) ??
        false; // In case the user dismisses the dialog by clicking away from it
  }

  Widget buildTransaction(TransactionData transactions) => Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (_) {
                if (promptUser(transactions) == true) {}
              },
              backgroundColor: Colors.red.shade500,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        key: ValueKey<String>(transactions.id + transactions.date.toString()),
        // confirmDismiss: (direction) => promptUser(transactions),
        // background: Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Container(
        //         child: Icon(
        //       Icons.delete,
        //       color: Colors.red.shade400,
        //     )),
        //   ],
        // ),
        child: Column(
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
                        style: Styles.transactionAmount
                            .copyWith(color: Colors.red),
                      ),
              ),
            ),
          ],
        ),
      );
}
