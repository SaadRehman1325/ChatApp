import 'package:chatapp/constants/constants.dart';
import 'package:chatapp/models/UiHelper.dart';
import 'package:chatapp/models/usermodel.dart';
import 'package:chatapp/pages/CompleteProfilePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController cPasswordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();

    if (email == "" || password == "" || cPassword == "") {
      UIHelper.showAlertDialog(
          context, "Missing Fields", "Please fill all the fields!");
    } else if (password != cPassword) {
      UIHelper.showAlertDialog(context, "Password mismatched",
          "The password you entered does not match!");
    } else {
      signup(email, password);
    }
  }

  void signup(String email, String password) async {
    UserCredential? credential;
    UIHelper.showloadingDialouge(context, 'Creaing new account..');

    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UIHelper.showAlertDialog(
          context, "An error occured", ex.message.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser =
          UserModel(uid: uid, email: email, fullName: "", profilePic: "");
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) => print("new User created"));

      Navigator.popUntil(context, (route) => route.isFirst);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return CompleteProfilePage(
              userModel: newUser, firebaseUser: credential!.user!);
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Center(
            child: SingleChildScrollView(
                child: Column(
              children: [
                Text(
                  'Chat App',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: "Email Address",
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: "Password"),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: cPasswordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(hintText: "Confirm Password"),
                ),
                const SizedBox(
                  height: 20,
                ),
                CupertinoButton(
                  onPressed: () {
                    checkValues();
                    // nextPage(
                    //     context: context, page: const CompleteProfilePage());
                  },
                  color: Theme.of(context).colorScheme.secondary,
                  child: const Text("Sign Up"),
                ),
              ],
            )),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            "Already have an account?",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          CupertinoButton(
            onPressed: () {
              goBack(context: context);
            },
            child: const Text("log In "),
          ),
        ]),
      ),
    );
  }
}
