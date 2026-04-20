import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';
import 'package:ocean_rent/pages/login/login_page.dart';
import 'package:ocean_rent/providers/auth_providers.dart';
import 'package:ocean_rent/widgets/dialog_confirmacion.dart';

class CustomerHomePage extends ConsumerWidget {
  const CustomerHomePage({super.key});

    //Esta página se ha creado para los ususarios regulares que tengan solo el rol de cliente en la base de datos

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OceanRent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => mostrarDialogoConfirmacion(
              context, 
              titulo: 'Cerrar Sesión', 
              mensaje: '¿Quieres cerrar sesión?', 
              onAceptar: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage())
                );
              }
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_boat_outlined,
                size: 64, color: AppTheme.oceanBlue),
            const SizedBox(height: 16),
            Text('Hola, ${user?.name ?? 'Navegante'}',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('Eres un cliente'),
          ],
        ),
      ),
    );
  }
}