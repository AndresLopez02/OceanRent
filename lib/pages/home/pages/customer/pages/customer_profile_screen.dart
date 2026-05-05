import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocean_rent/models/user_model.dart';
import 'package:ocean_rent/providers/auth_providers.dart';
import 'package:ocean_rent/providers/user_providers.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';

// Helpers y widgets anidados

enum LicenseStatus { pending, verified, rejected, none }

LicenseStatus _statusFromString(String s) => switch (s.toLowerCase()) {
  'pending'  => LicenseStatus.pending,
  'verified' => LicenseStatus.verified,
  'rejected' => LicenseStatus.rejected,
  _          => LicenseStatus.none,
};

({Color color, IconData icon, String label}) _statusCfg(LicenseStatus s) =>
    switch (s) {
      LicenseStatus.verified => (color: AppTheme.oceanBlue,  icon: Icons.check_circle_rounded,          label: 'Verificado'),
      LicenseStatus.pending  => (color: AppTheme.sunsetGold, icon: Icons.hourglass_top_rounded,         label: 'Pendiente'),
      LicenseStatus.rejected => (color: AppTheme.alertRed,   icon: Icons.cancel_rounded,                label: 'Rechazado'),
      LicenseStatus.none     => (color: AppTheme.deepNavy.withValues(alpha: 0.50), icon: Icons.remove_circle_outline_rounded, label: 'Sin verificar'),
    };


// Decoración de los campos de texto

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

// SCREEN PRINCIPAL

class CustomerProfileScreen extends ConsumerStatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  ConsumerState<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends ConsumerState<CustomerProfileScreen>
    with SingleTickerProviderStateMixin {

  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _emailCtrl   = TextEditingController();

  UserModel?    _profile;
  bool          _isLoading    = true;
  bool          _isSaving     = false;
  bool          _isUploading  = false;
  LicenseStatus _licenseStatus = LicenseStatus.none;
  String        _licenseType   = 'none';
  String?       _pickedFileName;

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

  // Lógica y funciones auxiliares

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
        _licenseStatus    = _statusFromString(profile.nauticalLicense?.status ?? 'none');
        _licenseType      = profile.nauticalLicense?.type ?? 'none';
        _isLoading        = false;
      });
      _fadeCtrl.forward();
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _snack('Error al cargar el perfil: $e', error: true);
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.isEmpty) return;
    setState(() { _pickedFileName = result.files.single.name; _isUploading = true; });
    try {
      final uid  = ref.read(authNotifierProvider).currentUser!.uid;
      final repo = ref.read(userRepositoryProvider);
      final url  = await repo.uploadLicenseDocument(uid: uid, file: XFile(result.files.single.path!));
      await repo.updateNauticalLicense(uid: uid, type: _licenseType, documentUrl: url, status: 'pending');
      setState(() { _isUploading = false; _licenseStatus = LicenseStatus.pending; });
      _snack('Documento enviado para verificación');
    } catch (e) {
      setState(() => _isUploading = false);
      _snack('Error al subir el documento: $e', error: true);
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
      body: SafeArea(
        child: FadeTransition(
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
                    const SizedBox(height: 28),
                    const _SectionLabel('Titulación Náutica'),
                    const SizedBox(height: 16),
                    _NauticalCard(
                      licenseStatus:  _licenseStatus,
                      licenseType:    _licenseType,
                      pickedFileName: _pickedFileName,
                      isUploading:    _isUploading,
                      profile:        _profile!,
                      onTypeChanged:  (v) => setState(() => _licenseType = v),
                      onPickDocument: _pickDocument,
                    ),
                    const SizedBox(height: 36),
                    _SaveButton(isSaving: _isSaving, onPressed: _saveProfile),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widgets anidados

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
              color: AppTheme.oceanBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Cliente', style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.oceanBlue, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

//  Section label 

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.deepNavy.withValues(alpha: 0.50), letterSpacing: 0.8),
  );
}

// Contenedor de sección

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

  final TextEditingController       controller;
  final String                      label;
  final IconData                    icon;
  final TextInputType               keyboardType;
  final bool                        readOnly;
  final String? Function(String?)?  validator;

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

// Titulación náutica 

class _NauticalCard extends StatelessWidget {
  const _NauticalCard({
    required this.licenseStatus,
    required this.licenseType,
    required this.pickedFileName,
    required this.isUploading,
    required this.profile,
    required this.onTypeChanged,
    required this.onPickDocument,
  });

  final LicenseStatus        licenseStatus;
  final String               licenseType;
  final String?              pickedFileName;
  final bool                 isUploading;
  final UserModel            profile;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback         onPickDocument;

  static const _licenseTypes = [
    ('none', 'Sin licencia'),
    ('pnb',  'Patrón de Navegación Básica (PNB)'),
    ('per',  'Patrón de Embarcaciones de Recreo (PER)'),
  ];

  @override
  Widget build(BuildContext context) {
    final cfg = _statusCfg(licenseStatus);
    return _ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Estado de verificación', style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.deepNavy)),
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: cfg.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cfg.color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cfg.icon, size: 13, color: cfg.color),
                    const SizedBox(width: 5),
                    Text(cfg.label, style: GoogleFonts.montserrat(fontSize: 12, color: cfg.color, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: licenseType,
            decoration: _fieldDeco(label: 'Tipo de titulación', icon: Icons.anchor_rounded),
            style: GoogleFonts.openSans(fontSize: 15, color: AppTheme.deepNavy, fontWeight: FontWeight.w500),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            items: _licenseTypes.map((t) => DropdownMenuItem(
              value: t.$1,
              child: Text(t.$2, style: GoogleFonts.openSans(fontSize: 14, color: AppTheme.deepNavy)),
            )).toList(),
            onChanged: (v) { if (v != null) onTypeChanged(v); },
          ),
          const SizedBox(height: 20),
          Divider(color: AppTheme.deepNavy.withValues(alpha: 0.12)),
          const SizedBox(height: 16),
          _DocumentUpload(
            licenseStatus:  licenseStatus,
            pickedFileName: pickedFileName,
            isUploading:    isUploading,
            profile:        profile,
            onTap:          onPickDocument,
          ),
        ],
      ),
    );
  }
}

// Upload de documento 

class _DocumentUpload extends StatelessWidget {
  const _DocumentUpload({
    required this.licenseStatus,
    required this.pickedFileName,
    required this.isUploading,
    required this.profile,
    required this.onTap,
  });

  final LicenseStatus licenseStatus;
  final String?       pickedFileName;
  final bool          isUploading;
  final UserModel     profile;
  final VoidCallback  onTap;

  @override
  Widget build(BuildContext context) {
    final hasFile = pickedFileName != null || (profile.nauticalLicense?.documentUrl.isNotEmpty ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Documento acreditativo', style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.deepNavy)),
        const SizedBox(height: 4),
        Text('Sube tu titulación en formato PDF, JPG o PNG (máx. 10 MB)', style: GoogleFonts.openSans(fontSize: 12, color: AppTheme.deepNavy.withValues(alpha: 0.50))),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: isUploading ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: hasFile ? AppTheme.oceanBlue.withValues(alpha: 0.04) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFile ? AppTheme.oceanBlue.withValues(alpha: 0.4) : AppTheme.deepNavy.withValues(alpha: 0.20),
                width: 1.5,
              ),
            ),
            child: isUploading
                ? Column(children: [
                    const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.oceanBlue)),
                    const SizedBox(height: 10),
                    Text('Subiendo documento...', style: GoogleFonts.openSans(color: AppTheme.deepNavy.withValues(alpha: 0.50), fontSize: 13)),
                  ])
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        hasFile ? Icons.insert_drive_file_rounded : Icons.upload_file_rounded,
                        color: hasFile ? AppTheme.oceanBlue : AppTheme.deepNavy.withValues(alpha: 0.50),
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          pickedFileName ?? ((profile.nauticalLicense?.documentUrl.isNotEmpty ?? false) ? 'Documento subido' : 'Seleccionar documento'),
                          style: GoogleFonts.openSans(
                            fontSize: 13, fontWeight: FontWeight.w500,
                            color: hasFile ? AppTheme.oceanBlue : AppTheme.deepNavy.withValues(alpha: 0.50),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!hasFile) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppTheme.oceanBlue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                          child: Text('Examinar', style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.oceanBlue)),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
        if (licenseStatus == LicenseStatus.rejected) ...[
          const SizedBox(height: 10),
          _InfoBanner(color: AppTheme.alertRed,   icon: Icons.info_outline_rounded,  text: 'Tu documento fue rechazado. Por favor, sube uno nuevo.'),
        ],
        if (licenseStatus == LicenseStatus.pending) ...[
          const SizedBox(height: 10),
          _InfoBanner(color: AppTheme.sunsetGold, icon: Icons.hourglass_top_rounded, text: 'Documento en revisión. Te avisaremos cuando sea verificado.'),
        ],
        if (licenseStatus == LicenseStatus.verified) ...[
          const SizedBox(height: 10),
          _InfoBanner(color: AppTheme.oceanBlue,  icon: Icons.verified_rounded,       text: 'Tu titulación náutica ha sido verificada correctamente.'),
        ],
      ],
    );
  }
}

// Botón guardar 

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

// Info del banner 

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.color, required this.icon, required this.text});
  final Color color; final IconData icon; final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withValues(alpha: 0.25)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: GoogleFonts.openSans(fontSize: 12, color: color, fontWeight: FontWeight.w500, height: 1.4))),
      ],
    ),
  );
}
