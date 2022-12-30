class ChatRoomModel {
  String? chatRoomId;
  Map<String, dynamic>? participants;
  String? lastMessage;
  DateTime? createdOn;
  List<dynamic>? users;

  ChatRoomModel({
    this.chatRoomId,
    this.participants,
    this.lastMessage,
    this.createdOn,
    this.users,
  });

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatRoomId = map['chatRoomId'];
    participants = map['participants'];
    lastMessage = map['lastMessage'];
    createdOn = map['createdOn'].toDate();
    users = map['users'];
  }

  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'participants': participants,
      'lastMessage': lastMessage,
      'createdOn': createdOn,
      'users': users,
    };
  }
}
