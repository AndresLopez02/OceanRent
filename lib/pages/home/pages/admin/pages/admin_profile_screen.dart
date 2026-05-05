import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocean_rent/models/user_model.dart';
import 'package:ocean_rent/providers/auth_providers.dart';
import 'package:ocean_rent/providers/user_providers.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';


// Decoración de campos de texto


InputDecoration _fieldDeco({required String label, required IconData icon, bool readOnly = false}) =>
    InputDecoration(
      labelText:  label,
      labelStyle: GoogleFonts.openSans(color: AppTheme.deepNavy.withValues(alpha: 0.50), fontSize: 13),
      prefixIcon: Icon(icon, size: 18, color: AppTheme.deepNavy.withValues(alpha: 0.50)),
      filled:     true,
      fillColor:  readOnly ? AppTheme.pearlWhite : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.deepNavy.withValues(alpha: 0.20))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.deepNavy.withValues(alpha: 0.20))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.oceanBlue, width: 1.5)),
      errorBorder:   OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.alertRed)),
      errorStyle:    GoogleFonts.openSans(fontSize: 12, color: AppTheme.alertRed),
    );

// Screen principal

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  static void navigate(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminProfileScreen()));

  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen>
    with SingleTickerProviderStateMixin {

  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _emailCtrl   = TextEditingController();

  UserModel? _profile;
  bool       _isLoading = true;
  bool       _isSaving  = false;

  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 600),
  );
  late final Animation<double> _fadeAnim =
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _surnameCtrl.dispose(); _emailCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // Lógica 

  Future<void> _loadProfile() async {
    final auth = ref.read(authNotifierProvider);
    if (auth.currentUser == null) await auth.checkCurrentSession();

    final uid = ref.read(authNotifierProvider).currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      _snack('No se pudo obtener el usuario', error: true);
      return;
    }
    try {
      final profile = await ref.read(userRepositoryProvider).getUser(uid);
      if (!mounted) return;
      setState(() {
        _profile          = profile;
        _nameCtrl.text    = profile.name;
        _surnameCtrl.text = profile.surname;
        _emailCtrl.text   = profile.email;
        _isLoading        = false;
      });
      _fadeCtrl.forward();
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _snack('Error al cargar el perfil: $e', error: true);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final uid = ref.read(authNotifierProvider).currentUser!.uid;
      await ref.read(userRepositoryProvider).updateProfile(
        uid: uid, name: _nameCtrl.text.trim(), surname: _surnameCtrl.text.trim(),
      );
      _snack('Perfil actualizado correctamente');
    } catch (e) {
      _snack('Error al guardar el perfil: $e', error: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.openSans(fontSize: 14, color: Colors.white)),
      backgroundColor: error ? AppTheme.alertRed : AppTheme.oceanBlue,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // Build 

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.oceanBlue)));
    if (_profile == null) return Scaffold(body: Center(child: Text('No se pudo cargar el perfil', style: GoogleFonts.openSans(fontSize: 16, color: AppTheme.deepNavy))));

    return Scaffold(
      backgroundColor: AppTheme.pearlWhite,
      appBar: _AdminAppBar(onBack: () => Navigator.of(context).maybePop()),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth * 0.05,
              vertical: 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AvatarSection(profile: _profile!),
                  const SizedBox(height: 32),
                  const _SectionLabel('Datos Personales'),
                  const SizedBox(height: 16),
                  _PersonalDataCard(nameCtrl: _nameCtrl, surnameCtrl: _surnameCtrl, emailCtrl: _emailCtrl),
                  const SizedBox(height: 36),
                  _SaveButton(isSaving: _isSaving, onPressed: _saveProfile),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widgets anidados
// AppBar 

class _AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AdminAppBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: AppTheme.deepNavy,
    elevation: 0,
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
      onPressed: onBack,
    ),
    title: Text('OceanRent', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: 0.2)),
    actions: const [
      Padding(
        padding: EdgeInsets.only(right: 16),
        child: Icon(Icons.directions_boat_rounded, color: Colors.white, size: 24),
      ),
    ],
  );
}

// Avatar 

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({required this.profile});
  final UserModel profile;

  @override
  Widget build(BuildContext context) {
    final initials = '${profile.name[0]}${profile.surname[0]}'.toUpperCase();
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.oceanBlue, AppTheme.deepNavy],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppTheme.oceanBlue.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Center(child: Text(initials, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700))),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.deepNavy.withValues(alpha: 0.12), width: 1.5),
                  ),
                  child: Icon(Icons.camera_alt_rounded, size: 14, color: AppTheme.deepNavy.withValues(alpha: 0.50)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${profile.name} ${profile.surname}',
            style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.deepNavy, letterSpacing: -0.4),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.deepNavy.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.deepNavy.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_rounded, size: 12, color: AppTheme.deepNavy),
                const SizedBox(width: 4),
                Text('Administrador', style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.deepNavy, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Section label 

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.deepNavy.withValues(alpha: 0.50), letterSpacing: 0.8),
  );
}

// Card contenedor 

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.055), blurRadius: 20, offset: const Offset(0, 4))],
    ),
    child: child,
  );
}

// Datos personales 

class _PersonalDataCard extends StatelessWidget {
  const _PersonalDataCard({required this.nameCtrl, required this.surnameCtrl, required this.emailCtrl});
  final TextEditingController nameCtrl, surnameCtrl, emailCtrl;

  static String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null;

  @override
  Widget build(BuildContext context) => _ProfileCard(
    child: Column(
      children: [
        _ProfileField(controller: nameCtrl,    label: 'Nombre',   icon: Icons.person_outline_rounded, validator: _required),
        const SizedBox(height: 20),
        _ProfileField(controller: surnameCtrl, label: 'Apellidos', icon: Icons.badge_outlined,         validator: _required),
        const SizedBox(height: 20),
        _ProfileField(
          controller: emailCtrl, label: 'Correo Electrónico',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress, readOnly: true,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Campo requerido';
            if (!v.contains('@')) return 'Email inválido';
            return null;
          },
        ),
      ],
    ),
  );
}

// Campo de texto 

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.validator,
  });

  final TextEditingController      controller;
  final String                     label;
  final IconData                   icon;
  final TextInputType              keyboardType;
  final bool                       readOnly;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller, keyboardType: keyboardType,
    readOnly: readOnly, validator: validator,
    style: GoogleFonts.openSans(
      fontSize: 15,
      color: readOnly ? AppTheme.deepNavy.withValues(alpha: 0.50) : AppTheme.deepNavy,
      fontWeight: FontWeight.w500,
    ),
    decoration: _fieldDeco(label: label, icon: icon, readOnly: readOnly),
  );
}

//  Botón guardar

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isSaving, required this.onPressed});
  final bool         isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 52,
    child: ElevatedButton(
      onPressed: isSaving ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.oceanBlue,
        disabledBackgroundColor: AppTheme.oceanBlue.withValues(alpha: 0.5),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: isSaving
          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
          : Text('Guardar cambios', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: Colors.white)),
    ),
  );
}

