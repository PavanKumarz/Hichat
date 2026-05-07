class ChatUser {
  late String image;
  late String name;
  late String username;
  late String createdAt;
  late bool isOnline;
  late String id;
  late String lastActive;
  late String email;

  ChatUser({
    required this.image,
    required this.name,
    required this.username,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.email,
  });

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    name = json['name'] ?? '';
    username = json['username'] ?? '';
    createdAt = json['createdAt'] ?? '';
    isOnline = json['isOnline'] ?? false;
    id = json['id'] ?? '';
    lastActive = json['lastActive'] ?? '';
    email = json['email'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['name'] = name;
    data['username'] = username;
    data['createdAt'] = createdAt;
    data['isOnline'] = isOnline;
    data['id'] = id;
    data['lastActive'] = lastActive;
    data['email'] = email;
    return data;
  }
}
