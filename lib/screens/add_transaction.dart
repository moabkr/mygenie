import 'package:abo_app/screens/bottom_nav_bar.dart';
import 'package:abo_app/utils/custom_page_route.dart';
import 'package:abo_app/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class AddTransaction extends StatefulWidget {
  final Function addTx;
  const AddTransaction(this.addTx, {super.key});

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  bool _incomeType = true;
  int currentIndex = 0;
  String _transactionStatus = "";
  bool _isVisible = true;

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _incomeType = !_incomeType;
    });
  }

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  List<dynamic> fieldValues = [];
  bool _validateName = false;

  static DateTime _selectedDate = DateTime.now();

  void submitData() {
    if (_amountController.text.isEmpty || _amountController.text != int) {
      setState(() {
        _validateName = true;
      });
      FocusScope.of(context).unfocus();
      return;
    }
    final enteredFinal = _titleController.text;
    final enteredAmount = double.parse(_amountController.text);

    if (enteredFinal.isEmpty || enteredAmount <= 0) {
      return;
    }

    FocusScope.of(context).unfocus();
    _titleController.clear();
    _amountController.clear();

    try {
      if (_incomeType == true) {
        FirebaseFirestore.instance
            .collection('cards')
            .doc(fieldValues[currentIndex][1].toString())
            .update({
          'balance': FieldValue.increment(enteredAmount),
          'incomeTotal': FieldValue.increment(enteredAmount)
        });
      } else {
        FirebaseFirestore.instance
            .collection('cards')
            .doc(fieldValues[currentIndex][1].toString())
            .update({
          'balance': FieldValue.increment(-enteredAmount),
          'expenseTotal': FieldValue.increment(enteredAmount)
        });
      }
      widget.addTx(
        enteredFinal,
        enteredAmount,
        _incomeType,
        fieldValues[currentIndex][1].toString(),
      );
      setState(() {
        _transactionStatus = "lib/images/success.json";
      });
    } catch (error) {
      setState(() {
        _transactionStatus = "lib/images/fail.json";
      });
    }
  }

  void _presentDatePicker() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2019),
            lastDate: DateTime.now())
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
    print("...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
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
                              style: Styles.headlineStyle3.copyWith(),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                              CustomPageRoute(child: const BottomNavBar(0)));
                        },
                      ),
                    ),
                    FutureBuilder(
                      future:
                          FirebaseFirestore.instance.collection('cards').get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var len = snapshot.data!.docs.length;
                          if (len > 0) {
                            for (var doc in snapshot.data!.docs) {
                              fieldValues
                                  .add([doc.data()["title"], doc.data()["id"]]);
                            }
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  currentIndex =
                                      (currentIndex + 1) % fieldValues.length;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  fieldValues[currentIndex][0],
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
                const Gap(30),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextField(
                      style: Styles.headlineStyle3
                          .copyWith(color: Styles.blackColor),
                      decoration: InputDecoration(
                        suffixIcon: Container(
                          width: 0,
                          decoration: const BoxDecoration(
                              border: Border(
                                  left: BorderSide(
                                      width: 2.0, color: Colors.black38))),
                          child: IconButton(
                            padding: const EdgeInsets.all(0),
                            onPressed: () {
                              // Update the state i.e. toogle the state of passwordVisible variable
                              setState(() {
                                _incomeType = !_incomeType;
                              });
                            },
                            icon: Icon(
                              _incomeType ? Icons.add : Icons.remove,
                              size: 35,
                              color: _incomeType ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        hintText: "Title",
                        hintStyle: Styles.headlineStyle3,
                        contentPadding: const EdgeInsets.only(
                          left: 15,
                          bottom: 20,
                          top: 20,
                          right: 15,
                        ),
                      ),
                      controller: _titleController,
                      keyboardType: TextInputType.text,
                      onSubmitted: (_) => submitData(),
                      // onChanged: ((value) {
                      //   amountInput = value;
                      // }),
                    ),
                    const Gap(10),
                    TextField(
                      onTap: () {
                        setState(() {
                          _validateName = false;
                        });
                      },
                      style: Styles.headlineStyle3
                          .copyWith(color: Styles.blackColor),
                      decoration: InputDecoration(
                        prefixIcon: _validateName == false
                            ? Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: Text(
                                  "\$",
                                  style: Styles.headlineStyle2
                                      .copyWith(fontSize: 30),
                                ))
                            : const Icon(
                                Icons.error,
                                color: Colors.redAccent,
                              ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        hintText: "Amount",
                        hintStyle: Styles.headlineStyle3,
                        contentPadding: const EdgeInsets.only(
                          left: 15,
                          bottom: 20,
                          top: 20,
                          right: 15,
                        ),
                      ),
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      onSubmitted: (_) => submitData(),
                      // onChanged: ((value) {
                      //   amountInput = value;
                      // }),
                    ),
                    SizedBox(
                      height: 70,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                _selectedDate == null
                                    ? "No date chosen!"
                                    : DateFormat.yMd().format(_selectedDate),
                                style: Styles.headlineStyle3
                                    .copyWith(fontSize: 15),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Styles.blueColor),
                              onPressed: _presentDatePicker,
                              child: Text(
                                'Chosen Date',
                                style: TextStyle(
                                    color: Styles.whiteColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ]),
                    ),
                  ],
                ),
                _transactionStatus != ""
                    ? SizedBox(
                        child: Center(
                        child: Lottie.asset(_transactionStatus,
                            onLoaded: (composition) {
                          Future.delayed(composition.duration, () {
                            setState(() {
                              _isVisible = false;
                              _transactionStatus = "";
                            });
                          });
                        }),
                      ))
                    : const SizedBox(),
                const Spacer(),
                GestureDetector(
                  onTap: submitData,
                  child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                          color: Styles.blueColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                          child: Text(
                        "Submit",
                        style: Styles.headlineStyle2.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Styles.whiteColor),
                      ))),
                )
              ],
            )),
      ),
    );
  }
}
