import 'package:cloud_firestore/cloud_firestore.dart';

class Boat {
  final String id;
  final String name;
  final String type;
  final int capacity;
  final double pricePerDay;
  final String description;
  final String imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Boat({
    required this.id,
    required this.name,
    required this.type,
    required this.capacity,
    required this.pricePerDay,
    required this.description,
    required this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Boat.fromMap(Map<String, dynamic> map, String documentId) {
    final Timestamp? createdAtTimestamp = map['createdAt'] as Timestamp?;
    final Timestamp? updatedAtTimestamp = map['updatedAt'] as Timestamp?;

    return Boat(
      id: documentId,
      name: (map['name'] ?? '') as String,
      type: (map['type'] ?? '') as String,
      capacity: (map['capacity'] ?? 0) as int,
      pricePerDay: (map['pricePerDay'] ?? 0).toDouble(),
      description: (map['description'] ?? '') as String,
      imageUrl: (map['imageUrl'] ?? '') as String,
      createdAt: createdAtTimestamp?.toDate(),
      updatedAt: updatedAtTimestamp?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'capacity': capacity,
      'pricePerDay': pricePerDay,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Boat copyWith({
    String? id,
    String? name,
    String? type,
    int? capacity,
    double? pricePerDay,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Boat(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      capacity: capacity ?? this.capacity,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
