// Cuando el backend esté listo, descomentar estas dos líneas:
// import 'dart:convert';
// import 'package:http/http.dart' as http;

import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  const StripeService._();
  static const StripeService instance = StripeService._();

  // Clave pública de Stripe.
  // Pasarla via --dart-define=STRIPE_PK=pk_test_... para no exponerla en el repo.
  static const String _publishableKey = String.fromEnvironment(
    'STRIPE_PK',
    defaultValue: 'pk_test_PLACEHOLDER_SUSTITUIR_POR_CLAVE_REAL',
  );

  // TODO: Implementar lógica Stripe — sustituir por la URL real del backend
  // static const String _backendBaseUrl = 'https://TU_BACKEND_URL';

  static Future<void> initialize() async {
    Stripe.publishableKey = _publishableKey;
    // applySettings() inicializa PaymentConfiguration en el lado nativo Android/iOS
    await Stripe.instance.applySettings();
  }

  /// Procesa el pago de una reserva usando el flujo de confirmación client-side.
  ///
  /// Flujo:
  ///   1. El frontend llama al backend para crear el PaymentIntent.
  ///   2. El backend usa la clave secreta de Stripe para crear el PI y
  ///      devuelve el [client_secret] y el [payment_intent_id].
  ///   3. El frontend confirma el pago directamente contra Stripe usando
  ///      el [client_secret] y los datos de tarjeta del CardFormField.
  ///      Los datos de tarjeta NUNCA pasan por el backend.
  ///   4. Se retorna el [paymentIntentId] para guardarlo en la reserva.
  ///
  /// En caso de error de pago se lanza [StripeException] con el mensaje
  /// localizado de Stripe, que [CheckoutPage] captura y muestra al usuario.
  Future<String> processPayment({
    required double amount,
    required String currency,
    required String bookingId,
  }) async {
    // ── PASO 1: pedir el client_secret al backend ──────────────────────────
    // TODO: Implementar lógica Stripe — el backend debe exponer este endpoint.
    // El backend crea el PaymentIntent con la clave SECRETA de Stripe
    // y devuelve: { "client_secret": "pi_xxx_secret_xxx", "payment_intent_id": "pi_xxx" }
    //
    // Descomentar cuando el backend esté disponible:
    //
    // final response = await http.post(
    //   Uri.parse('$_backendBaseUrl/api/stripe/create-payment-intent'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({
    //     'amount': (amount * 100).toInt(), // Stripe trabaja en céntimos
    //     'currency': currency,
    //     'booking_id': bookingId,
    //   }),
    // );
    //
    // if (response.statusCode != 200) {
    //   throw Exception('Error del servidor al crear el pago.');
    // }
    //
    // final data = jsonDecode(response.body) as Map<String, dynamic>;
    // final clientSecret = data['client_secret'] as String;
    // final paymentIntentId = data['payment_intent_id'] as String;

    // ── PASO 2: confirmar el pago client-side ──────────────────────────────
    // Los datos de tarjeta del CardFormField son usados automáticamente por
    // el SDK nativo de Stripe — nunca pasan por código Dart ni por el backend.
    //
    // Descomentar cuando el backend esté disponible:
    //
    // await Stripe.instance.confirmPayment(
    //   paymentIntentClientSecret: clientSecret,
    //   data: const PaymentMethodParams.card(
    //     paymentMethodData: PaymentMethodData(),
    //   ),
    // );
    //
    // return paymentIntentId;

    // ── STUB temporal ──────────────────────────────────────────────────────
    // Simula un pago exitoso mientras el backend no está disponible.
    // Eliminar este bloque y descomentar los pasos 1 y 2 cuando el backend esté listo.
    await Future.delayed(const Duration(milliseconds: 900));
    return 'pi_stub_${DateTime.now().millisecondsSinceEpoch}';
  }
}
