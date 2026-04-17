import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ocean_rent/providers/auth_providers.dart';


//ESTA TENDRA QUE HACERLA EL QUE LE TOQUE LA TAREA
///ESTA PANTALLA ES SOLO DE PRUEBA, SE MOSTRARA
/// CUANDO EL USUARIO INICIE SESION CORRECTAMENTE,
/// AUN NO TIENE FUNCIONALIDAD REAL, SOLO MUESTRA
/// EL CORREO DEL USUARIO Y UN BOTON PARA CERRAR
/// SESION



class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OceanRent'),
        actions: [
          IconButton(
            onPressed: authState.isLoading
                ? null
                : () async {
                    await ref.read(authNotifierProvider).signOut();
                  },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sesión iniciada correctamente',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                user?.email ?? 'Usuario sin email',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (authState.isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
