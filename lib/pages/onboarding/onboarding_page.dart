import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';
import 'package:ocean_rent/pages/home/pages/customer/customer_home_page.dart';
import 'package:ocean_rent/widgets/app_navigator.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  void _goToExploreBoats(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CustomerHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppTheme.deepNavy,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.deepNavy,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.deepNavy,
        body: SafeArea(
          child: Padding(
            padding: AppTheme.responsiveHorizontalScreenPadding(context),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AppTheme.maxContentWidth(context),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppTheme.spacing22),

                    const _OnboardingIndicator(),

                    const SizedBox(height: AppTheme.spacing34),

                    const _BoatIllustration(),

                    const SizedBox(height: AppTheme.spacing28),

                    Text(
                      'El mar te espera',
                      textAlign: TextAlign.center,
                      style: AppTheme.onboardingTitleStyle.copyWith(
                        fontSize: AppTheme.responsiveFontSize(
                          context,
                          AppTheme.fontSize24,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacing12),

                    Text(
                      'Alquila tu barco perfecto \n ahora mismo',
                      textAlign: TextAlign.center,
                      style: AppTheme.onboardingSubtitleStyle.copyWith(
                        color: AppTheme.pearlWhite.withValues(
                          alpha: AppTheme.alphaTextSoft,
                        ),
                        fontSize: AppTheme.responsiveFontSize(
                          context,
                          AppTheme.fontSize24,
                        ),
                        fontWeight: FontWeight.w800,
                        height: AppTheme.lineHeightTight,
                      ),
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      height: AppTheme.onboardingButtonHeight,
                      child: ElevatedButton(
                        onPressed: () => _goToExploreBoats(context),
                        style: AppTheme.onboardingButtonStyle(
                          backgroundColor: AppTheme.oceanBlue,
                          foregroundColor: AppTheme.pearlWhite,
                        ),
                        child: Text(
                          'Explorar Barcos',
                          style: AppTheme.onboardingPrimaryButtonTextStyle
                              .copyWith(
                                fontSize: AppTheme.responsiveFontSize(
                                  context,
                                  AppTheme.fontSize22,
                                ),
                              ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacing20),

                    SizedBox(
                      width: double.infinity,
                      height: AppTheme.onboardingButtonHeight,
                      child: ElevatedButton(
                        onPressed: () => AppNavigator.goToLogin(context),
                        style: AppTheme.onboardingButtonStyle(
                          backgroundColor: AppTheme.pearlWhite,
                          foregroundColor: AppTheme.deepNavy,
                        ),
                        child: Text(
                          'Ya tengo una cuenta',
                          style: AppTheme.onboardingSecondaryButtonTextStyle
                              .copyWith(
                                fontSize: AppTheme.responsiveFontSize(
                                  context,
                                  AppTheme.fontSize20,
                                ),
                              ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacing12),

                    TextButton(
                      style: AppTheme.textButtonStyle,
                      onPressed: () => _goToExploreBoats(context),
                      child: Text(
                        'Saltar Introducción',
                        style: AppTheme.onboardingLinkTextStyle.copyWith(
                          fontSize: AppTheme.responsiveFontSize(
                            context,
                            AppTheme.fontSize16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacing28),
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

class _OnboardingIndicator extends StatelessWidget {
  const _OnboardingIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: AppTheme.onboardingIndicatorWidth,
          height: AppTheme.onboardingIndicatorHeight,
          decoration: const BoxDecoration(
            color: AppTheme.oceanBlue,
            borderRadius: AppTheme.borderRadiusBadge,
          ),
        ),
        const SizedBox(width: AppTheme.spacing8),
        const _IndicatorDot(),
        const SizedBox(width: AppTheme.spacing8),
        const _IndicatorDot(),
      ],
    );
  }
}

class _IndicatorDot extends StatelessWidget {
  const _IndicatorDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppTheme.onboardingDotSize,
      height: AppTheme.onboardingDotSize,
      decoration: BoxDecoration(
        color: AppTheme.pearlWhite.withValues(alpha: AppTheme.alphaTextMuted),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _BoatIllustration extends StatelessWidget {
  const _BoatIllustration();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: AppTheme.onboardingIllustrationWidth,
      height: AppTheme.onboardingIllustrationHeight,
      child: CustomPaint(painter: _BoatIllustrationPainter()),
    );
  }
}

class _BoatIllustrationPainter extends CustomPainter {
  const _BoatIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pearlPaint = Paint()
      ..color = AppTheme.pearlWhite
      ..style = PaintingStyle.fill;

    final Paint oceanPaint = Paint()
      ..color = AppTheme.oceanBlue
      ..style = PaintingStyle.fill;

    final Paint boatPaint = Paint()
      ..color = AppTheme.boatPurple
      ..style = PaintingStyle.fill;

    final Paint boatDarkPaint = Paint()
      ..color = AppTheme.boatDark
      ..style = PaintingStyle.fill;

    final Paint wavePaint = Paint()
      ..color = AppTheme.windowBlue
      ..strokeWidth = AppTheme.borderWidthStrong
      ..strokeCap = StrokeCap.round;

    final double w = size.width;
    final double h = size.height;

    // Sol / luna
    canvas.drawOval(
      Rect.fromLTWH(w * 0.12, h * 0.10, w * 0.32, h * 0.36),
      pearlPaint,
    );

    // Parte superior del barco
    final Path cabin = Path()
      ..moveTo(w * 0.46, h * 0.44)
      ..quadraticBezierTo(w * 0.52, h * 0.34, w * 0.66, h * 0.34)
      ..lineTo(w * 0.78, h * 0.34)
      ..quadraticBezierTo(w * 0.84, h * 0.34, w * 0.86, h * 0.40)
      ..lineTo(w * 0.59, h * 0.40)
      ..quadraticBezierTo(w * 0.50, h * 0.40, w * 0.46, h * 0.44)
      ..close();

    canvas.drawPath(cabin, boatPaint);

    // Ventanas superiores
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.61, h * 0.39, w * 0.20, h * 0.035),
        const Radius.circular(AppTheme.radiusSm),
      ),
      boatDarkPaint,
    );

    // Mástil
    canvas.drawRect(
      Rect.fromLTWH(w * 0.54, h * 0.10, w * 0.018, h * 0.26),
      oceanPaint,
    );

    // Bandera
    final Path flag = Path()
      ..moveTo(w * 0.56, h * 0.10)
      ..lineTo(w * 0.72, h * 0.12)
      ..quadraticBezierTo(w * 0.68, h * 0.15, w * 0.72, h * 0.17)
      ..lineTo(w * 0.56, h * 0.17)
      ..close();

    canvas.drawPath(flag, oceanPaint);

    // Cuerpo principal del barco
    final Path hull = Path()
      ..moveTo(w * 0.10, h * 0.60)
      ..lineTo(w * 0.92, h * 0.60)
      ..quadraticBezierTo(w * 0.86, h * 0.88, w * 0.62, h * 0.88)
      ..lineTo(w * 0.04, h * 0.88)
      ..lineTo(w * 0.15, h * 0.74)
      ..quadraticBezierTo(w * 0.25, h * 0.72, w * 0.32, h * 0.70)
      ..lineTo(w * 0.26, h * 0.68)
      ..quadraticBezierTo(w * 0.36, h * 0.60, w * 0.46, h * 0.60)
      ..close();

    canvas.drawPath(hull, boatPaint);

    // Cubierta
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.42, h * 0.51, w * 0.32, h * 0.05),
        const Radius.circular(AppTheme.radiusMd),
      ),
      boatDarkPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.52, h * 0.61, w * 0.34, h * 0.05),
        const Radius.circular(AppTheme.radiusMd),
      ),
      boatDarkPaint,
    );

    // Ventanas inferiores
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.38, h * 0.70, w * 0.44, h * 0.06),
        const Radius.circular(AppTheme.radiusMd),
      ),
      boatDarkPaint,
    );

    for (int i = 0; i < 7; i++) {
      final double left = w * (0.42 + i * 0.055);
      canvas.drawRect(
        Rect.fromLTWH(left, h * 0.715, w * 0.027, h * 0.035),
        Paint()
          ..color = AppTheme.windowBlue.withValues(
            alpha: AppTheme.alphaTextSecondary,
          ),
      );
    }

    // Olas
    canvas.drawLine(
      Offset(w * 0.08, h * 0.93),
      Offset(w * 0.42, h * 0.93),
      wavePaint,
    );
    canvas.drawLine(
      Offset(w * 0.50, h * 0.93),
      Offset(w * 0.92, h * 0.93),
      wavePaint,
    );

    canvas.drawLine(
      Offset(w * 0.08, h * 0.98),
      Offset(w * 0.20, h * 0.98),
      wavePaint,
    );
    canvas.drawLine(
      Offset(w * 0.28, h * 0.98),
      Offset(w * 0.58, h * 0.98),
      wavePaint,
    );
    canvas.drawLine(
      Offset(w * 0.62, h * 0.98),
      Offset(w * 0.92, h * 0.98),
      wavePaint,
    );

    canvas.drawLine(
      Offset(w * 0.18, h * 1.03),
      Offset(w * 0.34, h * 1.03),
      wavePaint,
    );
    canvas.drawLine(
      Offset(w * 0.50, h * 1.03),
      Offset(w * 0.64, h * 1.03),
      wavePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
