import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/hive_service.dart';
import 'providers/expense_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/expense_list_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/analytics_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive local storage
  await HiveService.init();

  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
            create: (_) => ExpenseProvider()..loadExpenses()),
        ChangeNotifierProvider(
            create: (_) => BudgetProvider()..loadBudget()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'ExpenseTracker',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            initialRoute: '/',
            routes: {
              '/': (_) => const SplashScreen(),
              '/login': (_) => const LoginScreen(),
              '/home': (_) => const HomeScreen(),
              '/add': (_) => const AddExpenseScreen(),
              '/expenses': (_) => const ExpenseListScreen(),
              '/budget': (_) => const BudgetScreen(),
              '/analytics': (_) => const AnalyticsScreen(),
            },
          );
        },
      ),
    );
  }
}
