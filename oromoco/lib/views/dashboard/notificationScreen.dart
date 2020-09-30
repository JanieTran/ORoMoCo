import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oromoco/services/database.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  @override
  void initState() {
    super.initState();
    databaseMethods.getBroadcasts().then((value) {
      setState(() {
        broadcastStream = value;
      });
    });
  }

  Stream broadcastStream;

  Future<void> _onNotificationDetailQuery(MessageItem item) async {
    return showDialog<void>(
      context: context,
      // barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
          ),
          title: Container(
            padding: EdgeInsets.only(bottom: 15),
            child: Text(
              item.sender,
              style: Theme.of(context)
                      .textTheme
                      .headline5
                      .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          content: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15)
              )
            ),
            padding: EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    DateFormat("dd/MM/yyyy kk:mm").format(DateTime.parse(item.time)),
                    style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(fontWeight: FontWeight.normal, color: Color(0x8D083276)),
                  ),
                  SizedBox(height: 20),
                  Text(
                    item.body,
                    style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(fontWeight: FontWeight.normal, color: Colors.black)
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scafoldKey,
      body: SafeArea(
        child: StreamBuilder(
          stream: broadcastStream,
          builder: (context, snapshot) {
            return snapshot.hasData
              ? ListView.builder(
                  reverse: false,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    final docData = snapshot.data.documents[index];
                    final String time = DateTime.fromMillisecondsSinceEpoch(snapshot.data.documents[index].data["time"]).toLocal().toString();
                    final item = MessageItem(
                        docData.data['title'], docData.data['content'], time);

                    bool showTimeHeader;

                    try{
                      if(DateTime.parse(DateFormat("yyyy-MM-dd").format(DateTime.parse(DateTime.fromMillisecondsSinceEpoch(snapshot.data.documents[index-1].data["time"]).toLocal().toString()))).difference(DateTime.parse(DateFormat("yyyy-MM-dd").format(DateTime.parse(DateTime.fromMillisecondsSinceEpoch(snapshot.data.documents[index].data["time"]).toLocal().toString())))).inDays > 0){
                        showTimeHeader = true;
                      } else{
                        showTimeHeader = false;
                      }
                    } catch (e){
                      // time = snapshot.data.documents.length < 20 ? DateTime.fromMillisecondsSinceEpoch(snapshot.data.documents[index].data["time"]).toLocal().toString() : '';
                      showTimeHeader = snapshot.data.documents.length < 20 ? true : false;
                    }

                    if(index == 0){
                      showTimeHeader = true;
                    }

                    Map<String, String> dateAliasMap= {
                      DateFormat("dd/MM/yyyy").format(DateTime.now().toLocal()).toString(): "Hôm nay",
                      DateFormat("dd/MM/yyyy").format(DateTime.now().toLocal().add(Duration(days: -1))).toString(): "Hôm qua"
                    };
                    
                    String timeString = dateAliasMap[DateFormat("dd/MM/yyyy").format(DateTime.parse(time)).toString()];
                    if(timeString == null){
                      timeString = DateFormat("dd/MM/yyyy").format(DateTime.parse(time)).toString();
                    }

                    return Column(
                      children: [
                        showTimeHeader ? Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(
                            top: 25,
                            bottom: 14
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 26),
                          child: Text(
                            timeString,
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black)
                          ),
                        ) : Container(),
                        Container(
                          decoration: item is MessageItem
                              ? BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  // border: Border.all(
                                  //   color: Theme.of(context).primaryColor,
                                  //   width: 2.0,
                                  // ),
                                  color: Colors.transparent,
                                )
                              : null,
                          // padding:
                          //     item is MessageItem ? EdgeInsets.all(14) : null,
                          margin: item is MessageItem
                              ? EdgeInsets.only(
                                  left: 26,
                                  right: 26,
                                  bottom: 14,
                                )
                              : null,
                          child: Column(
                            children: [
                              ButtonTheme(
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.all(0),
                                buttonColor: Color(0xFFF5F5F5),
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  elevation: 1,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  onPressed: (){
                                    _onNotificationDetailQuery(item);
                                  },
                                  child: ListTile(
                                    title: item.buildTitle(context),
                                    subtitle: item.buildSubtitle(context),
                                  ),
                                ),
                              ),
                              // Container(
                              //   width: MediaQuery.of(context).size.width,
                              //   alignment: Alignment.centerRight,
                              //   child: Text(
                              //     DateFormat("dd/MM/yyyy").format(DateTime.parse(time)).toString(),
                              //     style: Theme.of(context).textTheme.bodyText2
                              //   )
                              // )
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.end,
                              //   children: [
                              //     Container(
                              //       alignment: Alignment.centerRight,
                              //       child: Text(
                              //         "... Xem tiếp",
                              //         style: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.black)
                              //       )
                              //     )
                              //   ],
                              // )
                            ]
                          ),
                        )
                      ],
                    );
                  },
                )
              : Container();
          },
        ),
      ),
    );
  }
}

/// The base class for the different types of items the list can contain.
abstract class ListItem {
  /// The title line to show in a list item.
  Widget buildTitle(BuildContext context);

  /// The subtitle line, if any, to show in a list item.
  Widget buildSubtitle(BuildContext context);
}

/// A ListItem that contains data to display a heading.
class HeadingItem implements ListItem {
  final String heading;

  HeadingItem(this.heading);

  Widget buildTitle(BuildContext context) {
    return Text(
      heading,
      style: Theme.of(context).textTheme.headline5,
    );
  }

  Widget buildSubtitle(BuildContext context) => null;
}

/// A ListItem that contains data to display a message.
class MessageItem implements ListItem {
  final String sender;
  final String body;
  final String time;

  MessageItem(this.sender, this.body, this.time);

  Widget buildTitle(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      sender,
      style: Theme.of(context).textTheme.headline6.copyWith(color: Color(0xFF0849B1)),
    ),
  );

  Widget buildSubtitle(BuildContext context) => Text(
    body,
    style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black),
    overflow: TextOverflow.fade,
    maxLines: 2,
    softWrap: false,
  );
}
