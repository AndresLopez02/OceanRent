import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocean_rent/pages/login/login_page.dart';
import 'package:ocean_rent/pages/admin/boats/boat_list_page.dart';
import 'package:ocean_rent/pages/home/home_page.dart';
import 'package:ocean_rent/services/auth_service.dart';
import 'package:ocean_rent/services/user_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        // 🔄 loading auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ no logueado → login
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final user = snapshot.data!;

        // 🔐 comprobar rol
        return FutureBuilder<bool>(
          future: UserService.instance.isAdmin(user.uid),
          builder: (context, roleSnapshot) {
            if (!roleSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final isAdmin = roleSnapshot.data!;

            if (isAdmin) {
              return const BoatListPage(); // ADMIN
            } else {
              return const HomePage(); // USER NORMAL
            }
          },
        );
      },
    );
  }
}
