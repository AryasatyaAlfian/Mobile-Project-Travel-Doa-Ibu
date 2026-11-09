import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/travel_api.dart';
import 'widgets/skeleton_view.dart';

/// Halaman Informasi Akun & Data Pribadi Jemaah
/// Layout 1:1 Presisi Sesuai Figma Prototype Profile:
/// Header Ka'bah malam, Kartu Profil Melayang, dan Data Pribadi
class ProfileAccountInfoPage extends StatefulWidget {
  const ProfileAccountInfoPage({
    super.key,
    this.api,
    this.name,
    this.email,
    this.phone,
    this.birthDate,
    this.gender,
    this.isAdmin = false,
  });

  final TravelApi? api;
  final String? name;
  final String? email;
  final String? phone;
  final String? birthDate;
  final String? gender;
  final bool isAdmin;

  @override
  State<ProfileAccountInfoPage> createState() => _ProfileAccountInfoPageState();
}

class _ProfileAccountInfoPageState extends State<ProfileAccountInfoPage> {
  late String _name;
  late String _email;
  late String _phone;
  late String _birthDate;
  late String _gender;
  bool _isLoading = false;

  static const Color _gold = Color(0xFFECC485);
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _muted = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    final user = TravelApi.currentUser ?? widget.api?.user;
    final isRoleAdmin = widget.isAdmin || (user?.isAdmin ?? false);
    _name = widget.name ?? user?.name ?? (isRoleAdmin ? 'Raina' : 'Jemaah');
    _email = widget.email ?? user?.email ?? (isRoleAdmin ? 'raina@gmail.com' : 'Belum ada email');
    _phone = widget.phone ?? user?.phone ?? (isRoleAdmin ? '0855 3668 1691' : 'Belum diatur');
    _birthDate = widget.birthDate ?? (isRoleAdmin ? '1 Jan 1998' : 'Belum diatur');
    _gender = widget.gender ?? (isRoleAdmin ? 'Perempuan' : 'Belum diatur');

    if (widget.api != null) {
      _loadProfileFromBackend();
    }
  }

  Future<void> _loadProfileFromBackend() async {
    if (widget.api == null) return;
    setState(() => _isLoading = true);
    try {
      final res = await widget.api!.getProfile();
      if (!mounted) return;
      final profile = res['profile'] as Map<String, dynamic>?;
      setState(() {
        if (res['name'] != null && (res['name'] as String).isNotEmpty) {
          _name = res['name'] as String;
        }
        if (res['email'] != null && (res['email'] as String).isNotEmpty) {
          _email = res['email'] as String;
        }
        if (res['phone'] != null && (res['phone'] as String).isNotEmpty) {
          _phone = res['phone'] as String;
        }
        final rawBirth = profile?['birth_date'] as String?;
        if (rawBirth != null && rawBirth.isNotEmpty) {
          _birthDate = _formatDateDisplay(rawBirth);
        }
        final rawGender = profile?['gender'] as String?;
        if (rawGender == 'P') {
          _gender = 'Perempuan';
        } else if (rawGender == 'L') {
          _gender = 'Laki-laki';
        }
      });
    } catch (_) {} finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDateDisplay(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  Future<void> _saveFieldToBackend(Map<String, dynamic> data, String fieldName) async {
    if (widget.api == null) return;
    final isRoleAdmin = widget.isAdmin || (widget.api?.user?.isAdmin ?? false);
    if (isRoleAdmin && (fieldName == 'Tanggal Lahir' || fieldName == 'Jenis Kelamin')) {
      // shortcut: backend admin belum menyediakan kolom birth_date & gender pada /me/profile, upgrade ketika backend menambahkan relasi profil admin
      return;
    }
    try {
      await widget.api!.updateProfile(data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan $fieldName ke server: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _editTextField({
    required String title,
    required String initialValue,
    required String backendKey,
    required ValueChanged<String> onSaved,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final controller = TextEditingController(text: initialValue == 'Belum diatur' ? '' : initialValue);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Ubah $title',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                autofocus: true,
                style: GoogleFonts.poppins(fontSize: 14, color: _ink),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  hintText: 'Masukkan $title',
                  hintStyle: GoogleFonts.poppins(color: _muted, fontSize: 13),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _gold, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    onSaved(text);
                    _saveFieldToBackend({backendKey: text}, title);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$title berhasil diperbarui.'),
                        backgroundColor: const Color(0xFF22C55E),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _ink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Simpan Perubahan',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1930),
      lastDate: DateTime.now().subtract(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _ink,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _ink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      final formatted = '${picked.day} ${months[picked.month - 1]} ${picked.year}';
      final isoDate = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() => _birthDate = formatted);
      _saveFieldToBackend({'birth_date': isoDate}, 'Tanggal Lahir');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tanggal lahir diubah menjadi $_birthDate.'),
            backgroundColor: const Color(0xFF22C55E),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _selectGender() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Pilih Jenis Kelamin',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  title: Text(
                    'Perempuan',
                    style: GoogleFonts.poppins(
                      fontWeight: _gender == 'Perempuan' ? FontWeight.w700 : FontWeight.w500,
                      color: _ink,
                    ),
                  ),
                  trailing: _gender == 'Perempuan'
                      ? const Icon(Icons.check_circle_rounded, color: _ink)
                      : null,
                  onTap: () {
                    setState(() => _gender = 'Perempuan');
                    _saveFieldToBackend({'gender': 'P'}, 'Jenis Kelamin');
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  title: Text(
                    'Laki-laki',
                    style: GoogleFonts.poppins(
                      fontWeight: _gender == 'Laki-laki' ? FontWeight.w700 : FontWeight.w500,
                      color: _ink,
                    ),
                  ),
                  trailing: _gender == 'Laki-laki'
                      ? const Icon(Icons.check_circle_rounded, color: _ink)
                      : null,
                  onTap: () {
                    setState(() => _gender = 'Laki-laki');
                    _saveFieldToBackend({'gender': 'L'}, 'Jenis Kelamin');
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getInitials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return 'U';
    final parts = clean.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final headerHeight = topPadding + 115.0;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // 1. Header Ka'bah Malam di Latar Belakang (Berhenti di separuh atas kartu profil)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: Image.asset(
              'assets/images/Header Bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, _, _) => Image.asset(
                'assets/images/Background.webp',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // 2. Konten Scrollable
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Bar Navigasi (Tinggi 44px, Ikon Back Putih & Judul Emas Tengah)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: SizedBox(
                      height: 44,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text(
                              'Informasi Akun',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: _gold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48), // Penyeimbang IconButton
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  if (_isLoading)
                    _buildSkeletonAccountInfoView()
                  else ...[
                    // 1. Kartu Profil Jemaah Melayang di Atas Header Ka'bah (Warna: #FFF8EC)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar Inisial Dinamis dengan Lencana Verifikasi Emas (Hero Smooth Animation)
                          Hero(
                            tag: 'profile_avatar_hero',
                            child: Material(
                              type: MaterialType.transparency,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFECC485), Color(0xFFD4A359)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _gold.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _getInitials(_name),
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: _ink,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -2,
                                    right: -2,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: _gold,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.5),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        size: 11,
                                        color: _ink,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _email,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: _muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Seksi Data Pribadi (Berada di Bawah Header Ka'bah & Kartu Profil)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        'Data Pribadi',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Field 1: Nama Lengkap
                    _buildInfoCard(
                      icon: Icons.person_outline_rounded,
                      label: 'Nama Lengkap',
                      value: _name,
                      actionIcon: Icons.edit_outlined,
                      onTap: () => _editTextField(
                        title: 'Nama Lengkap',
                        initialValue: _name,
                        backendKey: 'name',
                        onSaved: (val) => setState(() => _name = val),
                      ),
                    ),

                    // Field 2: Email
                    _buildInfoCard(
                      icon: Icons.mail_outline_rounded,
                      label: 'Email',
                      value: _email,
                      actionIcon: Icons.edit_outlined,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Email terhubung dengan kredensial akun server.',
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                            backgroundColor: _ink,
                          ),
                        );
                      },
                    ),

                    // Field 3: Nomor Telepon
                    _buildInfoCard(
                      icon: Icons.phone_outlined,
                      label: 'Nomor Telepon',
                      value: _phone,
                      actionIcon: Icons.edit_outlined,
                      onTap: () => _editTextField(
                        title: 'Nomor Telepon',
                        initialValue: _phone,
                        backendKey: 'phone',
                        keyboardType: TextInputType.phone,
                        onSaved: (val) => setState(() => _phone = val),
                      ),
                    ),

                    // Field 4: Tanggal Lahir
                    _buildInfoCard(
                      icon: Icons.calendar_today_outlined,
                      label: 'Tanggal Lahir',
                      value: _birthDate,
                      actionIcon: Icons.calendar_month_outlined,
                      onTap: _selectBirthDate,
                    ),

                    // Field 5: Jenis Kelamin
                    _buildInfoCard(
                      icon: Icons.person_outline_rounded,
                      label: 'Jenis Kelamin',
                      value: _gender,
                      actionIcon: Icons.keyboard_arrow_down_rounded,
                      onTap: _selectGender,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required IconData actionIcon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF1E7D5), width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: _ink, size: 21),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _muted,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        value,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _ink,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(actionIcon, color: _ink, size: 19),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Skeleton placeholder saat memuat data akun & pribadi
  Widget _buildSkeletonAccountInfoView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Kartu Profil Jemaah Skeleton
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              SkeletonCircle(size: 60),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 140, height: 16, borderRadius: 6),
                    SizedBox(height: 6),
                    SkeletonBox(width: 180, height: 11, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Seksi Data Pribadi Skeleton
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: SkeletonBox(width: 110, height: 16, borderRadius: 6),
        ),
        const SizedBox(height: 10),

        // 5 Item Field Skeleton Cards
        for (int i = 0; i < 5; i++)
          Container(
            margin: const EdgeInsets.fromLTRB(18, 0, 18, 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF1E7D5), width: 0.8),
            ),
            child: const Row(
              children: [
                SkeletonCircle(size: 24),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 90, height: 11, borderRadius: 4),
                      SizedBox(height: 5),
                      SkeletonBox(width: 160, height: 14, borderRadius: 4),
                    ],
                  ),
                ),
                SkeletonBox(width: 20, height: 20, borderRadius: 6),
              ],
            ),
          ),
      ],
    );
  }
}
