import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ocean_rent/providers/auth_providers.dart';
import 'package:ocean_rent/widgets/build_label_text_fields.dart';
import 'package:ocean_rent/widgets/custom_text_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    ref.read(authNotifierProvider).clearError();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rellena todos los campos.')),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un correo válido.')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres.'),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden.')),
      );
      return;
    }

    final success = await ref
        .read(authNotifierProvider)
        .registerWithEmailAndPassword(email: email, password: password);

    if (!mounted) return;

    if (!success) {
      final error = ref.read(authNotifierProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'No se pudo completar el registro.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              buildLabelTextFields(context, 'correo electrónico'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                hintText: 'ejemplo@correo.com',
                obscureText: false,
              ),
              const SizedBox(height: 24),
              buildLabelTextFields(context, 'contraseña'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _passwordController,
                obscureText: true,
                hintText: 'mínimo 6 caracteres',
              ),
              const SizedBox(height: 24),
              buildLabelTextFields(context, 'confirmar contraseña'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _confirmPasswordController,
                obscureText: true,
                hintText: 'repite la contraseña',
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _register,
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Registrarme'),
                ),
              ),
              if (authState.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  authState.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
