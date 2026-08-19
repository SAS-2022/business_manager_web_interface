import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/utils/components/animated_radio.dart';
import 'package:business_manager_web_ui/src/app/utils/components/country_code.dart';
import 'package:business_manager_web_ui/src/app/utils/components/phone_validators.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/flush_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/models/client_model.dart';
import 'package:business_manager_web_ui/src/models/payment_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/client_service.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/order_service.dart';
import 'package:business_manager_web_ui/src/services/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/theme/responsive_utils.dart';
import '../../models/order_model.dart';
import '../../services/auth_service.dart';

class ClientAddEdit extends StatefulWidget {
  const ClientAddEdit({super.key, this.uid, this.clientId});
  final String? uid;
  final String? clientId;

  @override
  State<ClientAddEdit> createState() => _ClientAddEditState();
}

class _ClientAddEditState extends State<ClientAddEdit> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  ErrorClass errorClass = ErrorClass();
  AuthService as = AuthService();
  ClientService cs = ClientService();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  OrderService os = OrderService();
  DatabaseService db = DatabaseService();
  PaymentService ps = PaymentService();
  bool isLoading = false,
      isSearching = false,
      isIndividual = true,
      isUpdating = false;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController financialNumberController = TextEditingController();
  TextEditingController crNumberController = TextEditingController();
  TextEditingController ibanNumberController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  String? phoneCode, phoneCountry;
  UserDetails currentUser = UserDetails();
  Future<UserDetails>? getCurrentUser;
  ClientDetails client = ClientDetails();
  Future<ClientDetails>? getCurrentClient;
  int phoneLength = 10;
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
    if (widget.clientId != null) getCurrentClient = fetchClient();
    super.initState();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    companyNameController.dispose();
    phoneNumberController.dispose();
    emailAddressController.dispose();
    financialNumberController.dispose();
    crNumberController.dispose();
    ibanNumberController.dispose();
    bankNameController.dispose();
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

  /// Grouped card — children are separated by dividers automatically
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

  Widget _fieldRow({
    required IconData icon,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(left: responsive!.scaleWidth(14)),
          child: Icon(
            icon,
            size: responsive!.scaleHeight(18),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: FutureBuilder<UserDetails>(
          future: getCurrentUser,
          builder: (context, usershot) {
            if (usershot.hasError) {
              return Center(
                  child: MyText(text: errorClass.userNoTFoundError()));
            }
            if (usershot.connectionState == ConnectionState.waiting) {
              return const GradientSkeleton();
            }
            currentUser = usershot.data!;
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                title: MyText(
                  text: widget.clientId == null
                      ? appLoc!.addClient
                      : appLoc!.editClient,
                  fontScale: responsive!.scaleFont(18),
                  fontWeight: FontWeight.w500,
                ),
                actions: [
                  if (widget.clientId != null)
                    IconButton(
                      onPressed: () => GoRouter.of(context).pushNamed(
                        'clientStatement',
                        pathParameters: {
                          'uid': widget.uid!,
                          'clientId': widget.clientId!,
                        },
                      ),
                      icon: Icon(Icons.receipt_long_outlined,
                          size: responsive!.scaleHeight(22)),
                    ),
                  IconButton(
                    icon: Icon(Icons.save_outlined,
                        size: responsive!.scaleHeight(22)),
                    onPressed: () =>
                        widget.clientId == null ? addClient() : updateClient(),
                  ),
                ],
              ),
              body: Stack(
                children: [
                  _buildClientViewBody(),
                  if (isLoading) const Center(child: AnimatedArcLoader()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildClientViewBody() {
    return FutureBuilder(
      future: getCurrentClient,
      builder: (context, clientshot) {
        if (clientshot.hasError) {
          return Center(child: MyText(text: errorClass.clientNotLoading()));
        }
        if (clientshot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        }

        if (clientshot.hasData && !isUpdating) {
          isIndividual = clientshot.data!.individual ?? false;
          isUpdating = true;
        }

        return SingleChildScrollView(
          padding: responsive!.responsivePaddingM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Client type toggle ──────────────────────────────────────
              _sectionLabel(appLoc!.clientType),
              SizedBox(
                height: responsive!.scaleHeight(110),
                width: responsive!.screenWidth,
                child: AnimatedRadioButton(
                  quantity: 2,
                  titles: [appLoc!.individual, appLoc!.company],
                  initialSelected: isIndividual ? 0 : 1,
                  onSelected: onClientTypeSelected,
                ),
              ),
              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Personal / Company info ─────────────────────────────────
              _sectionLabel(isIndividual
                  ? appLoc!.personalInfo // add to l10n
                  : appLoc!.companyInfo), // add to l10n
              _groupCard(children: [
                if (!isIndividual)
                  _fieldRow(
                    icon: Icons.business_outlined,
                    child: FlushTextField(
                      controller: companyNameController,
                      hintText: appLoc!.company,
                      textCapitalization: TextCapitalization.words,
                      fontSize: responsive!.scaleFont(13),
                    ),
                  ),
                _fieldRow(
                  icon: Icons.person_outline_rounded,
                  child: FlushTextField(
                    controller: firstNameController,
                    hintText: appLoc!.firstName,
                    textCapitalization: TextCapitalization.words,
                    fontSize: responsive!.scaleFont(13),
                  ),
                ),
                _fieldRow(
                  icon: Icons.person_outline_rounded,
                  child: FlushTextField(
                    controller: lastNameController,
                    hintText: appLoc!.lastName,
                    textCapitalization: TextCapitalization.words,
                    fontSize: responsive!.scaleFont(13),
                  ),
                ),
              ]),

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Contact info ────────────────────────────────────────────
              _sectionLabel(appLoc!.contactInfo),
              _groupCard(children: [
                // Phone row — CountryCodePhone + FlushTextField
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: responsive!.scaleWidth(14),
                      ),
                      child: SizedBox(
                        width: responsive!.screenWidth * 0.25,
                        child: CountryCodePhone(
                          initialCode: phoneCountry,
                          onSelected: (code, country) {
                            if (code.isNotEmpty) {
                              phoneCode = code;
                              phoneCountry = country;
                              phoneLength =
                                  PhoneValidators.getPhoneNumberLength(
                                      phoneCountry ?? 'US');
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: FlushTextField(
                        controller: phoneNumberController,
                        hintText: appLoc!.phoneNumber,
                        keyboardType: TextInputType.phone,
                        maxLength: phoneLength,
                        fontSize: responsive!.scaleFont(13),
                      ),
                    ),
                  ],
                ),
                _fieldRow(
                  icon: Icons.mail_outline_rounded,
                  child: FlushTextField(
                    controller: emailAddressController,
                    hintText: appLoc!.emailAddress,
                    keyboardType: TextInputType.emailAddress,
                    fontSize: responsive!.scaleFont(13),
                  ),
                ),
              ]),

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Official / Financial data ───────────────────────────────
              _sectionLabel(
                  appLoc!.officialData), // add to l10n: "Official data"
              _groupCard(children: [
                _fieldRow(
                  icon: Icons.numbers_outlined,
                  child: FlushTextField(
                    controller: financialNumberController,
                    hintText: appLoc!.financialNumber,
                    textCapitalization: TextCapitalization.words,
                    fontSize: responsive!.scaleFont(13),
                  ),
                ),
                _fieldRow(
                  icon: Icons.badge_outlined,
                  child: FlushTextField(
                    controller: crNumberController,
                    hintText: appLoc!.crNumber,
                    textCapitalization: TextCapitalization.words,
                    fontSize: responsive!.scaleFont(13),
                  ),
                ),
                _fieldRow(
                  icon: Icons.account_balance_outlined,
                  child: FlushTextField(
                    controller: ibanNumberController,
                    hintText: appLoc!.ibanNumber,
                    textCapitalization: TextCapitalization.characters,
                    fontSize: responsive!.scaleFont(13),
                  ),
                ),
                _fieldRow(
                  icon: Icons.corporate_fare_outlined,
                  child: FlushTextField(
                    controller: bankNameController,
                    hintText: appLoc!.bankName,
                    textCapitalization: TextCapitalization.words,
                    fontSize: responsive!.scaleFont(13),
                  ),
                ),
              ]),

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Client orders ───────────────────────────────────────────
              if (widget.clientId != null) ...[
                clientOrders(),
                SizedBox(height: responsive!.scaleHeight(20)),
              ],

              // ── Upcoming payments ───────────────────────────────────────
              if (widget.clientId != null) upcomingPayments(),

              SizedBox(height: responsive!.scaleHeight(24)),
            ],
          ),
        );
      },
    );
  }

  // ── Client orders ──────────────────────────────────────────────────────────

  Widget clientOrders() {
    return StreamBuilder<List<Orders>>(
      stream: os.streamClientOrders(widget.uid!, widget.clientId ?? ''),
      builder: (context, ordershot) {
        if (ordershot.hasError) {
          return Center(child: MyText(text: errorClass.ordersNotLoading()));
        }
        if (ordershot.connectionState == ConnectionState.waiting) {
          return const Center(child: AnimatedArcLoader());
        }

        final orders = ordershot.data ?? [];
        double totalValue = 0.0;
        for (var order in orders) {
          for (var product in (order.orderedProducts ?? {}).values) {
            totalValue += product.price! * product.quantity!;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel(appLoc!.clientOrders),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.5),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Order rows
                  SizedBox(
                    height: responsive!.scaleHeight(220),
                    child: orders.isEmpty
                        ? Center(
                            child: MyText(
                              text: appLoc!.noExpenseFound,
                              fontScale: responsive!.scaleFont(13),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: orders.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 0,
                              thickness: 0.5,
                              indent: responsive!.scaleWidth(14),
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.25),
                            ),
                            itemBuilder: (context, index) {
                              double orderValue = 0.0;
                              for (var product in (orders[index]
                                      .orderedProducts ??
                                  {}).values) {
                                orderValue +=
                                    product.price! * product.quantity!;
                              }
                              return GestureDetector(
                                onTap: () => GoRouter.of(context)
                                    .pushNamed('editOrder', pathParameters: {
                                  'uid': widget.uid!,
                                  'orderId': orders[index].uid!,
                                }),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: responsive!.scaleWidth(14),
                                    vertical: responsive!.scaleHeight(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.chevron_right,
                                        size: responsive!.scaleHeight(14),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      SizedBox(
                                          width: responsive!.scaleWidth(6)),
                                      MyText(
                                        text:
                                            '${orders[index].orderedAt!.day}/${orders[index].orderedAt!.month}/${orders[index].orderedAt!.year}',
                                        fontScale: responsive!.scaleFont(13),
                                      ),
                                      const Spacer(),
                                      MyText(
                                        text:
                                            '${currentUser.currency!['symbol']} ${number.format(orderValue)}',
                                        fontScale: responsive!.scaleFont(13),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  // Total footer
                  Divider(
                    height: 0,
                    thickness: 0.5,
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive!.scaleWidth(14),
                      vertical: responsive!.scaleHeight(10),
                    ),
                    child: Row(
                      children: [
                        MyText(
                          text: appLoc!.totalValue,
                          fontScale: responsive!.scaleFont(12),
                          fontWeight: FontWeight.w500,
                        ),
                        const Spacer(),
                        MyText(
                          text:
                              '${currentUser.currency!['symbol']} ${number.format(totalValue)}',
                          fontScale: responsive!.scaleFont(13),
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Upcoming payments ──────────────────────────────────────────────────────

  Widget upcomingPayments() {
    return StreamBuilder<List<Payments>>(
      stream: ps.streamClientPayments(widget.uid, widget.clientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: AnimatedArcLoader());
        }
        if (snapshot.hasError) {
          return Center(
              child: MyText(
                  text: errorClass
                      .expensesNotLoading(snapshot.error.toString())));
        }

        final payments = snapshot.data ?? [];
        final upcoming = payments.where((p) {
          return p.status == 'Pending' && p.dueDate != null;
        }).toList();

        if (upcoming.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel(appLoc!.upcomingPayments),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.5),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: upcoming.asMap().entries.map((entry) {
                  final i = entry.key;
                  final payment = entry.value;
                  final isLast = i == upcoming.length - 1;
                  final daysUntilDue =
                      payment.dueDate!.difference(DateTime.now()).inDays;

                  Color dotColor;
                  Color badgeBg;
                  Color badgeText;
                  String badgeLabel;

                  if (daysUntilDue < 0) {
                    dotColor = Colors.red;
                    badgeBg = Colors.red.shade50;
                    badgeText = Colors.red.shade700;
                    badgeLabel = appLoc!.overDue;
                  } else if (daysUntilDue <= 5) {
                    dotColor = Colors.orange;
                    badgeBg = Colors.orange.shade50;
                    badgeText = Colors.orange.shade800;
                    badgeLabel = appLoc!.dueSoon; // add to l10n
                  } else {
                    dotColor = Colors.green;
                    badgeBg = Colors.green.shade50;
                    badgeText = Colors.green.shade800;
                    badgeLabel = appLoc!.onTrack; // add to l10n
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive!.scaleWidth(14),
                          vertical: responsive!.scaleHeight(10),
                        ),
                        child: Row(
                          children: [
                            // Status dot
                            Container(
                              width: 8,
                              height: 8,
                              margin: EdgeInsets.only(
                                  right: responsive!.scaleWidth(10)),
                              decoration: BoxDecoration(
                                color: dotColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            // Name + due date
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    text: payment.clientName ?? '',
                                    fontScale: responsive!.scaleFont(13),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  MyText(
                                    text:
                                        '${appLoc!.due}: ${payment.dueDate!.day}/${payment.dueDate!.month}/${payment.dueDate!.year}',
                                    fontScale: responsive!.scaleFont(11),
                                  ),
                                ],
                              ),
                            ),
                            // Amount + badge
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                MyText(
                                  text:
                                      '${currentUser.currency!['symbol']} ${number.format(payment.amount)}',
                                  fontScale: responsive!.scaleFont(13),
                                  fontWeight: FontWeight.w500,
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: badgeBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: MyText(
                                    text: badgeLabel,
                                    fontScale: responsive!.scaleFont(10),
                                    fontColor: badgeText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          height: 0,
                          thickness: 0.5,
                          indent: responsive!.scaleWidth(14),
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.25),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Logic — completely unchanged ───────────────────────────────────────────

  Future<UserDetails> fetchUser() async => db.getCurrentUser(uid: widget.uid);

  Future<ClientDetails> fetchClient() async {
    var result = await cs.futureSingleClient(widget.uid, widget.clientId);
    companyNameController.text = result.companyName ?? '';
    firstNameController.text = result.firstName ?? '';
    lastNameController.text = result.lastName ?? '';
    isIndividual = result.individual ?? false;
    phoneCountry = result.phoneNumber!['country'];
    phoneCode = result.phoneNumber?['code'];
    phoneNumberController.text = result.phoneNumber?['number'] ?? '';
    emailAddressController.text = result.email ?? '';
    financialNumberController.text = result.financialNumber ?? '';
    crNumberController.text = result.crNumber ?? '';
    ibanNumberController.text = result.ibanNumber ?? '';
    bankNameController.text = result.bankName ?? '';
    onClientTypeSelected(isIndividual ? 0 : 1);
    return result;
  }

  void onClientTypeSelected(value) {
    setState(() => value == 0 ? isIndividual = true : isIndividual = false);
  }

  Future<void> addClient() async {
    if (!isIndividual && companyNameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.clientCompanyName;
      snackbarWidget.showSnack();
      return;
    }
    if (firstNameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.clientNameEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (phoneNumberController.text.isEmpty) {
      snackbarWidget.content = appLoc!.phoneNumberEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (phoneCode == null || phoneCode!.isEmpty) {
      phoneCode = '+1';
      phoneCountry = 'US';
    }
    client = ClientDetails(
      companyName: companyNameController.text.trim(),
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      phoneNumber: <String, String>{
        'country': phoneCountry ?? '',
        'code': phoneCode ?? '',
        'number': phoneNumberController.text.trim(),
      },
      email: emailAddressController.text.trim(),
      individual: isIndividual,
      createdAt: DateTime.now(),
      financialNumber: financialNumberController.text,
      crNumber: crNumberController.text,
      ibanNumber: ibanNumberController.text,
      bankName: bankNameController.text,
    );
    setState(() => isLoading = true);
    await cs.addClient(uid: widget.uid, client: client);
    if (mounted) {
      setState(() => isLoading = false);
      GoRouter.of(context).pop();
    }
  }

  Future<void> updateClient() async {
    if (!isIndividual && companyNameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.companyNameEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (firstNameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.clientNameEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (phoneCode == null || phoneCode!.isEmpty) {
      snackbarWidget.content = appLoc!.phoneCodeEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (phoneNumberController.text.isEmpty) {
      snackbarWidget.content = appLoc!.phoneNumberEmpty;
      snackbarWidget.showSnack();
      return;
    }
    client = ClientDetails(
      uid: widget.clientId,
      companyName: companyNameController.text.trim(),
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      phoneNumber: <String, String>{
        'country': phoneCountry ?? '',
        'code': phoneCode ?? '',
        'number': phoneNumberController.text.trim(),
      },
      email: emailAddressController.text.trim(),
      individual: isIndividual,
      financialNumber: financialNumberController.text,
      crNumber: crNumberController.text,
      ibanNumber: ibanNumberController.text,
      bankName: bankNameController.text,
    );
    setState(() => isLoading = true);
    await cs.updateClient(uid: widget.uid, client: client);
    if (mounted) {
      setState(() => isLoading = false);
      GoRouter.of(context).pop();
    }
  }
}
