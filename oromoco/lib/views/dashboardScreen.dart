import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oromoco/bluetooth/MainPage.dart';
import 'package:oromoco/helper/authenticate.dart';
import 'package:oromoco/helper/constants.dart';
import 'package:oromoco/helper/helperFunctions.dart';
import 'package:oromoco/services/auth.dart';
import 'package:oromoco/services/database.dart';
import 'package:oromoco/views/chatScreen.dart';
import 'package:oromoco/views/controlPanelScreen.dart';
import 'package:oromoco/views/homeScreen.dart';
import 'package:oromoco/views/notificationScreen.dart';
import 'package:oromoco/views/toolDetailScreen.dart';
import 'package:oromoco/widgets/animated_bottom_bar.dart';

class DashboardScreen extends StatefulWidget {
  final int index;
  final int hasNewBroadcast;
  final int hasNewMessage;
  
  DashboardScreen(this.index, this.hasNewMessage, this.hasNewBroadcast);
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

// Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
//   if (message.containsKey('data')) {
//     // Handle data message
//     final dynamic data = message['data'];
//   }

//   if (message.containsKey('notification')) {
//     // Handle notification message
//     final dynamic notification = message['notification'];
//   }
// }

class _DashboardScreenState extends State<DashboardScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  List featureList = [];
  int selectedBarIndex;
  bool hasNewMessage;
  bool hasNewBroadcast;
  List<Widget> screenList;
  DateTime currentBackPressTime;
  GlobalKey<AnimatedBottomBarState> _key = GlobalKey();

  Widget featureTile (String name){
    return GestureDetector(
      onTap: (){
        onFeatureTap(name);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).accentColor
        ),
        height: 50,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6
        ),
      ),
    );
  }

  void onFeatureTap(name) async {
    if(name == "Pin"){
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ControlPanelScreen()));
    }
  }

  void _changeTab(int index) {
    setState(() {
      selectedBarIndex = index;
      if(index == Constants.bottomBar["chat"]){
        hasNewMessage = false;
        databaseMethods.resetMessageNotification();
      }
      if(index == Constants.bottomBar["notification"]){
        hasNewBroadcast = false;
        databaseMethods.resetBroadcastNotification();
      }
    });
  }

  showMessageNotification(Map<String, dynamic> message) async {
    var android = new AndroidNotificationDetails(
        "channelId", "channelName", "channelDescription");
    var platform = new NotificationDetails(android, null);
    await flutterLocalNotificationsPlugin.show(
        0,
        message["notification"]["title"],
        message["notification"]["body"],
        platform);
    setState(() {
      if(message["notification"]["title"].toString().contains('You have a message from')){
        hasNewMessage = true;
      } else{
        hasNewBroadcast = true;
      }
    });
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    hasNewMessage = false;
    hasNewBroadcast = false;
    selectedBarIndex = widget.index;
        flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('mipmap/ic_launcher');
    var initSettings = new InitializationSettings(android, null);
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: null);

    // StreamSubscription<HardwareButtons.HomeButtonEvent>
    //     _homeButtonSubscription =
    //     HardwareButtons.homeButtonEvents.listen((event) {
    //   databaseMethods.updateUserChattingWith(null);
    //   SystemNavigator.pop();
    // });

    selectedBarIndex = widget.index;
    onUpdateUserToken("1234");

    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("onMessage: $message");
    //     showMessageNotification(message);
    //   },
    //   onBackgroundMessage: myBackgroundMessageHandler,
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("onLaunch: $message");
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print("onResume: $message");
    //   },
    // );

    // _firebaseMessaging.getToken().then((String token) {
    //   assert(token != null);
    //   print("Push Messaging token: $token");
    //   onUpdateUserToken(token);
    // });
    // _firebaseMessaging.subscribeToTopic("oromoco-all");
  }

  onUpdateUserToken(String token) async {
    String name = Constants.username;
    String email = Constants.email;
    databaseMethods.getUserByUserEmail(Constants.email).then((val) async {
      final List<DocumentSnapshot> documents = val.documents;
      if (documents.length == 0) {
        Map<String, dynamic> userInfoMap = {
          "name": name,
          "email": email,
          "token": token,
          "chattingWith": null,
          "hasNewBroadcast": false,
          "hasNewMessage": false,
          "id": null
        };

        final DocumentReference docRef =
            await databaseMethods.uploadUserInfo(userInfoMap);

        Constants.firebase_uid = docRef.documentID;
        await databaseMethods.updateUserUid(Constants.firebase_uid);
      } else {
        Constants.firebase_uid = documents[0]['id'];
        if (documents[0]["token"] != token) {
          Fluttertoast.showToast(msg: "Đăng nhập lần đầu tiên trên thiết bị");
          await databaseMethods.updateUserToken(token, Constants.firebase_uid);
        }

        if(documents[0]["hasNewBroadcast"] == null || documents[0]["hasNewMessage"] == null){
          await databaseMethods.updateUserMissingField(Constants.firebase_uid, "hasNewMessage", false);
          await databaseMethods.updateUserMissingField(Constants.firebase_uid, "hasNewBroadcast", false);
          setState(() {
            hasNewBroadcast = false;
            hasNewMessage = false;
          });
        } else{
          setState(() {
            hasNewBroadcast = documents[0]['hasNewBroadcast'];
            hasNewMessage = documents[0]['hasNewMessage'];
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    featureList.clear();
    featureList.add(featureTile("Pin"));

    double width = MediaQuery.of(context).size.width;
    List<BarItem> barItems = [
      BarItem(text: "Sản phẩm", iconText: "Sản phẩm", iconDataNone: "tool-list.svg", iconDataClicked: "tool-list-on-board.svg", isNotified: false),
      BarItem(text: "Trang chủ", iconText: "Trang chủ", iconDataNone: "trang-chu.svg", iconDataClicked: "trang-chu-on-board.svg", isNotified: false),
      BarItem(text: "Trò chuyện cùng Vulcan", iconText: "Tin nhắn", iconDataNone:"tin-nhan.svg", iconDataClicked: "tin-nhan-on-board.svg", isNotified: hasNewMessage),
      BarItem(text: "Thông báo", iconText: "Thông báo", iconDataNone: "thong-bao.svg", iconDataClicked: "thong-bao-on-board.svg", isNotified: hasNewBroadcast)
    ];

    AnimatedBottomBar bottomNavigationBar = new AnimatedBottomBar(
      barItems: barItems,
      animationDuration: const Duration(milliseconds: 150),
      barStyle: BarStyle(fontSize: 0, iconSize: width * 0.08),
      currentIndex: selectedBarIndex,
      onBarTap: (index) => _changeTab(index),
      key: _key
    );

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );

    screenList = [
      ToolDetailScreen(),
      HomeScreen(),
      ChatScreen(),
      NotificationScreen()
    ];

    final bool isHome = selectedBarIndex == Constants.bottomBar["home"];

    return WillPopScope(
      onWillPop: () async {
        databaseMethods.updateUserChattingWith(null);
        if(isHome){
          DateTime now = DateTime.now();
          if (currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)) {
            currentBackPressTime = now;
            Fluttertoast.showToast(msg: "Thêm 1 lần nữa để tắt");
            return Future.value(false);
          }
          SystemNavigator.pop();
          return Future.value(true);
        } else{
          _key.currentState.setIndex(Constants.bottomBar["home"]);
        }
        return Future.value(false);
      },
      child: SafeArea(
        child: Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Constants.username,
                        style: Theme.of(context).textTheme.headline5.copyWith(color: Theme.of(context).accentColor)
                      ),
                      SizedBox(height: 10),
                      Text(
                        Constants.email,
                        style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white)
                      ),
                    ]
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                ListTile(
                  title: Text(
                    'Devices',
                    style: Theme.of(context).textTheme.headline6
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage()));
                  },
                ),
                ListTile(
                  title: Text(
                    'Sign Out',
                    style: Theme.of(context).textTheme.headline6
                  ),
                  onTap: () {
                    HelperFunctions.resetUserLoggedInSharedPreferencs();
                    AuthMethod().signOut();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Authenticate()));
                  },
                ),
              ],
            ),
          ),
          appBar: AppBar(
            iconTheme: new IconThemeData(
              color: Theme.of(context).accentColor
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: Text(
                      "OROMOCO",
                      style: Theme.of(context).textTheme.headline5.copyWith(color: Theme.of(context).accentColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(
                  child: Icon(
                    Icons.menu,
                    color: Theme.of(context).primaryColor
                  ),
                )
              ],
            ),
          ),
          body: screenList[selectedBarIndex],
          // Container(
          //   padding: EdgeInsets.symmetric(
          //     vertical: 20
          //   ),
          //   child: Container(
          //     child: ListView.builder(
          //       shrinkWrap: true,
          //       itemCount: featureList.length,
          //       itemBuilder: (context, index){
          //         return Container(
          //           padding: EdgeInsets.symmetric(
          //             horizontal: 26,
          //             vertical: 5
          //            ),
          //           child: featureList[index]
          //         );
          //       }
          //     ),
          //   ),
          // ),
          bottomNavigationBar: bottomNavigationBar,
        ),
      ),
    );
  }
}