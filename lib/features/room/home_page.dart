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
              Container(
                width: 320,
                height: 80,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 250, 235, 255),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('사람답게 살자', style: TextStyle(fontSize: 16,),)
              ),
              SizedBox(height: 40,),
            ],
          ),
        ),
      ),
    );
  }
}