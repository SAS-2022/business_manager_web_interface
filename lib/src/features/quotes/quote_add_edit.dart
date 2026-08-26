import 'dart:math';
import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/app_constants.dart';
import 'package:business_manager_web_ui/src/app/constants/dimensions.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/utils/components/url_launcher_func.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
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
import 'package:business_manager_web_ui/src/services/quote_service.dart';
import 'package:business_manager_web_ui/src/services/error_logging_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/theme/responsive_utils.dart';
import '../../app/widgets/Text/my_text_field.dart';
import '../../models/product_model.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';

class QuoteAddEdit extends StatefulWidget {
  const QuoteAddEdit({
    super.key,
    this.uid,
    this.quoteId,
    this.clientId,
    this.quoteToOrderId,
  });
  final String? uid;
  final String? quoteId;
  final String? clientId;
  final String? quoteToOrderId;

  @override
  State<QuoteAddEdit> createState() => _QuoteAddEditState();
}

class _QuoteAddEditState extends State<QuoteAddEdit> {
  //Initials
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  //Service
  ErrorClass errorClass = ErrorClass();
  DatabaseService db = DatabaseService();
  AuthService as = AuthService();
  QuoteService qs = QuoteService();
  ClientService cs = ClientService();
  ProductService ps = ProductService();
  OrderService os = OrderService();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  ProductInfoDialog infoDialog = ProductInfoDialog();
  YesAndNoDialog yesNoDialog = YesAndNoDialog();
  UrlLauncherFunc urlLaunch = UrlLauncherFunc();
  PaymentTerms pt = PaymentTerms();
  ConstantStrings constStrings = ConstantStrings();
  //Variables
  bool isLoading = false,
      isIndividual = true,
      isUpdating = false,
      enabled = true,
      requiredEditing = false;
  TextEditingController clientNameController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  final ValueNotifier<double> _valueNotifier = ValueNotifier(0.0);
  List<ClientDetails> allClients = [];
  List<Product> allProducts = [];
  ClientDetails? selectedClient = ClientDetails();
  Map<String, OrderProducts>? selectedProduct = {};
  String? phoneCode, phoneCountry;
  Orders quote = Orders();
  Future<Orders>? getCurrentQuote;
  Future<Orders>? getLastQuote;
  Future<UserDetails>? getCurrentUser;
  Future<ClientDetails>? getCurrentClient;
  UserDetails? currentUser = UserDetails();
  double? quoteTotalValue = 0;
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
    if (widget.uid != null) {
      getCurrentUser = fetchUser();
    }
    if (widget.quoteId != null) {
      getCurrentQuote = fetchQuote();
    } else {
      getLastQuote = fetchLastQuoteId();
    }
    if (widget.clientId != null) {
      getCurrentClient = fetchClient();
    }
    super.initState();
  }

  @override
  void dispose() {
    clientNameController.dispose();
    productNameController.dispose();
    _valueNotifier.dispose();
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

  Widget _cardWrap(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

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
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: MyText(
              text: widget.quoteId == null
                  ? appLoc!.addQuote
                  : appLoc!.editQuote,
              fontScale: responsive!.scaleFont(18),
              fontWeight: FontWeight.w500,
            ),
            actions: [
              if (widget.quoteId != null && widget.quoteToOrderId == null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      requiredEditing = !requiredEditing;
                    });
                  },
                  child: MyText(
                    text: appLoc!.edit,
                    fontScale: responsive!.scaleFont(12),
                  ),
                ),
              IconButton(
                icon: Icon(
                  Icons.next_plan_rounded,
                  size: responsive!.scaleHeight(26),
                ),
                onPressed: () {
                  widget.quoteId == null ? addQuote() : updateQuote();
                },
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
                  } else {
                    currentUser = usershot.data;
                    return _buildQuoteViewBody();
                  }
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
    );
  }

  // ── Quote view body ────────────────────────────────────────────────────────

  Widget _buildQuoteViewBody() {
    return FutureBuilder(
      future: widget.quoteId != null ? getCurrentQuote : getLastQuote,
      builder: (context, quoteshot) {
        if (quoteshot.hasError) {
          return Center(
            child: MyText(
              text: errorClass.quotesNotLoading(quoteshot.error.toString()),
            ),
          );
        } else if (quoteshot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        } else {
          if (quoteshot.hasData && !isUpdating) isUpdating = true;
          if (quoteshot.hasData && quoteshot.data!.invoiceUrl != null) {
            if (requiredEditing == false) {
              enabled = false;
            } else {
              enabled = true;
            }
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
                        // ── Quote ID bar ────────────────────────────
                        if (quoteshot.data != null)
                          _buildQuoteIdBar(quoteshot.data!),

                        // ── Client ────────────────────────────────────
                        _sectionLabel(appLoc!.clientName),
                        clientNameTypeIn(),

                        SizedBox(height: responsive!.scaleHeight(20)),

                        // ── Payment terms ───────────────────────────
                        _sectionLabel(appLoc!.paymentTerms),
                        paymentTermsWidget(),

                        SizedBox(height: responsive!.scaleHeight(20)),

                        // ── Products ────────────────────────────────
                        _sectionLabel(appLoc!.product),
                        productDetails(),
                      ],
                    ),

                    // Cancelled stamp overlay — logic unchanged
                    if (widget.quoteId != null && quote.status == 'canceled')
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
                                text: quote.status == 'canceled'
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

                    if (quoteshot.data?.status == constStrings.cancel)
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

  // ── Quote ID bar ───────────────────────────────────────────────────────────

  Widget _buildQuoteIdBar(Orders quoteData) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive!.scaleHeight(16)),
      child: Row(
        children: [
          // Quote ID pill
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
              text: '${appLoc!.id}: ${quoteData.uid}',
              fontScale: responsive!.scaleFont(12),
              fontWeight: FontWeight.w500,
            ),
          ),

          const Spacer(),

          // Action buttons — same logic, restyled as pills
          if (!enabled) ...[
            // Make Order / Duplicate button
            if (quoteData.quoteToOrderId != null)
              GestureDetector(
                onTap: () async {
                  setState(() => isLoading = true);
                  await duplicateQuote(quoteData);
                  if (mounted) setState(() => isLoading = false);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: MyText(
                    text: appLoc!.dublicate,
                    fontScale: responsive!.scaleFont(11),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: () async {
                  setState(() => isLoading = true);
                  await changeToOrder(quoteData);
                  if (mounted) setState(() => isLoading = false);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: MyText(
                    text: appLoc!.makeOrder,
                    fontScale: responsive!.scaleFont(11),
                    fontWeight: FontWeight.w500,
                    fontColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

            SizedBox(width: responsive!.scaleWidth(8)),

            // Invoice / Quoted button
            GestureDetector(
              onTap: () async {
                setState(() => isLoading = true);
                await urlLaunch.launchUrlWidget(quoteData.invoiceUrl!);
                if (mounted) setState(() => isLoading = false);
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
                      text: appLoc!.quoted,
                      fontScale: responsive!.scaleFont(11),
                      fontWeight: FontWeight.w500,
                      fontColor: const Color(0xFF27500A),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Client name typeahead — LOGIC UNCHANGED, container restyled ───────────

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
                        quote.clientId = widget.clientId;
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
                              '${value.individual! ? '${value.firstName} ${value.lastName}' : value.companyName}',
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
                        quote.clientId = value.uid;
                        quote.clientName = value.individual!
                            ? '${value.firstName} ${value.lastName}'
                            : value.companyName;
                      } else {
                        selectedClient = null;
                        clientNameController.clear();
                        quote.clientId = null;
                        quote.clientName = null;
                      }
                    },
                    suggestionsCallback: (String search) {
                      return getClientSuggestions(search);
                    },
                  ),
                );
              },
            ),
          )
        : _readOnlyRow(
            icon: Icons.person_outline_rounded,
            label: appLoc!.clientName,
            value: quote.clientName.toString(),
          );
  }

  Widget clientInfo(TextEditingController controller, FocusNode focusNode) {
    return FutureBuilder(
      future: getCurrentClient,
      builder: (context, suppliershot) {
        if (suppliershot.hasError) {
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
        } else if (suppliershot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        } else {
          controller = TextEditingController(
            text: suppliershot.data?.individual == true
                ? '${suppliershot.data?.firstName} ${suppliershot.data?.lastName}'
                : suppliershot.data?.companyName,
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

  // ── Payment terms — LOGIC UNCHANGED, container restyled ───────────────────

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
                initialValue: quote.paymentTerms ?? 'Cash',
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
                    setState(() => quote.paymentTerms = value);
                  }
                },
              ),
            ),
          )
        : _readOnlyRow(
            icon: Icons.receipt_outlined,
            label: appLoc!.paymentTerms,
            value: quote.paymentTerms.toString(),
          );
  }

  // ── Product details — LOGIC UNCHANGED, list restyled ──────────────────────

  Widget productDetails() {
    return SingleChildScrollView(
      child: Padding(
        padding: responsive!.responsivePaddingLBottom,
        child: Column(
          children: [
            // Added products list
            if (selectedProduct != null && selectedProduct!.isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: responsive!.scaleHeight(12)),
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
                                SizedBox(height: responsive!.scaleHeight(2)),
                                MyText(
                                  text:
                                      '${p.packing}  ·  ${currentUser?.currency?['symbol'] ?? ''}${number.format(p.price)}',
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
                            // Settings / info button
                            GestureDetector(
                              onTap: () {
                                infoDialog.show(
                                  context,
                                  responsive!,
                                  appLoc!,
                                  quote.storeLocation ?? '',
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.error.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  size: responsive!.scaleHeight(15),
                                  color: Theme.of(context).colorScheme.error,
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
                      onSelected: (Product? value) {
                        _addProductToSelection(value!);
                      },
                      suggestionsCallback: (String search) {
                        return getProductSuggestions(search);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Cancelled widget — RegulartButton kept, restyled ──────────────────────

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
          onTap: () async {
            await reactivateQuote(quote, constStrings.active);
          },
          child: RegulartButton(
            text: appLoc!.reactivate,
            textColor: Theme.of(context).colorScheme.secondary,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  // ── Bottom sheet — same ValueNotifier logic, restyled ─────────────────────

  Widget bottomSheet() {
    quoteTotalValue = 0;
    for (var product in selectedProduct!.values) {
      double productValue = product.price! * product.quantity!;
      quoteTotalValue = (quoteTotalValue ?? 0) + productValue;
    }
    _valueNotifier.value = quoteTotalValue!;
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

  // ── All logic methods — byte-for-byte unchanged ────────────────────────────

  Future<UserDetails> fetchUser() async {
    return await db.getCurrentUser(uid: widget.uid);
  }

  Future<Orders> fetchQuote() async {
    double? itemTotal = 0;
    var result = await qs.futureSingleQuote(widget.uid, widget.quoteId);
    clientNameController.text = '${result.clientName}';
    quote = result;
    selectedProduct = result.orderedProducts ?? {};
    for (var product in selectedProduct!.values) {
      itemTotal = itemTotal! + (product.price! * product.quantity!);
    }
    _valueNotifier.value = itemTotal!;
    return quote;
  }

  Future<Orders> fetchLastQuoteId() async {
    var result = await qs.fetchLastQuoteId(widget.uid);
    if (result != null && result.uid != null) {
      String digits = result.uid!.replaceAll(RegExp(r'[^0-9]'), '');
      int lastId = int.tryParse(digits) ?? 0;
      lastId++;
      quote.uid = 'QT${lastId.toString().padLeft(6, '0')}';
    } else {
      quote.uid = 'QT1000001';
    }
    return quote;
  }

  Future<ClientDetails> fetchClient() async {
    var result = await cs.futureSingleClient(widget.uid!, widget.clientId!);
    selectedClient = result;
    clientNameController.text =
        '${result.individual! ? '${result.firstName} ${result.lastName}' : result.companyName}';
    quote.clientId = result.uid;
    quote.clientName = result.individual!
        ? '${result.firstName} ${result.lastName}'
        : result.companyName;
    return result;
  }

  Future<void> addQuote() async {
    if (clientNameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.clientNameEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (quote.clientId == null) {
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
    quote.paymentTerms ??= 'Cash';
    try {
      Orders newQuote = Orders(
        uid: quote.uid,
        clientId: quote.clientId,
        clientName: quote.clientName,
        paymentTerms: quote.paymentTerms,
        orderedProducts: selectedProduct!,
        orderedAt: DateTime.now(),
        deliveryTerms: '',
        returnTerms: '',
        storeLocation: quote.storeLocation,
      );
      await qs.addQuote(uid: widget.uid, quote: newQuote);
      ProgressManager.completeLoading();
      if (mounted) {
        setState(() => isLoading = false);
        GoRouter.of(context).pushNamed(
          'quoteTerms',
          pathParameters: {'uid': widget.uid!, 'quoteId': newQuote.uid!},
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

  Future<void> updateQuote() async {
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
    if (quote.status == constStrings.cancel) {
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
      Orders newQuote = Orders(
        uid: widget.quoteId,
        clientId: quote.clientId,
        clientName: quote.clientName,
        paymentTerms: quote.paymentTerms,
        orderedProducts: selectedProduct!,
        orderedAt: quote.orderedAt,
        scheduledAt: quote.scheduledAt,
        scheduledDate: quote.scheduledDate,
        scheduled: quote.scheduled,
        deliveryTerms: quote.deliveryTerms,
        deliveryFees: quote.deliveryFees,
        returnTerms: quote.returnTerms,
        invoiceUrl: quote.invoiceUrl,
        storeLocation: quote.storeLocation,
        setReminder: quote.setReminder,
        taxAmount: quote.taxAmount,
      );
      await qs.editQuote(uid: widget.uid, quote: newQuote);
      ProgressManager.completeLoading();
      if (mounted) {
        setState(() => isLoading = false);
        GoRouter.of(context).pushNamed(
          'quoteTerms',
          pathParameters: {'uid': widget.uid!, 'quoteId': newQuote.uid!},
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
    if (value.id != null && !selectedProduct!.containsKey(value.id!)) {
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
          packing: '${value.packingValue} ${value.packingUnit}',
        );
        productNameController.clear();
      });
    }
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

  Future<void> reactivateQuote(Orders quote, String status) async {
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
      quote.status = status;
      await qs.editQuote(uid: widget.uid, quote: quote);
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

  Future<void> changeToOrder(Orders originalQuote) async {
    Orders order = originalQuote.copyWith(
      clientId: quote.clientId,
      clientName: quote.clientName,
      paymentTerms: quote.paymentTerms,
      orderedProducts: selectedProduct!,
      orderedAt: quote.orderedAt,
      deliveryTerms: quote.deliveryTerms,
      returnTerms: quote.returnTerms,
      storeLocation: quote.storeLocation,
    );
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
      if (quote.quoteToOrderId != null) {
        Orders? existingOrder = await os.futureSingleOrder(
          widget.uid,
          quote.quoteToOrderId!,
        );
        if (existingOrder.uid != null && existingOrder.invoiceUrl == null) {
          if (mounted) {
            setState(() {
              ProgressManager.completeLoading();
              isLoading = false;
            });
            GoRouter.of(context).pushNamed(
              'editOrder',
              pathParameters: {
                'uid': widget.uid!,
                'orderId': existingOrder.uid!,
              },
            );
          }
          return;
        }
      }
      var result = await os.fetchLastOrderId(widget.uid);
      if (result != null && result.uid != null) {
        String digits = result.uid!.replaceAll(RegExp(r'[^0-9]'), '');
        int lastId = int.tryParse(digits) ?? 0;
        lastId++;
        order.uid = 'OR${lastId.toString().padLeft(6, '0')}';
      } else {
        order.uid = 'OR1000001';
      }
      Orders newOrder = order;
      newOrder.invoiceUrl = null;
      await os.addOrder(uid: widget.uid, order: newOrder);
      originalQuote.quoteToOrderId = order.uid;
      await qs.editQuote(uid: widget.uid, quote: originalQuote);
      ProgressManager.completeLoading();
      // ignore: use_build_context_synchronously
      GoRouter.of(context).pushReplacementNamed(
        'editOrder',
        pathParameters: {'uid': widget.uid!, 'orderId': newOrder.uid!},
      );
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

  Future<void> duplicateQuote(Orders originalQuote) async {
    String newQuoteId = '';
    var result = await qs.fetchLastQuoteId(widget.uid);
    if (result != null && result.uid != null) {
      String digits = result.uid!.replaceAll(RegExp(r'[^0-9]'), '');
      int lastId = int.tryParse(digits) ?? 0;
      lastId++;
      newQuoteId = 'QT${lastId.toString().padLeft(6, '0')}';
    } else {
      newQuoteId = 'QT1000001';
    }
    Orders newQuote = originalQuote.copyWith(
      uid: newQuoteId,
      orderedAt: DateTime.now(),
      quoteToOrderId: null,
    );
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
      await qs.addQuote(uid: widget.uid, quote: newQuote);
      ProgressManager.completeLoading();
      // ignore: use_build_context_synchronously
      GoRouter.of(context).pushReplacementNamed(
        'editQuote',
        pathParameters: {'uid': widget.uid!, 'quoteId': newQuoteId},
      );
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
}
