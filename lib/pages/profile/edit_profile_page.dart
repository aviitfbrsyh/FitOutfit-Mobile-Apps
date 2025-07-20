import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class EditProfilePage extends StatefulWidget {
  final String initialName;
  final String initialBio;
  final String? initialPhotoUrl;

  const EditProfilePage({
    super.key,
    required this.initialName,
    required this.initialBio,
    this.initialPhotoUrl,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  File? _imageFile;
  Uint8List? _webImage;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _bioController = TextEditingController(text: widget.initialBio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      print('Picked image path: ${picked.path}');
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImage = bytes;
          _imageFile = null;
        });
      } else {
        setState(() {
          _imageFile = File(picked.path);
          _webImage = null;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _loading = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String? photoUrl = widget.initialPhotoUrl;

    // Upload new photo if picked
    if (_imageFile != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pict')
          .child('${user.uid}.jpg');
      try {
        await ref.putFile(_imageFile!);
        photoUrl = await ref.getDownloadURL();
      } catch (e) {
        print('Upload error: $e');
        // Tampilkan pesan error ke user jika perlu
      }
    } else if (_webImage != null && kIsWeb) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pict')
          .child('${user.uid}.jpg');
      try {
        await ref.putData(_webImage!);
        photoUrl = await ref.getDownloadURL();
      } catch (e) {
        print('Upload error: $e');
      }
    }

    // Update Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': _nameController.text,
      'bio': _bioController.text,
      'photoUrl': photoUrl ?? '',
    }, SetOptions(merge: true));

    // Update Firebase Auth
    if (_nameController.text != user.displayName ||
        (photoUrl != null && photoUrl != user.photoURL)) {
      await user.updateDisplayName(_nameController.text);
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }
    }

    await user.reload();

    setState(() {
      _loading = false;
    });

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4A90E2)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // Profile Picture
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _webImage != null
                        ? CircleAvatar(
                            key: const ValueKey('web'),
                            radius: 48,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: MemoryImage(_webImage!),
                          )
                        : _imageFile != null
                            ? CircleAvatar(
                                key: ValueKey(_imageFile!.path),
                                radius: 48,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: FileImage(_imageFile!),
                              )
                            : (widget.initialPhotoUrl != null && widget.initialPhotoUrl!.isNotEmpty
                                ? CircleAvatar(
                                    key: ValueKey(widget.initialPhotoUrl),
                                    radius: 48,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: NetworkImage(widget.initialPhotoUrl!),
                                  )
                                : CircleAvatar(
                                    key: const ValueKey('default'),
                                    radius: 48,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: const AssetImage('assets/avatar.jpg'),
                                  )),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5A623),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Username
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: const Icon(Icons.person_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 18),
            // Bio
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Bio',
                prefixIcon: const Icon(Icons.info_outline_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Save Changes',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
