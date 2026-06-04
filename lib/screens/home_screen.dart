import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hichat/api/api.dart';
import 'package:hichat/widgets/my_textfield.dart';
import 'package:hichat/widgets/my_containr.dart';
import 'package:hichat/screens/chat_screen.dart';
import 'package:hichat/helper/dialogs.dart';
import 'package:hichat/models/chat_user_model.dart';
import 'package:hichat/screens/profile_screen.dart';
import 'package:hichat/widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool _isSearching = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  final List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];

  @override
  Widget build(BuildContext context) {
    return MyContainer(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddUserDialog(context);
          },
          backgroundColor: Colors.blue,
          elevation: 4,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'HiChat',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Keep connecting',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: FutureBuilder(
                            future: Api.getSelfInfo(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircleAvatar(
                                  child: Icon(Icons.person),
                                );
                              }

                              return Api.me.image.isNotEmpty
                                  ? Image.network(
                                      Api.me.image,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const CircleAvatar(
                                                backgroundColor: Colors.cyan,
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                ),
                                              ),
                                    )
                                  : const CircleAvatar(
                                      backgroundColor: Colors.cyan,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                    );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: MyTextField(
                  hintText: 'Search by username or name...',
                  icon: Icons.search_rounded,
                  controller: _searchController,
                  onChanged: (val) {
                    _searchList.clear();
                    final query = val.trim().toLowerCase();

                    for (var i in _list) {
                      if (i.name.toLowerCase().contains(query) ||
                          i.username.toLowerCase().contains(query) ||
                          i.email.toLowerCase().contains(query) ||
                          i.displayName.toLowerCase().contains(query) ||
                          i.displayHandle.toLowerCase().contains(query)) {
                        _searchList.add(i);
                      }
                    }

                    setState(() {
                      _isSearching = query.isNotEmpty;
                    });
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: Api.getAllUsers(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(child: CircularProgressIndicator());

                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        _list.clear();
                        _list.addAll(
                          data
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [],
                        );

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                            padding: const EdgeInsets.only(top: 24, bottom: 24),
                            itemCount: _isSearching
                                ? _searchList.length
                                : _list.length,
                            itemBuilder: (context, index) {
                              final user = _isSearching
                                  ? _searchList[index]
                                  : _list[index];
                              return ChatUserCard(user: user);
                            },
                          );
                        } else {
                          return const Center(
                            child: Text(
                              'No Connections Found!',
                              style: TextStyle(fontSize: 20),
                            ),
                          );
                        }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.grey[50],
        title: Row(
          children: [
            Icon(Icons.person_add_rounded, color: Colors.blue[600]),
            const SizedBox(width: 12),
            const Text(
              'Add User',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the unique ID of the person you want to chat with.',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 20),
            MyTextField(
              hintText: 'Unique ID',
              icon: Icons.alternate_email_rounded,
              controller: _usernameController,
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _usernameController.clear();
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_usernameController.text.isNotEmpty) {
                String username = _usernameController.text;
                _usernameController.clear();

                final chatUser = await Api.getUserByUsername(username);

                if (context.mounted) {
                  Navigator.pop(context);

                  if (chatUser != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(user: chatUser),
                      ),
                    );
                  } else {
                    Dialogs.showSnackbar(
                      context,
                      'User not found with ID: $username',
                      color: Colors.red,
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }
}
