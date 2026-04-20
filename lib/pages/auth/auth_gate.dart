import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ocean_rent/pages/admin/boat_list_page.dart';
import 'package:ocean_rent/pages/home/home_page.dart';
import 'package:ocean_rent/pages/login/login_page.dart';
import 'package:ocean_rent/services/auth_service.dart';
import 'package:ocean_rent/services/user_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const LoginPage();
        }

        final user = snapshot.data!;

        return FutureBuilder<bool>(
          future: UserService.instance.isAdmin(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (roleSnapshot.hasError) {
              return const Scaffold(
                body: Center(
                  child: Text('Error comprobando el rol del usuario'),
                ),
              );
            }

            final isAdmin = roleSnapshot.data ?? false;

            if (isAdmin) {
              return const BoatListPage();
            } else {
              return const HomePage();
            }
          },
        );
      },
    );
  }
}
