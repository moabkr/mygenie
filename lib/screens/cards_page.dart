import 'package:mygenie/models/cards.dart';
import 'package:mygenie/screens/add_card.dart';
import 'package:mygenie/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  Stream<List<CardDetails>> readCards() => FirebaseFirestore.instance
      .collection('cards')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => CardDetails.fromJson(doc.data()))
          .toList());

  Future _addNewCard(
    String txTitle,
    double txBalance,
    int txCardDigits,
  ) async {
    final docUser = FirebaseFirestore.instance.collection('cards').doc();
    final newTx = CardDetails(
      id: docUser.id,
      title: txTitle,
      balance: txBalance,
      cardDigits: txCardDigits,
      // incomeTotal: 0,
      // expenseTotal: 0,
    );
    final json = newTx.toJson();
    await docUser.set(json);
    print("new card added");
  }

  Future<void> deleteDocumentsByFieldValue(
      String collectionName, String fieldName, dynamic fieldValue) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .where(fieldName, isEqualTo: fieldValue)
        .get();
    for (var document in querySnapshot.docs) {
      document.reference.delete();
    }
  }

  NumberFormat numberFormat = NumberFormat("#,##0.00", "en_US");

  void showCustomDialog(BuildContext context, String cardId, String cardTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: RichText(
            text: TextSpan(
              text: 'Are you sure you want to delete card ',
              children: [
                TextSpan(
                    text: '$cardTitle?',
                    style: Styles.headlineStyle2
                        .copyWith(fontSize: 17, fontWeight: FontWeight.w600))
              ],
              style: Styles.headlineStyle2
                  .copyWith(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final cardUser =
                    FirebaseFirestore.instance.collection('cards').doc(cardId);
                deleteDocumentsByFieldValue(
                    "transactions", 'cardDigits', cardId);
                cardUser.delete();
                Navigator.of(context).pop();
              },
              child: const Text("Yes"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageViewController = PageController();

    return Scaffold(
      backgroundColor: Styles.whiteColor,
      body: Container(
        child: Column(children: [
          Gap(MediaQuery.of(context).size.height * 0.015),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: const Color.fromARGB(10, 0, 0, 0),
                  borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "My Cards",
                      style: Styles.headlineStyle2
                          .copyWith(color: Styles.blackColor),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<CardDetails>>(
                        stream: readCards(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Text("error");
                          } else {
                            final cards = snapshot.data!;

                            return ListView(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                controller: pageViewController,
                                physics: const ClampingScrollPhysics(),
                                children: cards.map(buildCards).toList());
                          }
                        }),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return AddCard(_addNewCard);
            })),
            child: Container(
                padding: const EdgeInsets.all(15.0),
                margin: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                    child: Text(
                  "Create new card",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Styles.whiteColor,
                      fontSize: 20),
                ))),
          )
        ]),
      ),
    );
  }

  Widget buildCards(CardDetails cardInfo) => Container(
      margin: const EdgeInsets.all(5),
      width: double.infinity,
      height: 200,
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
        Positioned(
            left: 200, bottom: -110, child: Image.asset('lib/images/3.png')),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  GestureDetector(
                    onTap: () {
                      showCustomDialog(context, cardInfo.id, cardInfo.title);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 20),
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(255, 220, 244, 255),
                            width: 2),
                        color: const Color.fromARGB(184, 0, 0, 0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.delete_outline_sharp,
                        size: 30,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ]));
}
