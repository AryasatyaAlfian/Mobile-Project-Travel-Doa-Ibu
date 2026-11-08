import 'package:flutter/material.dart';

import '../core/smooth_page_route.dart';
import '../models/models.dart';
import '../services/travel_api.dart';
import 'booking_form_page.dart';
import 'widgets/skeleton_view.dart';

class PackageDetailPage extends StatefulWidget {
  const PackageDetailPage({
    super.key,
    required this.package,
    required this.api,
  });

  final TravelPackage package;
  final TravelApi api;

  @override
  State<PackageDetailPage> createState() => _PackageDetailPageState();
}

class _PackageDetailPageState extends State<PackageDetailPage> {
  late Future<TravelPackage> _detailFuture;
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;

  bool _isDescriptionExpanded = false;
  int _selectedRoomIndex = 0; // 0: Quad, 1: Triple, 2: Double
  int? _selectedGroupIndex;
  bool _isFavorite = false;

  List<Map<String, dynamic>> _getRoomTypes(TravelPackage data) {
    final basePrice = data.startingPrice ?? 35000000.0;
    double quadPrice = basePrice;
    double triplePrice = basePrice >= 15000000 ? basePrice + 2500000 : (basePrice * 1.1).roundToDouble();
    double doublePrice = basePrice >= 15000000 ? basePrice + 5500000 : (basePrice * 1.25).roundToDouble();

    if (data.pricing != null) {
      if (data.pricing!['quad'] is num) quadPrice = (data.pricing!['quad'] as num).toDouble();
      if (data.pricing!['triple'] is num) triplePrice = (data.pricing!['triple'] as num).toDouble();
      if (data.pricing!['double'] is num) doublePrice = (data.pricing!['double'] as num).toDouble();
    }

    return [
      {
        'name': 'Quad',
        'capacity': '4 orang / kamar',
        'price': quadPrice,
        'formatted': 'Rp ${_formatNumber(quadPrice)}',
      },
      {
        'name': 'Triple',
        'capacity': '3 orang / kamar',
        'price': triplePrice,
        'formatted': 'Rp ${_formatNumber(triplePrice)}',
      },
      {
        'name': 'Double',
        'capacity': '2 orang / kamar',
        'price': doublePrice,
        'formatted': 'Rp ${_formatNumber(doublePrice)}',
      },
    ];
  }

  String _formatNumber(double amount) {
    final intVal = amount.toInt();
    final str = intVal.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'Apakah bisa bayar dengan cicilan?',
      'answer':
          'Bisa, bayar DP Rp 10.000.000 saat pemesanan, sisanya dapat dicicil hingga 30 hari sebelum keberangkatan.',
    },
    {
      'question': 'Bagaimana jika keberangkatan ditunda?',
      'answer':
          'Jadwal keberangkatan dapat dialihkan ke rombongan berikutnya tanpa biaya penalti sesuai ketentuan Doa Ibu Travel.',
    },
    {
      'question': 'Kapan jadwal manasik dilaksanakan?',
      'answer':
          'Manasik intensif dilaksanakan 2 kali di hotel transit dan secara daring 2 minggu sebelum jadwal keberangkatan.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _detailFuture = widget.api.package(widget.package.slug).catchError((_) => widget.package);
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  void _onRoomSelected(int index) {
    setState(() => _selectedRoomIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: FutureBuilder<TravelPackage>(
        future: _detailFuture,
        initialData: widget.package,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting && snapshot.data == null;
          if (isLoading) {
            return _buildSkeletonDetail();
          }

          final data = snapshot.data ?? widget.package;
          return _buildLoadedContent(data);
        },
      ),
    );
  }

  Widget _buildSkeletonDetail() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          SkeletonBox(height: 260, borderRadius: 20),
          SizedBox(height: 20),
          SkeletonBox(width: 140, height: 24, borderRadius: 6),
          SizedBox(height: 12),
          SkeletonBox(width: 220, height: 28, borderRadius: 6),
          SizedBox(height: 16),
          SkeletonBox(height: 80, borderRadius: 16),
          SizedBox(height: 20),
          SkeletonBox(height: 120, borderRadius: 16),
          SizedBox(height: 20),
          SkeletonBox(height: 200, borderRadius: 16),
        ],
      ),
    );
  }

  Widget _buildLoadedContent(TravelPackage data) {
    // Foto list: gabungkan image utama dan list images
    final images = [
      if (data.image != null && data.image!.isNotEmpty) data.image!,
      ...data.images,
    ];
    if (images.isEmpty) {
      images.add('assets/images/mecca.jpg');
    }

    final groups = data.departureGroups;
    // Inisialisasi selected group jika belum ada
    if (_selectedGroupIndex == null && groups.isNotEmpty) {
      final firstOpen = groups.indexWhere((g) => !g.isFull);
      _selectedGroupIndex = firstOpen != -1 ? firstOpen : 0;
    }

    final roomTypes = _getRoomTypes(data);
    final selectedRoomIndex = _selectedRoomIndex < roomTypes.length ? _selectedRoomIndex : 0;
    final currentRoom = roomTypes[selectedRoomIndex];
    final roomPriceFormatted = currentRoom['formatted'] as String;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // Hero Image Carousel & Floating Action Icons
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  SizedBox(
                    height: 320,
                    width: double.infinity,
                    child: PageView.builder(
                      controller: _imagePageController,
                      itemCount: images.length,
                      onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                      itemBuilder: (context, index) {
                        final img = images[index];
                        if (img.startsWith('http')) {
                          return Image.network(
                            img,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: const Color(0xFFEFE8DE),
                              child: const Icon(Icons.image, size: 48, color: Colors.grey),
                            ),
                          );
                        }
                        return Image.asset(img, fit: BoxFit.cover);
                      },
                    ),
                  ),
                  // Dark gradient overlay on top
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 110,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.45),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Header Back, Share, Favorite
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCircleIconButton(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.pop(context),
                          ),
                          Row(
                            children: [
                              _buildCircleIconButton(
                                icon: Icons.share_outlined,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tautan paket telah disalin')),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildCircleIconButton(
                                icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : const Color(0xFF1F1F1F),
                                onTap: () => setState(() => _isFavorite = !_isFavorite),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Page Indicator Badge (1/5)
                  Positioned(
                    bottom: 16,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_currentImageIndex + 1}/${images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Konten Body
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFDFBF7),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Kategori & Review Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F1F8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                data.category?.name ?? 'Paket Umrah',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF336288),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 16, color: Color(0xFFE8B972)),
                              SizedBox(width: 4),
                              Text(
                                '4.9 ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xFF1F1F1F),
                                ),
                              ),
                              Text(
                                '(128 ulasan)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF72787D),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Nama Paket
                      Text(
                        data.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F1F1F),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Quick Specs Row
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          if (data.duration != null && data.duration!.isNotEmpty)
                            _buildSpecItem(Icons.access_time, data.duration!),
                          if (data.airline != null && data.airline!.isNotEmpty)
                            _buildSpecItem(Icons.flight, data.airline!),
                          _buildSpecItem(
                            Icons.people_outline,
                            data.remainingQuota != null
                                ? 'Sisa ${data.remainingQuota} Kursi'
                                : (data.quota != null ? 'Sisa ${data.quota} Kursi' : 'Tersedia'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Golden Price Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF2D8AA), Color(0xFFECC485)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Mulai dari',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF4A3B22),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      data.formattedPrice,
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF1F1F1F),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    '/ orang - kamar Quad',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF5A492E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Cicilan 0%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F1F1F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Jadwal Keberangkatan
                      _buildSectionHeader('Jadwal Keberangkatan', actionText: 'Lihat Semua'),
                      const SizedBox(height: 12),
                      _buildDepartureGroupsList(data),
                      const SizedBox(height: 24),

                      // Tentang Paket
                      const Text(
                        'Tentang Paket',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (data.description != null && data.description!.isNotEmpty)
                            ? data.description!
                            : (data.excerpt ??
                                'Perjalanan ibadah Umrah selama 15 hari di Madinah dan Makkah, dilanjutkan wisata keindahan Istanbul dan Cappadocia. Didampingi muthawwif berpengalaman serta tour leader dari Indonesia sejak keberangkatan hingga kembali ke tanah air.'),
                        maxLines: _isDescriptionExpanded ? null : 3,
                        overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Color(0xFF555B60),
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                        child: Text(
                          _isDescriptionExpanded ? 'Tutup selengkapnya' : 'Baca selengkapnya',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB57F26),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Fasilitas Grid 2 Kolom
                      const Text(
                        'Fasilitas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFacilitiesGrid(data),
                      const SizedBox(height: 24),

                      // Akomodasi Hotel
                      const Text(
                        'Akomodasi Hotel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildHotelsList(data),
                      const SizedBox(height: 24),

                      // Itinerary Perjalanan Timeline
                      const Text(
                        'Itinerary Perjalanan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildItineraryTimeline(data),
                      const SizedBox(height: 24),

                      // Yang Didapat (Termasuk / Tidak Termasuk)
                      _buildInclusionsExclusionsCard(data),
                      const SizedBox(height: 24),

                      // Pilihan Tipe Kamar
                      const Text(
                        'Pilihan Tipe Kamar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(roomTypes.length, (idx) {
                        final room = roomTypes[idx];
                        final isSelected = selectedRoomIndex == idx;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: () => _onRoomSelected(idx),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFFFF7EB) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFE8B972) : const Color(0xFFE9E5DD),
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                    size: 20,
                                    color: isSelected ? const Color(0xFFB57F26) : const Color(0xFFA0A6AC),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          room['name'] as String,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F1F1F),
                                          ),
                                        ),
                                        Text(
                                          room['capacity'] as String,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF72787D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    room['formatted'] as String,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1F1F1F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),

                      // Syarat & Dokumen
                      _buildRequirementsCard(data),
                      const SizedBox(height: 24),

                      // Pertanyaan Seputar Paket (Accordion)
                      const Text(
                        'Pertanyaan Seputar Paket',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFaqSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // Sticky Bottom Booking Bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Biaya',
                          style: TextStyle(fontSize: 11, color: Color(0xFF72787D)),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            roomPriceFormatted,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1F1F1F),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final selectedGroup = (data.departureGroups.isNotEmpty &&
                              _selectedGroupIndex != null &&
                              _selectedGroupIndex! < data.departureGroups.length)
                          ? data.departureGroups[_selectedGroupIndex!]
                          : null;

                      Navigator.push(
                        context,
                        SmoothPageRoute(
                          page: BookingFormPage(
                            package: data,
                            api: widget.api,
                            initialSelectedGroup: selectedGroup,
                            initialRoomType: currentRoom['name'] as String,
                            initialRoomPrice: (currentRoom['price'] as num).toDouble(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFECC485),
                      foregroundColor: const Color(0xFF1F1F1F),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: const Text(
                      'Pesan Sekarang',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = const Color(0xFF1F1F1F),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF72787D)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF555B60),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {String? actionText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F1F1F),
            ),
          ),
        ),
        if (actionText != null) ...[
          const SizedBox(width: 8),
          Text(
            actionText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB57F26),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDepartureGroupsList(TravelPackage data) {
    final groups = data.departureGroups;
    if (groups.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9E5DD)),
        ),
        child: Text(
          data.departureDate != null
              ? 'Keberangkatan: ${data.departureDate!.day}/${data.departureDate!.month}/${data.departureDate!.year}'
              : 'Jadwal Fleksibel (Dikonfirmasi oleh Admin)',
          style: const TextStyle(fontSize: 13, color: Color(0xFF1F1F1F)),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(groups.length, (idx) {
          final group = groups[idx];
          final isSelected = _selectedGroupIndex == idx;
          final isFull = group.isFull;

          final dateStr = group.departureDate != null
              ? '${group.departureDate!.day} ${_monthName(group.departureDate!.month)} ${group.departureDate!.year}'
              : group.name;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: isFull ? null : () => setState(() => _selectedGroupIndex = idx),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 125,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isFull
                      ? const Color(0xFFF1F1F1)
                      : (isSelected ? const Color(0xFFFFF7EB) : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isFull
                        ? const Color(0xFFE0E0E0)
                        : (isSelected ? const Color(0xFFE8B972) : const Color(0xFFE9E5DD)),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isFull ? const Color(0xFFA0A6AC) : const Color(0xFF1F1F1F),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isFull ? 'Penuh' : 'Sisa ${group.remainingQuota ?? 10} kursi',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isFull ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFacilitiesGrid(TravelPackage data) {
    if (data.features.isNotEmpty) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.features.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.3,
        ),
        itemBuilder: (context, index) {
          final f = data.features[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE9E5DD)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_mapFeatureIcon(f.icon), size: 18, color: const Color(0xFFB57F26)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        f.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      if (f.description != null && f.description!.isNotEmpty)
                        Text(
                          f.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF72787D),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    final dynamicFacilities = <Map<String, dynamic>>[];
    if (data.hotel != null && data.hotel!.isNotEmpty) {
      dynamicFacilities.add({
        'icon': Icons.hotel_rounded,
        'title': 'Akomodasi Hotel',
        'subtitle': data.hotel!,
      });
    }
    if (data.airline != null && data.airline!.isNotEmpty) {
      dynamicFacilities.add({
        'icon': Icons.flight_takeoff,
        'title': 'Penerbangan PP',
        'subtitle': data.airline!,
      });
    }
    if (data.meals != null && data.meals!.isNotEmpty) {
      dynamicFacilities.add({
        'icon': Icons.restaurant_outlined,
        'title': 'Konsumsi',
        'subtitle': data.meals!,
      });
    }
    for (final inc in data.inclusions) {
      if (dynamicFacilities.length >= 8) break;
      dynamicFacilities.add({
        'icon': _mapInclusionIcon(inc),
        'title': inc,
        'subtitle': 'Termasuk Paket',
      });
    }

    if (dynamicFacilities.isEmpty) {
      dynamicFacilities.addAll([
        {'icon': Icons.hotel_rounded, 'title': 'Akomodasi Hotel', 'subtitle': 'Sesuai Program'},
        {'icon': Icons.flight_takeoff, 'title': 'Tiket Transportasi', 'subtitle': 'Pulang Pergi'},
        {'icon': Icons.restaurant_outlined, 'title': 'Makan Terjadwal', 'subtitle': 'Selama Program'},
        {'icon': Icons.verified_user_outlined, 'title': 'Asuransi Perjalanan', 'subtitle': 'Terlindungi'},
      ]);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dynamicFacilities.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.3,
      ),
      itemBuilder: (context, index) {
        final f = dynamicFacilities[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE9E5DD)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(f['icon'] as IconData, size: 18, color: const Color(0xFFB57F26)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      f['title'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                    Text(
                      f['subtitle'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF72787D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _mapFeatureIcon(String? icon) {
    if (icon == null) return Icons.verified_outlined;
    final lower = icon.toLowerCase();
    if (lower.contains('hotel') || lower.contains('bed') || lower.contains('room')) return Icons.hotel_rounded;
    if (lower.contains('flight') || lower.contains('plane') || lower.contains('pesawat') || lower.contains('tiket')) {
      return Icons.flight_takeoff;
    }
    if (lower.contains('bus') || lower.contains('transport') || lower.contains('mobil')) {
      return Icons.directions_bus_outlined;
    }
    if (lower.contains('visa') || lower.contains('doc') || lower.contains('paspor')) return Icons.description_outlined;
    if (lower.contains('food') || lower.contains('meal') || lower.contains('makan') || lower.contains('kuliner')) {
      return Icons.restaurant_outlined;
    }
    if (lower.contains('guide') || lower.contains('mutawif') || lower.contains('muthawwif') || lower.contains('pemandu')) {
      return Icons.support_agent_rounded;
    }
    if (lower.contains('bag') || lower.contains('luggage') || lower.contains('koper') || lower.contains('perlengkapan')) {
      return Icons.luggage_outlined;
    }
    if (lower.contains('manasik') || lower.contains('book') || lower.contains('buku')) return Icons.menu_book_outlined;
    if (lower.contains('asuransi') || lower.contains('shield') || lower.contains('safe')) return Icons.security_rounded;
    return Icons.verified_outlined;
  }

  IconData _mapInclusionIcon(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('hotel') || lower.contains('kamar') || lower.contains('akomodasi')) return Icons.hotel_rounded;
    if (lower.contains('pesawat') || lower.contains('tiket') || lower.contains('flight')) return Icons.flight_takeoff;
    if (lower.contains('bus') || lower.contains('transport') || lower.contains('kendaraan')) {
      return Icons.directions_bus_outlined;
    }
    if (lower.contains('makan') || lower.contains('konsumsi') || lower.contains('sarapan')) {
      return Icons.restaurant_outlined;
    }
    if (lower.contains('visa') || lower.contains('paspor') || lower.contains('dokumen')) return Icons.description_outlined;
    if (lower.contains('asuransi')) return Icons.security_rounded;
    if (lower.contains('muthawwif') || lower.contains('guide') || lower.contains('pemandu') || lower.contains('leader')) {
      return Icons.support_agent_rounded;
    }
    if (lower.contains('perlengkapan') || lower.contains('koper') || lower.contains('ihram')) {
      return Icons.luggage_outlined;
    }
    return Icons.check_circle_outline;
  }

  Widget _buildHotelsList(TravelPackage data) {
    final rawHotel = data.hotel?.trim();
    if (rawHotel == null || rawHotel.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE9E5DD)),
        ),
        child: const Row(
          children: [
            Icon(Icons.apartment_rounded, color: Color(0xFFB57F26), size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Akomodasi hotel bintang 4/5 strategis sesuai program paket.',
                style: TextStyle(fontSize: 13, color: Color(0xFF555B60)),
              ),
            ),
          ],
        ),
      );
    }

    final hotelEntries = rawHotel.contains('\n')
        ? rawHotel.split('\n')
        : (rawHotel.contains(';') ? rawHotel.split(';') : (rawHotel.contains(' - ') ? rawHotel.split(' - ') : [rawHotel]));

    return Column(
      children: hotelEntries.where((h) => h.trim().isNotEmpty).map((h) {
        final text = h.trim();
        final starCount = text.toLowerCase().contains('bintang 5') ? 5 : 4;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE9E5DD)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.apartment_rounded, size: 20, color: Color(0xFFB57F26)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.category?.name ?? 'Akomodasi Program',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF72787D)),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  starCount,
                  (_) => const Icon(Icons.star, size: 14, color: Color(0xFFE8B972)),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildItineraryTimeline(TravelPackage data) {
    final itineraries = List<ItineraryDay>.from(data.itineraries)
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));

    if (itineraries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE9E5DD)),
        ),
        child: const Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFFB57F26)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Jadwal itinerary harian detail akan diinformasikan oleh tim pembimbing sebelum keberangkatan.',
                style: TextStyle(fontSize: 13, color: Color(0xFF555B60), height: 1.4),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(itineraries.length, (idx) {
        final item = itineraries[idx];
        final isLast = idx == itineraries.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge Hari
              Container(
                width: 65,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8B972),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Hari ${item.dayNumber}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Garis Timeline
              Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8B972),
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 1.5,
                        color: const Color(0xFFE5DECF),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Deskripsi
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      if (item.description != null && item.description!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.description!,
                          style: const TextStyle(
                            fontSize: 11,
                            height: 1.4,
                            color: Color(0xFF555B60),
                          ),
                        ),
                      ],
                      if (item.meals != null && item.meals!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7EB),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Makan: ${item.meals}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB57F26),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInclusionsExclusionsCard(TravelPackage data) {
    final inclusions = data.inclusions.isNotEmpty
        ? data.inclusions
        : [
            'Tiket transportasi / pesawat sesuai program',
            'Akomodasi hotel sesuai pilihan',
            'Konsumsi makan sesuai program',
            'Pemandu / Muthawwif berpengalaman',
            'Asuransi perjalanan',
          ];

    final exclusions = data.exclusions.isNotEmpty
        ? data.exclusions
        : [
            'Pengeluaran pribadi & laundry',
            'Biaya kelebihan bagasi maskapai',
            'Tips pemandu / supir lokal',
            'Dokumen pribadi (paspor / vaksin)',
          ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9E5DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yang Didapat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Termasuk',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 8),
          ...inclusions.map((inc) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      inc,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 14),
          const Text(
            'Tidak Termasuk',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 8),
          ...exclusions.map((exc) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.cancel_rounded, size: 16, color: Color(0xFFEF4444)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      exc,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRequirementsCard(TravelPackage data) {
    final docs = [
      'Paspor berlaku minimal 8 bulan (untuk luar negeri / Umrah)',
      'KTP & Kartu Keluarga',
      'Pas Foto latar putih (wajah 80%)',
      'Buku kuning vaksin meningitis (khusus Umrah)',
      'Buku nikah (untuk pasangan suami istri)',
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9E5DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Syarat & Dokumen',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 12),
          ...docs.map((doc) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.assignment_outlined, size: 16, color: Color(0xFFB57F26)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      doc,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF444444)),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (data.importantNotes != null && data.importantNotes!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7EB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFECC485)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Color(0xFFB57F26)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catatan Penting:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F1F1F),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.importantNotes!,
                          style: const TextStyle(fontSize: 11, height: 1.4, color: Color(0xFF5A492E)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFaqSection() {
    return Column(
      children: _faqs.map((faq) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE9E5DD)),
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  faq['question'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                iconColor: const Color(0xFFB57F26),
                collapsedIconColor: const Color(0xFF72787D),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                children: [
                  Text(
                    faq['answer'] as String,
                    style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF555B60)),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }
}
