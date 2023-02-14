import 'package:abo_app/utils/styles.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CardInfo extends StatelessWidget {
  final String title;
  final Widget amount;
  final String icon;
  final Color color;

  CardInfo(
      {super.key,
      required this.title,
      required this.amount,
      required this.icon,
      required this.color});

  NumberFormat numberFormat = NumberFormat("#,##0", "en_US");

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 30,
            vertical: MediaQuery.of(context).size.width / 1000),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(10)),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width / 60),
                decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20)),
                child: (icon == 'balance')
                    ? Icon(
                        FluentIcons.money_16_regular,
                        color: Styles.whiteColor,
                      )
                    : (icon == 'income')
                        ? Icon(FluentIcons.people_money_24_regular,
                            color: Styles.whiteColor)
                        : (icon == 'expense')
                            ? Icon(FluentIcons.money_dismiss_20_regular,
                                color: Styles.whiteColor)
                            : (icon == 'analytics')
                                ? Icon(FluentIcons.chart_multiple_20_regular,
                                    color: Styles.whiteColor)
                                : const Text("No Icon")),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title != 'Analytics' ? 'Total $title' : 'Analytics',
                  style: GoogleFonts.inter(
                      color: const Color.fromARGB(255, 22, 22, 22),
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
                amount
                // Text(
                //   title != 'Analytics'
                //       ? '\$${(numberFormat.format(amount))}'
                //       : '+$amount%',
                //   style: GoogleFonts.inter(
                //       color: const Color.fromARGB(255, 22, 22, 22),
                //       fontSize: 15,
                //       fontWeight: FontWeight.w400),
                // )
              ],
            )
          ],
        ),
      ),
    );
  }
}
