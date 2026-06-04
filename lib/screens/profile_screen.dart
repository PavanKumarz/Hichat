import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hichat/api/api.dart';
import 'package:hichat/helper/dialogs.dart';
import 'package:hichat/widgets/glass_container.dart';
import 'package:hichat/widgets/my_containr.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  String? _image;
  bool _isEditing = false;
  late TextEditingController _nameController;
  late Future<void> _getSelfInfoFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _getSelfInfoFuture = Api.getSelfInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MyContainer(
      child: Scaffold(
        body: SafeArea(
          child: FutureBuilder(
            future: _getSelfInfoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    Center(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Stack(
                                children: [
                                  _image != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            60,
                                          ),
                                          child: Image.file(
                                            File(_image!),
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey[200]!,
                                              width: 2,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              60,
                                            ),
                                            child: Image.network(
                                              Api.me.image,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const CircleAvatar(
                                                    backgroundColor:
                                                        Colors.cyan,
                                                    radius: 60,
                                                    child: Icon(
                                                      Icons.person,
                                                      color: Colors.white,
                                                      size: 25,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                  if (_isEditing)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: MaterialButton(
                                        elevation: 1,
                                        onPressed: () {
                                          _showBottomSheet();
                                        },
                                        shape: const CircleBorder(),
                                        color: Colors.white,
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _isEditing
                                        ? TextField(
                                            controller: _nameController,
                                            decoration: const InputDecoration(
                                              hintText: 'Enter your name',
                                              border: InputBorder.none,
                                              isCollapsed: true,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                              letterSpacing: -0.5,
                                            ),
                                          )
                                        : Text(
                                            Api.me.name,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                    Text(
                                      '@${Api.me.username}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Text(
                                      Api.me.email,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black45,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    OutlinedButton(
                                      onPressed: () async {
                                        if (_isEditing) {
                                          if (_nameController.text
                                              .trim()
                                              .isNotEmpty) {
                                            Api.me.name = _nameController.text
                                                .trim();
                                            await Api.updateUserInfo();
                                            if (mounted) {
                                              Dialogs.showSnackbar(
                                                context,
                                                'Profile updated successfully!',
                                              );
                                            }
                                          }
                                        } else {
                                          _nameController.text = Api.me.name;
                                        }
                                        setState(() {
                                          _isEditing = !_isEditing;
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: _isEditing
                                            ? Colors.blue
                                            : Colors.black87,
                                        side: BorderSide(
                                          color: _isEditing
                                              ? Colors.blue
                                              : Colors.grey[300]!,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Text(
                                        _isEditing
                                            ? 'Save Changes'
                                            : 'Edit Profile',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSettingsItem(
                      icon: Icons.alternate_email_rounded,
                      title: 'Unique ID',
                      subtitle: '@${Api.me.username}',
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: Api.me.username));
                        Dialogs.showSnackbar(
                          context,
                          'Unique ID copied to clipboard!',
                        );
                      },
                      trailing: const Icon(
                        Icons.copy_rounded,
                        size: 18,
                        color: Colors.blue,
                      ),
                    ),
                    _buildSettingsItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      subtitle: 'Message, group & call tones',
                    ),
                    _buildSettingsItem(
                      icon: Icons.lock_outline_rounded,
                      title: 'Privacy',
                      subtitle: 'Block contacts, disappearing messages',
                    ),

                    const SizedBox(height: 32),

                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Row(
                              children: const [
                                Icon(Icons.logout, color: Colors.red),
                                SizedBox(width: 10),
                                Text('Logout'),
                              ],
                            ),
                            content: const Text(
                              'Are you sure you want to logout from HiChat?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await FirebaseAuth.instance.signOut();
                                },
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Logout',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: 16,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(top: 20, bottom: 40),
          children: [
            const Text(
              'Pick Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: const Size(120, 120),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        _image = image.path;
                      });
                      if (mounted) Navigator.pop(context);
                      await Api.updateProfilePicture(File(_image!));
                      setState(() {
                        _image = null;
                      });
                    }
                  },
                  child: const Icon(Icons.image, size: 60, color: Colors.blue),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: const Size(120, 120),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        _image = image.path;
                      });
                      if (mounted) Navigator.pop(context);
                      await Api.updateProfilePicture(File(_image!));
                      setState(() {
                        _image = null;
                      });
                    }
                  },
                  child: const Icon(
                    Icons.camera_alt,
                    size: 60,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
