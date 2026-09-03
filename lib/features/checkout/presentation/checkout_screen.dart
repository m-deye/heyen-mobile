import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../core/api/api_unreachable.dart';

import '../../../core/geo/nouakchott_neighborhoods.dart';
import '../../../shared/formatters/price_formatter.dart';
import '../../../shared/formatters/whatsapp_message.dart';
import '../../../shared/models/client_type.dart';
import '../../../shared/models/delivery_location.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/order_line.dart';
import '../../../shared/models/order_status.dart';
import '../../../shared/models/payment_method.dart';
import '../../../shared/services/order_notification_service.dart';
import '../../../shared/widgets/delivery_location_picker.dart';
import '../../../shared/widgets/payment_method_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../theme/heyn_theme.dart';
import '../../auth/application/auth_session_controller.dart';
import '../../cart/application/cart_controller.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../notifications/presentation/notifications_sheet.dart';
import '../../orders/application/order_tracking_controller.dart';
import '../../orders/data/api_orders_repository.dart';
import '../../profile/data/api_profile_repository.dart';
import '../application/checkout_controllers.dart';
import '../data/addresses_api.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late DeliveryLocation _location;
  MobilePaymentMethod? _paymentMethod;
  late final TextEditingController _shopNameController;
  late final TextEditingController _walletController;
  var _submitting = false;

  @override
  void initState() {
    super.initState();
    final start = nouakchottNeighborhoods.first;
    _location = DeliveryLocation(
      neighborhood: start.name,
      landmark: '',
      latitude: start.latitude,
      longitude: start.longitude,
      phone: ref.read(authSessionControllerProvider)?.phone ?? '',
    );
    _paymentMethod = MobilePaymentMethod.bankily;
    _shopNameController = TextEditingController();
    _walletController = TextEditingController(
      text: ref.read(authSessionControllerProvider)?.phone ?? '',
    );
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lines = ref.watch(cartControllerProvider);
    final total = ref.watch(cartTotalProvider);
    final clientType = ref.watch(currentClientTypeProvider);
    final profile = ref.watch(userProfileProvider).value;
    if (profile != null &&
        _shopNameController.text.isEmpty &&
        profile.shopName.isNotEmpty) {
      _shopNameController.text = profile.shopName;
    }

    final user = ref.watch(authSessionControllerProvider);
    final isQuote = clientType.isCommercant;
    final productLabel = lines.length <= 1
        ? '${lines.length} produit'
        : '${lines.length} produits';

    if (lines.isEmpty) {
      return const CartScreen();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HeynPageBackdrop(
        child: Column(
          children: [
          _CheckoutHeader(
            clientType: clientType,
            isQuote: isQuote,
            initials: user?.initials ?? 'H',
            notificationCount: ref.watch(orderNotificationsProvider).length,
            onBack: () => context.pop(),
            onAvatar: () => context.go('/profile'),
            onNotify: () => openNotifications(context, ref),
          ),
          Expanded(
            child: SingleChildScrollView(
              key: const Key('checkout-scroll'),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _QuoteSummaryCard(
                    productLabel: productLabel,
                    totalLabel: formatOuguiya(total),
                  ),
                  if (isQuote) ...[
                    const SizedBox(height: 18),
                    Text(
                      'Nom de la boutique',
                      style: HeynTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    HeynSilverField(
                      fieldKey: const Key('checkout-shop'),
                      controller: _shopNameController,
                      hintText: 'Epicerie Al Amal',
                      icon: Icons.storefront_outlined,
                    ),
                  ],
                  const SizedBox(height: 18),
                  DeliveryLocationPicker(
                    location: _location,
                    compact: isQuote,
                    onChanged: (value) => setState(() => _location = value),
                  ),
                  if (!isQuote) ...[
                    const SizedBox(height: 18),
                    PaymentMethodPicker(
                      selected: _paymentMethod,
                      onSelected: (value) =>
                          setState(() => _paymentMethod = value),
                    ),
                  ],
                  const SizedBox(height: 22),
                  HeynPrimaryButton(
                    key: const Key('checkout-submit'),
                    label: isQuote
                        ? 'Envoyer la demande de devis'
                        : 'Confirmer et payer',
                    icon: isQuote ? Icons.send_rounded : null,
                    isLoading: _submitting,
                    onPressed: _submitting ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final lines = ref.read(cartControllerProvider);
    final total = ref.read(cartTotalProvider);
    final clientType = ref.read(currentClientTypeProvider);
    final session = ref.read(authSessionControllerProvider);

    if (lines.isEmpty) {
      return;
    }
    if (!_location.isComplete) {
      _showMessage('Indiquez un quartier et un repère de livraison.');
      return;
    }
    if (!_location.hasPhone) {
      _showMessage('Indiquez votre numéro de téléphone.');
      return;
    }
    if (!clientType.isCommercant && _paymentMethod == null) {
      _showMessage('Choisissez un mode de paiement.');
      return;
    }
    if (!clientType.isCommercant &&
        (_paymentMethod?.requiresWallet ?? false) &&
        _walletController.text.trim().isEmpty) {
      _showMessage('Indiquez le numéro du compte mobile.');
      return;
    }
    if (clientType.isCommercant && _shopNameController.text.trim().isEmpty) {
      _showMessage('Indiquez le nom de la boutique.');
      return;
    }

    setState(() => _submitting = true);

    final paymentMethod = _paymentMethod ?? MobilePaymentMethod.bankily;
    final contactPhone = _location.phone.trim();
    final walletPhone = _walletController.text.trim().isNotEmpty
        ? _walletController.text.trim()
        : contactPhone;
    final whatsApp = session?.whatsApp.isNotEmpty == true
        ? session!.whatsApp
        : contactPhone;
    final items = [
      for (final line in lines) '${line.quantity} x ${line.product.name}',
    ];
    final notifier = ref.read(orderNotificationServiceProvider);

    try {
      if (clientType.isCommercant) {
        final quote = ref
            .read(quotesControllerProvider.notifier)
            .create(
              lines: lines,
              shopName: _shopNameController.text.trim(),
              deliveryLocation: _location,
              paymentMethod: paymentMethod,
              walletPhone: walletPhone,
              whatsApp: whatsApp,
            );
        ref.read(cartControllerProvider.notifier).clear();
        final message = orderWhatsAppMessage(
          reference: quote.id,
          neighborhood: _location.neighborhood,
          landmark: _location.landmark,
          phone: contactPhone,
          paymentLabel: paymentMethod.label,
          totalLabel: formatOuguiya(total),
          isQuote: true,
          clientTypeLabel: clientType.label,
          items: items,
        );
        unawaited(
          notifier.sendConfirmation(
            message: message,
            clientPhone: contactPhone,
          ),
        );
        if (!mounted) {
          return;
        }
        await _showWhatsAppDialog(
          title: 'Devis envoyé',
          body:
              'Le devis ${quote.id} est enregistré et lié au $contactPhone (${clientType.label}). '
              'Un message WhatsApp est prêt pour le service client.',
          message: message,
          clientPhone: contactPhone,
        );
        if (mounted) {
          context.go('/orders');
        }
        return;
      }

      final order = await _placeRetailOrder(
        lines: lines,
        paymentMethod: paymentMethod,
        walletPhone: walletPhone,
        contactPhone: contactPhone,
        clientType: clientType,
        userId: session?.id ?? '',
      );
      ref.read(cartControllerProvider.notifier).clear();
      final message = orderWhatsAppMessage(
        reference: order.id,
        neighborhood: _location.neighborhood,
        landmark: _location.landmark,
        phone: contactPhone,
        paymentLabel: paymentMethod.label,
        totalLabel: formatOuguiya(total),
        isQuote: false,
        clientTypeLabel: clientType.label,
        items: items,
      );
      unawaited(
        notifier.sendConfirmation(message: message, clientPhone: contactPhone),
      );
      if (!mounted) {
        return;
      }
      await _showWhatsAppDialog(
        title: 'Commande confirmée',
        body:
            'La commande ${order.id} est enregistrée et liée au $contactPhone (${clientType.label}). '
            'Un message WhatsApp est prêt pour le service client.',
        message: message,
        clientPhone: contactPhone,
      );
      if (mounted) {
        context.go('/orders');
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<Order> _placeRetailOrder({
    required List<OrderLine> lines,
    required MobilePaymentMethod paymentMethod,
    required String walletPhone,
    required String contactPhone,
    required ClientType clientType,
    required String userId,
  }) async {
    final localOrders = ref.read(localOrdersControllerProvider.notifier);
    Order fallback() {
      return localOrders.add(
        lines: lines,
        deliveryLocation: _location,
        paymentMethod: paymentMethod,
        walletPhone: walletPhone,
        contactPhone: contactPhone,
        clientType: clientType,
        userId: userId,
      );
    }

    if (!ref.read(apiConfigProvider).isConfigured) {
      return fallback();
    }

    final draft = Order(
      id: 'pending',
      date: DateTime.now(),
      status: OrderStatus.confirmee,
      lines: [for (final line in lines) line.copyWith()],
      deliveryAddress: _location.formattedAddress,
      paymentMethod: paymentMethod,
      walletPhone: walletPhone,
      contactPhone: contactPhone,
      clientType: clientType,
      userId: userId,
    );

    try {
      await ref.read(cartControllerProvider.notifier).syncToRemote();
      String? addressId;
      try {
        addressId = await AddressesApi(ref.read(dioProvider)).create(
          label: _location.neighborhood,
          city: 'Nouakchott',
          district: _location.neighborhood,
          street: _location.landmark,
        );
      } catch (_) {}

      final created = await ref
          .read(ordersRepositoryProvider)
          .createOrder(draft, addressId: addressId);
      if (created.id.isEmpty || created.id == draft.id) {
        return fallback();
      }
      ref.invalidate(ordersProvider);
      return created;
    } on DioException catch (error) {
      if (!isApiUnreachable(error)) {
        // Panier API vide ou validation : on garde une commande locale.
      }
      return fallback();
    } catch (_) {
      return fallback();
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _showWhatsAppDialog({
    required String title,
    required String body,
    required String message,
    required String clientPhone,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(body),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
            FilledButton(
              key: const Key('checkout-whatsapp'),
              onPressed: () async {
                await const OrderNotificationService().sendConfirmation(
                  message: message,
                  clientPhone: clientPhone,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Envoyer WhatsApp'),
            ),
          ],
        );
      },
    );
  }
}

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader({
    required this.clientType,
    required this.isQuote,
    required this.initials,
    required this.notificationCount,
    required this.onBack,
    required this.onAvatar,
    required this.onNotify,
  });

  final ClientType clientType;
  final bool isQuote;
  final String initials;
  final int notificationCount;
  final VoidCallback onBack;
  final VoidCallback onAvatar;
  final VoidCallback onNotify;

  @override
  Widget build(BuildContext context) {
    return HeynDarkHeader(
      title: isQuote ? 'Devis gros avant commande' : 'Confirmer votre commande',
      subtitle: isQuote ? 'Demande de devis' : 'Checkout',
      onBack: onBack,
      leading: HeynInitialsAvatar(
        initials: initials,
        night: false,
        onTap: onAvatar,
      ),
      trailing: HeynRoundIconButton(
        icon: Icons.notifications_none_rounded,
        onTap: onNotify,
        showBadge: notificationCount > 0,
      ),
      bottom: HeynOutlineBadge(
        label: clientType.label,
        icon: clientType.isCommercant
            ? Icons.storefront_outlined
            : Icons.person_outline,
        onDark: false,
      ),
    );
  }
}

class _QuoteSummaryCard extends StatelessWidget {
  const _QuoteSummaryCard({
    required this.productLabel,
    required this.totalLabel,
  });

  final String productLabel;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    return HeynCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(productLabel, style: HeynTextStyles.subtitle),
          ),
          Text(
            totalLabel,
            style: HeynTextStyles.priceBold.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
