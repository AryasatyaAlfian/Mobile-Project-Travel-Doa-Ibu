import 'package:flutter/material.dart';

import 'core/api_config.dart';
import 'core/app_colors.dart';
import 'core/app_theme.dart';
import 'models/models.dart';
import 'services/travel_api.dart';
import 'ui/contact_page.dart';
import 'ui/landing_page.dart';
import 'ui/package_detail_page.dart';
import 'ui/welcome_landing_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.api});

  final TravelApi? api;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final TravelApi _api;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? TravelApi();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Doa Ibu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: RootNavigation(api: _api),
    );
  }
}

class RootNavigation extends StatefulWidget {
  const RootNavigation({super.key, required this.api});

  final TravelApi api;

  @override
  State<RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<RootNavigation> {
  bool _hasEnteredApp = false;

  @override
  Widget build(BuildContext context) {
    if (!_hasEnteredApp) {
      return WelcomeLandingPage(
        api: widget.api,
        onContinueAsGuest: () => setState(() => _hasEnteredApp = true),
      );
    }
    return MainScreen(
      api: widget.api,
      onBackToWelcome: () => setState(() => _hasEnteredApp = false),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.api, this.onBackToWelcome});

  final TravelApi api;
  final VoidCallback? onBackToWelcome;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget currentBody;
    if (_currentIndex == 0) {
      currentBody = LandingPage(
        api: widget.api,
        onExplorePackages: () => setState(() => _currentIndex = 1),
        onConsultation: () => setState(() => _currentIndex = 2),
      );
    } else if (_currentIndex == 1) {
      currentBody = PackageListPage(api: widget.api);
    } else {
      currentBody = ContactPage(api: widget.api);
    }

    return Scaffold(
      extendBody: true,
      body: currentBody,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 60,
          margin: const EdgeInsets.fromLTRB(48, 0, 48, 16),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF9DBED8).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(9999),
            boxShadow: [
              BoxShadow(
                color: AppColors.elysianSecondary.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavIcon(0, Icons.home_outlined, Icons.home_rounded),
              _buildNavIcon(1, Icons.confirmation_number_outlined, Icons.confirmation_number_rounded),
              _buildNavIcon(2, Icons.map_outlined, Icons.map_rounded),
              _buildNavIcon(3, Icons.person_outline_rounded, Icons.person_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(int index, IconData inactiveIcon, IconData activeIcon) {
    final isSelected = (_currentIndex == index) || (_currentIndex > 2 && index == 3);
    return InkWell(
      onTap: () {
        if (index == 2) {
          setState(() => _currentIndex = 1); // maps to packages
        } else if (index == 3) {
          setState(() => _currentIndex = 2); // maps to contact/profile
        } else {
          setState(() => _currentIndex = index);
        }
      },
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          isSelected ? activeIcon : inactiveIcon,
          size: 26,
          color: isSelected ? AppColors.elysianSecondary : AppColors.elysianSecondary.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

/// Daftar paket dari `GET /api/v1/packages` — data yang sama dengan web.
/// Dilengkapi fitur pencarian dan filter kategori dengan desain Teal Modern.
class PackageListPage extends StatefulWidget {
  const PackageListPage({super.key, required this.api});

  final TravelApi api;

  @override
  State<PackageListPage> createState() => _PackageListPageState();
}

class _PackageListPageState extends State<PackageListPage> {
  final _searchController = TextEditingController();
  late Future<Paginated<TravelPackage>> _future;
  String? _selectedCategory;

  final List<String> _categories = const [
    'Semua',
    'Umrah',
    'Wisata Halal',
    'Domestik',
    'Internasional',
  ];

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  void _fetchPackages() {
    final query = _searchController.text.trim();
    _future = widget.api.packages(
      search: query.isEmpty ? null : query,
      category: (_selectedCategory == null || _selectedCategory == 'Semua')
          ? null
          : _selectedCategory!.toLowerCase(),
    );
  }

  Future<void> _refresh() async {
    setState(() => _fetchPackages());
    await _future.catchError((_) => Paginated<TravelPackage>(items: [], currentPage: 1, lastPage: 1, total: 0));
  }

  void _onSearch(String value) {
    setState(() => _fetchPackages());
  }

  void _onCategorySelected(String cat) {
    setState(() {
      _selectedCategory = cat;
      _fetchPackages();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        title: const Text(
          'Katalog Paket Wisata',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark),
        ),
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textDark),
            onPressed: _refresh,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchController,
              onSubmitted: _onSearch,
              style: const TextStyle(color: AppColors.textDark, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari destinasi atau paket wisata...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppColors.tealPrimary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _fetchPackages());
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.tealPrimary, width: 1.5),
                ),
              ),
            ),
          ),

          // Horizontal Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = (_selectedCategory == null && cat == 'Semua') || (_selectedCategory == cat);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => _onCategorySelected(cat),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.tealPrimary : AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.tealDark : AppColors.border,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: AppColors.tealPrimary.withValues(alpha: 0.18),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.textBody,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Package List Body
          Expanded(
            child: RefreshIndicator(
              color: AppColors.tealPrimary,
              backgroundColor: AppColors.surfaceWhite,
              onRefresh: _refresh,
              child: FutureBuilder<Paginated<TravelPackage>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.tealPrimary));
                  }
                  if (snapshot.hasError) {
                    return ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        const Icon(Icons.cloud_off, size: 48, color: AppColors.tealPrimary),
                        const SizedBox(height: 12),
                        Text('${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textDark)),
                        const SizedBox(height: 8),
                        Text('API: ${ApiConfig.baseUrl}', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    );
                  }
                  final packages = snapshot.data!.items;
                  if (packages.isEmpty) {
                    return ListView(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text('Belum ada paket wisata yang cocok.', style: TextStyle(color: AppColors.textBody)),
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: packages.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final p = packages[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PackageDetailPage(package: p, api: widget.api),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: p.image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      p.image!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        width: 60,
                                        height: 60,
                                        color: AppColors.tealSubtle,
                                        child: const Icon(Icons.image_not_supported, color: AppColors.textMuted),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.tealSubtle,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.landscape, color: AppColors.textMuted),
                                  ),
                            title: Text(
                              p.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                [p.category?.name, p.duration].whereType<String>().join(' • '),
                                style: const TextStyle(color: AppColors.tealDark, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                            trailing: Text(
                              p.formattedPrice,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.tealPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
