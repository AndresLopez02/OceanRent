import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';
import 'package:ocean_rent/models/user_model.dart';
import 'package:ocean_rent/providers/auth_providers.dart';
import 'package:ocean_rent/providers/user_providers.dart';
import 'package:ocean_rent/widgets/profile_widgets.dart';

// Screen principal

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  static void navigate(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AdminProfileScreen()));
  }

  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  UserModel? _profile;
  bool _isLoading = true;
  bool _isSaving = false;

  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: AppTheme.fadeDuration,
  );

  late final Animation<double> _fadeAnim = CurvedAnimation(
    parent: _fadeCtrl,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _emailCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // Lógica

  Future<void> _loadProfile() async {
    final auth = ref.read(authNotifierProvider);

    if (auth.currentUser == null) {
      await auth.checkCurrentSession();
    }

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
        _profile = profile;
        _nameCtrl.text = profile.name;
        _surnameCtrl.text = profile.surname;
        _emailCtrl.text = profile.email;
        _isLoading = false;
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

      await ref
          .read(userRepositoryProvider)
          .updateProfile(
            uid: uid,
            name: _nameCtrl.text.trim(),
            surname: _surnameCtrl.text.trim(),
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.white),
        ),
        backgroundColor: error ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: AppTheme.borderRadiusInput,
        ),
        margin: AppTheme.listPadding,
      ),
    );
  }

  // Build

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.oceanBlue,
            strokeWidth: AppTheme.borderWidthMedium,
          ),
        ),
      );
    }

    if (_profile == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Text(
            'No se pudo cargar el perfil',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.deepNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _AdminAppBar(onBack: () => Navigator.of(context).maybePop()),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: AppTheme.responsiveScreenPadding(context),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AvatarSection(profile: _profile!),
                const SizedBox(height: AppTheme.spacing32),
                ProfileSectionLabel(
                  'Datos Personales',
                  color: AppTheme.deepNavy.withValues(
                    alpha: AppTheme.alphaDisabled,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                _PersonalDataCard(
                  nameCtrl: _nameCtrl,
                  surnameCtrl: _surnameCtrl,
                  emailCtrl: _emailCtrl,
                ),
                const SizedBox(height: AppTheme.spacing36),
                ProfileSaveButton(isSaving: _isSaving, onPressed: _saveProfile),
                const SizedBox(height: AppTheme.spacing24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// AppBar

class _AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AdminAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.deepNavy,
      foregroundColor: AppTheme.white,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: AppTheme.appBarTitleStyle,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: AppTheme.iconSizeLg,
          color: AppTheme.white,
        ),
        onPressed: onBack,
      ),
      title: const Text('OceanRent'),
      actions: const [
        Icon(
          Icons.directions_boat_rounded,
          size: AppTheme.iconSizeLarge,
          color: AppTheme.white,
        ),
        SizedBox(width: AppTheme.spacing16),
      ],
    );
  }
}

// Avatar

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({required this.profile});

  final UserModel profile;

  @override
  Widget build(BuildContext context) {
    final initials = (profile.name.isNotEmpty && profile.surname.isNotEmpty)
        ? '${profile.name[0]}${profile.surname[0]}'.toUpperCase()
        : profile.name.isNotEmpty
        ? profile.name[0].toUpperCase()
        : '?';

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: AppTheme.avatarSize,
                height: AppTheme.avatarSize,
                decoration: AppTheme.profileAvatarDecoration(),
                child: Center(
                  child: Text(
                    initials,
                    style: AppTheme.titleLarge.copyWith(
                      color: AppTheme.white,
                      fontSize: AppTheme.fontSize30,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: AppTheme.avatarCameraSize,
                  height: AppTheme.avatarCameraSize,
                  decoration: AppTheme.profileCameraDecoration(),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: AppTheme.iconSizeSmall,
                    color: AppTheme.deepNavy.withValues(
                      alpha: AppTheme.alphaDisabled,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            '${profile.name} ${profile.surname}',
            style: AppTheme.cardTitleStyle.copyWith(color: AppTheme.deepNavy),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Container(
            padding: AppTheme.profileBadgePadding,
            decoration: AppTheme.badgeDecoration(color: AppTheme.deepNavy),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shield_rounded,
                  size: AppTheme.iconSizeMini,
                  color: AppTheme.deepNavy,
                ),
                const SizedBox(width: AppTheme.spacing4),
                Text(
                  'Administrador',
                  style: AppTheme.badgeTextStyle.copyWith(
                    color: AppTheme.deepNavy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Datos personales

class _PersonalDataCard extends StatelessWidget {
  const _PersonalDataCard({
    required this.nameCtrl,
    required this.surnameCtrl,
    required this.emailCtrl,
  });

  final TextEditingController nameCtrl;
  final TextEditingController surnameCtrl;
  final TextEditingController emailCtrl;

  static String? _required(String? v) {
    return (v == null || v.trim().isEmpty) ? 'Campo requerido' : null;
  }

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Column(
        children: [
          ProfileField(
            controller: nameCtrl,
            label: 'Nombre',
            icon: Icons.person_outline_rounded,
            validator: _required,
          ),
          const SizedBox(height: AppTheme.spacing20),
          ProfileField(
            controller: surnameCtrl,
            label: 'Apellidos',
            icon: Icons.badge_outlined,
            validator: _required,
          ),
          const SizedBox(height: AppTheme.spacing20),
          ProfileField(
            controller: emailCtrl,
            label: 'Correo Electrónico',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            readOnly: true,
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
}
