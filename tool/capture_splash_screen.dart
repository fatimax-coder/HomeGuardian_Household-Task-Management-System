import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final outPath =
      r'C:\Users\Dr Sis\.gemini\antigravity\brain\dc686791-8a4a-4d5b-b000-61a926c1fd6b\screenshots\00_splash.png';

  int debugPort = 58271;
  String splashUrl = 'http://localhost:8080/#/splash';

  stdout.writeln('Connecting to Chrome on port $debugPort...');

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

  var cmdId = 200;
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

  stdout.writeln('Navigating to $splashUrl...');
  await sendCdp('Page.navigate', {'url': splashUrl});

  // Wait 1.5 seconds so image and timer render cleanly
  await Future.delayed(const Duration(milliseconds: 1500));

  final res = await sendCdp('Page.captureScreenshot', {
    'format': 'png',
    'quality': 100,
    'captureBeyondViewport': true,
  });

  final base64Data = res['data'] as String;
  final bytes = base64Decode(base64Data);
  final outFile = File(outPath);
  await outFile.writeAsBytes(bytes);
  stdout.writeln('Captured Splash Screen: ${outFile.path} (${bytes.length} bytes)');

  await ws.close();
  client.close();
  stdout.writeln('Done!');
}

