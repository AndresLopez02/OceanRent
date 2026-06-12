import 'package:flutter/material.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';
import 'package:ocean_rent/pages/onboarding/widgets/custom_card.dart';
import 'package:ocean_rent/widgets/app_navigator.dart';

class OnboardingPlacePage extends StatefulWidget {
  final Function(List<String>) onFinish;

  const OnboardingPlacePage({super.key, required this.onFinish});

  @override
  State<OnboardingPlacePage> createState() => _OnboardingPlacePageState();
}

class _OnboardingPlacePageState extends State<OnboardingPlacePage> {
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
                '¿Dónde quieres navegar?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              Text(
                'Selecciona tu zona preferida',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
              CustomCard(
                title: 'Marbella',
                description: 'Costa del Sol, Málaga',
                isSelected: selected.contains('Marbella'),
                onTap: () => setState(() {
                  selected.contains('Marbella')
                      ? selected.remove('Marbella')
                      : selected.add('Marbella');
                }),
                imagePath: 'assets/icons/playa.svg',
              ),
              const SizedBox(height: AppTheme.spacing8),
              CustomCard(
                title: 'Málaga',
                description: 'Capital de la Costa del Sol',
                isSelected: selected.contains('Málaga'),
                onTap: () => setState(() {
                  selected.contains('Málaga')
                      ? selected.remove('Málaga')
                      : selected.add('Málaga');
                }),
                imagePath: 'assets/icons/playa.svg',
              ),
              const SizedBox(height: AppTheme.spacing8),
              CustomCard(
                title: 'Cabo Cañaveral',
                description: 'Aguas tranquilas del Mediterráneo',
                isSelected: selected.contains('Cabo Cañaveral'),
                onTap: () => setState(() {
                  selected.contains('Cabo Cañaveral')
                      ? selected.remove('Cabo Cañaveral')
                      : selected.add('Cabo Cañaveral');
                }),
                imagePath: 'assets/icons/playa.svg',
              ),
              const SizedBox(height: AppTheme.spacing24),
              SizedBox(
                width: double.infinity,
                height: AppTheme.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => widget.onFinish(selected),
                  style: AppTheme.onboardingButtonStyle(
                    backgroundColor: AppTheme.oceanBlue,
                    foregroundColor: AppTheme.pearlWhite,
                  ),
                  child: Text(
                    'Explorar Barcos',
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