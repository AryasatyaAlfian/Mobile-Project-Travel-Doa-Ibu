import 'package:flutter/material.dart';

import 'core/api_config.dart';
import 'models/models.dart';
import 'services/travel_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.api});

  final TravelApi? api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Doa Ibu',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E))),
      home: PackageListPage(api: api ?? TravelApi()),
    );
  }
}

/// Daftar paket dari `GET /api/v1/packages` — data yang sama dengan web.
/// Tarik ke bawah untuk memuat ulang setelah mengubah data di admin web.
class PackageListPage extends StatefulWidget {
  const PackageListPage({super.key, required this.api});

  final TravelApi api;

  @override
  State<PackageListPage> createState() => _PackageListPageState();
}

class _PackageListPageState extends State<PackageListPage> {
  late Future<Paginated<TravelPackage>> _future = widget.api.packages();

  Future<void> _refresh() async {
    final future = widget.api.packages();
    setState(() => _future = future);
    await future.catchError((_) => Paginated<TravelPackage>(items: [], currentPage: 1, lastPage: 1, total: 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paket Wisata')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<Paginated<TravelPackage>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Icon(Icons.cloud_off, size: 48),
                  const SizedBox(height: 12),
                  Text('${snapshot.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('API: ${ApiConfig.baseUrl}', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                ],
              );
            }
            final packages = snapshot.data!.items;
            if (packages.isEmpty) {
              return ListView(children: const [Padding(padding: EdgeInsets.all(24), child: Text('Belum ada paket.'))]);
            }
            return ListView.separated(
              itemCount: packages.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = packages[index];
                return ListTile(
                  leading: p.image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(p.image!, width: 56, height: 56, fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported)),
                        )
                      : const Icon(Icons.landscape),
                  title: Text(p.name),
                  subtitle: Text([p.category?.name, p.duration].whereType<String>().join(' • ')),
                  trailing: Text(p.formattedPrice),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
