import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../core/api/api_unreachable.dart';

import '../../../core/geo/nouakchott_neighborhoods.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/formatters/price_formatter.dart';
import '../../../shared/formatters/whatsapp_message.dart';
import '../../../shared/localization/display_localizations.dart';
import '../../../shared/models/client_type.dart';
import '../../../shared/models/delivery_location.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/order_line.dart';
import '../../../shared/models/order_status.dart';
import '../../../shared/models/payment_method.dart';
import '../../../shared/services/order_notification_service.dart';
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

const _deliveryFee = 200.0;
const _freeDeliveryThreshold = 10000.0;

double _deliveryFeeFor(double subtotal) {
  if (subtotal <= 0 || subtotal >= _freeDeliveryThreshold) {
    return 0;
  }
  return _deliveryFee;
}

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
  late final TextEditingController _landmarkController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;
  late DateTime _deliveryAt;
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
    _paymentMethod = MobilePaymentMethod.cash;
    _shopNameController = TextEditingController();
    _walletController = TextEditingController(
      text: ref.read(authSessionControllerProvider)?.phone ?? '',
    );
    _landmarkController = TextEditingController(text: _location.landmark);
    _phoneController = TextEditingController(text: _location.phone);
    _notesController = TextEditingController();
    _deliveryAt = _defaultDeliveryAt();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _walletController.dispose();
    _landmarkController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lines = ref.watch(cartControllerProvider);
    final clientType = ref.watch(currentClientTypeProvider);
    final profile = ref.watch(userProfileProvider).value;
    if (profile != null &&
        _shopNameController.text.isEmpty &&
        profile.shopName.isNotEmpty) {
      _shopNameController.text = profile.shopName;
    }

    final user = ref.watch(authSessionControllerProvider);
    final isQuote = clientType.isCommercant;
    final productLabel = l10n.commonProductCount(lines.length);

    if (lines.isEmpty) {
      return const CartScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _CheckoutTopBar(
              title: isQuote
                  ? l10n.checkoutQuoteHeaderTitle
                  : l10n.checkoutOrderHeaderTitle,
              itemCountLabel: productLabel,
              onBack: () =>
                  context.canPop() ? context.pop() : context.go('/cart'),
              onNotify: () => openNotifications(context, ref),
              notificationCount: ref.watch(orderNotificationsProvider).length,
              initials: user?.initials ?? 'H',
              onAvatar: () => context.go('/profile'),
            ),
            Expanded(
              child: SingleChildScrollView(
                key: const Key('checkout-scroll'),
                padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isQuote) ...[
                      _CheckoutSectionCard(
                        title: l10n.authShopName,
                        child: _CheckoutTextField(
                          fieldKey: const Key('checkout-shop'),
                          controller: _shopNameController,
                          hintText: l10n.checkoutShopExample,
                          icon: Icons.storefront_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _DeliveryAddressCard(
                      location: _location,
                      landmarkController: _landmarkController,
                      phoneController: _phoneController,
                      onChanged: (value) => setState(() => _location = value),
                    ),
                    const SizedBox(height: 16),
                    _DeliveryScheduleCard(
                      value: _deliveryAt,
                      onChanged: (value) => setState(() => _deliveryAt = value),
                    ),
                    if (!isQuote) ...[
                      const SizedBox(height: 16),
                      _PaymentCard(
                        selected: _paymentMethod,
                        onSelected: (value) =>
                            setState(() => _paymentMethod = value),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _CheckoutSectionCard(
                      title: l10n.checkoutNotesTitle,
                      child: _CheckoutTextField(
                        controller: _notesController,
                        hintText: l10n.checkoutNotesHint,
                        icon: Icons.notes_rounded,
                        minLines: 3,
                        maxLines: 4,
                      ),
                    ),
                    const SizedBox(height: 88),
                  ],
                ),
              ),
            ),
            _StickyConfirmButton(
              key: const Key('checkout-submit'),
              label: isQuote
                  ? l10n.checkoutSubmitQuote
                  : l10n.checkoutConfirmAndPay,
              isLoading: _submitting,
              onPressed: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final lines = ref.read(cartControllerProvider);
    final total = ref.read(cartTotalProvider);
    final clientType = ref.read(currentClientTypeProvider);
    final session = ref.read(authSessionControllerProvider);

    if (lines.isEmpty) {
      return;
    }
    if (!_location.isComplete) {
      _showMessage(l10n.checkoutCompleteLocationError);
      return;
    }
    if (!_location.hasPhone) {
      _showMessage(l10n.checkoutPhoneError);
      return;
    }
    if (!clientType.isCommercant && _paymentMethod == null) {
      _showMessage(l10n.checkoutPaymentMethodError);
      return;
    }
    if (!clientType.isCommercant &&
        (_paymentMethod?.requiresWallet ?? false) &&
        _walletController.text.trim().isEmpty) {
      _showMessage(l10n.checkoutWalletPhoneError);
      return;
    }
    if (clientType.isCommercant && _shopNameController.text.trim().isEmpty) {
      _showMessage(l10n.checkoutShopNameError);
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
        unawaited(ref.read(cartControllerProvider.notifier).clear());
        final message = orderWhatsAppMessage(
          reference: quote.id,
          neighborhood: _location.neighborhood,
          landmark: _location.landmark,
          phone: contactPhone,
          paymentLabel: paymentMethod.localizedLabel(l10n),
          totalLabel: formatOuguiya(total),
          isQuote: true,
          clientTypeLabel: clientType.localizedLabel(l10n),
          l10n: l10n,
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
        final destination = await _showWhatsAppDialog(
          title: l10n.checkoutQuoteSentTitle,
          body: l10n.checkoutQuoteWhatsAppBody(
            quote.id,
            contactPhone,
            clientType.localizedLabel(l10n),
          ),
          message: message,
          clientPhone: contactPhone,
          reference: quote.id,
          deliveryLabel: _formatDeliveryAt(context, _deliveryAt),
          totalLabel: formatOuguiya(total),
          isQuote: true,
        );
        if (mounted) {
          context.go(
            destination == _CheckoutSuccessDestination.home ? '/' : '/orders',
          );
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
      await ref.read(cartControllerProvider.notifier).clear();
      final message = orderWhatsAppMessage(
        reference: order.id,
        neighborhood: _location.neighborhood,
        landmark: _location.landmark,
        phone: contactPhone,
        paymentLabel: paymentMethod.localizedLabel(l10n),
        totalLabel: formatOuguiya(total),
        isQuote: false,
        clientTypeLabel: clientType.localizedLabel(l10n),
        l10n: l10n,
        items: items,
      );
      unawaited(
        notifier.sendConfirmation(message: message, clientPhone: contactPhone),
      );
      if (!mounted) {
        return;
      }
      final destination = await _showWhatsAppDialog(
        title: l10n.checkoutOrderConfirmedTitle,
        body: l10n.checkoutOrderWhatsAppBody(
          order.id,
          contactPhone,
          clientType.localizedLabel(l10n),
        ),
        message: message,
        clientPhone: contactPhone,
        reference: order.id,
        deliveryLabel: _formatDeliveryAt(context, _deliveryAt),
        totalLabel: formatOuguiya(total + _deliveryFeeFor(total)),
        isQuote: false,
      );
      if (mounted) {
        context.go(
          destination == _CheckoutSuccessDestination.home ? '/' : '/orders',
        );
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

  Future<_CheckoutSuccessDestination> _showWhatsAppDialog({
    required String title,
    required String body,
    required String message,
    required String clientPhone,
    required String reference,
    required String deliveryLabel,
    required String totalLabel,
    required bool isQuote,
  }) {
    return showDialog<_CheckoutSuccessDestination>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          backgroundColor: AppColors.scaffoldBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(_CheckoutSuccessDestination.orders),
                      child: Text(l10n.commonClose),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const _SuccessMark(),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: HeynTextStyles.sectionTitle.copyWith(
                      color: AppColors.darkText,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isQuote
                        ? l10n.checkoutQuoteSuccessSubtitle
                        : l10n.checkoutOrderSuccessSubtitle,
                    textAlign: TextAlign.center,
                    style: HeynTextStyles.subtitle.copyWith(
                      color: AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SuccessSummaryCard(
                    reference: reference,
                    deliveryLabel: deliveryLabel,
                    totalLabel: totalLabel,
                  ),
                  const SizedBox(height: 18),
                  _DialogPrimaryButton(
                    label: l10n.checkoutTrackOrder,
                    icon: Icons.local_shipping_outlined,
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(_CheckoutSuccessDestination.orders),
                  ),
                  const SizedBox(height: 10),
                  _DialogSecondaryButton(
                    key: const Key('checkout-whatsapp'),
                    label: l10n.checkoutSendInvoiceWhatsApp,
                    icon: Icons.chat_bubble_outline_rounded,
                    onPressed: () async {
                      await const OrderNotificationService().sendConfirmation(
                        message: message,
                        clientPhone: clientPhone,
                      );
                      if (context.mounted) {
                        Navigator.of(
                          context,
                        ).pop(_CheckoutSuccessDestination.orders);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(_CheckoutSuccessDestination.home),
                    child: Text(l10n.checkoutReturnHome),
                  ),
                  Offstage(child: Text(body)),
                ],
              ),
            ),
          ),
        );
      },
    ).then((value) => value ?? _CheckoutSuccessDestination.orders);
  }
}

enum _CheckoutSuccessDestination { orders, home }

DateTime _defaultDeliveryAt() {
  final now = DateTime.now();
  var hour = now.minute > 0 ? now.hour + 1 : now.hour;
  if (hour < 9) {
    hour = 9;
  }
  if (hour > 20) {
    return DateTime(now.year, now.month, now.day + 1, 9);
  }
  return DateTime(now.year, now.month, now.day, hour);
}

String _formatDeliveryAt(BuildContext context, DateTime value) {
  final locale = Localizations.localeOf(context).toString();
  return '${DateFormat.yMMMEd(locale).format(value)} · ${DateFormat.Hm(locale).format(value)}';
}

class _CheckoutTopBar extends StatelessWidget {
  const _CheckoutTopBar({
    required this.title,
    required this.itemCountLabel,
    required this.notificationCount,
    required this.onBack,
    required this.onAvatar,
    required this.onNotify,
    required this.initials,
  });

  final String title;
  final String itemCountLabel;
  final int notificationCount;
  final VoidCallback onBack;
  final VoidCallback onAvatar;
  final VoidCallback onNotify;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 12),
      child: Row(
        children: [
          _CircleIconButton(icon: const BackButtonIcon(), onPressed: onBack),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: HeynTextStyles.sectionTitle.copyWith(
                    color: AppColors.darkText,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  itemCountLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: HeynTextStyles.caption.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _CircleIconButton(
            icon: Badge(
              isLabelVisible: notificationCount > 0,
              smallSize: 8,
              backgroundColor: AppColors.cartBadge,
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.darkText,
                size: 20,
              ),
            ),
            onPressed: onNotify,
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onAvatar,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary,
              child: Text(
                initials,
                style: HeynTextStyles.caption.copyWith(
                  color: AppColors.background,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed});

  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox.square(dimension: 46, child: Center(child: icon)),
      ),
    );
  }
}

class _DeliveryAddressCard extends StatelessWidget {
  const _DeliveryAddressCard({
    required this.location,
    required this.landmarkController,
    required this.phoneController,
    required this.onChanged,
  });

  final DeliveryLocation location;
  final TextEditingController landmarkController;
  final TextEditingController phoneController;
  final ValueChanged<DeliveryLocation> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _CheckoutSectionCard(
      title: l10n.checkoutDeliveryAddress,
      child: Column(
        children: [
          _CheckoutTextField(
            fieldKey: const Key('checkout-landmark'),
            controller: landmarkController,
            hintText: l10n.checkoutAddressHint,
            icon: Icons.location_on_outlined,
            minLines: 3,
            maxLines: 4,
            keyboardType: TextInputType.streetAddress,
            textInputAction: TextInputAction.next,
            textAlign: TextAlign.start,
            onChanged: (value) => onChanged(
              location.copyWith(
                landmark: value,
                neighborhood: value.trim().isEmpty
                    ? location.neighborhood
                    : value,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _CheckoutTextField(
            fieldKey: const Key('checkout-phone'),
            controller: phoneController,
            hintText: l10n.deliveryPhoneNumber,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onChanged: (value) => onChanged(location.copyWith(phone: value)),
          ),
        ],
      ),
    );
  }
}

class _DeliveryScheduleCard extends StatelessWidget {
  const _DeliveryScheduleCard({required this.value, required this.onChanged});

  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: value.isBefore(firstDate) ? firstDate : value,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 30)),
      helpText: AppLocalizations.of(context).checkoutDeliveryDate,
    );
    if (picked == null) {
      return;
    }
    onChanged(
      DateTime(picked.year, picked.month, picked.day, value.hour, value.minute),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
      helpText: AppLocalizations.of(context).checkoutDeliveryHour,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked == null) {
      return;
    }
    onChanged(
      DateTime(value.year, value.month, value.day, picked.hour, picked.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    return _CheckoutSectionCard(
      title: l10n.checkoutDeliveryTime,
      child: Column(
        children: [
          _SchedulePickerTile(
            fieldKey: const Key('checkout-delivery-date'),
            label: l10n.checkoutDeliveryDate,
            value: DateFormat.yMMMEd(locale).format(value),
            icon: Icons.calendar_month_rounded,
            onTap: () => _pickDate(context),
          ),
          const SizedBox(height: 12),
          _SchedulePickerTile(
            fieldKey: const Key('checkout-delivery-time'),
            label: l10n.checkoutDeliveryHour,
            value: DateFormat.Hm(locale).format(value),
            icon: Icons.schedule_rounded,
            onTap: () => _pickTime(context),
          ),
        ],
      ),
    );
  }
}

class _SchedulePickerTile extends StatelessWidget {
  const _SchedulePickerTile({
    required this.fieldKey,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final Key fieldKey;
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: fieldKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: InputDecorator(
          decoration: _fieldDecoration(context, icon: icon, hintText: label),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: HeynTextStyles.bodyMedium.copyWith(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                label,
                style: HeynTextStyles.caption.copyWith(
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.selected, required this.onSelected});

  final MobilePaymentMethod? selected;
  final ValueChanged<MobilePaymentMethod> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _CheckoutSectionCard(
      title: l10n.paymentMethodTitle,
      child: Column(
        children: [
          for (final method in MobilePaymentMethod.values) ...[
            _PaymentMethodTile(
              method: method,
              selected: selected == method,
              onTap: () => onSelected(method),
            ),
            if (method != MobilePaymentMethod.values.last)
              const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final MobilePaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subtitle = method == MobilePaymentMethod.cash
        ? l10n.checkoutPaymentCashOnDelivery
        : method.localizedDescription(l10n);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: Key('payment-${method.name}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 12, 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.lightTeal : AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              _WalletBrandIcon(method: method),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      method.localizedLabel(l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: HeynTextStyles.bodyMedium.copyWith(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: HeynTextStyles.caption.copyWith(
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.mutedText,
                    width: selected ? 6 : 2,
                  ),
                  color: AppColors.background,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutSectionCard extends StatelessWidget {
  const _CheckoutSectionCard({required this.child, this.title});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(
              title!,
              textAlign: TextAlign.end,
              style: HeynTextStyles.bodyMedium.copyWith(
                color: AppColors.darkText,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}

class _CheckoutTextField extends StatelessWidget {
  const _CheckoutTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.fieldKey,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.minLines = 1,
    this.maxLines = 1,
    this.textAlign = TextAlign.end,
  });

  final Key? fieldKey;
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int minLines;
  final int maxLines;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: fieldKey,
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      minLines: minLines,
      maxLines: maxLines,
      textAlign: textAlign,
      style: HeynTextStyles.bodyMedium.copyWith(
        color: AppColors.darkText,
        fontWeight: FontWeight.w600,
      ),
      decoration: _fieldDecoration(context, icon: icon, hintText: hintText),
    );
  }
}

InputDecoration _fieldDecoration(
  BuildContext context, {
  required IconData icon,
  String? hintText,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: HeynTextStyles.subtitle.copyWith(color: AppColors.mutedText),
    prefixIcon: Icon(icon, color: AppColors.primary, size: 21),
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
    ),
  );
}

class _WalletBrandIcon extends StatelessWidget {
  const _WalletBrandIcon({required this.method});

  final MobilePaymentMethod method;

  @override
  Widget build(BuildContext context) {
    final style = switch (method) {
      MobilePaymentMethod.bankily => (
        color: const Color(0xFFE87722),
        icon: Icons.account_balance_wallet_rounded,
      ),
      MobilePaymentMethod.masrivi => (
        color: const Color(0xFF128A4B),
        icon: Icons.account_balance_rounded,
      ),
      MobilePaymentMethod.sedad => (
        color: const Color(0xFF1B4F9C),
        icon: Icons.phone_iphone_rounded,
      ),
      MobilePaymentMethod.cash => (
        color: AppColors.primary,
        icon: Icons.payments_rounded,
      ),
    };

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: style.color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(style.icon, color: Colors.white, size: 24),
    );
  }
}

class _StickyConfirmButton extends StatelessWidget {
  const _StickyConfirmButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.scaffoldBackground,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 14, 20, 16),
          child: SizedBox(
            height: 64,
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: onPressed,
              icon: isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.background,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline_rounded, size: 21),
              label: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: HeynTextStyles.button.copyWith(
                  color: AppColors.background,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessMark extends StatelessWidget {
  const _SuccessMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: const BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.successBackground,
            blurRadius: 28,
            spreadRadius: 12,
          ),
        ],
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 50),
    );
  }
}

class _SuccessSummaryCard extends StatelessWidget {
  const _SuccessSummaryCard({
    required this.reference,
    required this.deliveryLabel,
    required this.totalLabel,
  });

  final String reference;
  final String deliveryLabel;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _SuccessInfoRow(
            icon: Icons.receipt_long_outlined,
            label: l10n.checkoutOrderNumber,
            value: reference,
          ),
          const SizedBox(height: 14),
          _SuccessInfoRow(
            icon: Icons.schedule_outlined,
            label: l10n.checkoutExpectedDelivery,
            value: deliveryLabel,
          ),
          const SizedBox(height: 14),
          _SuccessInfoRow(
            icon: Icons.payments_outlined,
            label: l10n.checkoutFinalAmount,
            value: totalLabel,
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class _SuccessInfoRow extends StatelessWidget {
  const _SuccessInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: HeynTextStyles.bodyMedium.copyWith(
              color: emphasized ? AppColors.primary : AppColors.darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: HeynTextStyles.subtitle.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, color: AppColors.secondaryText, size: 20),
      ],
    );
  }
}

class _DialogPrimaryButton extends StatelessWidget {
  const _DialogPrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 21),
        label: Text(label),
      ),
    );
  }
}

class _DialogSecondaryButton extends StatelessWidget {
  const _DialogSecondaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: AppColors.background,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 21),
        label: Text(label),
      ),
    );
  }
}
