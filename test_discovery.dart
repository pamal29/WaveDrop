import 'dart:async';
import 'lib/services/discovery_service.dart';

void main() async {
  final alice = DiscoveryService(myName: 'Alice-Device', myTcpPort: 45679);
  final bob = DiscoveryService(myName: 'Bob-Device', myTcpPort: 45680);

  alice.peersStream.listen((peers) {
    print('Alice sees: ${peers.map((p) => p.name).toList()}');
  });
  bob.peersStream.listen((peers) {
    print('Bob sees: ${peers.map((p) => p.name).toList()}');
  });

  await alice.start();
  await bob.start();

  print('Waiting for discovery...');
  await Future.delayed(const Duration(seconds: 6));

  alice.stop();
  bob.stop();
}