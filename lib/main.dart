import 'package:flutter/material.dart';
import 'package:gravity_rewards_app/constants/app_constants.dart';
import 'package:gravity_rewards_app/constants/app_theme.dart';
import 'package:gravity_rewards_app/providers/activity_provider.dart';
import 'package:gravity_rewards_app/providers/auth_provider.dart';
import 'package:gravity_rewards_app/providers/rewards_provider.dart';
import 'package:gravity_rewards_app/screens/claimed_rewards_screen.dart';
import 'package:gravity_rewards_app/screens/home_screen.dart';
import 'package:gravity_rewards_app/screens/login_screen.dart';
import 'package:gravity_rewards_app/screens/profile_screen.dart';
import 'package:gravity_rewards_app/services/notification_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RewardsProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
      ],
      child: MaterialApp(
        title: 'Gravity Rewards',
        theme: AppTheme.getTheme(),
        debugShowCheckedModeBanner: false,
       // home: LoginScreen(),
        home: const InitDataWrapper(),
        routes: {
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.home: (context) => const HomeScreen(),
          AppRoutes.profile: (context) => const ProfileScreen(),
          AppRoutes.claimedRewards: (context) => const ClaimedRewardsScreen(),
        },
      ),
    );
  }
}

// This widget initializes the providers with mock data
class InitDataWrapper extends StatefulWidget {
  const InitDataWrapper({Key? key}) : super(key: key);

  @override
  State<InitDataWrapper> createState() => _InitDataWrapperState();
}

class _InitDataWrapperState extends State<InitDataWrapper> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final rewardsProvider = Provider.of<RewardsProvider>(context, listen: false);
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    
    // Give auth provider time to initialize
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (authProvider.user != null) {
      // Load mock data for rewards and activities
      await rewardsProvider.loadRewardsForUser(authProvider.user!.id);
      await rewardsProvider.loadRedemptionHistory(authProvider.user!.id);
      await activityProvider.loadUserPoints(authProvider.user!.id);
      await activityProvider.loadActivityHistory(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSplashScreen();
        }
        
        return const AuthWrapper();
      },
    );
  }
  
  Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'images/Gravity-Logo.png',
              height: 120,
              color: AppColors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'Gravity Rewards',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// This widget monitors authentication state and routes accordingly
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // If loading, show splash screen
    if (authProvider.isLoading) {
      return _buildSplashScreen();
    }
    
    // For UI development - use this line to bypass authentication check
    // return const HomeScreen();
    
    // If authenticated, show home screen
    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    }
    
    // If not authenticated, show login screen
    return const LoginScreen();
  }
  
  Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'images/Gravity-Logo.png',
              height: 120,
              color: AppColors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'Gravity Rewards',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}

