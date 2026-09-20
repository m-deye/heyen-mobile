import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/heyn_support.dart';
import '../formatters/whatsapp_message.dart';

final orderNotificationServiceProvider = Provider<OrderNotificationService>((
  ref,
) {
  return const OrderNotificationService();
});

class OrderNotificationService {
  const OrderNotificationService();

  String get targetPhone {
    final support = whatsAppDigits(heynSupportWhatsApp);
    return support;
  }

  Uri confirmationUri({required String message, required String clientPhone}) {
    final support = targetPhone;
    final target = support.isNotEmpty ? support : whatsAppDigits(clientPhone);
    return whatsAppUri(phone: target, message: message);
  }

  Uri smsUri({required String message, required String clientPhone}) {
    final support = targetPhone;
    final target = support.isNotEmpty ? support : whatsAppDigits(clientPhone);
    return Uri.parse('sms:$target?body=${Uri.encodeComponent(message)}');
  }

  /// Ouvre le canal support WhatsApp, sans numéro client de repli.
  Future<bool> openSupport({required String message}) async {
    final support = targetPhone;
    if (support.isEmpty) {
      return false;
    }
    if (await _tryLaunch(whatsAppUri(phone: support, message: message))) {
      return true;
    }
    return _tryLaunch(smsUri(message: message, clientPhone: support));
  }

  /// Ouvre WhatsApp pré-rempli, ou un SMS si WhatsApp n'est pas disponible.
  Future<bool> sendConfirmation({
    required String message,
    required String clientPhone,
  }) async {
    final whatsapp = confirmationUri(
      message: message,
      clientPhone: clientPhone,
    );
    if (await _tryLaunch(whatsapp)) {
      return true;
    }
    return _tryLaunch(smsUri(message: message, clientPhone: clientPhone));
  }

  Future<bool> _tryLaunch(Uri uri) async {
    try {
      if (!await canLaunchUrl(uri)) {
        return false;
      }
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
