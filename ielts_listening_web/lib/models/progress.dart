// class Progress {
//   final String id;
//   final double score;
//   final DateTime timestamp;
//
//   Progress({
//     required this.id,
//     required this.score,
//     required this.timestamp,
//   });
//
//   factory Progress.fromFirestore(Map<String, dynamic>? data, String id) {
//     return Progress(
//       id: id,
//       score: (data?['score'] as num?)?.toDouble() ?? 0.0,
//       timestamp: (data?['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
//     );
//   }
//
//   Map<String, dynamic> toFirestore() {
//     return {
//       'score': score,
//       'timestamp': FieldValue.serverTimestamp(),
//     };
//   }
// }