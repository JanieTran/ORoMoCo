import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oromoco/helper/authenticate.dart';
import 'package:oromoco/helper/helperFunctions.dart';
import 'package:oromoco/services/auth.dart';
import 'package:oromoco/services/database.dart';
import 'package:oromoco/views/dashboardScreen.dart';
import 'package:oromoco/views/loadingScreen.dart';
import 'package:oromoco/widgets/widget.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignIn extends StatefulWidget {
  final Function toggle;
  SignIn(this.toggle);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final formKey = GlobalKey<FormState>();
  AuthMethod authMethod = new AuthMethod();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();

  bool isLoading = false;
  QuerySnapshot snapshotUserInfo;
  signUserIn(){
    if(formKey.currentState.validate()){
      HelperFunctions.saveUserEmailSharedPreference(emailTextEditingController.text);

      setState((){
        isLoading = true;
      });

      databaseMethods.getUserByUserEmail(emailTextEditingController.text).then((val){
        snapshotUserInfo = val;
        HelperFunctions.saveUserNameSharedPreference(snapshotUserInfo.documents[0].data["name"]);
      });

      authMethod.signInWithEmailAndPassword(emailTextEditingController.text, passwordTextEditingController.text).then((val){
        print(val);
        if(val != null && val != 0){
          HelperFunctions.saveUserLoggedInSharedPreference(true);
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => LoadingScreen()
          ));
        } else if(val == 0){
          Fluttertoast.showToast(msg: "Email và mật khẩu không hợp lệ. Xin thử lại.");
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => Authenticate()
          ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading ? Container(
        child: Center(child: CircularProgressIndicator())
      ):SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 50,
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (val){
                          return RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(val) ? null: "Please Provide a Valid Email";
                        },
                        controller: emailTextEditingController,
                        style: simnpleTextStyle(),
                        decoration: textFieldInputDecoration('Địa chỉ email')
                      ),
                      TextFormField(
                        obscureText: true,
                        validator: (val){
                          return val.length > 6 ? null: "Xin điền mật khẩu dài hơn";
                        },
                        controller: passwordTextEditingController,
                        style: simnpleTextStyle(),
                        decoration: textFieldInputDecoration('Mật khẩu')
                      ),
                    ]
                  ),
                ),
                SizedBox(height: 8),
                // Container(
                //   alignment: Alignment.centerRight,
                //   child: Container(
                //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //     child: Text('Forgot Password ?', style: simnpleTextStyle()),
                //   )
                // ),
                SizedBox(height: 20),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: (){
                    signUserIn();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Theme.of(context).primaryColor
                    ),
                    child: Text(
                      "Đăng nhập", 
                      style: mediumTextStyle().copyWith(color: Colors.white),
                    )
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Không có tài khoản? ", style: mediumTextStyle()),
                    GestureDetector(
                      onTap: (){
                        widget.toggle();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Đăng kí ngay", style: TextStyle(
                          fontSize: 17,
                          decoration: TextDecoration.underline
                        )),
                      ),
                    )
                  ]
                ),
                SizedBox(height: 50)
              ],
            )
          ),
        ),
      )
    );
  }
}