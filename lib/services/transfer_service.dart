import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class TransferProgress {
  final int bytesTransferred;
  final int totalBytes;
  final double speedBytesPerSec;
  
  TransferProgress(
    this.bytesTransferred, 
    this.totalBytes, 
    this.speedBytesPerSec
  );

  double get percent => totalBytes == 0 ? 0 : bytesTransferred / totalBytes;
  
  Duration get eta {
    if (speedBytesPerSec <= 0) return Duration.zero;
    final remaining = totalBytes - bytesTransferred;
    return Duration(seconds: (remaining / speedBytesPerSec).round());
  }
}

class TransferService {
  ServerSocket? _server;

  Future<void> startServer({
    required int port,
    required String saveDirectory,
    required void Function(String filePath) onFileReceived,
    required void Function(TransferProgress progress) onProgress,
  
  }) async {
    
    _server = await ServerSocket.bind(
      InternetAddress.anyIPv4, 
      port
    );

    _server!.listen((Socket client) {
      _handleIncoming(
        client, 
        saveDirectory, 
        onFileReceived, 
        onProgress
      );
    });
  }

  void _handleIncoming(
    Socket client,
    String saveDirectory,
    void Function(String) onFileReceived,
    void Function(TransferProgress) onProgress,
  ) 
  {
    final buffer = BytesBuilder();
    bool headerParsed = false;
    late String fileName;
    late int fileSize;
    int bytesWritten = 0;
    IOSink? fileSink;
    final startTime = DateTime.now();

    client.listen(
      
      //list that include bytes that were received
      (List<int> data) {
        if (!headerParsed) {
          buffer.add(data);
          final bytes = buffer.toBytes();
          final newlineIndex = bytes.indexOf(10); // \n
          if (newlineIndex == -1) return; // header not complete yet

          final headerStr = utf8.decode(
            bytes.sublist(0, newlineIndex)
          );
          
          final header = jsonDecode(headerStr);
          fileName = header['name'];
          fileSize = header['size'];
          headerParsed = true;

          final filePath = '$saveDirectory/$fileName';
          fileSink = File(filePath).openWrite();

          // Any bytes after the newline are already file data — write them now
          final remaining = bytes.sublist(newlineIndex + 1);
          if (remaining.isNotEmpty) {
            fileSink!.add(remaining);
            bytesWritten += remaining.length;
          }
          buffer.clear();
        } else {
          fileSink!.add(data);
          bytesWritten += data.length;

          final elapsed = DateTime.now().difference(startTime).inMilliseconds / 1000;
          final speed = elapsed > 0 ? bytesWritten / elapsed : 0.0;
          onProgress(TransferProgress(bytesWritten, fileSize, speed));
        }
      },
      onDone: () async {
        await fileSink?.close();
        if (headerParsed) {
          onFileReceived('$saveDirectory/$fileName');
        }
        client.close();
      },
      onError: (_) {
        fileSink?.close();
        client.close();
      },
    );
  }

  void stopServer() {
    _server?.close();
  }
}