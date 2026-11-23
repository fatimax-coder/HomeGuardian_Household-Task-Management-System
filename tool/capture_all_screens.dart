import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final outDir = Directory(
      r'C:\Users\Dr Sis\.gemini\antigravity\brain\dc686791-8a4a-4d5b-b000-61a926c1fd6b\screenshots');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  // Fixed deterministic ports for Flutter Chrome web run
  int debugPort = 58271;
  String baseUrl = 'http://localhost:8080';

  if (args.length >= 2) {
    debugPort = int.parse(args[0]);
    baseUrl = args[1];
  }

  stdout.writeln('Target Chrome debugPort: $debugPort, baseUrl: $baseUrl');

  final client = HttpClient();
  final request =
      await client.getUrl(Uri.parse('http://127.0.0.1:$debugPort/json'));
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  final List<dynamic> targets = jsonDecode(responseBody);

  final pageTarget = targets.firstWhere(
    (t) => t['title'] == 'HomeGuardian' || t['type'] == 'page',
    orElse: () => null,
  );

  if (pageTarget == null) {
    stderr.writeln('No active HomeGuardian page target found.');
    exit(1);
  }

  final wsUrl = pageTarget['webSocketDebuggerUrl'] as String;
  stdout.writeln('Connecting to WebSocket: $wsUrl');
  final ws = await WebSocket.connect(wsUrl);

  var cmdId = 100;
  final completers = <int, Completer<dynamic>>{};

  ws.listen((rawMsg) {
    final Map<String, dynamic> data = jsonDecode(rawMsg as String);
    final id = data['id'] as int?;
    if (id != null && completers.containsKey(id)) {
      if (data.containsKey('error')) {
        completers[id]!.completeError(Exception('CDP Error: ${data['error']}'));
      } else {
        completers[id]!.complete(data['result']);
      }
    }
  });

  Future<dynamic> sendCdp(String method, [Map<String, dynamic>? params]) {
    final id = ++cmdId;
    final completer = Completer<dynamic>();
    completers[id] = completer;

    final payload = jsonEncode({
      'id': id,
      'method': method,
      ...?params != null ? {'params': params} : null,
    });
    ws.add(payload);
    return completer.future;
  }

  final routes = {
    '01_login': '$baseUrl/#/login',
    '02_dashboard': '$baseUrl/#/dashboard',
    '03_tasks': '$baseUrl/#/tasks',
    '04_appliances': '$baseUrl/#/appliances',
    '05_reminders': '$baseUrl/#/reminders',
    '06_household': '$baseUrl/#/household',
    '07_members': '$baseUrl/#/members',
    '08_appliance_form': '$baseUrl/#/appliance-form',
  };

  for (final entry in routes.entries) {
    final name = entry.key;
    final url = entry.value;

    stdout.writeln('Navigating to $name ($url)...');
    await sendCdp('Page.navigate', {'url': url});

    // Wait 2.2 seconds for Flutter to render the view and unpack image assets
    await Future.delayed(const Duration(milliseconds: 2200));

    final res = await sendCdp('Page.captureScreenshot', {
      'format': 'png',
      'quality': 100,
      'captureBeyondViewport': true,
    });

    final base64Data = res['data'] as String;
    final bytes = base64Decode(base64Data);
    final outFile = File('${outDir.path}/$name.png');
    await outFile.writeAsBytes(bytes);
    stdout.writeln('Captured $name.png (${bytes.length} bytes)');
  }

  await ws.close();
  client.close();
  stdout.writeln('All screen captures completed successfully!');
}
