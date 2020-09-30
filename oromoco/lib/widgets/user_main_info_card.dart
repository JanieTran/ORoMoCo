import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oromoco/helper/constants.dart';

class UserMainInfoCard extends StatelessWidget {
  const UserMainInfoCard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Stack(
          children: [
            Container(
              height: 260,
              // height: 250,
              color: Color(0xFF083279),
            ),
            Positioned(
              top: 223,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                height: 140,
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          height: 223.0,
          padding: const EdgeInsets.all(18.0),
          margin: const EdgeInsets.symmetric(horizontal: 26.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: Color(0xFF083279),
          ),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // new Text(
                  //   'Xin chào,',
                  //   style: Theme.of(context).textTheme.headline5.copyWith(
                  //         color: Colors.white,
                  //         fontSize: 15,
                  //         fontWeight: FontWeight.normal
                  //       ),
                  // ),
                  // new Text(
                  //   Constants.username,
                  //   style: Theme.of(context).textTheme.headline5.copyWith(
                  //     color: Colors.amber,
                  //   ),
                  // ),
                ],
              ),
              new Column(
                children: [
                  new Row(
                    children: [

                    ],
                  ),
                  SizedBox(height: 8),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                    ],
                  )
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 18,
          right: 26,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: (){
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => ProfileScreen()));
                },
                child: new Container(
                  child: new CircleAvatar(
                    child: ClipOval(
                      child: SvgPicture.asset(
                        'assets/images/icon/tai-khoan-trang.svg',
                      ),
                    ),
                    radius: 35,
                    backgroundColor: Color(0xFF083279),
                  ),
                ),
              ),
              SizedBox(height: 10), 
              Text(
                Constants.userID,
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                    ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
