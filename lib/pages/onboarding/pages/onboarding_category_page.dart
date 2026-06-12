import 'package:flutter/material.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';
import 'package:ocean_rent/pages/onboarding/widgets/custom_card.dart';
import 'package:ocean_rent/widgets/app_navigator.dart';

class OnboardingCategoryPage extends StatefulWidget {
  final Function(List<String>) onNext;
  const OnboardingCategoryPage({super.key, required this.onNext});

  @override
  State<OnboardingCategoryPage> createState() => OnboardingCategoryPageState();
}

class OnboardingCategoryPageState extends State<OnboardingCategoryPage> {
  final List<String> selected = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pearlWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: AppTheme.spacing40),
              Text(
                '¿Qué barco estás \n buscando?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              Text(
                'Selecciona el que más te interese',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.pearlWhite.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
              CustomCard(
                title: 'Velero',
                description: 'Experiencia de navegación relajada',
                imagePath: 'assets/icons/veleroOriginal.svg',
                isSelected: selected.contains('velero'),
                onTap: () => setState(() {
                  selected.contains('velero')
                      ? selected.remove('velero')
                      : selected.add('velero');
                }),
              ),
              const SizedBox(height: AppTheme.spacing8),
              CustomCard(
                title: 'Lancha',
                description: 'Rápido, para excursiones cortas',
                imagePath: 'assets/icons/lanchaModificada.svg',
                isSelected: selected.contains('lancha'),
                onTap: () => setState(() {
                  selected.contains('lancha')
                      ? selected.remove('lancha')
                      : selected.add('lancha');
                }),
              ),
              const SizedBox(height: AppTheme.spacing8),
              CustomCard(
                title: 'Catamarán',
                description: 'Ideal para grupos',
                imagePath: 'assets/icons/catamaranModificado.svg',
                isSelected: selected.contains('catamaran'),
                onTap: () => setState(() {
                  selected.contains('catamaran')
                      ? selected.remove('catamaran')
                      : selected.add('catamaran');
                }),
              ),
              const SizedBox(height: AppTheme.spacing8),
              CustomCard(
                title: 'Yate a motor',
                description: 'Rápido y cómodo',
                imagePath: 'assets/icons/yateModificado.svg',
                isSelected: selected.contains('yate'),
                onTap: () => setState(() {
                  selected.contains('yate')
                      ? selected.remove('yate')
                      : selected.add('yate');
                }),
              ),
              const SizedBox(height: AppTheme.spacing8),
              CustomCard(
                title: 'Jet Ski',
                description: 'Ágil y emocionante',
                imagePath: 'assets/icons/jetskiModificado.svg',
                isSelected: selected.contains('jetski'),
                onTap: () => setState(() {
                  selected.contains('jetski')
                      ? selected.remove('jetski')
                      : selected.add('jetski');
                }),
              ),
              const SizedBox(height: AppTheme.spacing24),
              SizedBox(
                width: double.infinity,
                height: AppTheme.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => widget.onNext(selected),
                  style: AppTheme.onboardingButtonStyle(
                    backgroundColor: AppTheme.oceanBlue,
                    foregroundColor: AppTheme.pearlWhite,
                  ),
                  child: Text(
                    'Siguiente',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.pearlWhite,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing20),
              SizedBox(
                width: double.infinity,
                height: AppTheme.buttonHeight,
                child: OutlinedButton(
                  onPressed: () => AppNavigator.goToExploreBoats(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.deepNavy,
                    side: const BorderSide(
                      color: AppTheme.deepNavy,
                      width: AppTheme.borderWidthMedium,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppTheme.borderRadiusMd,
                    ),
                  ),
                  child: Text(
                    'Saltar',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.deepNavy,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing20),
            ],
          ),
        ),
      ),
    );
  }
}