import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFAFAFE),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 70,),
              Text('302호', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
              SizedBox(height: 8,),
              Text('사람답게 살자', style: TextStyle(fontSize: 16,),),
              SizedBox(height: 40,),
            ],
          ),
        ),
      ),
    );
  }
}