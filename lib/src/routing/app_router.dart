import 'package:business_manager_web_ui/src/features/auth/forgot_screen.dart';
import 'package:business_manager_web_ui/src/features/auth/login_screen.dart';
import 'package:business_manager_web_ui/src/features/auth/register_screen.dart';
import 'package:business_manager_web_ui/src/features/auth/verify_email_screen.dart';
import 'package:business_manager_web_ui/src/features/auth/wrapper.dart';
import 'package:business_manager_web_ui/src/features/clients/client_add_edit.dart';
import 'package:business_manager_web_ui/src/features/clients/client_statement.dart';
import 'package:business_manager_web_ui/src/features/clients/clients_view.dart';
import 'package:business_manager_web_ui/src/features/contact_us_stub_screen.dart';
import 'package:business_manager_web_ui/src/features/gallery/view_gallery.dart';
import 'package:business_manager_web_ui/src/features/home/home_screen.dart';
import 'package:business_manager_web_ui/src/features/products/add_product_screen.dart';
import 'package:business_manager_web_ui/src/features/products/product_records.dart';
import 'package:business_manager_web_ui/src/features/products/products_screen.dart';
import 'package:business_manager_web_ui/src/features/quotes/quotes_view.dart';
import 'package:business_manager_web_ui/src/features/quotes/quote_add_edit.dart';
import 'package:business_manager_web_ui/src/features/quotes/quote_terms.dart';
import 'package:business_manager_web_ui/src/features/purchases/view_purchases.dart';
import 'package:business_manager_web_ui/src/features/purchases/add_edit_purchase.dart';
import 'package:business_manager_web_ui/src/features/purchases/purchase_term.dart';
import 'package:business_manager_web_ui/src/features/suppliers/supplier_view.dart';
import 'package:business_manager_web_ui/src/features/suppliers/supplier_add_edit.dart';
import 'package:business_manager_web_ui/src/features/products/manufacturing/raw_material/raw_material_view.dart';
import 'package:business_manager_web_ui/src/features/products/manufacturing/raw_material/raw_cost_add.dart';
import 'package:business_manager_web_ui/src/features/purchases/material_receivable.dart';
import 'package:business_manager_web_ui/src/features/user_details/profile_settings.dart';
import 'package:business_manager_web_ui/src/features/user_details/account_settings.dart';
import 'package:business_manager_web_ui/src/features/user_details/app_settings.dart';
import 'package:business_manager_web_ui/src/features/user_details/app_settings/general_settings.dart';
import 'package:business_manager_web_ui/src/features/user_details/app_settings/inventory_settings.dart';
import 'package:business_manager_web_ui/src/features/user_details/app_settings/purchase_settings.dart';
import 'package:business_manager_web_ui/src/features/user_details/app_settings/financial_settings.dart';
import 'package:business_manager_web_ui/src/features/reports/sales_report.dart';
import 'package:business_manager_web_ui/src/features/reports/inventory/inventory_report_variables.dart';
import 'package:business_manager_web_ui/src/features/reports/profit_and_lost/pl_variables.dart';
import 'package:business_manager_web_ui/src/features/reports/profit_and_lost/pl_summary.dart';
import 'package:business_manager_web_ui/src/features/products/manufacturing/receipe_creation.dart';
import 'package:business_manager_web_ui/src/features/payments/payment_view.dart';
import 'package:business_manager_web_ui/src/features/capital_and_expenses/routing_page.dart';
import 'package:business_manager_web_ui/src/features/reports/reports_navigation.dart';
import 'package:business_manager_web_ui/src/features/products/manufacturing/receipe_view.dart';
import 'package:business_manager_web_ui/src/features/faq/faq_view.dart';
import 'package:business_manager_web_ui/src/features/user_details/contact_us.dart';
import 'package:business_manager_web_ui/src/features/capital_and_expenses/expenses/view_expenses.dart';
import 'package:business_manager_web_ui/src/features/capital_and_expenses/expenses/expenses_add_edit.dart';
import 'package:business_manager_web_ui/src/features/capital_and_expenses/assets/view_assets.dart';
import 'package:business_manager_web_ui/src/features/capital_and_expenses/assets/assets_add_edit.dart';
import 'package:business_manager_web_ui/src/features/faq/faq_edit_add.dart';
import 'package:business_manager_web_ui/src/features/business/business_type.dart';
import 'package:business_manager_web_ui/src/features/route_stub_screen.dart';
import 'package:business_manager_web_ui/src/features/sales/order_add_edit.dart';
import 'package:business_manager_web_ui/src/features/sales/order_terms.dart';
import 'package:business_manager_web_ui/src/features/sales/orders_screen.dart';
import 'package:business_manager_web_ui/src/features/sales/orders_view.dart';
import 'package:business_manager_web_ui/src/features/settings/settings_screen.dart';
import 'package:business_manager_web_ui/src/routing/app_shell.dart';
import 'package:go_router/go_router.dart';

/// Stage 4 scope so far: products list/browse. Route names/paths mirror
/// business_manager's src/routing/app_router.dart where mobile has an
/// equivalent route (mobile's tabs don't have their own URLs — that's a
/// web-native addition). Feature content (reports, clients, etc.) gets
/// added as each further stage builds it.
final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      name: '/',
      path: '/',
      builder: (context, state) => const Wrapper(),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(
        uid: state.pathParameters['uid'] ?? '',
        location: state.matchedLocation,
        child: child,
      ),
      routes: [
        GoRoute(
          name: 'homeId',
          path: '/home/:uid',
          builder: (context, state) =>
              HomeScreen(uid: state.pathParameters['uid']),
        ),
        GoRoute(
          name: 'orders',
          path: '/orders/:uid',
          builder: (context, state) =>
              OrdersScreen(uid: state.pathParameters['uid']),
        ),
        GoRoute(
          name: 'products',
          path: '/products/:uid',
          builder: (context, state) =>
              ProductScreen(uid: state.pathParameters['uid']),
        ),
        GoRoute(
          name: 'settings',
          path: '/settings/:uid',
          builder: (context, state) =>
              SettingsScreen(uid: state.pathParameters['uid']),
        ),
      ],
    ),
    GoRoute(
      name: 'register',
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      name: 'verifyEmail',
      path: '/verify-email',
      builder: (context, state) =>
          VerifyEmailScreen(email: state.extra as String?),
    ),
    GoRoute(
      name: 'login',
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      name: 'loginMessage',
      path: '/login/:message/:verified',
      builder: (context, state) => LoginScreen(
        message: state.pathParameters['message'],
        verified: state.pathParameters['verified'],
      ),
    ),
    GoRoute(
      name: 'forgot',
      path: '/forgot',
      builder: (context, state) => const ForgotScreen(),
    ),
    GoRoute(
      name: 'contactUs',
      path: '/contactUs',
      builder: (context, state) => const ContactUsStubScreen(),
    ),
    // Linked from products_screen.dart; real screens land in later stages.
    GoRoute(
      name: 'businessType',
      path: '/businessType/:uid',
      builder: (context, state) =>
          BusinessType(uid: state.pathParameters['uid']),
    ),
    // currencyLocation is an onboarding-only next-step this screen can
    // redirect to when a user's currency/address aren't set yet — out of
    // scope for now (a future stage, if ever needed post-onboarding).
    GoRoute(
      name: 'currencyLocation',
      path: '/currencyLocation/:uid',
      builder: (context, state) =>
          const RouteStubScreen(title: 'Currency & Location'),
    ),
    GoRoute(
      name: 'addProduct',
      path: '/addProduct/:uid',
      builder: (context, state) =>
          AddEditProduct(uid: state.pathParameters['uid']),
    ),
    GoRoute(
      name: 'editProduct',
      path: '/editProduct/:uid/:productId',
      builder: (context, state) => AddEditProduct(
        uid: state.pathParameters['uid'],
        productId: state.pathParameters['productId'],
      ),
    ),
    // Linked from add_product_screen.dart; real screens land in later stages
    // (product records, manufacturing recipes).
    GoRoute(
      name: 'viewImages',
      path: '/viewImages/:uid/:showAddButton',
      builder: (context, state) => ViewGallery(
        uid: state.pathParameters['uid'],
        showAddButton: state.pathParameters['showAddButton'] == 'true',
      ),
    ),
    GoRoute(
      name: 'productRecords',
      path: '/productRecords/:uid/:productId',
      builder: (context, state) => ProductRecords(
        uid: state.pathParameters['uid'],
        productId: state.pathParameters['productId'],
      ),
    ),
    GoRoute(
      name: 'receipeViewProduct',
      path: '/receipeView/:uid/:productId',
      builder: (context, state) => const RouteStubScreen(title: 'Recipe'),
    ),
    // Reached from Settings/Menu (once that's built) — the fuller order
    // list+search+filter+add, as opposed to the calendar-only Orders tab.
    GoRoute(
      name: 'orderView',
      path: '/orderView/:uid',
      builder: (context, state) => OrderView(uid: state.pathParameters['uid']),
    ),
    // OrderAddEdit — shared add/edit form, reached three ways on mobile.
    GoRoute(
      name: 'addOrder',
      path: '/addOrder/:uid',
      builder: (context, state) =>
          OrderAddEdit(uid: state.pathParameters['uid']),
    ),
    GoRoute(
      name: 'addOrderClient',
      path: '/addOrderClient/:uid/:clientId',
      builder: (context, state) => OrderAddEdit(
        uid: state.pathParameters['uid'],
        clientId: state.pathParameters['clientId'],
      ),
    ),
    GoRoute(
      name: 'editOrder',
      path: '/editOrder/:uid/:orderId',
      builder: (context, state) => OrderAddEdit(
        uid: state.pathParameters['uid'],
        orderId: state.pathParameters['orderId'],
      ),
    ),
    // OrderTerms — Stage 10 scope: delivery scheduling, terms & conditions,
    // charges, payment-reminder info, save. Invoice generation/printing and
    // order statistics are deferred (see comment atop order_terms.dart).
    GoRoute(
      name: 'orderTerms',
      path: '/orderTerms/:uid/:orderId',
      builder: (context, state) => OrderTerms(
        uid: state.pathParameters['uid'],
        orderId: state.pathParameters['orderId'],
      ),
    ),
    // Invoice settings screen isn't built yet — stubbed so the "Settings ›"
    // link on OrderTerms' terms-and-conditions card doesn't crash.
    GoRoute(
      name: 'invoice_settings',
      path: '/invoice_settings/:uid',
      builder: (context, state) =>
          const RouteStubScreen(title: 'Invoice Settings'),
    ),
    // Clients feature isn't built yet — stubbed so the "add client" link
    // from OrderAddEdit's client typeahead empty-state doesn't crash.
    GoRoute(
      name: 'addClient',
      path: '/addClient/:uid',
      builder: (context, state) =>
          ClientAddEdit(uid: state.pathParameters['uid']),
    ),
    GoRoute(
      name: 'editClient',
      path: '/editClient/:uid/:clientId',
      builder: (context, state) => ClientAddEdit(
        uid: state.pathParameters['uid'],
        clientId: state.pathParameters['clientId'],
      ),
    ),
    // client_statement.dart (dart:io-based PDF export) — deferred like
    // invoice generation; stubbed so the receipt-icon button doesn't crash.
    GoRoute(
      name: 'clientStatement',
      path: '/clientStatement/:uid/:clientId',
      builder: (context, state) => ClientStatment(
        uid: state.pathParameters['uid'],
        clientId: state.pathParameters['clientId'],
      ),
    ),
    // Reached from Home's sales-statistics section (top clients, top
    // products, upcoming payments) — Payments and top-products list screens
    // aren't built yet either.
    GoRoute(
      name: 'paymentView',
      path: '/paymentView/:uid',
      builder: (context, state) => PaymentView(
        uid: state.pathParameters['uid'],
      ),
    ),
    GoRoute(
      name: 'editPayment',
      path: '/editPayment/:uid/:paymentId',
      builder: (context, state) => const RouteStubScreen(title: 'Payment'),
    ),
    GoRoute(
      name: 'topProductsScreen',
      path: '/topProductsScreen/:uid',
      builder: (context, state) =>
          const RouteStubScreen(title: 'Top Products'),
    ),
    GoRoute(
      name: 'termsPage',
      path: '/termsPage/:uid',
      builder: (context, state) =>
          const RouteStubScreen(title: 'Terms of Use'),
    ),
    // Settings/Menu destinations (Stage 12) — none of these sub-screens are
    // built yet; each gets its own future stage.
    GoRoute(
      name: 'profile',
      path: '/profile/:uid',
      builder: (context, state) =>
          ProfileSettings(uid: state.pathParameters['uid']),
    ),
    GoRoute(
      name: 'accounts',
      path: '/accounts/:uid',
      builder: (context, state) =>
          AccountSettings(uid: state.pathParameters['uid']),
    ),
    // MapLocationPicker is the next Account-adjacent stage — a live map
    // location picker for the business-address section above.
    GoRoute(
      name: 'MapLocationPicker',
      path: '/MapLocationPicker/:uid',
      builder: (context, state) =>
          const RouteStubScreen(title: 'Business Address'),
    ),
    GoRoute(
      name: 'app_settings',
      path: '/app_settings/:uid',
      builder: (context, state) =>
          AppSettings(uid: state.pathParameters['uid']),
    ),
    // Destinations AppSettings' menu rows reach — each its own future stage.
    GoRoute(
      name: 'general_settings',
      path: '/general_settings/:uid',
      builder: (context, state) => GeneralSettingsWidget(
        uid: state.pathParameters['uid'],
      ),
    ),
    GoRoute(
      name: 'inventory_settings',
      path: '/inventory_settings/:uid',
      builder: (context, state) => CreateInventory(
        uid: state.pathParameters['uid'],
      ),
    ),
    GoRoute(
      name: 'purchase_settings',
      path: '/purchase_settings/:uid',
      builder: (context, state) => PurchaseSettings(
        uid: state.pathParameters['uid'],
      ),
    ),
    GoRoute(
      name: 'financial_settings',
      path: '/financial_settings/:uid',
      builder: (context, state) => FinancialSettings(
        uid: state.pathParameters['uid'],
      ),
    ),
    GoRoute(
      name: 'clientsView',
      path: '/clientsView/:uid',
      builder: (context, state) =>
          ClientsView(uid: state.pathParameters['uid']),
    ),
    GoRoute(
      name: 'quoteView',
      path: '/quoteView/:uid',
      builder: (context, state) => QuoteView(uid: state.pathParameters['uid']),
    ),
    // QuoteAddEdit — shared add/edit form, reached three ways, mirroring
    // OrderAddEdit's own routing. Quote terms is the next Quotes stage.
    GoRoute(
      name: 'addQuote',
      path: '/addQuote/:uid',
      builder: (context, state) =>
          QuoteAddEdit(uid: state.pathParameters['uid']),
    ),
    GoRoute(
      name: 'addQuoteClient',
      path: '/addQuoteClient/:uid/:clientId',
      builder: (context, state) => QuoteAddEdit(
        uid: state.pathParameters['uid'],
        clientId: state.pathParameters['clientId'],
      ),
    ),
    GoRoute(
      name: 'editQuote',
      path: '/editQuote/:uid/:quoteId',
      builder: (context, state) => QuoteAddEdit(
        uid: state.pathParameters['uid'],
        quoteId: state.pathParameters['quoteId'],
      ),
    ),
    GoRoute(
      name: 'editQuoteOrder',
      path: '/editQuoteOrder/:uid/:quoteId/:quoteToOrderId',
      builder: (context, state) => QuoteAddEdit(
        uid: state.pathParameters['uid'],
        quoteId: state.pathParameters['quoteId'],
        quoteToOrderId: state.pathParameters['quoteToOrderId']!.isEmpty
            ? null
            : state.pathParameters['quoteToOrderId'],
      ),
    ),
    GoRoute(
      name: 'quoteTerms',
      path: '/quoteTerms/:uid/:quoteId',
      builder: (context, state) => QuoteTerms(
        uid: state.pathParameters['uid'],
        quoteId: state.pathParameters['quoteId'],
      ),
    ),
    GoRoute(
      name: 'viewSupplier',
      path: '/viewSupplier/:uid',
      builder: (context, state) =>
          SupplierView(uid: state.pathParameters['uid']),
    ),
    GoRoute(
      name: 'purchaseView',
      path: '/purchaseView/:uid',
      builder: (context, state) =>
          PurchaseView(uid: state.pathParameters['uid']),
    ),
    // PurchaseAddEdit — shared add/edit form, reached three ways, mirroring
    // OrderAddEdit/QuoteAddEdit's own routing. PurchaseTerms is the next
    // Purchases stage; receiveMaterial/addSupplier/rawItemsAdd are stubs
    // reached from PurchaseAddEdit but belong to still-unbuilt features.
    GoRoute(
      name: 'addPurchase',
      path: '/addPurchase/:uid',
      builder: (context, state) =>
          PurchaseAddEdit(uid: state.pathParameters['uid']),
    ),
    GoRoute(
      name: 'addPurchaseName',
      path: '/addPurchaseName/:uid/:supplierId',
      builder: (context, state) => PurchaseAddEdit(
        uid: state.pathParameters['uid'],
        supplierId: state.pathParameters['supplierId'],
      ),
    ),
    GoRoute(
      name: 'editPurchase',
      path: '/editPurchase/:uid/:purchaseId',
      builder: (context, state) => PurchaseAddEdit(
        uid: state.pathParameters['uid'],
        purchaseId: state.pathParameters['purchaseId'],
      ),
    ),
    GoRoute(
      name: 'purchaseTerms',
      path: '/purchaseTerms/:uid/:purchaseId',
      builder: (context, state) => PurchaseTerms(
        uid: state.pathParameters['uid'],
        purchaseId: state.pathParameters['purchaseId'],
      ),
    ),
    GoRoute(
      name: 'receiveMaterial',
      path: '/receiveMaterial/:uid/:poId',
      builder: (context, state) => MaterialReceivalClass(
        uid: state.pathParameters['uid'],
        poId: state.pathParameters['poId'],
      ),
    ),
    GoRoute(
      name: 'addSupplier',
      path: '/addSupplier/:uid',
      builder: (context, state) =>
          SupplierAddEdit(uid: state.pathParameters['uid']),
    ),
    GoRoute(
      name: 'editSupplier',
      path: '/editSupplier/:uid/:supplierId',
      builder: (context, state) => SupplierAddEdit(
        uid: state.pathParameters['uid'],
        suppliedId: state.pathParameters['supplierId'],
      ),
    ),
    GoRoute(
      name: 'rawItemsAdd',
      path: '/rawItemsAdd/:uid',
      builder: (context, state) =>
          RawMaterialAddEdit(uid: state.pathParameters['uid']),
    ),
    GoRoute(
      name: 'rawItemsEdit',
      path: '/rawItemsEdit/:uid/:rawItemId',
      builder: (context, state) => RawMaterialAddEdit(
        uid: state.pathParameters['uid'],
        rawItemId: state.pathParameters['rawItemId'],
      ),
    ),
    GoRoute(
      name: 'capitalExpenses',
      path: '/capitalExpenses/:uid',
      builder: (context, state) =>
          RoutingPage(uid: state.pathParameters['uid']),
    ),
    // Destinations RoutingPage's two menu rows reach — each its own stage.
    GoRoute(
      name: 'viewExpenses',
      path: '/viewExpenses/:uid',
      builder: (context, state) =>
          ExpensesView(uid: state.pathParameters['uid']),
    ),
    GoRoute(
      name: 'addExpenses',
      path: '/addExpenses/:uid',
      builder: (context, state) =>
          ExpensesAddEdit(uid: state.pathParameters['uid']),
    ),
    GoRoute(
      name: 'editExpenses',
      path: '/editExpenses/:uid/:expenseId',
      builder: (context, state) => ExpensesAddEdit(
        uid: state.pathParameters['uid'],
        expenseId: state.pathParameters['expenseId'],
      ),
    ),
    GoRoute(
      name: 'viewAssets',
      path: '/viewAssets/:uid',
      builder: (context, state) =>
          AssetsView(uid: state.pathParameters['uid']),
    ),
    GoRoute(
      name: 'addAsset',
      path: '/addAsset/:uid',
      builder: (context, state) =>
          AssetsAddEdit(uid: state.pathParameters['uid']),
    ),
    GoRoute(
      name: 'editAsset',
      path: '/editAsset/:uid/:assetId',
      builder: (context, state) => AssetsAddEdit(
        uid: state.pathParameters['uid'],
        assetId: state.pathParameters['assetId'],
      ),
    ),
    GoRoute(
      name: 'reportsNavigation',
      path: '/reportsNavigation/:uid',
      builder: (context, state) =>
          ReportsNavigation(uid: state.pathParameters['uid']),
    ),
    // Destinations ReportsNavigation's three menu rows reach — each its own
    // future stage.
    GoRoute(
      name: 'salesReport',
      path: '/salesReport/:uid',
      builder: (context, state) => SalesReport(
        uid: state.pathParameters['uid'],
      ),
    ),
    GoRoute(
      name: 'inventoryReport',
      path: '/inventoryReport/:uid',
      builder: (context, state) => InventoryReportVariables(
        uid: state.pathParameters['uid'],
      ),
    ),
    GoRoute(
      name: 'plVariables',
      path: '/plVariables/:uid',
      builder: (context, state) => PandLVariables(
        uid: state.pathParameters['uid'],
      ),
    ),
    GoRoute(
      name: 'plSummary',
      path: '/plSummary/:uid/:start/:end',
      builder: (context, state) => PlSummary(
        uid: state.pathParameters['uid'],
        startDate: state.pathParameters['start'],
        endDate: state.pathParameters['end'],
        selectedOptions:
            state.extra as Map<String, Map<String, dynamic>>?,
      ),
    ),
    GoRoute(
      name: 'receipeView',
      path: '/receipeView/:uid',
      builder: (context, state) =>
          ReceipeView(uid: state.pathParameters['uid']),
    ),
    GoRoute(
      name: 'receipeViewProduct',
      path: '/receipeView/:uid/:productId',
      builder: (context, state) => ReceipeView(
        uid: state.pathParameters['uid'],
        productId: state.pathParameters['productId'],
      ),
    ),
    // ReceipeCreation (add/edit) is the next Recipes stage — reached from
    // ReceipeView's FAB and per-row edit button.
    GoRoute(
      name: 'receipeAdd',
      path: '/receipeAdd/:uid',
      builder: (context, state) => ReceipeCreation(
        uid: state.pathParameters['uid'],
      ),
    ),
    GoRoute(
      name: 'receipeEdit',
      path: '/receipeAdd/:uid/:receipeId',
      builder: (context, state) => ReceipeCreation(
        uid: state.pathParameters['uid'],
        receipeId: state.pathParameters['receipeId'],
      ),
    ),
    GoRoute(
      name: 'rawItemsView',
      path: '/rawItemsView/:uid',
      builder: (context, state) =>
          RawMaterialView(uid: state.pathParameters['uid']),
    ),
    GoRoute(
      name: 'faq',
      path: '/faq/:uid',
      builder: (context, state) => FaqView(uid: state.pathParameters['uid']),
    ),
    // FaqEditAdd (admin-only add/edit) is a future stage — reached only for
    // users with UserDetails.level == 'admin'.
    GoRoute(
      name: 'faq_add',
      path: '/faq_add/:uid',
      builder: (context, state) =>
          FaqEditAdd(uid: state.pathParameters['uid']),
    ),
    GoRoute(
      name: 'faq_edit',
      path: '/faq_edit/:uid/:questionId',
      builder: (context, state) => FaqEditAdd(
        uid: state.pathParameters['uid'],
        questionid: state.pathParameters['questionId'],
      ),
    ),
    GoRoute(
      name: 'contactUsId',
      path: '/contactUsId/:uid',
      builder: (context, state) => ContactUs(uid: state.pathParameters['uid']),
    ),
  ],
);
