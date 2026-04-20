import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ocean_rent/services/auth_service.dart';

class BoatListPage extends StatelessWidget {
  const BoatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final boatsRef = FirebaseFirestore.instance.collection('boats');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Admin - Barcos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: boatsRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay barcos'));
          }

          final boats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: boats.length,
            itemBuilder: (context, index) {
              final boat = boats[index];
              final data = boat.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['name'] ?? 'Sin nombre'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tipo: ${data['type'] ?? ''}'),
                      Text('Capacidad: ${data['capacity'] ?? ''}'),
                      Text('Precio: ${data['price'] ?? ''} €/día'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await boatsRef.doc(boat.id).delete();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
