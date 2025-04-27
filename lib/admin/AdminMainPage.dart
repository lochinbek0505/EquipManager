import 'package:equip_manager/admin/AdminPage.dart';
import 'package:equip_manager/admin/RejectedActiveDevicesPage.dart';
import 'package:equip_manager/admin/StatisPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Adminmainpage extends StatefulWidget {
  const Adminmainpage({super.key});

  @override
  State<Adminmainpage> createState() => _AdminmainpageState();
}

class _AdminmainpageState extends State<Adminmainpage> {
  var pages = [AdminPage(), StatisPage(), RejectedActiveDevicesPage()];
  var selectIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ""),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar_alt_fill),
            label: "",
          ),

          BottomNavigationBarItem(icon: Icon(Icons.history), label: ""),
        ],
        onTap: (Index) {
          setState(() {
            selectIndex = Index;
          });
        },
      ),
    );
  }
}
