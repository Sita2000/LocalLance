import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mylocallance/views/freelancer/chatlist_screen.dart';
import 'package:mylocallance/views/freelancer/chatroom.dart';
import 'package:mylocallance/views/freelancer/dashboard.dart';
import 'package:mylocallance/views/freelancer/job_details_screen.dart';
import 'package:mylocallance/views/freelancer/notifications.dart';
import 'package:mylocallance/views/freelancer/payment_screen.dart';
import 'package:mylocallance/views/freelancer/profile_screen.dart';
import 'package:mylocallance/views/freelancer/review_screen.dart';
import 'package:mylocallance/views/home.dart';
import 'package:mylocallance/views/job_recruiter/login_screen.dart';

import 'firebase_options.dart';
import 'package:go_router/go_router.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'MyLocalLance',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          routerConfig: appRouter,

        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title; 

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), 
      ),
      body: Center(
        child: Column(),
      ), 
    );
  }
}
