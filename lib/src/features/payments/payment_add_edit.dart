import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/flush_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/deletion_dialog.dart';
import 'package:business_manager_web_ui/src/models/client_model.dart';
import 'package:business_manager_web_ui/src/models/client_statement.dart';
import 'package:business_manager_web_ui/src/models/payment_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/client_service.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/payment_service.dart';
import 'package:business_manager_web_ui/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../app/animations/loading_animation.dart';

class PaymentAddEdit extends StatefulWidget {
  const PaymentAddEdit({super.key, this.uid, this.paymentId});
  final String? uid;
  final String? paymentId;

  @override
  State<PaymentAddEdit> createState() => _PaymentAddEditState();
}

class _PaymentAddEditState extends State<PaymentAddEdit> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  DatabaseService db = DatabaseService();
  ErrorClass errorClass = ErrorClass();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  DeletionDialog deletionDialog = DeletionDialog();
  StorageService ss = StorageService();
  PaymentService ps = PaymentService();
  ClientService cs = ClientService();
  final ImagePicker imagePicker = ImagePicker();
  bool isLoading = false,
      isUpdating = false,
      isInitialized = false,
      enabled = false;
  TextEditingController clientNameController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  UserDetails? currentUser = UserDetails();
  Future<UserDetails>? getCurrentUser;
  Future<Payments>? getCurrentPayment;
  Payments? currentPayment;
  List<dynamic> images = [];
  final number = NumberFormat("#,##0.00", "en_US");
  String? clientId, status;
  List<ClientDetails> allClients = [];

  // Payment methods with icons
  final List<Map<String, dynamic>> paymentMethods = [
    {'label': 'Cash', 'icon': Icons.payments_outlined},
    {'label': 'Transfer', 'icon': Icons.swap_horiz_outlined},
    {'label': 'POS', 'icon': Icons.point_of_sale_outlined},
    {'label': 'Cheque', 'icon': Icons.edit_note_outlined},
    {'label': 'Mobile Money', 'icon': Icons.phone_android_outlined},
    {'label': 'Other', 'icon': Icons.more_horiz_outlined},
  ];
  String? selectedCategory;

  @override
  void didChangeDependencies() {
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
    snackbarWidget.context = context;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    if (widget.uid != null) getCurrentUser = fetchUser();
    if (widget.paymentId != null) getCurrentPayment = fetchPayment();
    valueController.addListener(_onValueChanged);
    super.initState();
  }

  @override
  void dispose() {
    clientNameController.dispose();
    valueController.dispose();
    super.dispose();
  }

  void _initializeData(Payments payment) {
    clientNameController.text = payment.clientName!;
    valueController.removeListener(_onValueChanged);
    valueController.text = payment.amount.toString();
    isInitialized = true;
    currentPayment = payment;
  }

  void _onValueChanged() => setState(() {});

  // ── Design helpers ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String text, {String? sub}) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: responsive!.scaleHeight(10),
        top: responsive!.scaleHeight(4),
      ),
      child: Row(
        children: [
          MyText(
            text: text.toUpperCase(),
            fontScale: responsive!.scaleFont(11),
            fontWeight: FontWeight.w500,
          ),
          if (sub != null) ...[
            const SizedBox(width: 6),
            MyText(text: sub, fontScale: responsive!.scaleFont(10)),
          ],
        ],
      ),
    );
  }

  Widget _groupCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
                Divider(
                  height: 0,
                  thickness: 0.5,
                  indent: responsive!.scaleWidth(14),
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: MyText(
              text: widget.paymentId == null
                  ? appLoc!.addPayment
                  : appLoc!.updatePayment,
              fontScale: responsive!.scaleFont(18),
              fontWeight: FontWeight.w500,
            ),
          ),
          body: Stack(
            children: [
              _buildPaymentViewBody(),
              if (isLoading)
                StreamBuilder<double>(
                  stream: Stream.periodic(
                    const Duration(milliseconds: 100),
                    (_) => ProgressManager.progress,
                  ),
                  builder: (context, progressshot) {
                    final progress = progressshot.data ?? 0.0;
                    return Center(
                      child: AnimatedArcLoader(
                        progress: progress,
                        size: 150,
                        fontSize: responsive!.scaleFont(15),
                        color: Colors.blueAccent,
                        showPercentage: true,
                        onTimeout: () {
                          setState(() => isLoading = false);
                          ProgressManager.stopLoading();
                          snackbarWidget.content = appLoc!.operationTimedOut;
                          snackbarWidget.showSnack();
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
          resizeToAvoidBottomInset: false,
        ),
      ),
    );
  }

  Widget _buildPaymentViewBody() {
    return FutureBuilder(
      future: getCurrentPayment,
      builder: (context, paymentshot) {
        if (paymentshot.hasError) {
          return Center(
            child: MyText(
              text: errorClass.paymentsNotLoading(
                  e: paymentshot.error.toString()),
            ),
          );
        }
        if (paymentshot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        }
        if (paymentshot.hasData && !isInitialized) {
          _initializeData(paymentshot.data!);
        }
        if (paymentshot.hasData && !isUpdating) isUpdating = true;

        return SingleChildScrollView(
          padding: responsive!.responsivePaddingM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Client ──────────────────────────────────────────────
              _sectionLabel(appLoc!.clientName),
              _groupCard(children: [clientNameTypeIn()]),

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Payment method ───────────────────────────────────────
              _sectionLabel(appLoc!.method),
              _buildMethodList(),

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Amount ───────────────────────────────────────────────
              _sectionLabel(appLoc!.value),
              _groupCard(children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(14),
                    vertical: responsive!.scaleHeight(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.monetization_on_outlined,
                        size: responsive!.scaleHeight(18),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: responsive!.scaleWidth(10)),
                      if (currentUser?.currency != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surface
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                          child: MyText(
                            text: currentUser!.currency!['symbol'] ?? '',
                            fontScale: responsive!.scaleFont(13),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      SizedBox(width: responsive!.scaleWidth(8)),
                      Expanded(
                        child: FlushTextField(
                          controller: valueController,
                          hintText: appLoc!.value,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          fontSize: responsive!.scaleFont(15),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),

              // ── Status banner ────────────────────────────────────────
              _buildStatusBanner(),

              // ── Due date ─────────────────────────────────────────────
              if (currentPayment?.dueDate != null) ...[
                _sectionLabel(appLoc!.dueOn),
                _groupCard(children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive!.scaleWidth(14),
                      vertical: responsive!.scaleHeight(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: responsive!.scaleHeight(18),
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: responsive!.scaleWidth(12)),
                        MyText(
                          text: DateFormat.yMMMd()
                              .format(currentPayment!.dueDate!),
                          fontScale: responsive!.scaleFont(14),
                          fontWeight: FontWeight.w500,
                        ),
                        const Spacer(),
                        // Status pill
                        if (currentPayment?.status != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: _statusBadgeColor(currentPayment!.status!),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: MyText(
                              text: currentPayment!.status!,
                              fontScale: responsive!.scaleFont(11),
                              fontWeight: FontWeight.w500,
                              fontColor:
                                  _statusTextColor(currentPayment!.status!),
                            ),
                          ),
                      ],
                    ),
                  ),
                ]),
                SizedBox(height: responsive!.scaleHeight(20)),
              ],

              // ── Proof images ─────────────────────────────────────────
              _sectionLabel(appLoc!.imagesOptional,
                  sub: '(${appLoc!.optional})'),
              _buildImagesSection(),

              SizedBox(height: responsive!.scaleHeight(28)),

              // ── Update button ────────────────────────────────────────
              GestureDetector(
                onTap: !isLoading ? updatePayment : null,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      vertical: responsive!.scaleHeight(15)),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: MyText(
                      text: appLoc!.update,
                      fontScale: responsive!.scaleFont(15),
                      fontWeight: FontWeight.w500,
                      fontColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),

              SizedBox(height: responsive!.scaleHeight(32)),
            ],
          ),
        );
      },
    );
  }

  // ── Payment method radio list ──────────────────────────────────────────────

  Widget _buildMethodList() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: paymentMethods.asMap().entries.map((entry) {
          final i = entry.key;
          final method = entry.value;
          final label = method['label'] as String;
          final icon = method['icon'] as IconData;
          final isSelected = selectedCategory == label;
          final isLast = i == paymentMethods.length - 1;

          return Column(
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  selectedCategory = label;
                  currentPayment = currentPayment?.copyWith(method: label);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  color: isSelected
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.06)
                      : Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(14),
                    vertical: responsive!.scaleHeight(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: responsive!.scaleHeight(18),
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: responsive!.scaleWidth(12)),
                      Expanded(
                        child: MyText(
                          text: label,
                          fontScale: responsive!.scaleFont(13),
                          fontColor: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .dividerColor
                                    .withValues(alpha: 0.5),
                            width: isSelected ? 0 : 0.5,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 12,
                                color: Theme.of(context).colorScheme.onPrimary,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 0,
                  thickness: 0.5,
                  indent: responsive!.scaleWidth(14),
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Status banner ──────────────────────────────────────────────────────────

  Widget _buildStatusBanner() {
    double? amountPaid;
    if (valueController.text.isNotEmpty) {
      amountPaid = double.tryParse(valueController.text.trim());
    }
    if (amountPaid == null || currentPayment == null) {
      return const SizedBox.shrink();
    }

    final double paid = amountPaid;
    final double currentAmount = currentPayment?.amount ?? 0;

    Color bg;
    Color iconColor;
    Color textColor;
    String message;
    IconData icon;

    if (paid < currentAmount) {
      final remaining = currentAmount - paid;
      bg = const Color(0xFFFAEEDA);
      iconColor = const Color(0xFF854F0B);
      textColor = const Color(0xFF633806);
      icon = Icons.info_outline_rounded;
      message = appLoc!.partialPayment(remaining);
    } else if (paid > currentAmount) {
      final additional = paid - currentAmount;
      bg = const Color(0xFFFCEBEB);
      iconColor = const Color(0xFFA32D2D);
      textColor = const Color(0xFF791F1F);
      icon = Icons.warning_amber_outlined;
      message = appLoc!.paymentOverpaid(additional);
    } else {
      bg = const Color(0xFFEAF3DE);
      iconColor = const Color(0xFF3B6D11);
      textColor = const Color(0xFF27500A);
      icon = Icons.check_circle_outline_rounded;
      message = appLoc!.paymentCovered;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: responsive!.scaleHeight(20)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive!.scaleWidth(14),
          vertical: responsive!.scaleHeight(12),
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: responsive!.scaleHeight(18), color: iconColor),
            SizedBox(width: responsive!.scaleWidth(10)),
            Expanded(
              child: MyText(
                text: message,
                fontScale: responsive!.scaleFont(13),
                fontWeight: FontWeight.w500,
                fontColor: textColor,
                softWrap: true,
                optimalSizeEnabled: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Status badge helpers ───────────────────────────────────────────────────

  Color _statusBadgeColor(String status) {
    switch (status) {
      case 'Paid':
        return const Color(0xFFEAF3DE);
      case 'Partial Payment':
        return const Color(0xFFFAEEDA);
      case 'Overpaid':
        return const Color(0xFFFCEBEB);
      default:
        return const Color(0xFFFAEEDA);
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'Paid':
        return const Color(0xFF27500A);
      case 'Partial Payment':
        return const Color(0xFF633806);
      case 'Overpaid':
        return const Color(0xFF791F1F);
      default:
        return const Color(0xFF633806);
    }
  }

  // ── Images section ─────────────────────────────────────────────────────────

  Widget _buildImagesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(responsive!.scaleWidth(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: responsive!.scaleHeight(72),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...images.asMap().entries.map((entry) {
                  final index = entry.key;
                  final image = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(right: responsive!.scaleWidth(8)),
                    child: GestureDetector(
                      onLongPress: () => _removeImage(index),
                      onTap: _addImage,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: responsive!.scaleHeight(72),
                          height: responsive!.scaleHeight(72),
                          // Same XFile-or-network-URL Image.network pattern
                          // established in Expenses/Assets — XFile.path is a
                          // blob: URL Image.network can load directly on web.
                          child: Image.network(
                            image is XFile ? image.path : image,
                            fit: BoxFit.cover,
                            loadingBuilder:
                                (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Theme.of(context).colorScheme.surface,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.broken_image,
                                  color: Colors.grey[500]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                if (images.length < 4)
                  GestureDetector(
                    onTap: _addImage,
                    child: Container(
                      width: responsive!.scaleHeight(72),
                      height: responsive!.scaleHeight(72),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.4),
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        size: responsive!.scaleHeight(24),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (images.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: responsive!.scaleHeight(8)),
              child: MyText(
                text: appLoc!.longPressToRemove,
                fontScale: responsive!.scaleFont(11),
              ),
            ),
        ],
      ),
    );
  }

  // ── Client name typeahead / readonly — logic unchanged ─────────────────────

  Widget clientNameTypeIn() {
    if (widget.paymentId != null) {
      enabled = false;
    } else {
      enabled = true;
    }

    if (!enabled) {
      // Read-only display
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsive!.scaleWidth(14),
          vertical: responsive!.scaleHeight(14),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: responsive!.scaleHeight(18),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: responsive!.scaleWidth(12)),
            Expanded(
              child: MyText(
                text: clientNameController.text,
                fontScale: responsive!.scaleFont(14),
                fontWeight: FontWeight.w500,
                softWrap: true,
                textOverflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    // Typeahead for new payment
    return StreamBuilder<List<ClientDetails>>(
      stream: cs.streamAllClients(widget.uid!),
      builder: (context, clientshot) {
        if (clientshot.hasData) allClients = clientshot.data!;
        return TypeAheadField<ClientDetails>(
          autoFlipDirection: true,
          controller: clientNameController,
          emptyBuilder: (context) => Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive!.scaleWidth(14),
              vertical: responsive!.scaleHeight(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: MyText(
                    text: appLoc!.noClientsFound,
                    fontScale: responsive!.scaleFont(13),
                  ),
                ),
                GestureDetector(
                  onTap: () => GoRouter.of(context).pushNamed('addClient',
                      pathParameters: {'uid': widget.uid!}),
                  child: Icon(Icons.add_circle_outline,
                      size: responsive!.scaleHeight(22),
                      color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
          decorationBuilder: (context, child) => Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            type: MaterialType.card,
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            child: child,
          ),
          builder: (context, controller, focusNode) {
            return Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: responsive!.scaleWidth(14)),
                  child: Icon(
                    Icons.search,
                    size: responsive!.scaleHeight(18),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    style: TextStyle(fontSize: responsive!.scaleFont(13)),
                    decoration: InputDecoration(
                      hintText: appLoc!.clientName,
                      hintStyle: TextStyle(
                          fontSize: responsive!.scaleFont(13),
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: responsive!.scaleWidth(10),
                        vertical: responsive!.scaleHeight(14),
                      ),
                      suffixIcon: controller.text.isNotEmpty
                          ? IconButton(
                              onPressed: () =>
                                  setState(() => controller.clear()),
                              icon: Icon(Icons.clear,
                                  size: responsive!.scaleHeight(16)),
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            );
          },
          itemBuilder: (context, value) => Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive!.scaleWidth(14),
              vertical: responsive!.scaleHeight(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: value.individual!
                      ? '${value.firstName} ${value.lastName}'
                      : value.companyName!,
                  fontScale: responsive!.scaleFont(13),
                  fontWeight: FontWeight.w500,
                ),
                MyText(
                  text:
                      '(${value.phoneNumber!['code']}) ${value.phoneNumber!['number']}  ·  ${value.email ?? ''}',
                  fontScale: responsive!.scaleFont(11),
                ),
              ],
            ),
          ),
          onSelected: (ClientDetails? value) {
            setState(() {
              clientNameController.text = value!.individual!
                  ? '${value.firstName} ${value.lastName}'
                  : value.companyName!;
              clientId = value.uid;
            });
          },
          suggestionsCallback: getClientSuggestions,
        );
      },
    );
  }

  // ── Logic — completely unchanged (except image upload, see below) ─────────

  Future<UserDetails> fetchUser() async {
    var result = await db.getCurrentUser(uid: widget.uid);
    currentUser = result;
    return result;
  }

  Future<Payments> fetchPayment() async =>
      ps.futureSinglePayment(widget.uid, widget.paymentId);

  // Mobile picks camera-vs-gallery via a bottom sheet, then platform-branches
  // on dart:io Platform.isIOS/isAndroid for the actual picker call — none of
  // that applies on web. Goes straight to the browser's file picker
  // (image_picker's web implementation), same pattern as Gallery/Account
  // Settings/Contact Us/Expenses/Assets.
  Future<void> _addImage() async {
    List<XFile> selectedImages;
    try {
      selectedImages = await imagePicker.pickMultiImage();
    } catch (error) {
      snackbarWidget.content = error.toString();
      snackbarWidget.showSnack();
      return;
    }
    if (selectedImages.isEmpty) {
      snackbarWidget.content = appLoc!.imageNotSelected;
      snackbarWidget.showSnack();
      return;
    }
    int currentCount = images.length;
    setState(() => isLoading = true);
    int remainingSlots = 4 - currentCount;
    if (selectedImages.length > remainingSlots) {
      images.addAll(selectedImages.take(remainingSlots));
      snackbarWidget.content = appLoc!.imageLimit4(currentCount);
      snackbarWidget.showSnack();
    } else {
      images.addAll(selectedImages);
    }
    setState(() => isLoading = false);
  }

  Future<void> _removeImage(int index) async {
    try {
      if (images.isNotEmpty) {
        var delete = await deletionDialog.showDeletionDialog(context, appLoc!);
        if (delete) {
          setState(() => isLoading = true);
          ProgressManager.startLoading(
            onTimeout: () {
              if (mounted) {
                setState(() => isLoading = false);
                snackbarWidget.content = appLoc!.operationTimedOut;
                snackbarWidget.showSnack();
              }
            },
            timeoutDuration: const Duration(seconds: 30),
          );
          if (images[index] is XFile) {
            images.removeAt(index);
          } else {
            await ss.deleteItemFromStorage(
                url: images[index],
                uid: widget.uid,
                folder: '${widget.uid}/expenses');
            images.removeAt(index);
            currentPayment!.images = images;
            await ps.setPayment(uid: widget.uid, payment: currentPayment);
            ProgressManager.completeLoading();
          }
          setState(() => isLoading = false);
        }
      }
    } on Exception catch (e) {
      ProgressManager.stopLoading();
      snackbarWidget.content = '${appLoc!.errorRemovingImage} ${e.toString()}';
      snackbarWidget.showSnack();
    }
  }

  Future<void> updatePayment() async {
    if (widget.paymentId == null) {
      snackbarWidget.content = appLoc!.dataNotLoading;
      snackbarWidget.showSnack();
      return;
    }
    List<String> imageUrls = [];
    if (clientNameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.nameRequired;
      snackbarWidget.showSnack();
      return;
    }
    if (valueController.text.isEmpty) {
      snackbarWidget.content = appLoc!.valueRequired;
      snackbarWidget.showSnack();
      return;
    }

    final double? amount = double.tryParse(valueController.text);
    final double currentAmount = currentPayment?.amount ?? 0;
    if (amount != null) {
      if (amount < currentAmount) {
        status = 'Partial Payment';
      } else if (amount == currentAmount) {
        status = 'Paid';
      } else if (amount > currentAmount) {
        status = 'Overpaid';
      } else {
        status = 'Pending';
      }
    }

    setState(() => isLoading = true);
    ProgressManager.startLoading(
      onTimeout: () {
        if (mounted) {
          setState(() => isLoading = false);
          snackbarWidget.content = appLoc!.operationTimedOut;
          snackbarWidget.showSnack();
        }
      },
      timeoutDuration: const Duration(seconds: 30),
    );

    try {
      if (images.isNotEmpty) {
        for (var image in images) {
          if (image is XFile) {
            final bytes = await image.readAsBytes();
            var result = await ss.uploadImageToStorage(
                bytes: bytes,
                fileName: image.name,
                folderName: '${widget.uid}/expenses');
            if (result.isNotEmpty) imageUrls.add(result);
          } else {
            imageUrls.add(image);
          }
        }
      }
      currentPayment = currentPayment?.copyWith(
        clientName: clientNameController.text.trim(),
        amount: double.tryParse(valueController.text.trim()),
        images: imageUrls,
        paidOn: DateTime.now(),
        method: selectedCategory,
        status: status,
      );

      StatementRecord statementRecord = StatementRecord(
        recordId: currentPayment?.uid,
        entryDate: DateTime.now(),
        type: 'credit',
        value: double.tryParse(valueController.text.trim()),
      );

      await cs.setRecord(
        uid: widget.uid,
        clientId: currentPayment?.clientId,
        record: statementRecord,
      );

      await ps.setPayment(uid: widget.uid, payment: currentPayment!);
      ProgressManager.completeLoading();
      if (mounted) {
        setState(() => isLoading = false);
        GoRouter.of(context).pop();
      }
    } on Exception catch (e) {
      ProgressManager.stopLoading();
      snackbarWidget.content = e.toString();
      snackbarWidget.showSnack();
    } finally {
      setState(() {
        isLoading = false;
        if (ProgressManager.isLoading && !ProgressManager.isCompleted) {
          ProgressManager.stopLoading();
        }
      });
    }
  }

  Future<List<ClientDetails>> getClientSuggestions(String search) async {
    List<ClientDetails> matches = [];
    String lowerCase = search.toLowerCase();
    List<String> queries =
        lowerCase.contains(' ') ? lowerCase.split(' ') : [lowerCase];
    for (var client in allClients) {
      bool match = queries.every((queryWord) =>
          client.firstName!.toLowerCase().contains(queryWord) ||
          client.lastName != null &&
              client.lastName!.toLowerCase().contains(queryWord) ||
          client.companyName != null &&
              client.companyName!.toLowerCase().contains(queryWord) ||
          client.phoneNumber != null &&
              client.phoneNumber!['number']!.contains(queryWord) ||
          client.email != null &&
              client.email!.toLowerCase().contains(queryWord));
      if (match) matches.add(client);
    }
    return matches;
  }
}
