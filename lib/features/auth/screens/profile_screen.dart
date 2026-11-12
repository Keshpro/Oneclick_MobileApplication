
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onActivityTap;

  const ProfileScreen({
    super.key,
    this.onBack,
    this.onActivityTap,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color teal = Color(0xFF0D9488);
  static const Color dark = Color(0xFF102D38);
  static const Color bg = Color(0xFFF5F8FA);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _busy = false;

  User? get _user => _auth.currentUser;

  DocumentReference<Map<String, dynamic>>? get _userRef {
    final uid = _user?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  void _back() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.maybePop(context);
    }
  }

  String _value(dynamic input) {
    return input is String ? input.trim() : '';
  }

  String _name(Map<String, dynamic> data) {
    final firestoreName = _value(data['name']);
    final fullName = _value(data['fullName']);
    final authName = _value(_user?.displayName);

    if (firestoreName.isNotEmpty) return firestoreName;
    if (fullName.isNotEmpty) return fullName;
    if (authName.isNotEmpty) return authName;
    return 'OneClick User';
  }

  String _phone(Map<String, dynamic> data) {
    final stored = _value(data['phone']);
    if (stored.isNotEmpty) return stored;

    final alternate = _value(data['phoneNumber']);
    if (alternate.isNotEmpty) return alternate;

    return _user?.phoneNumber ?? '';
  }

  String _date(DateTime? date) {
    if (date == null) return 'Unavailable';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _editProfile(Map<String, dynamic> data) async {
    final user = _user;
    final ref = _userRef;

    if (user == null || ref == null) return;

    final nameController =
        TextEditingController(text: _name(data));
    final phoneController =
        TextEditingController(text: _phone(data));

    final formKey = GlobalKey<FormState>();

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        builder: (sheetContext) {
          bool saving = false;

          return StatefulBuilder(
            builder: (sheetContext, updateSheet) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  22,
                  24,
                  MediaQuery.viewInsetsOf(sheetContext).bottom +
                      MediaQuery.viewPaddingOf(sheetContext).bottom +
                      24,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            color: dark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Update your personal information',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: nameController,
                          maxLength: 80,
                          textCapitalization:
                              TextCapitalization.words,
                          decoration: _inputDecoration(
                            'Full Name',
                            Icons.person_outline_rounded,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 20,
                          decoration: _inputDecoration(
                            'Contact Number',
                            Icons.phone_outlined,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: user.email ?? '',
                          readOnly: true,
                          decoration: _inputDecoration(
                            'Email Address',
                            Icons.email_outlined,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Changing this contact number does not '
                          'change your Firebase Authentication phone number.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: saving
                                ? null
                                : () async {
                                    if (!formKey.currentState!
                                        .validate()) {
                                      return;
                                    }

                                    updateSheet(
                                      () => saving = true,
                                    );

                                    try {
                                      final name =
                                          nameController.text.trim();
                                      final phone =
                                          phoneController.text.trim();

                                      await ref.set({
                                        'name': name,
                                        'phone': phone,
                                        'updatedAt':
                                            FieldValue.serverTimestamp(),
                                      }, SetOptions(merge: true));

                                      await user.updateDisplayName(name);

                                      if (!sheetContext.mounted) {
                                        return;
                                      }

                                      Navigator.pop(sheetContext);

                                      if (mounted) {
                                        setState(() {});
                                        _message(
                                          'Profile updated successfully',
                                        );
                                      }
                                    } on FirebaseException catch (e) {
                                      if (sheetContext.mounted) {
                                        ScaffoldMessenger.of(
                                          sheetContext,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              e.message ??
                                                  'Unable to update profile',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (_) {
                                      if (sheetContext.mounted) {
                                        ScaffoldMessenger.of(
                                          sheetContext,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Unable to update profile',
                                            ),
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (sheetContext.mounted) {
                                        updateSheet(
                                          () => saving = false,
                                        );
                                      }
                                    }
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: teal,
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 17,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(15),
                              ),
                            ),
                            child: saving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save Changes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      phoneController.dispose();
    }
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: teal),
      filled: true,
      fillColor: bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _verifyEmail() async {
    final user = _user;

    if (user == null || user.email == null) return;

    setState(() => _busy = true);

    try {
      await user.reload();
      final refreshed = _auth.currentUser;

      if (refreshed?.emailVerified == true) {
        _message('Your email is already verified');
      } else {
        await refreshed!.sendEmailVerification();
        _message(
          'Verification email sent. Check your inbox.',
        );
      }

      if (mounted) setState(() {});
    } on FirebaseAuthException catch (e) {
      _message(e.message ?? 'Unable to send verification email');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _user?.email;

    if (email == null || email.isEmpty) {
      _message('No email address is linked to this account');
      return;
    }

    setState(() => _busy = true);

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _message('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      _message(e.message ?? 'Unable to send reset email');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out?'),
        content: const Text(
          'Are you sure you want to sign out of OneClick?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _busy = true);

    try {
      await _auth.signOut();

      if (!mounted) return;

      // The app's auth-state listener should switch
      // to the guest/login experience.
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        setState(() {});
      }
    } catch (_) {
      _message('Unable to log out. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, authSnapshot) {
        final user = authSnapshot.data ?? _auth.currentUser;

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: teal,
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            toolbarHeight: 76,
            automaticallyImplyLeading: false,
            leadingWidth: 58,
            leading: Padding(
              padding: const EdgeInsets.fromLTRB(
                12, 12, 0, 12,
              ),
              child: Material(
                color: Colors.white.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: _back,
                  borderRadius: BorderRadius.circular(14),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 19,
                  ),
                ),
              ),
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage your OneClick account',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          body: user == null
              ? _buildGuest()
              : _buildAuthenticated(user),
        );
      },
    );
  }

  Widget _buildGuest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundColor: Color(0xFFE0F2F1),
              child: Icon(
                Icons.person_outline_rounded,
                size: 48,
                color: teal,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to OneClick',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: dark,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Sign in to manage your profile, '
              'personal information and account security.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _back,
              style: FilledButton.styleFrom(
                backgroundColor: teal,
              ),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticated(User user) {
    final ref = _userRef;

    if (ref == null) {
      return const Center(
        child: CircularProgressIndicator(color: teal),
      );
    }

    return StreamBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      stream: ref.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to load profile from Firestore.\n'
                '${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: teal),
          );
        }

        final data = snapshot.data!.data() ??
            <String, dynamic>{};

        final name = _name(data);
        final email = user.email ?? '';
        final phone = _phone(data);
        final photoUrl = _value(user.photoURL).isNotEmpty
            ? user.photoURL!
            : _value(data['photoUrl']);

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            20, 22, 20, 120,
          ),
          children: [
            _buildProfileCard(
              name: name,
              email: email,
              photoUrl: photoUrl,
              verified: user.emailVerified,
              onEdit: () => _editProfile(data),
            ),

            const SizedBox(height: 25),

            _sectionTitle('Personal Information'),
            const SizedBox(height: 12),

            _sectionCard([
              _infoTile(
                Icons.person_outline_rounded,
                'Full Name',
                name,
              ),
              _infoTile(
                Icons.email_outlined,
                'Email Address',
                email.isEmpty ? 'Not available' : email,
              ),
              _infoTile(
                Icons.phone_outlined,
                'Contact Number',
                phone.isEmpty ? 'Not added' : phone,
              ),
              _infoTile(
                Icons.verified_user_outlined,
                'Email Status',
                user.emailVerified
                    ? 'Verified'
                    : 'Not Verified',
              ),
            ]),

            const SizedBox(height: 25),

            _sectionTitle('My Services'),
            const SizedBox(height: 12),

            _sectionCard([
              _actionTile(
                Icons.history_rounded,
                'My Activity',
                'View your activity history',
                onTap: widget.onActivityTap == null
                    ? null
                    : widget.onActivityTap!,
              ),
            ]),

            const SizedBox(height: 8),

            if (widget.onActivityTap == null)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Activity navigation will be available '
                  'when connected from HomeScreen.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ),

            const SizedBox(height: 25),

            _sectionTitle('Account & Security'),
            const SizedBox(height: 12),

            _sectionCard([
              if (email.isNotEmpty && !user.emailVerified)
                _actionTile(
                  Icons.mark_email_read_outlined,
                  'Verify Email',
                  'Send a verification link',
                  onTap: _busy ? null : _verifyEmail,
                ),
              if (email.isNotEmpty)
                _actionTile(
                  Icons.lock_reset_rounded,
                  'Reset Password',
                  'Send a password reset email',
                  onTap: _busy ? null : _resetPassword,
                ),
              _actionTile(
                Icons.calendar_month_outlined,
                'Member Since',
                _date(user.metadata.creationTime),
                onTap: null,
              ),
              _actionTile(
                Icons.fingerprint_rounded,
                'Account ID',
                user.uid,
                onTap: null,
              ),
            ]),

            const SizedBox(height: 25),

            _sectionTitle('Session'),
            const SizedBox(height: 12),

            _sectionCard([
              _actionTile(
                Icons.logout_rounded,
                'Log Out',
                'Sign out of your account',
                color: Colors.redAccent,
                onTap: _busy ? null : _logout,
              ),
            ]),

            if (_busy) ...[
              const SizedBox(height: 20),
              const Center(
                child: CircularProgressIndicator(color: teal),
              ),
            ],

            const SizedBox(height: 28),

            const Center(
              child: Text(
                'OneClick • Your everyday services, simplified',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileCard({
    required String name,
    required String email,
    required String photoUrl,
    required bool verified,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D9488),
            Color(0xFF075B60),
            Color(0xFF102D38),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 47,
            backgroundColor:
                Colors.white.withValues(alpha: .18),
            child: CircleAvatar(
              radius: 43,
              backgroundColor: Colors.white,
              backgroundImage: photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null,
              child: photoUrl.isEmpty
                  ? const Icon(
                      Icons.person_rounded,
                      size: 48,
                      color: teal,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          if (email.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    verified
                        ? Icons.verified_rounded
                        : Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    verified
                        ? 'Verified Account'
                        : 'Email Not Verified',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit Profile'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: dark,
      ),
    );
  }

  Widget _sectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE9EFF1),
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(
                height: 1,
                indent: 65,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _tileIcon(icon),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: dark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
    Color color = teal,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      leading: _tileIcon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color == Colors.redAccent ? color : dark,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.grey,
        ),
      ),
      trailing: onTap == null
          ? null
          : const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
            ),
      onTap: onTap,
    );
  }

  Widget _tileIcon(
    IconData icon, {
    Color color = teal,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }
}
