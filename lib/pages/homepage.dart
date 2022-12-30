import 'package:chatapp/constants/constants.dart';
import 'package:chatapp/models/ChatRoomModel.dart';
import 'package:chatapp/models/FirebaseHelper.dart';
import 'package:chatapp/models/usermodel.dart';
import 'package:chatapp/pages/ChatRoom.dart';
import 'package:chatapp/pages/loginPage.dart';
import 'package:chatapp/pages/searchPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const HomePage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat App'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return LoginPage();
                  }),
                );
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chatrooms')
                .where("users", arrayContains: widget.userModel.uid)
                .orderBy('createdOn', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatroomSnapshot =
                      snapshot.data as QuerySnapshot;
                  return ListView.builder(
                      itemCount: chatroomSnapshot.docs.length,
                      itemBuilder: (context, index) {
                        ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                          chatroomSnapshot.docs[index].data()
                              as Map<String, dynamic>,
                        );
                        Map<String, dynamic> participants =
                            chatRoomModel.participants!;
                        List<String> participantsKeys =
                            participants.keys.toList();
                        participantsKeys.remove(widget.userModel.uid);
                        return FutureBuilder(
                            future: FirebaseHelper.getUserModelById(
                                participantsKeys[0]),
                            builder: (context, userData) {
                              if (userData.connectionState ==
                                  ConnectionState.done) {
                                if (userData.data != null) {
                                  UserModel targetUser =
                                      userData.data as UserModel;
                                  return ListTile(
                                    onTap: () {
                                      nextPage(
                                          context: context,
                                          page: ChatRoomPage(
                                              targetUser: targetUser,
                                              chatroom: chatRoomModel,
                                              userModel: widget.userModel,
                                              firebaseUser:
                                                  widget.firebaseUser));
                                    },
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.grey[300],
                                      backgroundImage: NetworkImage(
                                          targetUser.profilePic.toString()),
                                    ),
                                    title: Text(targetUser.fullName.toString()),
                                    subtitle:
                                        (chatRoomModel.lastMessage.toString() !=
                                                "")
                                            ? Text(chatRoomModel.lastMessage
                                                .toString())
                                            : Text(
                                                'Say hi to your new friend !',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                              ),
                                  );
                                } else {
                                  return Container();
                                }
                              } else {
                                return Container();
                              }
                            });
                      });
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return const Center();
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          nextPage(
              context: context,
              page: SearchPage(
                  userModel: widget.userModel,
                  firebaseUser: widget.firebaseUser));
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
