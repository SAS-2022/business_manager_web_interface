import 'dart:math';
import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/linear_animation.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/app_constants.dart';
import 'package:business_manager_web_ui/src/app/constants/dimensions.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/utils/components/url_launcher_func.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/regular_button.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/product_info_dialog.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/yes_and_no.dart';
import 'package:business_manager_web_ui/src/models/client_model.dart';
import 'package:business_manager_web_ui/src/models/order_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/client_service.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/order_service.dart';
import 'package:business_manager_web_ui/src/services/error_logging_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/theme/responsive_utils.dart';
import '../../models/product_model.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';

class OrderAddEdit extends StatefulWidget {
  const OrderAddEdit({super.key, this.uid, this.orderId, this.clientId});
  final String? uid;
  final String? orderId;
  final String? clientId;

  @override
  State<OrderAddEdit> createState() => _OrderAddEditState();
}

class _OrderAddEditState extends State<OrderAddEdit> {
  // ── All variables — completely unchanged ───────────────────────────────────
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  ErrorClass errorClass = ErrorClass();
  DatabaseService db = DatabaseService();
  AuthService as = AuthService();
  OrderService os = OrderService();
  ClientService cs = ClientService();
  ProductService ps = ProductService();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  ProductInfoDialog infoDialog = ProductInfoDialog();
  YesAndNoDialog yesNoDialog = YesAndNoDialog();
  UrlLauncherFunc urlLaunch = UrlLauncherFunc();
  PaymentTerms pt = PaymentTerms();
  ConstantStrings constStrings = ConstantStrings();
  bool isLoading = false,
      isIndividual = true,
      isUpdating = false,
      enabled = true,
      useInventory = false,
      _isAddingProduct = false;
  TextEditingController clientNameController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  final ValueNotifier<double> _valueNotifier = ValueNotifier(0.0);
  List<ClientDetails> allClients = [];
  List<Product> allProducts = [];
  ClientDetails? selectedClient = ClientDetails();
  Map<String, OrderProducts>? selectedProduct = {};
  String? phoneCode, phoneCountry, inventoryLocation;
  Orders order = Orders();
  Future<Orders>? getCurrentOrder;
  Future<Orders>? getLastOrder;
  Future<UserDetails>? getCurrentUser;
  Future<ClientDetails>? getCurrentClient;
  UserDetails? currentUser = UserDetails();
  double? orderTotalValue = 0;
  final number = NumberFormat("#,##0.00", "en_US");

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
    if (widget.orderId != null) {
      getCurrentOrder = fetchOrder();
    } else {
      getLastOrder = fetchLastOrderId();
    }
    if (widget.clientId != null) getCurrentClient = fetchClient();
    super.initState();
  }

  @override
  void dispose() {
    clientNameController.dispose();
    productNameController.dispose();
    _valueNotifier.dispose();
    snackbarWidget.clear();
    super.dispose();
  }

  // ── Design helpers ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: responsive!.scaleHeight(10),
        top: responsive!.scaleHeight(4),
      ),
      child: MyText(
        text: text.toUpperCase(),
        fontScale: responsive!.scaleFont(11),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // Wraps any child widget in a styled card background
  Widget _cardWrap(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  // Read-only info row — used when enabled=false
  Widget _readOnlyRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(14),
        vertical: responsive!.scaleHeight(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: responsive!.scaleHeight(18),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: responsive!.scaleWidth(12)),
          Expanded(
            child: MyText(
              text: '$label: $value',
              fontScale: responsive!.scaleFont(14),
              softWrap: true,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: PopScope(
          onPopInvokedWithResult: (bool didPop, String? result) async {
            if (didPop) {
              snackbarWidget.clear();
              await Future.delayed(const Duration(milliseconds: 650));
            }
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: MyText(
                text: widget.orderId == null
                    ? appLoc!.addOrder
                    : appLoc!.editOrder,
                fontScale: responsive!.scaleFont(18),
                fontWeight: FontWeight.w500,
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.next_plan_rounded,
                    size: responsive!.scaleHeight(26),
                  ),
                  onPressed: () =>
                      widget.orderId == null ? addOrder() : updateOrder(),
                ),
              ],
            ),
            body: Stack(
              children: [
                FutureBuilder<UserDetails>(
                  future: getCurrentUser,
                  builder: (context, usershot) {
                    if (usershot.hasError) {
                      return Center(
                        child: MyText(
                          text: errorClass.userNoTFoundError(
                            e: usershot.error.toString(),
                          ),
                        ),
                      );
                    } else if (usershot.connectionState ==
                        ConnectionState.waiting) {
                      return const GradientSkeleton();
                    } else if (usershot.hasData) {
                      currentUser = usershot.data;
                      if (currentUser != null &&
                          currentUser!.isSubscribed != null &&
                          currentUser!.isSubscribed! &&
                          currentUser?.useInventory != null &&
                          currentUser!.useInventory!) {
                        useInventory = true;
                      }
                    }
                    return _buildOrderViewBody();
                  },
                ),
                if (isLoading)
                  StreamBuilder<double>(
                    stream: Stream.periodic(
                      const Duration(milliseconds: 100),
                      (_) => ProgressManager.progress,
                    ),
                    builder: (context, progressshot) {
                      double progress = progressshot.data ?? 0.0;
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
            bottomSheet: bottomSheet(),
          ),
        ),
      ),
    );
  }

  // ── Order view body ────────────────────────────────────────────────────────

  Widget _buildOrderViewBody() {
    return FutureBuilder(
      future: widget.orderId != null ? getCurrentOrder : getLastOrder,
      builder: (context, ordershot) {
        if (ordershot.hasError) {
          return Center(child: MyText(text: errorClass.ordersNotLoading()));
        } else if (ordershot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        } else {
          if (ordershot.hasData && !isUpdating) isUpdating = true;
          if (ordershot.hasData && ordershot.data!.invoiceUrl != null) {
            enabled = false;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: responsive!.scaleWidth(16),
              right: responsive!.scaleWidth(16),
              top: responsive!.scaleHeight(12),
              bottom: responsive!.scaleHeight(70),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppDimensions.maxGridContentWidth,
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Order ID bar ────────────────────────────
                        if (ordershot.data != null)
                          _buildOrderIdBar(ordershot.data!),

                        // ── Client ────────────────────────────────────
                        _sectionLabel(appLoc!.clientName),
                        clientNameTypeIn(),

                        SizedBox(height: responsive!.scaleHeight(20)),

                        // ── Payment terms ────────────────────────────
                        _sectionLabel(appLoc!.paymentTerms),
                        paymentTermsWidget(),

                        SizedBox(height: responsive!.scaleHeight(20)),

                        // ── Inventory location (conditional) ─────────
                        if (useInventory) ...[
                          _sectionLabel(appLoc!.selectLocation),
                          showInventoryOption(),
                          SizedBox(height: responsive!.scaleHeight(20)),
                        ],

                        // ── Products ──────────────────────────────────
                        _sectionLabel(appLoc!.product),
                        productDetails(),
                      ],
                    ),

                    // Cancelled overlay — unchanged
                    if (widget.orderId != null && order.status == 'canceled')
                      Positioned(
                        top: responsive!.scaleHeight(50),
                        left: responsive!.scaleWidth(50),
                        child: Transform(
                          transform: Matrix4.rotationZ(-25 * (pi / 180)),
                          alignment: Alignment.center,
                          child: Container(
                            width: responsive!.scaleWidth(160),
                            height: responsive!.scaleHeight(70),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.red, width: 2),
                            ),
                            child: Center(
                              child: MyText(
                                text: order.status == 'canceled'
                                    ? appLoc!.cancelled.toUpperCase()
                                    : '',
                                fontColor: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontScale: responsive!.scaleFont(40),
                              ),
                            ),
                          ),
                        ),
                      ),

                    if (ordershot.data?.status == constStrings.cancel)
                      Center(child: _buildCancelledWidget()),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  // ── Order ID bar ───────────────────────────────────────────────────────────

  Widget _buildOrderIdBar(Orders orderData) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive!.scaleHeight(16)),
      child: Row(
        children: [
          // Order ID pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: MyText(
              text: '${appLoc!.id}: ${orderData.uid}',
              fontScale: responsive!.scaleFont(12),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: responsive!.scaleWidth(8)),

          // Inventory update badge
          if (currentUser?.useInventory != null && currentUser!.useInventory!)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: MyText(
                text: '${appLoc!.update} ${appLoc!.inventory}',
                fontScale: responsive!.scaleFont(10),
                fontWeight: FontWeight.w500,
                fontColor: Theme.of(context).colorScheme.primary,
              ),
            ),

          const Spacer(),

          // Invoice download button — same logic, restyled
          if (!enabled)
            GestureDetector(
              onTap: () async {
                downloadandLaunch();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFB3D8A0),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.download_outlined,
                      size: responsive!.scaleHeight(13),
                      color: const Color(0xFF27500A),
                    ),
                    SizedBox(width: responsive!.scaleWidth(4)),
                    MyText(
                      text: appLoc!.invoiced,
                      fontScale: responsive!.scaleFont(11),
                      fontWeight: FontWeight.w500,
                      fontColor: const Color(0xFF27500A),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Client name typeahead — LOGIC UNCHANGED, only container restyled ───────

  Widget clientNameTypeIn() {
    return enabled
        ? _cardWrap(
            StreamBuilder<List<ClientDetails>>(
              stream: cs.streamAllClients(widget.uid!),
              builder: (context, clientshot) {
                if (clientshot.hasData) allClients = clientshot.data!;
                return Padding(
                  padding: responsive!.responsivePaddingES,
                  child: TypeAheadField<ClientDetails>(
                    autoFlipDirection: true,
                    controller: clientNameController,
                    emptyBuilder: (context) {
                      return Padding(
                        padding: responsive!.responsivePaddingM,
                        child: Row(
                          children: [
                            MyText(text: appLoc!.noClientsFound),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => GoRouter.of(context).pushNamed(
                                'addClient',
                                pathParameters: {'uid': widget.uid!},
                              ),
                              child: Icon(
                                Icons.add_circle,
                                size: responsive!.scaleHeight(25),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    decorationBuilder: (context, child) => Material(
                      color: Theme.of(context).colorScheme.secondary,
                      type: MaterialType.card,
                      elevation: 4,
                      borderRadius: BorderRadius.circular(5),
                      child: child,
                    ),
                    builder: (context, controller, focusNode) {
                      if (widget.clientId != null) {
                        order.clientId = widget.clientId;
                        return clientInfo(controller, focusNode);
                      }
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        style: TextStyle(fontSize: responsive!.scaleFont(15)),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: appLoc!.clientName,
                          suffixIcon: controller.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () =>
                                      setState(() => controller.clear()),
                                  child: Icon(
                                    Icons.clear,
                                    size: responsive!.screenHeight * 0.025,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      );
                    },
                    itemBuilder: (context, value) {
                      return ListTile(
                        title: MyText(
                          text:
                              '${value.individual!
                                  ? '${value.firstName} ${value.lastName}'
                                  : value.companyName != null && value.companyName!.length > 35
                                  ? '${value.companyName!.substring(0, 35)}...'
                                  : value.companyName}',
                          fontScale: responsive!.scaleFont(15),
                        ),
                        subtitle: MyText(
                          text:
                              '(${value.phoneNumber!['code']}) ${value.phoneNumber!['number']} - ${value.email}',
                          fontScale: responsive!.scaleFont(12),
                        ),
                      );
                    },
                    onSelected: (ClientDetails? value) {
                      if (value != null && value.uid != null) {
                        selectedClient = value;
                        clientNameController.text =
                            '${value.individual! ? '${value.firstName} ${value.lastName}' : value.companyName}';
                        order.clientId = value.uid;
                        order.clientName = value.individual!
                            ? '${value.firstName} ${value.lastName}'
                            : value.companyName;
                      } else {
                        selectedClient = null;
                        clientNameController.clear();
                        order.clientId = null;
                        order.clientName = null;
                      }
                    },
                    suggestionsCallback: getClientSuggestions,
                  ),
                );
              },
            ),
          )
        : _readOnlyRow(
            icon: Icons.person_outline_rounded,
            label: appLoc!.clientName,
            value: order.clientName.toString(),
          );
  }

  // ── Payment terms — LOGIC UNCHANGED, only container restyled ──────────────

  Widget paymentTermsWidget() {
    return enabled
        ? _cardWrap(
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive!.scaleWidth(4),
                vertical: responsive!.scaleHeight(2),
              ),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: order.paymentTerms ?? 'Cash',
                decoration: InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(10),
                    vertical: responsive!.scaleHeight(10),
                  ),
                ),
                elevation: 2,
                borderRadius: BorderRadius.circular(10),
                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                items: pt.paymentTerms.map<DropdownMenuItem<String>>((data) {
                  return DropdownMenuItem<String>(
                    value: data,
                    child: MyText(
                      text: data,
                      fontScale: responsive!.scaleFont(13),
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => order.paymentTerms = value);
                  }
                },
              ),
            ),
          )
        : _readOnlyRow(
            icon: Icons.receipt_outlined,
            label: appLoc!.paymentTerms,
            value: order.paymentTerms.toString(),
          );
  }

  // ── Inventory — LOGIC UNCHANGED, only container restyled ──────────────────

  Widget showInventoryOption() {
    return enabled
        ? _cardWrap(
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive!.scaleWidth(4),
                vertical: responsive!.scaleHeight(2),
              ),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: order.storeLocation,
                hint: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(10),
                  ),
                  child: MyText(
                    text: appLoc!.selectLocation,
                    fontScale: responsive!.scaleFont(13),
                  ),
                ),
                decoration: InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(10),
                    vertical: responsive!.scaleHeight(10),
                  ),
                ),
                elevation: 2,
                borderRadius: BorderRadius.circular(10),
                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                items: currentUser?.inventoryLoc?.entries
                    .map<DropdownMenuItem<String>>((data) {
                      return DropdownMenuItem<String>(
                        value: data.value,
                        child: MyText(
                          text: data.value,
                          fontScale: responsive!.scaleFont(13),
                        ),
                      );
                    })
                    .toList(),
                onChanged:
                    selectedProduct != null && selectedProduct!.isNotEmpty
                    ? null
                    : (String? value) {
                        if (value != null) {
                          setState(() {
                            order.storeLocation = value;
                            inventoryLocation = value;
                          });
                        }
                      },
              ),
            ),
          )
        : _readOnlyRow(
            icon: Icons.map_outlined,
            label: appLoc!.inventory,
            value: order.storeLocation.toString(),
          );
  }

  // ── Product details — LOGIC UNCHANGED, ListTile restyled ──────────────────

  Widget productDetails() {
    return SingleChildScrollView(
      child: Padding(
        padding: responsive!.responsivePaddingLBottom,
        child: Stack(
          children: [
            Column(
              children: [
                // Added products
                if (selectedProduct != null && selectedProduct!.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(
                      bottom: responsive!.scaleHeight(12),
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.3),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: selectedProduct!.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 0,
                        thickness: 0.5,
                        indent: responsive!.scaleWidth(14),
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.25),
                      ),
                      itemBuilder: (context, index) {
                        var p = selectedProduct!.entries.elementAt(index).value;
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive!.scaleWidth(14),
                            vertical: responsive!.scaleHeight(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                      text: p.name!.length > 30
                                          ? '${p.name!.substring(0, 30)}…'
                                          : p.name!,
                                      fontWeight: FontWeight.w500,
                                      softWrap: true,
                                      fontScale: responsive!.scaleFont(13),
                                    ),
                                    SizedBox(
                                      height: responsive!.scaleHeight(2),
                                    ),
                                    MyText(
                                      text:
                                          '${p.packing ?? ''}  ·  ${currentUser?.currency?['symbol'] ?? ''}${number.format(p.price)}',
                                      fontScale: responsive!.scaleFont(11),
                                    ),
                                    if (p.quantity! > 0)
                                      MyText(
                                        text:
                                            '${appLoc!.quantity}: ${p.quantity}  ·  ${appLoc!.discount}: ${p.discount ?? 0}%',
                                        fontScale: responsive!.scaleFont(11),
                                      ),
                                  ],
                                ),
                              ),
                              if (enabled) ...[
                                SizedBox(width: responsive!.scaleWidth(8)),
                                // Settings button
                                GestureDetector(
                                  onTap: () {
                                    infoDialog.show(
                                      context,
                                      responsive!,
                                      appLoc!,
                                      order.storeLocation ?? '',
                                      selectedProduct!.entries
                                          .elementAt(index)
                                          .value,
                                      (OrderProducts product) {
                                        setState(() {
                                          selectedProduct![selectedProduct!.keys
                                                  .elementAt(index)] =
                                              product;
                                        });
                                      },
                                      currentUser!,
                                      false,
                                    );
                                  },
                                  child: Container(
                                    width: responsive!.scaleWidth(32),
                                    height: responsive!.scaleHeight(32),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).dividerColor.withValues(alpha: 0.3),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.tune_outlined,
                                      size: responsive!.scaleHeight(15),
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                SizedBox(width: responsive!.scaleWidth(6)),
                                // Remove button
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedProduct!.remove(
                                        selectedProduct!.keys.elementAt(index),
                                      );
                                    });
                                  },
                                  child: Container(
                                    width: responsive!.scaleWidth(32),
                                    height: responsive!.scaleHeight(32),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.error
                                          .withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      size: responsive!.scaleHeight(15),
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                // Product typeahead — LOGIC COMPLETELY UNCHANGED
                if (enabled)
                  Padding(
                    padding: responsive!.responsivePaddingBottom,
                    child: StreamBuilder<List<Product>>(
                      stream: ps.getAllUserProducts(widget.uid!),
                      builder: (context, productshot) {
                        if (productshot.hasData) {
                          allProducts = productshot.data!;
                        }
                        return TypeAheadField<Product>(
                          autoFlipDirection: true,
                          controller: productNameController,
                          emptyBuilder: (context) {
                            return Padding(
                              padding: responsive!.responsivePaddingM,
                              child: Row(
                                children: [
                                  MyText(text: appLoc!.noProductFound),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => GoRouter.of(context).pushNamed(
                                      'addProduct',
                                      pathParameters: {'uid': widget.uid!},
                                    ),
                                    child: Icon(
                                      Icons.add_circle,
                                      size: responsive!.scaleHeight(25),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          decorationBuilder: (context, child) => Material(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            type: MaterialType.card,
                            elevation: 4,
                            borderRadius: BorderRadius.circular(5),
                            child: child,
                          ),
                          builder: (context, controller, focusNode) {
                            return MyTextField(
                              controller: controller,
                              focusNode: focusNode,
                              hintText: appLoc!.productName,
                              capitalize: TextCapitalization.words,
                              fontSize: responsive!.scaleFont(15),
                            );
                          },
                          itemBuilder: (context, value) {
                            bool added =
                                selectedProduct != null &&
                                selectedProduct!.isNotEmpty &&
                                selectedProduct!.containsKey(value.id);
                            return ListTile(
                              tileColor: added
                                  ? Theme.of(context).colorScheme.outline
                                  : Theme.of(context).scaffoldBackgroundColor,
                              title: MyText(
                                text: value.name,
                                fontScale: responsive!.scaleFont(15),
                              ),
                              subtitle: MyText(
                                text:
                                    '${value.packingValue} ${value.packingUnit} - ${currentUser?.currency!['symbol']}${value.price}',
                                fontScale: responsive!.scaleFont(12),
                              ),
                              trailing: IconButton(
                                onPressed: () => _addProductToSelection(value),
                                icon: Icon(
                                  Icons.add_circle,
                                  size: responsive!.scaleHeight(25),
                                ),
                              ),
                            );
                          },
                          onSelected: (Product? value) =>
                              _addProductToSelection(value!),
                          suggestionsCallback: getProductSuggestions,
                        );
                      },
                    ),
                  ),
              ],
            ),
            if (_isAddingProduct)
              Center(
                child: AnimatedBlockLoader(
                  size: responsive!.scaleHeight(100),
                  color: Theme.of(context).colorScheme.surface,
                  animationType: BlockAnimationType.rotate,
                  showPercentage: true,
                  timeoutDuration: const Duration(seconds: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Bottom sheet — same ValueNotifier logic, restyled ─────────────────────

  Widget bottomSheet() {
    orderTotalValue = 0;
    for (var product in selectedProduct!.values) {
      double productValue = product.price! * product.quantity!;
      orderTotalValue = (orderTotalValue ?? 0) + productValue;
    }
    _valueNotifier.value = orderTotalValue!;
    return ValueListenableBuilder<double>(
      valueListenable: _valueNotifier,
      builder: (context, value, child) {
        return Container(
          height: responsive!.scaleHeight(56),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Padding(
            padding: responsive!.responsivePaddingHor,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyText(
                  text: appLoc!.totalValue,
                  fontScale: responsive!.scaleFont(14),
                ),
                const Spacer(),
                MyText(
                  text:
                      '${currentUser?.currency != null ? currentUser?.currency!['symbol'] : ''}${number.format(value)}',
                  fontScale: responsive!.scaleFont(18),
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── _buildCancelledWidget — RegulartButton kept, restyled ─────────────────

  Widget _buildCancelledWidget() {
    return Column(
      children: [
        SizedBox(height: responsive!.scaleHeight(50)),
        Transform(
          transform: Matrix4.rotationZ(-25 * (pi / 180)),
          alignment: Alignment.center,
          child: Container(
            height: responsive!.scaleHeight(100),
            width: responsive!.scaleWidth(250),
            decoration: BoxDecoration(border: Border.all(color: Colors.red)),
            child: Center(
              child: MyText(
                text: appLoc!.cancelled,
                fontScale: responsive!.scaleFont(34, maxSize: 34),
                fontColor: Colors.red,
                fontWeight: FontWeight.bold,
                align: TextAlign.center,
              ),
            ),
          ),
        ),
        SizedBox(height: responsive!.scaleHeight(100)),
        GestureDetector(
          onTap: () async => await reactivateOrder(order, constStrings.active),
          child: RegulartButton(
            text: appLoc!.reactivate,
            textColor: Theme.of(context).colorScheme.secondary,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  // ── clientInfo — LOGIC UNCHANGED ──────────────────────────────────────────

  Widget clientInfo(TextEditingController controller, FocusNode focusNode) {
    return FutureBuilder(
      future: getCurrentClient,
      builder: (context, clientshot) {
        if (clientshot.hasError) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            style: TextStyle(fontSize: responsive!.scaleFont(15)),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: appLoc!.supplierName,
              suffixIcon: controller.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () => setState(() => controller.clear()),
                      child: Icon(
                        Icons.clear,
                        size: responsive!.screenHeight * 0.025,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          );
        } else if (clientshot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        } else {
          controller = TextEditingController(
            text: clientshot.data?.individual == true
                ? '${clientshot.data?.firstName} ${clientshot.data?.lastName}'
                : clientshot.data?.companyName != null &&
                      clientshot.data!.companyName!.length > 35
                ? '${clientshot.data?.companyName!.substring(0, 35)}...'
                : clientshot.data?.companyName!,
          );
          return TextField(
            controller: controller,
            focusNode: focusNode,
            style: TextStyle(fontSize: responsive!.scaleFont(15)),
            decoration: InputDecoration(
              enabled: false,
              border: InputBorder.none,
              hintText: appLoc!.supplierName,
            ),
          );
        }
      },
    );
  }

  // ── All logic methods — byte-for-byte unchanged ────────────────────────────

  Future<UserDetails> fetchUser() async =>
      await db.getCurrentUser(uid: widget.uid);

  Future<Orders> fetchOrder() async {
    double? itemTotal = 0;
    var result = await os.futureSingleOrder(widget.uid, widget.orderId);
    clientNameController.text = '${result.clientName}';
    order = result;
    selectedProduct = result.orderedProducts ?? {};
    for (var product in selectedProduct!.values) {
      itemTotal = itemTotal! + (product.price! * product.quantity!);
    }
    _valueNotifier.value = itemTotal!;
    return order;
  }

  Future<Orders> fetchLastOrderId() async {
    var result = await os.fetchLastOrderId(widget.uid);
    if (result != null && result.uid != null) {
      String digits = result.uid!.replaceAll(RegExp(r'[^0-9]'), '');
      int lastId = int.tryParse(digits) ?? 0;
      lastId++;
      order.uid = 'OR${lastId.toString().padLeft(6, '0')}';
    } else {
      order.uid = 'OR1000001';
    }
    return order;
  }

  Future<ClientDetails> fetchClient() async {
    var result = await cs.futureSingleClient(widget.uid!, widget.clientId!);
    selectedClient = result;
    clientNameController.text =
        '${result.individual! ? '${result.firstName} ${result.lastName}' : result.companyName}';
    order.clientId = result.uid;
    order.clientName = result.individual!
        ? '${result.firstName} ${result.lastName}'
        : result.companyName;
    return result;
  }

  Future<void> addOrder() async {
    if (clientNameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.clientNameEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (order.clientId == null) {
      snackbarWidget.content = appLoc!.clientNameInvalid;
      snackbarWidget.showSnack();
      return;
    }
    if (selectedProduct!.isEmpty) {
      snackbarWidget.content = appLoc!.productListEmpty;
      snackbarWidget.showSnack();
      return;
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
    order.paymentTerms ??= 'Cash';
    try {
      Orders newOrder = Orders(
        uid: order.uid,
        clientId: order.clientId,
        clientName: order.clientName,
        paymentTerms: order.paymentTerms,
        orderedProducts: selectedProduct!,
        orderedAt: DateTime.now(),
        deliveryTerms: '',
        returnTerms: '',
        storeLocation: order.storeLocation,
      );
      await os.addOrder(uid: widget.uid, order: newOrder);
      ProgressManager.completeLoading();
      if (mounted) {
        setState(() => isLoading = false);
        GoRouter.of(context).pushNamed(
          'orderTerms',
          pathParameters: {'uid': widget.uid!, 'orderId': newOrder.uid!},
        );
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

  Future<void> updateOrder() async {
    if (clientNameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.clientNameEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (selectedProduct!.isEmpty) {
      snackbarWidget.content = appLoc!.productListEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (order.status == constStrings.cancel) {
      snackbarWidget.content = appLoc!.orderCancelled;
      snackbarWidget.showSnack();
      return;
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
      Orders newOrder = Orders(
        uid: widget.orderId,
        clientId: order.clientId,
        clientName: order.clientName,
        paymentTerms: order.paymentTerms,
        orderedProducts: selectedProduct!,
        orderedAt: order.orderedAt,
        scheduledAt: order.scheduledAt,
        scheduledDate: order.scheduledDate,
        scheduled: order.scheduled,
        deliveryTerms: order.deliveryTerms,
        deliveryFees: order.deliveryFees,
        returnTerms: order.returnTerms,
        invoiceUrl: order.invoiceUrl,
        storeLocation: order.storeLocation,
        setReminder: order.setReminder,
        paymentReminderDate: order.paymentReminderDate,
        setPaymentReminder: order.setPaymentReminder,
        taxAmount: order.taxAmount,
      );
      await os.editOrder(uid: widget.uid, order: newOrder);
      ProgressManager.completeLoading();
      if (mounted) {
        setState(() => isLoading = false);
        GoRouter.of(context).pushNamed(
          'orderTerms',
          pathParameters: {'uid': widget.uid!, 'orderId': newOrder.uid!},
        );
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
    List<String> queries = [];
    matches.addAll(allClients.map((e) => e));
    String lowerCase = search.toLowerCase();
    if (lowerCase.contains(' ')) {
      queries = lowerCase.split(' ');
    } else {
      queries = [lowerCase];
    }
    matches.clear();
    for (var client in allClients) {
      bool match = queries.every(
        (queryWord) =>
            client.firstName!.toLowerCase().contains(queryWord) ||
            client.lastName != null &&
                client.lastName!.toLowerCase().contains(queryWord) ||
            client.companyName != null &&
                client.companyName!.toLowerCase().contains(queryWord) ||
            client.phoneNumber != null &&
                client.phoneNumber!['number']!.contains(queryWord) ||
            client.email != null &&
                client.email!.toLowerCase().contains(queryWord),
      );
      if (match) matches.add(client);
    }
    return matches;
  }

  void _addProductToSelection(Product value) async {
    setState(() => _isAddingProduct = true);
    if (value.id != null && !selectedProduct!.containsKey(value.id!)) {
      double stock = -1;
      if (inventoryLocation == null || order.storeLocation == null) {
        inventoryLocation =
            currentUser!.inventoryLoc != null &&
                currentUser!.inventoryLoc!.isNotEmpty
            ? currentUser!.inventoryLoc?.values.first
            : null;
        order.storeLocation = inventoryLocation;
      }
      if (currentUser != null &&
          currentUser!.isSubscribed != null &&
          currentUser!.isSubscribed! &&
          useInventory) {
        if (currentUser!.businessType == 'trading') {
          stock = await checkInventory(value);
        } else {
          stock = await checkRawMaterialStock(value);
        }

        if (stock <= 0) {
          snackbarWidget.content = appLoc!.insufficientStockFor(
            value.name,
            order.storeLocation ?? currentUser!.inventoryLoc!.values.first,
          );
          snackbarWidget.showSnack();
          setState(() => _isAddingProduct = false);
          return;
        }
      }
      setState(() {
        value.quantity = 1;
        selectedProduct![value.id!] = OrderProducts(
          id: value.id,
          userId: widget.uid,
          name: value.name,
          price: value.price,
          originalPrice: value.price,
          discount: value.discount,
          quantity: value.quantity,
          cost: value.cost,
          packing: value.packingValue != null
              ? '${value.packingValue} ${value.packingUnit ?? ''}'
              : '',
          storeLocation: useInventory ? order.storeLocation : null,
        );
        productNameController.clear();
      });
    }
    setState(() => _isAddingProduct = false);
  }

  Future<double> checkInventory(Product product) async {
    if (product.inventory != null &&
        product.inventory!.isNotEmpty &&
        product.inventory!.containsKey(order.storeLocation)) {
      return product.inventory![order.storeLocation] ?? -1;
    }
    return -1;
  }

  Future<double> checkRawMaterialStock(Product product) async {
    double stock = -1;
    Map<String, double> requiredMaterials = {};

    if (product.receipeId == null || product.receipeId!.isEmpty) return 1;

    if (!await ps.doesRecipeExist(
      userId: widget.uid,
      recipeId: product.receipeId!,
    )) {
      snackbarWidget.content = appLoc!.receipeIsMissing;
      snackbarWidget.time = 5;
      snackbarWidget.showSnack();
      return -1;
    }

    var receipe = await ps.futureSingleReceipe(
      userId: widget.uid,
      receipeId: product.receipeId!,
    );

    if (receipe.ingredients == null || receipe.ingredients!.isEmpty) return 1;
    // ── Build reserved map from selectedProducts already in the order ────────
    Map<String, double> alreadyReserved = {};

    for (var entry in selectedProduct!.entries) {
      // Skip the product being checked right now
      if (entry.key == product.id) continue;

      final selectedDetails = await ps.futureSingleProduct(
        userId: widget.uid!,
        productId: entry.key,
      );

      if (selectedDetails.receipeId == null ||
          selectedDetails.receipeId!.isEmpty) {
        continue;
      }

      if (!await ps.doesRecipeExist(
        userId: widget.uid,
        recipeId: selectedDetails.receipeId!,
      )) {
        continue;
      }

      final selectedReceipe = await ps.futureSingleReceipe(
        userId: widget.uid!,
        receipeId: selectedDetails.receipeId!,
      );

      if (selectedReceipe.ingredients == null) continue;

      for (var ing in selectedReceipe.ingredients!) {
        final rawItem = await ps.futureSingleRawItem(
          userId: widget.uid!,
          rawItemId: ing.uid!,
        );

        double ingQtyPerUnit = ing.quantity ?? 1.0;

        // Unit conversion
        if (ing.unit?.toLowerCase() != rawItem.unit?.toLowerCase()) {
          final rate = rawItem.conversion?[ing.unit?.toLowerCase()]?.rate;
          if (rate != null && rate != 0) {
            ingQtyPerUnit = ingQtyPerUnit / rate;
          }
        }

        // Multiply by how many of this selected product are in the order
        final quantityInOrder = entry.value.quantity ?? 1.0;
        final reservedAmount = ingQtyPerUnit * quantityInOrder;

        alreadyReserved[ing.uid!] =
            (alreadyReserved[ing.uid!] ?? 0) + reservedAmount;
      }
    }

    // ── Check stock for this product (1 unit) against effective stock ────────
    for (var ingredient in receipe.ingredients!) {
      if (!await ps.doesRawItemExist(
        userId: widget.uid,
        rawItemId: ingredient.uid!,
      )) {
        snackbarWidget.content = appLoc!.rawItemMissing;
        snackbarWidget.time = 5;
        snackbarWidget.showSnack();
        return -1;
      }
      var rawItem = await ps.futureSingleRawItem(
        userId: widget.uid!,
        rawItemId: ingredient.uid!,
      );

      if (rawItem.inventory == null ||
          rawItem.inventory!.isEmpty ||
          !rawItem.inventory!.containsKey(order.storeLocation)) {
        snackbarWidget.content = appLoc!.insufficientStockFor(
          rawItem.name!,
          order.storeLocation ?? currentUser!.inventoryLoc!.values.first,
        );
        snackbarWidget.showSnack();
        return -1;
      }

      double availableStock = rawItem.inventory![order.storeLocation] ?? 0;
      // Effective stock = total available minus what other selected products need
      final reserved = alreadyReserved[ingredient.uid!] ?? 0;
      final effectiveStock = availableStock - reserved;

      // Unit conversion — local variable, never mutate ingredient
      double ingredientQtyPerUnit = ingredient.quantity ?? 1.0;
      if (ingredient.unit?.toLowerCase() != rawItem.unit?.toLowerCase()) {
        final rate = rawItem.conversion?[ingredient.unit?.toLowerCase()]?.rate;
        if (rate != null && rate != 0) {
          ingredientQtyPerUnit = ingredientQtyPerUnit / rate;
        }
      }

      // 1 unit of this product needs ingredientQtyPerUnit of this raw material
      final remainingStock = effectiveStock - ingredientQtyPerUnit;
      requiredMaterials[ingredient.name!] = remainingStock >= 0
          ? remainingStock
          : -1;
    }

    if (requiredMaterials.containsValue(-1)) {
      var key = requiredMaterials.keys.firstWhere(
        (k) => requiredMaterials[k] == -1,
      );
      snackbarWidget.content = appLoc!.insufficientStockFor(
        key,
        order.storeLocation!,
      );
      snackbarWidget.showSnack();
      stock = -1;
    } else {
      stock = 1;
    }
    return stock;
  }

  Future<List<Product>> getProductSuggestions(String search) async {
    List<Product> matches = [];
    List<String> queries = [];
    matches.addAll(allProducts.map((e) => e));
    String lowerCase = search.toLowerCase();
    if (lowerCase.contains(' ')) {
      queries = lowerCase.split(' ');
    } else {
      queries = [lowerCase];
    }
    matches.clear();
    for (var product in allProducts) {
      bool match = queries.every(
        (queryWord) =>
            product.name.toLowerCase().contains(queryWord) ||
            product.description.toLowerCase().contains(queryWord) ||
            product.sku != null &&
                product.sku!.toLowerCase().contains(queryWord),
      );
      if (match) matches.add(product);
    }
    return matches;
  }

  Future<void> reactivateOrder(Orders order, String status) async {
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
      order.status = status;
      if (currentUser != null &&
          currentUser!.isSubscribed != null &&
          currentUser!.isSubscribed!) {
        if (order.storeLocation != null) {
          if (currentUser!.businessType == 'trading') {
            for (var item in order.orderedProducts!.entries) {
              var key = item.key;
              var val = item.value;
              var product = await ps.futureSingleProduct(
                userId: widget.uid,
                productId: key,
              );
              if (product.inventory != null &&
                  product.inventory![order.storeLocation] != null) {
                var stockReplenshed =
                    product.inventory![order.storeLocation] - val.quantity;
                if (stockReplenshed > 0) {
                  product.inventory![order.storeLocation!] = stockReplenshed;
                } else {
                  product.inventory![order.storeLocation!] = 0;
                }
                await ps.updateProduct(widget.uid!, product);
              }
            }
          } else if (currentUser!.businessType == 'manufacturing') {
          } else {}
        }
      }
      if (order.uid != null) {
        List productIds = order.orderedProducts!.keys.toList();
        if (productIds.isNotEmpty) {
          for (var id in productIds) {
            if (!await ps.checkIfProductRecordExist(
              widget.uid!,
              id,
              order.uid!,
            )) {
              await ps.updateProductRecord(
                userId: widget.uid,
                productId: id,
                orderId: order.uid,
                product: order.orderedProducts![id],
              );
            }
          }
        }
      }
      await os.editOrder(uid: widget.uid, order: order);
    } on Exception catch (e, s) {
      if (mounted) {
        setState(() {
          isLoading = false;
          ProgressManager.stopLoading();
        });
      }
      snackbarWidget.content = appLoc!.failedToRestoreOrder;
      snackbarWidget.time = 5;
      snackbarWidget.showSnack();
      ErrorLoggingService.instance.recordError(
        e,
        s,
        fatal: false,
        printDetails: true,
      );
    }
    if (mounted) {
      setState(() {
        isLoading = false;
        ProgressManager.stopLoading();
      });
    }
  }

  Future<void> downloadandLaunch() async {
    try {
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

      // Mobile downloads the PDF to a temp file and opens the native share
      // sheet (dart:io + share_plus, no web support) — the browser already
      // handles viewing/downloading a PDF when opened directly, so this just
      // opens the invoice URL in a new tab instead.
      await urlLaunch.launchUrlWidget(order.invoiceUrl!);
      ProgressManager.stopLoading();
      if (mounted) {
        setState(() => isLoading = false);
      }
    } catch (e) {
      snackbarWidget.content = appLoc!.failedToDownloadInvoice;
      snackbarWidget.showSnack();
      ProgressManager.stopLoading();
      if (mounted) {
        setState(() => isLoading = false);
      }
      ErrorLoggingService.instance.recordError(
        e,
        null,
        fatal: false,
        printDetails: true,
      );
    }
  }
}
