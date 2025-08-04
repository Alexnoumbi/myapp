import 'package:cloud_firestore/cloud_firestore.dart';

class KpiDefinition {
  String? id; // Optional for new definitions, required for existing ones
  final String name;
  final String description;
  final String unit;
  final double? thresholdMin; // Optional minimum threshold
  final double? thresholdMax; // Optional maximum threshold

  KpiDefinition({
    this.id,
    required this.name,
    required this.description,
    required this.unit,
    this.thresholdMin,
    this.thresholdMax,
  });

  // Convert a KpiDefinition object into a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'unit': unit,
      'thresholdMin': thresholdMin,
      'thresholdMax': thresholdMax,
    };
  }

  // Create a KpiDefinition object from a Firestore DocumentSnapshot
  factory KpiDefinition.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KpiDefinition(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      unit: data['unit'] ?? '',
      thresholdMin: (data['thresholdMin'] as num?)?.toDouble(),
      thresholdMax: (data['thresholdMax'] as num?)?.toDouble(),
    );
  }
}

