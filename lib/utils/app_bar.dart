import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mygenie/utils/styles.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color.fromARGB(255, 29, 29, 29)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              text: 'My',
              children: [
                TextSpan(
                    text: 'Genie',
                    style:
                        Styles.headlineStyle2.copyWith(color: Styles.blueColor))
              ],
              style: Styles.headlineStyle2.copyWith(color: Styles.whiteColor),
            ),
          ),
          Row(
            children: [
              Text(
                "Jonathan",
                style: Styles.headlineStyle3.copyWith(color: Colors.white70),
              ),
              const Gap(5),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(5)),
                child: Image.asset("lib/images/animoji.png"),
              )
            ],
          )
        ],
      ),
    );
  }
}
