import 'package:go_router/go_router.dart';
import 'package:sales_dashboard/dashboard/presentation/screens/screens.dart';


final appRouter = GoRouter(
  initialLocation: '/',
  routes: [

    GoRoute(
      path: '/',
      name: DashboardScreen.name,
      builder: (context, state) => const DashboardScreen(),
    ),
  ],
);