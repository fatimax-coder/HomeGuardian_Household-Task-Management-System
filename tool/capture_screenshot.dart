import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final screenshotPath = args.isNotEmpty
      ? args[0]
      : r'C:\Users\Dr Sis\.gemini\antigravity\brain\dc686791-8a4a-4d5b-b000-61a926c1fd6b\live_chrome_homeguardian.png';

  // 1. Get targets from Chrome remote debugging
  final client = HttpClient();
  final request =
      await client.getUrl(Uri.parse('http://127.0.0.1:58271/json'));
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
  stdout.writeln('Connecting to DevTools WebSocket: $wsUrl');

  final ws = await WebSocket.connect(wsUrl);

  // Send Page.captureScreenshot command
  final cmdId = 1;
  final msg = jsonEncode({
    'id': cmdId,
    'method': 'Page.captureScreenshot',
    'params': {
      'format': 'png',
      'quality': 100,
      'captureBeyondViewport': true,
    },
  });

  ws.add(msg);

  await for (final rawMsg in ws) {
    final Map<String, dynamic> data = jsonDecode(rawMsg as String);
    if (data['id'] == cmdId) {
      if (data.containsKey('error')) {
        stderr.writeln('CDP error: ${data['error']}');
        exit(1);
      }
      final base64Data = data['result']['data'] as String;
      final imageBytes = base64Decode(base64Data);
      final outFile = File(screenshotPath);
      await outFile.writeAsBytes(imageBytes);
      stdout.writeln(
          'Screenshot successfully saved to: ${outFile.absolute.path} (${imageBytes.length} bytes)');
      await ws.close();
      client.close();
      return;
    }
  }
}

