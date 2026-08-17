import 'package:business_manager_web_ui/src/features/auth/forgot_screen.dart';
import 'package:business_manager_web_ui/src/features/auth/login_screen.dart';
import 'package:business_manager_web_ui/src/features/auth/register_screen.dart';
import 'package:business_manager_web_ui/src/features/auth/verify_email_screen.dart';
import 'package:business_manager_web_ui/src/features/auth/wrapper.dart';
import 'package:business_manager_web_ui/src/features/contact_us_stub_screen.dart';
import 'package:business_manager_web_ui/src/features/gallery/view_gallery.dart';
import 'package:business_manager_web_ui/src/features/home/home_screen.dart';
import 'package:business_manager_web_ui/src/features/products/add_product_screen.dart';
import 'package:business_manager_web_ui/src/features/products/product_records.dart';
import 'package:business_manager_web_ui/src/features/products/products_screen.dart';
import 'package:business_manager_web_ui/src/features/route_stub_screen.dart';
import 'package:business_manager_web_ui/src/features/sales/order_add_edit.dart';
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
    // order_terms.dart (delivery/payment terms config, 2,027 lines) —
    // deferred to its own future stage; stubbed so the post-save navigation
    // from OrderAddEdit doesn't crash.
    GoRoute(
      name: 'orderTerms',
      path: '/orderTerms/:uid/:orderId',
      builder: (context, state) => const RouteStubScreen(title: 'Order Terms'),
    ),
    // Clients feature isn't built yet — stubbed so the "add client" link
    // from OrderAddEdit's client typeahead empty-state doesn't crash.
    GoRoute(
      name: 'addClient',
      path: '/addClient/:uid',
      builder: (context, state) => const RouteStubScreen(title: 'Add Client'),
    ),
  ],
);
