import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../core/api_client.dart';
import '../services/travel_api.dart';
import 'admin_maps_page.dart';
import 'muthawwif/muthawwif_maps_page.dart';

const Color _gold = Color(0xFFECC485);
const Color _bg = Color(0xFFFFF8EC);
const Color _ink = Color(0xFF1F1F1F);
const Color _muted = Color(0xFF64748B);
const Color _line = Color(0xFFEADFCC);

const Map<String, String> documentTypeLabels = {
  'passport': 'Paspor',
  'ktp': 'KTP',
  'kk': 'Kartu Keluarga',
  'photo': 'Pas Foto',
  'other': 'Lainnya',
  'general': 'Umum',
};

const List<String> requiredDocumentTypes = ['passport', 'ktp', 'kk', 'photo'];

String _text(dynamic value) => value == null ? '' : '$value';

String _date(dynamic value) {
  final raw = _text(value);
  if (raw.isEmpty) return 'Belum tersedia';
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
}

String visaLabel(String? status) {
  switch (status) {
    case 'approved':
    case 'issued':
      return 'Visa terbit';
    case 'processing':
      return 'Sedang diproses';
    case 'rejected':
      return 'Visa ditolak';
    case 'not_started':
      return 'Belum diproses';
    default:
      return (status == null || status.isEmpty) ? 'Belum tersedia' : status;
  }
}

Color visaColor(String? status) {
  switch (status) {
    case 'approved':
    case 'issued':
      return const Color(0xFF166534);
    case 'processing':
      return const Color(0xFFB45309);
    case 'rejected':
      return const Color(0xFFB91C1C);
    default:
      return _muted;
  }
}

class _PageScaffold extends StatelessWidget {
  const _PageScaffold({required this.title, required this.child, this.actions});
  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: _ink)),
          iconTheme: const IconThemeData(color: _ink),
          actions: actions,
        ),
        body: SafeArea(child: child),
      );
}

class _StateView extends StatelessWidget {
  const _StateView({required this.icon, required this.title, required this.message, this.onRetry, this.actionLabel});
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: _gold),
              const SizedBox(height: 14),
              Text(title, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: _ink)),
              const SizedBox(height: 6),
              Text(message, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, color: _muted)),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _ink, foregroundColor: Colors.white),
                  onPressed: onRetry,
                  child: Text(actionLabel ?? 'Coba lagi', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
        ),
      );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children, this.trailing});
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _line)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: _ink))),
              trailing ?? const SizedBox.shrink(),
            ]),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 120, child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: _muted))),
            const SizedBox(width: 8),
            Expanded(child: Text(value.isEmpty ? 'Belum tersedia' : value, style: GoogleFonts.poppins(fontSize: 12.5, color: _ink, fontWeight: FontWeight.w500))),
          ],
        ),
      );
}

Widget _identityHeader(Map<String, dynamic> data) {
  final identity = (data['identity'] as Map?)?.cast<String, dynamic>() ?? const {};
  final name = _text(identity['name'] ?? data['name']);
  final phone = _text(identity['phone'] ?? data['phone']);
  final role = _text(data['role']);
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF1F1F1F), Color(0xFF4A3B2A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(children: [
      CircleAvatar(
        radius: 28,
        backgroundColor: _gold,
        child: Text(
          name.isEmpty ? '?' : name.trim().split(' ').take(2).map((e) => e.isEmpty ? '' : e[0]).join().toUpperCase(),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: _ink),
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name.isEmpty ? 'Tanpa nama' : name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 2),
          Text(phone.isEmpty ? 'Nomor belum tersedia' : phone, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
          if (role.isNotEmpty) Text(role, style: GoogleFonts.poppins(fontSize: 11, color: _gold)),
        ]),
      ),
    ]),
  );
}

class JemaahProfileDetailPage extends StatefulWidget {
  const JemaahProfileDetailPage({super.key, required this.api});
  final TravelApi api;

  @override
  State<JemaahProfileDetailPage> createState() => _JemaahProfileDetailPageState();
}

class _JemaahProfileDetailPageState extends State<JemaahProfileDetailPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _data = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.api.getProfile();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
        _error = data.isEmpty ? 'Profil belum dapat dimuat.' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _PageScaffold(title: 'Profil Jemaah', child: Center(child: CircularProgressIndicator()));
    if (_error != null || _data.isEmpty) {
      return _PageScaffold(title: 'Profil Jemaah', child: _StateView(icon: Icons.person_off_outlined, title: 'Profil tidak tersedia', message: _error ?? 'Data profil belum tersedia.', onRetry: _load));
    }
    final profile = (_data['profile'] as Map?)?.cast<String, dynamic>() ?? const {};
    final group = (_data['group'] as Map?)?.cast<String, dynamic>() ?? const {};
    final pkg = (_data['package'] as Map?)?.cast<String, dynamic>() ?? const {};
    final muthawwif = (_data['muthawwif'] as Map?)?.cast<String, dynamic>() ?? const {};
    final departure = (_data['departure_group'] as Map?)?.cast<String, dynamic>() ?? const {};
    return _PageScaffold(
      title: 'Profil Jemaah',
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _identityHeader(_data),
            _InfoCard(title: 'Identitas', children: [
              _InfoRow('Nama', _text(identityName(_data))),
              _InfoRow('Email', _text(_data['email'])),
              _InfoRow('Telepon', _text(_data['phone'])),
              _InfoRow('Jenis kelamin', _text(profile['gender']) == 'P' ? 'Perempuan' : (_text(profile['gender']) == 'L' ? 'Laki-laki' : '')),
              _InfoRow('Tanggal lahir', _date(profile['birth_date'])),
              _InfoRow('Alamat', _text(profile['address'])),
              _InfoRow('Kota', _text(profile['city'])),
            ]),
            _InfoCard(title: 'Rombongan & Pembimbing', children: [
              _InfoRow('Grup', _text(group['name'] ?? profile['group_name'])),
              _InfoRow('Paket', _text(pkg['name'])),
              _InfoRow('Muthawwif', _text(muthawwif['name'])),
              _InfoRow('Kontak muthawwif', _text(muthawwif['phone'])),
              _InfoRow('Berangkat', _date(departure['departure_date'])),
            ]),
            _InfoCard(title: 'Kontak Darurat', children: [
              _InfoRow('Nama', _text(profile['emergency_contact_name'])),
              _InfoRow('Telepon', _text(profile['emergency_contact_phone'])),
            ]),
          ],
        ),
      ),
    );
  }
}

String identityName(Map<String, dynamic> data) {
  final identity = (data['identity'] as Map?)?.cast<String, dynamic>() ?? const {};
  return _text(identity['name'] ?? data['name']);
}

class JemaahDetailPage extends StatefulWidget {
  const JemaahDetailPage({super.key, required this.api, required this.userId});
  final TravelApi api;
  final int userId;

  @override
  State<JemaahDetailPage> createState() => _JemaahDetailPageState();
}

class _JemaahDetailPageState extends State<JemaahDetailPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _data = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final data = await widget.api.getJemaahDetail(widget.userId);
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
      _error = data.isEmpty ? 'Data jemaah tidak dapat diakses atau tidak ditemukan.' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _PageScaffold(title: 'Detail Jemaah', child: Center(child: CircularProgressIndicator()));
    if (_error != null) {
      return _PageScaffold(title: 'Detail Jemaah', child: _StateView(icon: Icons.lock_outline, title: 'Akses terbatas', message: _error!, onRetry: _load));
    }
    final profile = (_data['profile'] as Map?)?.cast<String, dynamic>() ?? const {};
    final group = (_data['group'] as Map?)?.cast<String, dynamic>() ?? const {};
    final pkg = (_data['package'] as Map?)?.cast<String, dynamic>() ?? const {};
    final muthawwif = (_data['muthawwif'] as Map?)?.cast<String, dynamic>() ?? const {};
    final departure = (_data['departure_group'] as Map?)?.cast<String, dynamic>() ?? const {};
    final status = _text(profile['visa_status']);
    return _PageScaffold(
      title: 'Detail Jemaah',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _identityHeader(_data),
          _InfoCard(title: 'Identitas', children: [
            _InfoRow('Nama', _text(_data['name'])),
            _InfoRow('Email', _text(_data['email'])),
            _InfoRow('Telepon', _text(_data['phone'])),
            _InfoRow('Grup', _text(group['name'] ?? profile['group_name'])),
            _InfoRow('Paket', _text(pkg['name'])),
            _InfoRow('Muthawwif', _text(muthawwif['name'])),
          ]),
          _InfoCard(
            title: 'Visa & Keberangkatan',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: visaColor(status).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(visaLabel(status), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: visaColor(status))),
            ),
            children: [
              _InfoRow('Nomor visa', _text(profile['visa_number'])),
              _InfoRow('Masa visa', _date(profile['visa_expiry'])),
              _InfoRow('Berangkat', _date(departure['departure_date'])),
              _InfoRow('Kembali', _date(departure['return_date'])),
            ],
          ),
        ],
      ),
    );
  }
}

class VisaDeparturePage extends StatefulWidget {
  const VisaDeparturePage({super.key, required this.api});
  final TravelApi api;

  @override
  State<VisaDeparturePage> createState() => _VisaDeparturePageState();
}

class _VisaDeparturePageState extends State<VisaDeparturePage> {
  bool _loading = true;
  Map<String, dynamic> _data = const {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.api.getProfile();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
        _error = data.isEmpty ? 'Data visa belum tersedia.' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _PageScaffold(title: 'Visa & Keberangkatan', child: Center(child: CircularProgressIndicator()));
    if (_error != null) {
      return _PageScaffold(title: 'Visa & Keberangkatan', child: _StateView(icon: Icons.badge_outlined, title: 'Belum ada informasi', message: _error!, onRetry: _load));
    }
    final profile = (_data['profile'] as Map?)?.cast<String, dynamic>() ?? const {};
    final departure = (_data['departure_group'] as Map?)?.cast<String, dynamic>() ?? const {};
    final group = (_data['group'] as Map?)?.cast<String, dynamic>() ?? const {};
    final status = _text(profile['visa_status']);
    return _PageScaffold(
      title: 'Visa & Keberangkatan',
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _identityHeader(_data),
            _InfoCard(
              title: 'Status Visa',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: visaColor(status).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(visaLabel(status), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: visaColor(status))),
              ),
              children: [
                _InfoRow('Nomor visa', _text(profile['visa_number'])),
                _InfoRow('Masa berlaku', _date(profile['visa_expiry'])),
                _InfoRow('Paspor', _text(profile['passport_number'])),
                _InfoRow('Masa paspor', _date(profile['passport_expiry'])),
              ],
            ),
            _InfoCard(title: 'Jadwal Keberangkatan', children: [
              _InfoRow('Grup', _text(departure['name'] ?? group['name'] ?? profile['group_name'])),
              _InfoRow('Tanggal berangkat', _date(departure['departure_date'])),
              _InfoRow('Tanggal kembali', _date(departure['return_date'])),
              _InfoRow('Tour leader', _text(departure['tour_leader_name'])),
            ]),
            if (status.isEmpty || status == 'not_started')
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(14)),
                child: Text(
                  'Informasi visa akan tampil setelah petugas memperbarui data pusat. Hubungi muthawwif bila ada pertanyaan.',
                  style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF92400E)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key, required this.api});
  final TravelApi api;

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  bool _loading = true;
  bool _uploading = false;
  List<Map<String, dynamic>> _documents = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final documents = await widget.api.getDocuments();
    if (!mounted) return;
    setState(() {
      _documents = documents;
      _loading = false;
    });
  }

  Future<void> _pickAndUpload() async {
    final type = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _bg,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Pilih jenis dokumen', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          for (final entry in documentTypeLabels.entries.where((e) => requiredDocumentTypes.contains(e.key)))
            ListTile(
              leading: const Icon(Icons.description_outlined, color: _ink),
              title: Text(entry.value, style: GoogleFonts.poppins(fontSize: 14)),
              onTap: () => Navigator.pop(context, entry.key),
            ),
        ]),
      ),
    );
    if (type == null || !mounted) return;
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      withData: false,
    );
    final path = picked?.files.single.path;
    if (path == null || !mounted) return;
    setState(() => _uploading = true);
    try {
      await widget.api.uploadDocument(path, filename: picked!.files.single.name, documentType: type);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dokumen berhasil diunggah.')));
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFB91C1C)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengunggah: $e'), backgroundColor: const Color(0xFFB91C1C)));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _open(Map<String, dynamic> document) async {
    final id = document['id'] as int?;
    if (id == null) return;
    try {
      final bytes = await widget.api.downloadDocument(id);
      if (!mounted) return;
      if (document['is_image'] == true) {
        await showDialog<void>(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.black,
            insetPadding: const EdgeInsets.all(12),
            child: Stack(children: [
              InteractiveViewer(child: Image.memory(Uint8List.fromList(bytes), fit: BoxFit.contain)),
              Positioned(top: 4, right: 4, child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context))),
            ]),
          ),
        );
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/${document['file_name'] ?? 'dokumen-$id.pdf'}');
        await file.writeAsBytes(bytes, flush: true);
        await OpenFilex.open(file.path);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFB91C1C)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dokumen tidak dapat dibuka: $e'), backgroundColor: const Color(0xFFB91C1C)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final present = _documents.map((d) => _text(d['document_type'])).toSet();
    final completed = requiredDocumentTypes.where(present.contains).length;
    return _PageScaffold(
      title: 'Dokumen Saya',
      actions: [
        IconButton(
          tooltip: 'Unggah dokumen',
          onPressed: _uploading ? null : _pickAndUpload,
          icon: _uploading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.upload_file_outlined),
        ),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _InfoCard(
                    title: 'Kelengkapan Dokumen',
                    trailing: Text('$completed/${requiredDocumentTypes.length}', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: completed == requiredDocumentTypes.length ? const Color(0xFF166534) : const Color(0xFFB45309))),
                    children: [
                      LinearProgressIndicator(value: completed / requiredDocumentTypes.length, minHeight: 8, color: _gold, backgroundColor: _line),
                      const SizedBox(height: 10),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final type in requiredDocumentTypes)
                          Chip(
                            label: Text(documentTypeLabels[type] ?? type, style: GoogleFonts.poppins(fontSize: 11)),
                            avatar: Icon(present.contains(type) ? Icons.check_circle : Icons.radio_button_unchecked, size: 16, color: present.contains(type) ? const Color(0xFF166534) : _muted),
                            backgroundColor: present.contains(type) ? const Color(0xFFE8F5E9) : Colors.white,
                            side: const BorderSide(color: _line),
                          ),
                      ]),
                    ],
                  ),
                  if (_documents.isEmpty)
                    _StateView(icon: Icons.folder_open_outlined, title: 'Belum ada dokumen', message: 'Unggah paspor, KTP, KK, dan pas foto untuk melengkapi administrasi.', actionLabel: 'Unggah sekarang', onRetry: _pickAndUpload)
                  else
                    for (final document in _documents)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _line)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: _bg,
                            child: Icon(document['is_image'] == true ? Icons.image_outlined : Icons.picture_as_pdf_outlined, color: _ink),
                          ),
                          title: Text(_text(document['original_name'] ?? document['file_name']), maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            '${documentTypeLabels[_text(document['document_type'])] ?? 'Dokumen'} • ${((document['size'] as num?) ?? 0) ~/ 1024} KB • ${_date(document['uploaded_at'])}',
                            style: GoogleFonts.poppins(fontSize: 11, color: _muted),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _open(document),
                        ),
                      ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: _ink, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
                    onPressed: _uploading ? null : _pickAndUpload,
                    icon: const Icon(Icons.upload_file_outlined),
                    label: Text('Unggah Dokumen', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
    );
  }
}

class DepartureHistoryPage extends StatefulWidget {
  const DepartureHistoryPage({super.key, required this.api});
  final TravelApi api;

  @override
  State<DepartureHistoryPage> createState() => _DepartureHistoryPageState();
}

class _DepartureHistoryPageState extends State<DepartureHistoryPage> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  bool _loading = true;
  List<Map<String, dynamic>> _groups = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  String get _monthKey => '${_month.year.toString().padLeft(4, '0')}-${_month.month.toString().padLeft(2, '0')}';

  String get _monthLabel {
    const names = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${names[_month.month - 1]} ${_month.year}';
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final groups = await widget.api.getDepartures(month: _monthKey);
    if (!mounted) return;
    setState(() {
      _groups = groups;
      _loading = false;
    });
  }

  void _shiftMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
    _load();
  }

  @override
  Widget build(BuildContext context) => _PageScaffold(
        title: 'Riwayat Keberangkatan',
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(children: [
              IconButton(onPressed: () => _shiftMonth(-1), icon: const Icon(Icons.chevron_left)),
              Expanded(child: Center(child: Text(_monthLabel, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)))),
              IconButton(onPressed: () => _shiftMonth(1), icon: const Icon(Icons.chevron_right)),
            ]),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _groups.isEmpty
                    ? _StateView(icon: Icons.event_busy_outlined, title: 'Tidak ada keberangkatan', message: 'Tidak ada grup yang berangkat pada $_monthLabel.', onRetry: _load)
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: _groups.length,
                          itemBuilder: (context, index) {
                            final group = _groups[index];
                            final members = (group['members'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _line)),
                              child: ExpansionTile(
                                shape: const Border(),
                                collapsedShape: const Border(),
                                tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                                childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                                title: Text(_text(group['name']), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
                                subtitle: Text(
                                  '${_date(group['departure_date'])} • ${_text((group['package'] as Map?)?['name'] ?? 'Paket belum tersedia')} • ${members.length} jemaah',
                                  style: GoogleFonts.poppins(fontSize: 11, color: _muted),
                                ),
                                children: [
                                  if (members.isEmpty)
                                    Align(alignment: Alignment.centerLeft, child: Text('Belum ada jemaah pada grup ini.', style: GoogleFonts.poppins(fontSize: 12, color: _muted)))
                                  else
                                    for (final member in members)
                                      ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(Icons.person_outline, size: 20),
                                        title: Text(_text(member['name']), style: GoogleFonts.poppins(fontSize: 12.5)),
                                        subtitle: Text(visaLabel(_text(member['visa_status'])), style: GoogleFonts.poppins(fontSize: 11, color: visaColor(_text(member['visa_status'])))),
                                      ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ]),
      );
}

class GroupManagementPage extends StatefulWidget {
  const GroupManagementPage({super.key, required this.api, required this.isAdmin});
  final TravelApi api;
  final bool isAdmin;

  @override
  State<GroupManagementPage> createState() => _GroupManagementPageState();
}

class _GroupManagementPageState extends State<GroupManagementPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _groups = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final now = DateTime.now();
    final month = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
    var groups = await widget.api.getDepartures(month: month);
    if (groups.isEmpty) {
      groups = await widget.api.getDepartures();
    }
    if (!mounted) return;
    setState(() {
      _groups = groups;
      _loading = false;
    });
  }

  Future<void> _openGroup(Map<String, dynamic> group) async {
    final id = group['id'] as int?;
    final members = (group['members'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _bg,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          children: [
            Text(_text(group['name']), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('${_date(group['departure_date'])} • ${members.length} jemaah', style: GoogleFonts.poppins(fontSize: 12, color: _muted)),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _ink, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => widget.isAdmin ? AdminMapsPage(api: widget.api) : MuthawwifMapsPage(api: widget.api, initialGroupId: id)));
              },
              icon: const Icon(Icons.map_outlined),
              label: const Text('Buka Tracker Grup'),
            ),
            const SizedBox(height: 8),
            if (members.isEmpty)
              const _StateView(icon: Icons.group_off_outlined, title: 'Belum ada anggota', message: 'Grup ini belum memiliki jemaah.')
            else
              for (final member in members)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(backgroundColor: _bg, child: Text(_text(member['name']).isEmpty ? '?' : _text(member['name'])[0].toUpperCase())),
                  title: Text(_text(member['name']), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(visaLabel(_text(member['visa_status'])), style: GoogleFonts.poppins(fontSize: 11, color: visaColor(_text(member['visa_status'])))),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final memberId = member['id'] as int?;
                    if (memberId == null) return;
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => JemaahDetailPage(api: widget.api, userId: memberId)));
                  },
                ),
            if (id != null) const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _PageScaffold(
        title: 'Kelola Jemaah per Grup',
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _groups.isEmpty
                ? _StateView(icon: Icons.groups_2_outlined, title: 'Belum ada grup', message: 'Belum ada grup keberangkatan yang dapat dikelola.', onRetry: _load)
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _groups.length,
                      itemBuilder: (context, index) {
                        final group = _groups[index];
                        final count = (group['members'] as List?)?.length ?? group['members_count'] ?? 0;
                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: _line)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            leading: const CircleAvatar(backgroundColor: _bg, child: Icon(Icons.groups_2_outlined, color: _ink)),
                            title: Text(_text(group['name']), style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700)),
                            subtitle: Text('${_date(group['departure_date'])} • $count jemaah', style: GoogleFonts.poppins(fontSize: 11, color: _muted)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _openGroup(group),
                          ),
                        );
                      },
                    ),
                  ),
      );
}


class StaffProfilePage extends StatefulWidget {
  const StaffProfilePage({super.key, required this.api});
  final TravelApi api;

  @override
  State<StaffProfilePage> createState() => _StaffProfilePageState();
}

class _StaffProfilePageState extends State<StaffProfilePage> {
  bool _loading = true;
  Map<String, dynamic> _data = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await widget.api.getProfile();
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _PageScaffold(title: 'Profil Staf', child: Center(child: CircularProgressIndicator()));
    if (_data.isEmpty) {
      return _PageScaffold(title: 'Profil Staf', child: _StateView(icon: Icons.support_agent_outlined, title: 'Profil belum tersedia', message: 'Data staf/muthawwif belum dapat dimuat.', onRetry: _load));
    }
    final profile = (_data['profile'] as Map?)?.cast<String, dynamic>() ?? const {};
    final languages = (profile['languages'] as List?)?.map((e) => '$e').where((e) => e.isNotEmpty).join(', ') ?? '';
    return _PageScaffold(
      title: 'Profil Staf',
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _identityHeader(_data),
            _InfoCard(title: 'Kontak & Peran', children: [
              _InfoRow('Nama', _text(_data['name'])),
              _InfoRow('Email', _text(_data['email'])),
              _InfoRow('Telepon', _text(_data['phone'])),
              _InfoRow('Peran', _text(_data['role']) == 'muthawwif' ? 'Muthawwif' : (_text(_data['role']) == 'admin' ? 'Admin' : _text(_data['role']))),
              _InfoRow('Jemaah bimbingan', _text(_data['guided_jemaah_count'])),
            ]),
            _InfoCard(title: 'Profil Profesional', children: [
              _InfoRow('Spesialisasi', _text(profile['specialization'])),
              _InfoRow('Pengalaman', profile['years_experience'] == null ? '' : '${profile['years_experience']} tahun'),
              _InfoRow('Bahasa', languages),
              _InfoRow('Sertifikasi', _text(profile['certification_number'])),
              _InfoRow('Bio', _text(profile['bio'])),
            ]),
          ],
        ),
      ),
    );
  }
}
