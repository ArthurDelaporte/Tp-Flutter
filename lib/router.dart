import 'package:go_router/go_router.dart';
import 'screens/product_list_screen.dart';
import 'screens/product_form_screen.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ProductListScreen(),
    ),
    GoRoute(
      path: '/create',
      builder: (context, state) => const ProductFormScreen(),
    ),
    GoRoute(
      path: '/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProductFormScreen(id: id);
      },
    ),
  ],
);
