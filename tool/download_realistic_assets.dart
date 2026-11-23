import 'dart:io';

Future<void> main() async {
  final Map<String, String> assetsToDownload = {
    // Banner: modern, elegant living room interior
    'assets/images/banner/home_interior.jpg':
        'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?auto=format&fit=crop&w=1200&q=80',

    // Household: natural-looking family photograph
    'assets/images/household/family.jpg':
        'https://images.unsplash.com/photo-1511895426328-dc8714191300?auto=format&fit=crop&w=800&q=80',

    // Appliances: realistic products
    'assets/images/appliances/refrigerator.jpg':
        'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=600&q=80',
    'assets/images/appliances/washing_machine.jpg':
        'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=600&q=80',
    'assets/images/appliances/air_conditioner.jpg':
        'https://images.unsplash.com/photo-1614633833026-0820552978b6?auto=format&fit=crop&w=600&q=80',
    'assets/images/appliances/microwave.jpg':
        'https://images.unsplash.com/photo-1585659722983-3a675dabf23d?auto=format&fit=crop&w=600&q=80',
    'assets/images/appliances/television.jpg':
        'https://images.unsplash.com/photo-1593784991095-a205069470b6?auto=format&fit=crop&w=600&q=80',
    'assets/images/appliances/default_appliance.jpg':
        'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?auto=format&fit=crop&w=600&q=80',

    // Maintenance: professional technician repairing appliance
    'assets/images/maintenance/technician.jpg':
        'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=800&q=80',

    // Tasks: realistic cleaning / chore management
    'assets/images/tasks/cleaning.jpg':
        'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=800&q=80',

    // Reminders: organized documents, bills, calendars
    'assets/images/reminders/documents_bills.jpg':
        'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=800&q=80',
  };

  stdout.writeln('=== DOWNLOADING REALISTIC PHOTOGRAPHY ASSETS ===');
  final client = HttpClient();

  for (final entry in assetsToDownload.entries) {
    final path = entry.key;
    final url = entry.value;

    final file = File(path);
    final dir = file.parent;
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    stdout.writeln('Fetching $path...');
    final req = await client.getUrl(Uri.parse(url));
    final resp = await req.close();

    if (resp.statusCode != 200) {
      stderr.writeln('Failed to download $url (Status ${resp.statusCode})');
      exit(1);
    }

    final bytes = await resp.fold<List<int>>([], (p, e) => p..addAll(e));
    await file.writeAsBytes(bytes);
    stdout.writeln('Saved: $path (${bytes.length} bytes)');
  }

  client.close();
  stdout.writeln('All 11 realistic photographic assets downloaded successfully!');
}

