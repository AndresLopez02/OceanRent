import 'package:flutter/material.dart';
import 'package:ocean_rent/widgets/build_label_text_fields.dart';
import 'package:ocean_rent/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(height: 40),
            buildLabelTextFields(context, 'correo electronico'),
            CustomTextField(),
            SizedBox(height: 40),
            buildLabelTextFields(context, 'contraseña'),
            CustomTextField(),
          ],//Prueba para ver que todo esta correcto y probar, borrar cuando se haga la pantalla de Login
        ),
      ),
    );
  }
}