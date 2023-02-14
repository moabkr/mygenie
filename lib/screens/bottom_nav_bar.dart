import 'package:abo_app/screens/analytics_page.dart';
import 'package:abo_app/screens/cards_page.dart';
import 'package:abo_app/screens/home.dart';
import 'package:abo_app/utils/app_bar.dart';
import 'package:abo_app/utils/styles.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar(this.i, {super.key});
  final int i;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _currentindex = widget.i;

  void _onItemTapped(int? index) {
    setState(() {
      _currentindex = index!;
    });
  }

  static final List<Widget> _bodyOptions = <Widget>[
    const HomePage(),
    const CardsPage(),
    const AnalyticsPage(),
  ];
  Future<void> _refreshData() async {
    // reload data from Firebase
    await Future.delayed(const Duration(seconds: 2)); // simulate network delay
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.whiteColor,
      appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: CustomAppBar(),
          ),
          titleSpacing: 0,
          automaticallyImplyLeading: false),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: IndexedStack(
          index: _currentindex,
          children: _bodyOptions,
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        height: 70,
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30), color: Styles.blackColor),
        child: GNav(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          selectedIndex: _currentindex,
          onTabChange: _onItemTapped,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          gap: 8,
          backgroundColor: Colors.transparent,
          color: Styles.whiteColor,
          activeColor: Styles.whiteColor,
          duration: const Duration(milliseconds: 400),
          tabBackgroundColor: Styles.blueColor,
          tabs: const [
            GButton(
              icon: FluentSystemIcons.ic_fluent_home_regular,
              text: "Home",
            ),
            GButton(
              icon: FluentIcons.wallet_credit_card_24_regular,
              text: "Cards",
            ),
            GButton(
              icon: FluentIcons.chart_multiple_20_regular,
              text: "Analytics",
            ),
          ],
        ),
      ),
    );
  }
}
