final String tableLogs = 'logs';

class LogsFields {
  static final List<String> values = [
    id, log
  ];

  static final String id = '_id';
  static final String log = 'log';
}

class LogsToSend {
  final int? id;
  final String log;

  const LogsToSend({
    this.id,
    required this.log,
  });

  LogsToSend copy({
    int? id,
    String? log,
  }) => LogsToSend(
    id: id ?? this.id,
    log: log ?? this.log,
  );



}