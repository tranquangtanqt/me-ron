import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/auth/auth_notifier.dart';
import '../../presentation/screens/setting/about_screen.dart';
import '../../presentation/screens/address/address_form_screen.dart';
import '../../presentation/screens/address/address_screen.dart';
import '../../presentation/screens/category/category_form_screen.dart';
import '../../presentation/screens/category/category_screen.dart';
import '../../presentation/screens/setting/setting_screen.dart';
import '../../presentation/screens/setting/printer_settings_screen.dart';
import '../../presentation/screens/setting/profile_form_screen.dart';
import '../../presentation/screens/error/error_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/main/main_screen.dart';
import '../../presentation/screens/order/order_detail_screen.dart';
import '../../presentation/screens/order/order_form_screen.dart';
import '../../presentation/screens/order/order_screen.dart';
import '../../presentation/screens/products/product_form_screen.dart';
import '../../presentation/screens/products/products_screen.dart';
import '../../presentation/screens/report/report_order_screen.dart';
import '../../presentation/screens/transactions/transaction_detail_screen.dart';
import '../../presentation/screens/transactions/transactions_screen.dart';
import '../../presentation/screens/user/user_form_screen.dart';
import '../../presentation/screens/user/user_screen.dart';
import '../../presentation/screens/welcome/welcome_screen.dart';
import '../../presentation/screens/report/report_product_screen.dart';
import '../../presentation/screens/report/report_screen.dart';
import 'params/error_screen_param.dart';

/// Route paths
class AppRouteConst {
  static const login = '/login';
  static const home = '/home';
  static const splash = '/';
}

final GlobalKey<NavigatorState> _rootNavigatorKey =
GlobalKey<NavigatorState>();

final GlobalKey<NavigatorState> _shellNavigatorKey =
GlobalKey<NavigatorState>();

/// App routes
class AppRoutes {
  final Ref _ref;

  AppRoutes(this._ref) {
    _initialize();
  }

  static final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final navNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'nav');

  GoRouter? _router;
  GoRouter get router {
    if (_router == null) _initialize();
    return _router!;
  }

  void _initialize() {
    final authNotifier = _ref.read(authNotifierProvider);
    final authStateNotifier = ValueNotifier(authNotifier);

    // Dispose the notifier when the provider is disposed
    _ref.onDispose(authStateNotifier.dispose);

    // Listen to the auth state and update the ValueNotifier
    _ref.listen(authNotifierProvider, (_, value) => authStateNotifier.value = value);

    _router = GoRouter(
      initialLocation: AppRouteConst.splash,
      navigatorKey: rootNavigatorKey,
      refreshListenable: authStateNotifier,
      errorBuilder: (context, state) => ErrorScreen(param: ErrorScreenParam(error: state.error)),
      redirect: (context, state) {
        final location = state.uri.toString();
        if (location == AppRouteConst.splash) {
          return AppRouteConst.home;
        }
        return null;
      },
      routes: [
        _splash(),
        _main(),
        _error(),
      ],
    );
  }

  GoRoute _splash() {
    return GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    );
  }

  GoRoute _error() {
    return GoRoute(
      path: '/error',
      builder: (context, state) {
        if (state.extra == null || state.extra! is! ErrorScreenParam) {
          throw 'Required ErrorScreenParam is not provided!';
        }

        return ErrorScreen(param: state.extra as ErrorScreenParam);
      },
    );
  }

  ShellRoute _main() {
    return ShellRoute(
      navigatorKey: navNavigatorKey,
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return MainScreen(child: child);
      },
      routes: [
        _home(),
        _product(),
        _transactions(),
        _setting(),
        _address(),
        _category(),
        _user(),
        _order(),
        _report(),
      ],
    );
  }

  GoRoute _home() {
    return GoRoute(
      path: '/home',
      pageBuilder: (context, state) {
        return const NoTransitionPage<void>(
          child: HomeScreen(),
        );
      },
    );
  }

  GoRoute _product() {
    return GoRoute(
      path: '/product',
      pageBuilder: (context, state) {
        return const NoTransitionPage<void>(
          child: ProductsScreen(),
        );
      },
      routes: [
        _productCreate(),
        _productEdit(),
      ],
    );
  }

  GoRoute _transactions() {
    return GoRoute(
      path: '/transactions',
      pageBuilder: (context, state) {
        return const NoTransitionPage<void>(
          child: TransactionsScreen(),
        );
      },
      routes: [
        _transactionDetail(),
      ],
    );
  }

  GoRoute _address() {
    return GoRoute(
      path: '/address',
      pageBuilder: (context, state) {
        return const NoTransitionPage<void>(
          child: AddressScreen(),
        );
      },
      routes: [
        _addressCreate(),
        _addressEdit(),
      ],
    );
  }

  GoRoute _category() {
    return GoRoute(
      path: '/category',
      pageBuilder: (context, state) {
        return const NoTransitionPage<void>(
          child: CategoryScreen(),
        );
      },
      routes: [
        _categoryCreate(),
        _categoryEdit(),
      ],
    );
  }

  GoRoute _user() {
    return GoRoute(
      path: '/user',
      pageBuilder: (context, state) {
        return const NoTransitionPage<void>(
          child: UserScreen(),
        );
      },
      routes: [
        _userCreate(),
        _userEdit(),
      ],
    );
  }

  GoRoute _order() {
    return GoRoute(
      path: '/order',
      pageBuilder: (context, state) {
        return const NoTransitionPage<void>(
          child: OrderScreen(),
        );
      },
      routes: [
        _orderCreate(),
        _orderEdit(),
        _orderDetail(),
      ],
    );
  }

  GoRoute _report() {
    return GoRoute(
      path: '/report',
      pageBuilder: (context, state) {
        return const NoTransitionPage<void>(
          child: ReportScreen(),
        );
      },
      routes: [
        _reportOrder(),
        _reportProduct(),
      ],
    );
  }

  GoRoute _setting() {
    return GoRoute(
      path: '/setting',
      pageBuilder: (context, state) {
        return const NoTransitionPage<void>(
          child: SettingScreen(),
        );
      },
      routes: [
        _profileEdit(),
        _about(),
        _printerSettings(),
      ],
    );
  }

  GoRoute _productCreate() {
    return GoRoute(
      path: 'product-create',
      parentNavigatorKey: navNavigatorKey,
      builder: (context, state) {
        return const ProductFormScreen();
      },
    );
  }

  GoRoute _productEdit() {
    return GoRoute(
      path: 'product-edit/:id',
      builder: (context, state) {
        int? id = int.tryParse(state.pathParameters["id"] ?? '');

        if (id == null) {
          throw 'Required productId is not provided!';
        }

        return ProductFormScreen(id: id);
      },
    );
  }

  GoRoute _orderCreate() {
    return GoRoute(
      path: 'order-create',
      parentNavigatorKey: navNavigatorKey,
      builder: (context, state) {
        return const OrderFormScreen();
      },
    );
  }

  GoRoute _reportOrder() {
    return GoRoute(
      path: 'report-order',
      builder: (context, state) {
        return ReportOrderScreen();
      },
    );
  }

  GoRoute _reportProduct() {
    return GoRoute(
      path: 'report-product',
      builder: (context, state) {
        return ReportProductScreen();
      },
    );
  }

  GoRoute _orderEdit() {
    return GoRoute(
      path: 'order-edit/:id',
      builder: (context, state) {
        int? id = int.tryParse(state.pathParameters["id"] ?? '');

        if (id == null) {
          throw 'Required productId is not provided!';
        }

        return OrderFormScreen(id: id);
      },
    );
  }

  GoRoute _orderDetail() {
    return GoRoute(
      path: 'order-detail',
      parentNavigatorKey: navNavigatorKey,
      builder: (context, state) {
        return const OrderDetailScreen();
      },
    );
  }

  GoRoute _transactionDetail() {
    return GoRoute(
      path: 'transaction-detail/:id',
      builder: (context, state) {
        int? id = int.tryParse(state.pathParameters["id"] ?? '');

        if (id == null) {
          throw 'Required productId is not provided!';
        }

        return TransactionDetailScreen(id: id);
      },
    );
  }

  GoRoute _profileEdit() {
    return GoRoute(
      path: 'profile',
      builder: (context, state) {
        return const ProfileFormScreen();
      },
    );
  }

  GoRoute _about() {
    return GoRoute(
      path: 'about',
      builder: (context, state) {
        return const AboutScreen();
      },
    );
  }

  GoRoute _printerSettings() {
    return GoRoute(
      path: 'printer-settings',
      builder: (context, state) {
        return const PrinterSettingsScreen();
      },
    );
  }

  GoRoute _addressCreate() {
    return GoRoute(
      path: 'address-create',
      builder: (context, state) {
        return const AddressFormScreen();
      },
    );
  }

  GoRoute _addressEdit() {
    return GoRoute(
      path: 'address-edit/:code',
      builder: (context, state) {
        String? code = state.pathParameters["code"] ?? '';

        if (code.isEmpty) {
          throw 'Required code is not provided!';
        }

        return AddressFormScreen(code: code);
      },
    );
  }

  GoRoute _categoryCreate() {
    return GoRoute(
      path: 'category-create',
      builder: (context, state) {
        return const CategoryFormScreen();
      },
    );
  }

  GoRoute _categoryEdit() {
    return GoRoute(
      path: 'category-edit/:id',
      builder: (context, state) {
        int? id = int.tryParse(state.pathParameters["id"] ?? '');

        if (id == null) {
          throw 'Required id is not provided!';
        }

        return CategoryFormScreen(id: id);
      },
    );
  }


  GoRoute _userCreate() {
    return GoRoute(
      path: 'user-create',
      builder: (context, state) {
        return const UserFormScreen();
      },
    );
  }

  GoRoute _userEdit() {
    return GoRoute(
      path: 'user-edit/:id',
      builder: (context, state) {
        int? id = int.tryParse(state.pathParameters["id"] ?? '');

        if (id == null) {
          throw 'Required id is not provided!';
        }

        return UserFormScreen(id: id);
      },
    );
  }
}
