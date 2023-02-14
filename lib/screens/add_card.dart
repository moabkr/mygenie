import 'package:abo_app/screens/bottom_nav_bar.dart';
import 'package:abo_app/utils/custom_page_route.dart';
import 'package:abo_app/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AddCard extends StatefulWidget {
  final Function addTx;
  const AddCard(this.addTx, {super.key});

  @override
  State<AddCard> createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  bool _incomeType = true;
  int currentIndex = 0;

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _incomeType = !_incomeType;
    });
  }

  final _titleController = TextEditingController();
  final _balanceController = TextEditingController();
  final _digitsController = TextEditingController();
  List<dynamic> fieldValues = [];

  static DateTime _selectedDate = DateTime.now();

  void submitData() {
    if (_balanceController.text.isEmpty) {
      return;
    }
    final enteredText = _titleController.text;

    final enteredBalance = double.parse(_balanceController.text);
    final enteredDigits = int.parse(_digitsController.text);

    if (enteredText.isEmpty ||
        enteredBalance <= 0 ||
        enteredDigits < 0 ||
        enteredDigits <= 4) {
      return;
    }

    widget.addTx(
      enteredText,
      enteredBalance,
      enteredDigits,
    );
    Navigator.of(context).push(CustomPageRoute(child: const BottomNavBar(1)));
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Card Details",
                      style: Styles.headlineStyle2.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: Styles.blackColor),
                    ),
                    const Gap(30),
                    TextField(
                      style: Styles.headlineStyle3
                          .copyWith(color: Styles.blackColor),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        fillColor: Colors.white10,
                        filled: true,
                        hintText: "Card Name",
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
                      style: Styles.headlineStyle3
                          .copyWith(color: Styles.blackColor),
                      decoration: InputDecoration(
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Text(
                            "\$",
                            style: Styles.headlineStyle2.copyWith(fontSize: 30),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        fillColor: Colors.white10,
                        filled: true,
                        hintText: "Balance",
                        hintStyle: Styles.headlineStyle3,
                        contentPadding: const EdgeInsets.only(
                          left: 15,
                          bottom: 20,
                          top: 20,
                          right: 15,
                        ),
                      ),
                      controller: _balanceController,
                      keyboardType: TextInputType.number,
                      onSubmitted: (_) => submitData(),
                      // onChanged: ((value) {
                      //   amountInput = value;
                      // }),
                    ),
                    const Gap(10),
                    TextField(
                      style: Styles.headlineStyle3
                          .copyWith(color: Styles.blackColor),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        fillColor: Colors.white10,
                        filled: true,
                        hintText: "Last Four Card Digits",
                        hintStyle: Styles.headlineStyle3,
                        contentPadding: const EdgeInsets.only(
                          left: 15,
                          bottom: 20,
                          top: 20,
                          right: 15,
                        ),
                      ),
                      controller: _digitsController,
                      keyboardType: TextInputType.number,
                      onSubmitted: (_) => submitData(),
                      // onChanged: ((value) {
                      //   amountInput = value;
                      // }),
                    ),
                  ],
                ),
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
                        "Add Card",
                        style: Styles.headlineStyle2.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Styles.whiteColor,
                            fontSize: 20),
                      ))),
                )
              ],
            )),
      ),
    );
  }
}
