import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 87,),
            Padding(
              padding: const EdgeInsets.fromLTRB(23.99, 0, 23.99, 37),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/mypage_profile.png', height: 80,),
                  SizedBox(width: 17,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('홍길동', style: TextStyle(color: Color(0xff0a0a0a), fontSize: 18, fontWeight: FontWeight.w600),),
                      SizedBox(height: 5.81,),
                      Text('hong@handong.ac.kr', style: TextStyle(color: Color(0xff6A7282), fontSize: 15, fontWeight: FontWeight.w400),),
                    ],
                  )
                ],
              ),
            ),
            Divider(height: 0, thickness: 1.18, color: Color(0xffE5E7EB),),
            SizedBox(height: 3,),
            Column(
              children: [
                InkWell(
                  onTap: (){},
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 0, 16),
                    child: Row(
                      children: [
                        SizedBox(width: 12,),
                        Text('내 정보 수정', style: TextStyle(color: Color(0xff101828), fontSize: 16, fontWeight: FontWeight.w400),),
                        SizedBox(width: 210,),
                      ],
                    ),
                  ),
                ), 
                Divider(color: Color(0xffF3F4F6), thickness: 1.18,),
                InkWell(
                  onTap: (){

                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 0, 16),
                    child: Row(
                      children: [
                        SizedBox(width: 12,),
                        Text('로그아웃', style: TextStyle(color: Color(0xffFB2C36), fontSize: 16, fontWeight: FontWeight.w400),),
                        SizedBox(width: 231,),
                      ],
                    ),
                  ),
                ), 
                Divider(color: Color(0xffF3F4F6), thickness: 1.18,),
              ],
            )
          ],
        ),
      ),
    );
  }
}