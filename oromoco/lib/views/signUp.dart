import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oromoco/helper/helperFunctions.dart';
import 'package:oromoco/services/auth.dart';
import 'package:oromoco/services/database.dart';
import 'package:oromoco/views/signIn.dart';
import 'package:oromoco/widgets/widget.dart';

class SignUp extends StatefulWidget {
  final Function toggle;
  SignUp(this.toggle);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  bool isLoading = false;
  AuthMethod authMethod = new AuthMethod();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  final formKey = GlobalKey<FormState>();
  TextEditingController userNameTextEditingController = new TextEditingController();
  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();

  signMeUp() async {
    if(formKey.currentState.validate()){
      Map<String, String> userInfoMap = {
        "name": userNameTextEditingController.text,
        "email": emailTextEditingController.text
      };

      setState(() {
        isLoading = true;
      });

      // check if there has been any account associated with this
      await DatabaseMethods().getUserByUserEmail(emailTextEditingController.text).then((val){
        final List<DocumentSnapshot> documents = val.documents;
        
        if(documents.length > 0){
          Fluttertoast.showToast(msg: "Email đã được sử dụng");
          setState(() {
            isLoading = false;
          });
          return;
        } else{
          authMethod.signUpWithEmailAndPassword(userNameTextEditingController.text, emailTextEditingController.text, passwordTextEditingController.text).then((val){
            databaseMethods.uploadUserInfo(userInfoMap);
            HelperFunctions.saveUserLoggedInSharedPreference(true);
            HelperFunctions.saveUserEmailSharedPreference(emailTextEditingController.text);
            HelperFunctions.saveUserNameSharedPreference(userNameTextEditingController.text);
            Fluttertoast.showToast(msg: "Đăng kí thành công. Vui lòng đăng nhập lại");
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => SignIn((){})
            ));
          });
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
                          return val.isEmpty || val.length < 2 ? "Xin điền tên của bạn": null;
                        },
                        controller: userNameTextEditingController,
                        style: simnpleTextStyle(),
                        decoration: textFieldInputDecoration('Họ và Tên')
                      ),
                      TextFormField(
                        validator: (val){
                          return RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(val) ? null: "Email không hợp lệ";
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
                      )
                    ]
                  ),
                ),
                SizedBox(height: 53),
                GestureDetector(
                  onTap: (){
                    signMeUp();
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
                      "Đăng kí", 
                      style: mediumTextStyle().copyWith(color: Colors.white),
                    )
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Đã có tài khoản? ", style: mediumTextStyle()),
                    GestureDetector(
                      onTap: (){
                        widget.toggle();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Đăng nhập ngay", style: TextStyle(
                          color: Colors.black,
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