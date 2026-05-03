import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';
import 'package:ocean_rent/models/boat_model.dart';
import 'package:ocean_rent/pages/home/pages/customer/pages/customer_profile_screen.dart';
import 'package:ocean_rent/pages/home/pages/customer/widgets/customer_boat_card.dart';
import 'package:ocean_rent/pages/login/login_page.dart';
import 'package:ocean_rent/pages/onboarding/onboarding_page.dart';
import 'package:ocean_rent/providers/auth_providers.dart';
import 'package:ocean_rent/widgets/dialog_confirmacion.dart';
import 'package:ocean_rent/widgets/app_navigator.dart';

class CustomerHomePage extends ConsumerWidget {
  const CustomerHomePage({super.key,});

  // Esta página se ha creado para los usuarios regulares que tengan solo el rol de cliente u anónimos

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authNotifierProvider).signOut();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingPage()),
      (_) => false,
    );
  }

  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(authNotifierProvider).currentUser;
  final isAnonymous = user == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OceanRent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () {
              if (isAnonymous) {
                AppNavigator.goToLogin(context);
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CustomerProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(isAnonymous ? Icons.login : Icons.logout),
            onPressed: () {
              if (isAnonymous) {
                AppNavigator.goToLogin(context);
                return;
              }

              mostrarDialogoConfirmacion(
                context,
                titulo: 'Cerrar Sesión',
                mensaje: '¿Quieres cerrar sesión?',
                onAceptar: () {
                  _logout(context, ref);
                },
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<BoatModel>('boats').listenable(),
        builder: (context, box, _) {
          final boats = box.values.toList();

          if (boats.isEmpty) {
            return Center(
              child: Text(
                'No hay barcos disponibles',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppTheme.deepNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: boats.length,
            itemBuilder: (context, index) {
              final boat = boats[index];
              return CustomerBoatCard(boat: boat);
            },
          );
        },
      ),
    );
  }
}
