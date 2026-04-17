import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ocean_rent/pages/register/register_page.dart';
import 'package:ocean_rent/providers/auth_providers.dart';
import 'package:ocean_rent/widgets/build_label_text_fields.dart';
import 'package:ocean_rent/widgets/custom_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    ref.read(authNotifierProvider).clearError();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rellena correo y contraseña.')),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un correo válido.')),
      );
      return;
    }

    final success = await ref
        .read(authNotifierProvider)
        .signInWithEmailAndPassword(email: email, password: password);

    if (!mounted) return;

    if (!success) {
      final error = ref.read(authNotifierProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'No se pudo iniciar sesión.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Text(
                'OceanRent',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Inicia sesión para continuar',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),
              buildLabelTextFields(context, 'correo electrónico'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                obscureText: false,
                hintText: 'ejemplo@correo.com',
              ),
              const SizedBox(height: 24),
              buildLabelTextFields(context, 'contraseña'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _passwordController,
                obscureText: true,
                hintText: 'tu contraseña',
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _login,
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Iniciar sesión'),
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          FocusScope.of(context).unfocus();
                          ref.read(authNotifierProvider).clearError();

                          final scaffoldMessenger = ScaffoldMessenger.of(
                            context,
                          );

                          final success = await ref
                              .read(authNotifierProvider)
                              .signInWithGoogle();

                          if (!mounted) return;

                          if (!success) {
                            final error = ref
                                .read(authNotifierProvider)
                                .errorMessage;
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  error ??
                                      'No se pudo iniciar sesión con Google.',
                                ),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.login),
                  label: const Text('Continuar con Google'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: authState.isLoading
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
              if (authState.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  authState.errorMessage!,
                  textAlign: TextAlign.center,
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
