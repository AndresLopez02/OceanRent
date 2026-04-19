import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';
import 'package:ocean_rent/models/user_model.dart';
import 'package:ocean_rent/pages/home/pages/admin_home_page.dart';
import 'package:ocean_rent/pages/home/pages/customer_home_page.dart';
import 'package:ocean_rent/pages/login/pages/register_page.dart';
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

  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Navegación según rol ─────────────────────────────────────────────────
  void _navigateByRole() {
    final user = ref.read(authNotifierProvider).currentUser;
    if (user == null) return;

    final destination = switch (user.role) {
      UserRole.admin    => const AdminHomePage(),
      UserRole.customer => const CustomerHomePage(),
    };

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destination),
      (_) => false,
    );
  }

  // ── Login con email ──────────────────────────────────────────────────────
  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    ref.read(authNotifierProvider).clearError();

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Rellena correo y contraseña.')),
      );
      return;
    }

    if (!email.contains('@')) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Introduce un correo válido.')),
      );
      return;
    }

    final success = await ref
        .read(authNotifierProvider)
        .signInWithEmailAndPassword(email: email, password: password);

    if (!mounted) return;

    if (success) {
      _navigateByRole(); // ← LA LÍNEA QUE FALTABA
    } else {
      final error = ref.read(authNotifierProvider).errorMessage;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(error ?? 'No se pudo iniciar sesión.')),
      );
    }
  }

  // ── Login con Google ─────────────────────────────────────────────────────
  Future<void> _loginWithGoogle() async {
    FocusScope.of(context).unfocus();
    ref.read(authNotifierProvider).clearError();

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final success = await ref.read(authNotifierProvider).signInWithGoogle();

    if (!mounted) return;

    if (success) {
      _navigateByRole(); // ← igual aquí
    } else {
      final error = ref.read(authNotifierProvider).errorMessage;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(error ?? 'No se pudo iniciar sesión con Google.'),
        ),
      );
    }
  }

  Widget _buildGoogleLogo() {
    return Image.asset(
      'assets/icons/google_logo.png',
      width: 20,
      height: 20,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.pearlWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.deepNavy,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Icon(
                            Icons.directions_boat_outlined,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'OceanRent',
                                style: textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Alquiler de barcos y reservas',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    decoration: BoxDecoration(
                      color: AppTheme.pearlWhite,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Iniciar sesión',
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 28),

                        buildLabelTextFields(context, 'Correo Electrónico'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          hintText: '',
                          obscureText: false,
                        ),

                        const SizedBox(height: 22),

                        buildLabelTextFields(context, 'Contraseña'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          hintText: '',
                          onSubmitted: (_) => _login(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() => _showPassword = !_showPassword);
                            },
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppTheme.deepNavy,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: authState.isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.oceanBlue,
                              foregroundColor: Colors.white,
                            ),
                            child: authState.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Entrar',
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'La recuperación de contraseña aún no está implementada.',
                                  ),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              '¿Has olvidado tu contraseña?',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppTheme.oceanBlue,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey[400], thickness: 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'o',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey[400], thickness: 1),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: authState.isLoading ? null : _loginWithGoogle,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.deepNavy,
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildGoogleLogo(),
                                const SizedBox(width: 10),
                                Text(
                                  'Continuar con Google',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

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
                          child: Text(
                            '¿No tienes cuenta? Regístrate',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.oceanBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),

                        if (authState.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            authState.errorMessage!,
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppTheme.alertRed,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}