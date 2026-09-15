class Peer{
  final String name;
  final String ip;
  final int port;
  final DateTime lastSeen;

  Peer({
    required this.name,
    required this.ip,
    required this.port,
    required this.lastSeen,
  });

  factory Peer.fromJson(Map<String, dynamic> json, String ip) {
    return Peer(
      name: json['name'] as String,
      ip: ip,
      port: json['port'] as int,
      lastSeen: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return{
      'name': name,
      'port':port,
    };
  }
}
