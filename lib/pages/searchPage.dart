import 'dart:developer';

import 'package:chatapp/constants/constants.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/models/ChatRoomModel.dart';
import 'package:chatapp/models/usermodel.dart';
import 'package:chatapp/pages/ChatRoom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController emailController = TextEditingController();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .where('participants.${widget.userModel.uid}', isEqualTo: true)
        .where('participants.${targetUser.uid}', isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatroom;
      log('Chatroom Already created');
    } else {
      ChatRoomModel newChatRoom = ChatRoomModel(
        chatRoomId: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
        users: [
          widget.userModel.uid.toString(),
          targetUser.uid.toString(),
        ],
        createdOn: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(newChatRoom.chatRoomId)
          .set(newChatRoom.toMap());
      chatRoom = newChatRoom;

      log('New ChatRoom Created');
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search")),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: "Email Address",
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          CupertinoButton(
              color: Theme.of(context).colorScheme.secondary,
              child: const Text('Search'),
              onPressed: () {
                setState(() {});
              }),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where("email", isEqualTo: emailController.text)
                .where("email", isNotEqualTo: widget.userModel.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                  if (dataSnapshot.docs.length > 0) {
                    Map<String, dynamic> userMap =
                        dataSnapshot.docs[0].data() as Map<String, dynamic>;

                    UserModel searchedUser = UserModel.fromMap(userMap);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        onTap: () async {
                          ChatRoomModel? chatRoomModel =
                              await getChatRoomModel(searchedUser);
                          if (chatRoomModel != null) {
                            goBack(context: context);
                            nextPage(
                              context: context,
                              page: ChatRoomPage(
                                  targetUser: searchedUser,
                                  chatroom: chatRoomModel,
                                  userModel: widget.userModel,
                                  firebaseUser: widget.firebaseUser),
                            );
                          }
                        },
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(searchedUser.profilePic!),
                          backgroundColor: Colors.grey[500],
                        ),
                        title: Text(searchedUser.fullName.toString()),
                        subtitle: Text(searchedUser.email!),
                        trailing: const Icon(Icons.keyboard_arrow_right),
                      ),
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('No Result Found !'),
                    );
                  }
                } else if (snapshot.hasError) {
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Text('No Result Found !'),
                  );
                }
              } else {
                return CircularProgressIndicator();
              }
              return Center();
            },
          ),
        ]),
      )),
    );
  }
}
