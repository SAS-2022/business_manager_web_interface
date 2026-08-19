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
          const RouteStubScreen(title: 'Business Type'),
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
      builder: (context, state) => const RouteStubScreen(title: 'Payments'),
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
      builder: (context, state) => const RouteStubScreen(title: 'Profile'),
    ),
    GoRoute(
      name: 'accounts',
      path: '/accounts/:uid',
      builder: (context, state) => const RouteStubScreen(title: 'Account'),
    ),
    GoRoute(
      name: 'app_settings',
      path: '/app_settings/:uid',
      builder: (context, state) =>
          const RouteStubScreen(title: 'App Settings'),
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
      builder: (context, state) => const RouteStubScreen(title: 'Quotes'),
    ),
    GoRoute(
      name: 'viewSupplier',
      path: '/viewSupplier/:uid',
      builder: (context, state) => const RouteStubScreen(title: 'Suppliers'),
    ),
    GoRoute(
      name: 'purchaseView',
      path: '/purchaseView/:uid',
      builder: (context, state) => const RouteStubScreen(title: 'Purchases'),
    ),
    GoRoute(
      name: 'capitalExpenses',
      path: '/capitalExpenses/:uid',
      builder: (context, state) =>
          const RouteStubScreen(title: 'Capital & Expenses'),
    ),
    GoRoute(
      name: 'reportsNavigation',
      path: '/reportsNavigation/:uid',
      builder: (context, state) =>
          const RouteStubScreen(title: 'Financial Reports'),
    ),
    GoRoute(
      name: 'receipeView',
      path: '/receipeView/:uid',
      builder: (context, state) => const RouteStubScreen(title: 'Recipes'),
    ),
    GoRoute(
      name: 'rawItemsView',
      path: '/rawItemsView/:uid',
      builder: (context, state) =>
          const RouteStubScreen(title: 'Raw Materials'),
    ),
    GoRoute(
      name: 'faq',
      path: '/faq/:uid',
      builder: (context, state) => const RouteStubScreen(title: 'FAQ'),
    ),
    GoRoute(
      name: 'contactUsId',
      path: '/contactUsId/:uid',
      builder: (context, state) => const RouteStubScreen(title: 'Contact Us'),
    ),
  ],
);
