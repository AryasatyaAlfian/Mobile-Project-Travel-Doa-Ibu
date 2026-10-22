import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../models/models.dart';
import '../services/travel_api.dart';
import 'booking_form_page.dart';

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

class _PackageDetailPageState extends State<PackageDetailPage> with SingleTickerProviderStateMixin {
  late Future<TravelPackage> _detailFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _detailFuture = widget.api.package(widget.package.slug).catchError((_) => widget.package);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: FutureBuilder<TravelPackage>(
        future: _detailFuture,
        initialData: widget.package,
        builder: (context, snapshot) {
          final data = snapshot.data ?? widget.package;

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 260,
                  pinned: true,
                  backgroundColor: AppColors.surfaceWhite,
                  foregroundColor: AppColors.textDark,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        data.image != null
                            ? Image.network(
                                data.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: AppColors.tealSubtle,
                                  child: const Icon(Icons.landscape, size: 64, color: AppColors.textMuted),
                                ),
                              )
                            : Container(
                                color: AppColors.tealSubtle,
                                child: const Icon(Icons.landscape, size: 64, color: AppColors.textMuted),
                              ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.transparent,
                                AppColors.textDark.withValues(alpha: 0.8),
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 20,
                          right: 20,
                          child: Row(
                            children: [
                              if (data.category != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceWhite,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.tealPrimary),
                                  ),
                                  child: Text(
                                    data.category!.name,
                                    style: const TextStyle(
                                      color: AppColors.tealPrimary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              if (data.duration != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.schedule, size: 12, color: AppColors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        data.duration!,
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (_) => const Icon(Icons.star_rounded, size: 16, color: AppColors.tealPrimary),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '5.0 (Rating Jamaah)',
                              style: TextStyle(color: AppColors.tealDark, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildQuickInfoGrid(data),
                        const SizedBox(height: 20),
                        TabBar(
                          controller: _tabController,
                          indicatorColor: AppColors.tealPrimary,
                          indicatorWeight: 3,
                          labelColor: AppColors.tealPrimary,
                          unselectedLabelColor: AppColors.textBody,
                          dividerColor: AppColors.border,
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          tabs: const [
                            Tab(text: 'Ikhtisar & Fasilitas'),
                            Tab(text: 'Rencana Itinerary'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(data),
                _buildItineraryTab(data),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomBookingBar(widget.package),
    );
  }

  Widget _buildQuickInfoGrid(TravelPackage data) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.calendar_today_outlined,
            title: 'Keberangkatan',
            subtitle: data.departureDate != null
                ? '${data.departureDate!.day}/${data.departureDate!.month}/${data.departureDate!.year}'
                : 'Jadwal Fleksibel',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.airline_seat_recline_normal,
            title: 'Sisa Kuota',
            subtitle: data.quota != null ? '${data.quota} Kursi' : 'Tersedia',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.tealSubtle,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.tealPrimary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(TravelPackage data) {
    final description = (data.description != null && data.description!.isNotEmpty)
        ? data.description!
        : (data.excerpt ?? 'Paket perjalanan terbaik bersama Doa Ibu Travel dengan bimbingan terpercaya dan fasilitas hotel berbintang.');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deskripsi Perjalanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textBody,
            ),
          ),
          const SizedBox(height: 24),

          // Inclusions (Fasilitas Termasuk)
          const Text(
            'Fasilitas Termasuk (Inclusions)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          if (data.inclusions.isNotEmpty)
            ...data.inclusions.map((item) => _buildBulletItem(item, isPositive: true))
          else
            _buildDefaultInclusions(),

          const SizedBox(height: 24),

          // Exclusions (Tidak Termasuk)
          const Text(
            'Fasilitas Belum Termasuk (Exclusions)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          if (data.exclusions.isNotEmpty)
            ...data.exclusions.map((item) => _buildBulletItem(item, isPositive: false))
          else
            _buildDefaultExclusions(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDefaultInclusions() {
    const defaultItems = [
      'Tiket pesawat PP kelas ekonomi',
      'Akomodasi hotel berbintang dekat masjid/destinasi',
      'Makan 3 kali sehari menu halal & nusantara',
      'Bimbingan muthawif & tour leader berpengalaman',
      'Transportasi bus AC eksekutif selama trip',
      'Asuransi perjalanan dan perlengkapan ibadah',
    ];
    return Column(
      children: defaultItems.map((item) => _buildBulletItem(item, isPositive: true)).toList(),
    );
  }

  Widget _buildDefaultExclusions() {
    const defaultItems = [
      'Pembuatan atau perpanjangan paspor',
      'Pengeluaran pribadi (laundry, telepon, kelebihan bagasi)',
      'Vaksin meningitis atau tes kesehatan opsional',
    ];
    return Column(
      children: defaultItems.map((item) => _buildBulletItem(item, isPositive: false)).toList(),
    );
  }

  Widget _buildBulletItem(String text, {required bool isPositive}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isPositive ? Icons.check_circle_rounded : Icons.cancel_outlined,
            size: 18,
            color: isPositive ? AppColors.tealPrimary : AppColors.redNegative,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryTab(TravelPackage data) {
    if (data.itineraries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.map_outlined, size: 48, color: AppColors.tealPrimary),
              SizedBox(height: 12),
              Text(
                'Jadwal Itinerary Detail Segera Hadir',
                style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Rencana perjalanan harian akan disampaikan lengkap saat konfirmasi pemesanan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textBody, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: data.itineraries.length,
      itemBuilder: (context, index) {
        final day = data.itineraries[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    gradient: AppColors.tealButtonGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${day.dayNumber}',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (index < data.itineraries.length - 1)
                  Container(
                    width: 2,
                    height: 80,
                    color: AppColors.tealLight.withValues(alpha: 0.5),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (day.description != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        day.description!,
                        style: const TextStyle(fontSize: 13, color: AppColors.textBody, height: 1.4),
                      ),
                    ],
                    if (day.meals != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.restaurant, size: 14, color: AppColors.tealPrimary),
                          const SizedBox(width: 6),
                          Text(
                            day.meals!,
                            style: const TextStyle(fontSize: 12, color: AppColors.tealDark, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomBookingBar(TravelPackage package) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Harga Mulai Dari',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                Text(
                  package.formattedPrice,
                  style: const TextStyle(
                    color: AppColors.tealPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingFormPage(
                      package: package,
                      api: widget.api,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                decoration: BoxDecoration(
                  gradient: AppColors.tealButtonGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.tealPrimary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long, color: AppColors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Pesan Sekarang',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
