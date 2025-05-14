import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test1/controllers/radio_controller.dart';
import 'package:test1/views/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Radio Visualizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      initialBinding: BindingsBuilder(() {
        Get.put(RadioController());
      }),
    );
  }
}