import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/smooth_page_route.dart';
import '../../models/muthawwif_models.dart';
import '../../services/travel_api.dart';
import 'muthawwif_member_detail_page.dart';

/// Halaman Daftar Anggota Rombongan (Gambar 1, Screen 3).
/// Menampilkan daftar jemaah dalam rombongan, pencarian nama,
/// status ketua rombongan (👑), dan navigasi ke detail masing-masing jemaah.
class MuthawwifMemberListPage extends StatefulWidget {
  const MuthawwifMemberListPage({
    super.key,
    required this.api,
    required this.group,
  });

  final TravelApi api;
  final MuthawwifGroupInfo group;

  @override
  State<MuthawwifMemberListPage> createState() => _MuthawwifMemberListPageState();
}

class _MuthawwifMemberListPageState extends State<MuthawwifMemberListPage> {
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _gold = Color(0xFFECC485);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _muted = Color(0xFF8E8E93);

  final TextEditingController _searchController = TextEditingController();
  List<MuthawwifMemberInfo> _members = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    try {
      final backendJemaah = await widget.api.getMuthawwifJemaah(
        departureGroupId: widget.group.id,
      );
      if (backendJemaah.isNotEmpty) {
        _members = backendJemaah
            .map((j) => MuthawwifMemberInfo.fromBackendJson(j))
            .toList();
      }
    } catch (_) {}

    if (_members.isEmpty) {
      _members = MuthawwifMemberInfo.defaultMemberList();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  List<MuthawwifMemberInfo> get _filteredMembers {
    if (_searchQuery.trim().isEmpty) return _members;
    final q = _searchQuery.toLowerCase();
    return _members
        .where((m) => m.name.toLowerCase().contains(q) || (m.passportNumber?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final headerHeight = topPadding + 115.0;
    final displayList = _filteredMembers;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // 1. Header Ka'bah Malam
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

          // 2. Konten
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Bar Navigasi (Tinggi 44px, Ikon Back Putih & Judul Emas)
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
                            'Anggota Rombongan (${_members.length})',
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
                const SizedBox(height: 12),

                // Search Bar Input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF1E7D5), width: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: GoogleFonts.poppins(fontSize: 13, color: _ink),
                      decoration: InputDecoration(
                        hintText: 'Cari anggota...',
                        hintStyle: GoogleFonts.poppins(fontSize: 13, color: _muted),
                        prefixIcon: const Icon(Icons.search_rounded, color: _muted, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18, color: _muted),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // List Anggota Scrollable
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: _ink))
                      : displayList.isEmpty
                          ? Center(
                              child: Text(
                                'Tidak ada anggota ditemukan',
                                style: GoogleFonts.poppins(color: _muted, fontSize: 13),
                              ),
                            )
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 36),
                              itemCount: displayList.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final member = displayList[index];
                                return _buildMemberCard(context, member);
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, MuthawwifMemberInfo member) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            SmoothPageRoute(
              page: MuthawwifMemberDetailPage(
                api: widget.api,
                member: member,
                group: widget.group,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFECC485), Color(0xFFD4A359)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _gold.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    member.initials,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Nama & Role Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          member.roleLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: member.isLeader ? const Color(0xFFC89745) : _muted,
                            fontWeight: member.isLeader ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        if (member.isLeader) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.workspace_premium_rounded,
                            size: 14,
                            color: Color(0xFFC89745),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Trailing Chevron
              const Icon(
                Icons.chevron_right_rounded,
                color: _ink,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

