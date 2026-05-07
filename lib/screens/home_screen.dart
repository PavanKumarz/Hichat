import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hichat/api/api.dart';
import 'package:hichat/widgets/glass_container.dart';
import 'package:hichat/widgets/my_textfield.dart';
import 'package:hichat/widgets/my_containr.dart';
import 'package:hichat/screens/chat_screen.dart';
import 'package:hichat/helper/dialogs.dart';
import 'package:hichat/models/chat_user_model.dart';
import 'package:hichat/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  final List<ChatUser> _list = [];

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
                                      ConnectionState.waiting &&
                                  !Api.auth.currentUser!.uid.isNotEmpty) {
                                return const CircleAvatar(
                                  child: Icon(Icons.person),
                                );
                              }

                              return Image.network(
                                Api.me.image,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const CircleAvatar(
                                      backgroundColor: Colors.cyan,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: MyTextField(
                  hintText: 'Search conversations...',
                  icon: Icons.search_rounded,
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
                            itemCount: _list.length,
                            itemBuilder: (context, index) {
                              final user = _list[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 5,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                          userName: user.name,
                                          userImage: user.image,
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: GlassContainer(
                                    padding: const EdgeInsets.all(12),
                                    borderRadius: 20,
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                          child: Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            child: user.image.isNotEmpty
                                                ? Image.network(
                                                    user.image,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context, child, loadingProgress) {
                                                      if (loadingProgress == null) return child;
                                                      return const Center(child: CircularProgressIndicator());
                                                    },
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => const Icon(
                                                          Icons.person_rounded,
                                                        ),
                                                  )
                                                : Center(
                                                    child: Text(
                                                      user.name.isNotEmpty
                                                          ? user.name[0]
                                                                .toUpperCase()
                                                          : '?',
                                                      style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    user.name,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  Text(
                                                    user.lastActive,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black45,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                user.email,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
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
              'Enter the email of the person you want to chat with.',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 20),
            MyTextField(
              hintText: 'Email address',
              icon: Icons.email_outlined,
              controller: _emailController,
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
              _emailController.clear();
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
            onPressed: () {
              if (_emailController.text.isNotEmpty) {
                String email = _emailController.text;
                _emailController.clear();
                Navigator.pop(context);

                Dialogs.showSnackbar(
                  context,
                  'Invitation sent to $email',
                  color: Colors.blue,
                );
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
