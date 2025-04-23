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
import 'dart:math';

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
      body: Stack(
        children: [
          // Animated gradient background
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.primaryDark,
                  AppColors.primary,
                  Color(0xFFF58A42), // Slightly lighter orange for gradient
                ],
              ),
            ),
          ),
          
          // Decorative circles
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          
          // Floating particles
          CustomPaint(
            painter: _ParticlesPainter(),
            size: Size.infinite,
          ),
          
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with container
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.9),
                      border: Border.all(
                        width: 3,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'images/Gravity-Logo.png',
                      height: 120,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Text with animation
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: const Text(
                    'Gravity Rewards',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle with animation
                FutureBuilder(
                  future: Future.delayed(const Duration(milliseconds: 200)),
                  builder: (context, snapshot) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: snapshot.connectionState == ConnectionState.done ? 1.0 : 0.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: child,
                        );
                      },
                      child: const Text(
                        'Jump higher, earn more!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }
                ),
                
                const SizedBox(height: 40),
                
                // Loading indicator with animation
                FutureBuilder(
                  future: Future.delayed(const Duration(milliseconds: 400)),
                  builder: (context, snapshot) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: snapshot.connectionState == ConnectionState.done ? 1.0 : 0.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                      ),
                    );
                  }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Particle painter for animated background
class _ParticlesPainter extends CustomPainter {
  final int particleCount = 30;
  final List<_Particle> particles = [];
  final Random random = Random();
  
  _ParticlesPainter() {
    for (int i = 0; i < particleCount; i++) {
      particles.add(_Particle(
        position: Offset(
          random.nextDouble() * 400,
          random.nextDouble() * 800,
        ),
        radius: random.nextDouble() * 4 + 1,
        color: Colors.white.withOpacity(random.nextDouble() * 0.4 + 0.1),
        speed: random.nextDouble() * 1 + 0.5,
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    
    for (var particle in particles) {
      // Update position with floating effect
      final double yOffset = sin(DateTime.now().millisecondsSinceEpoch * 0.001 * particle.speed) * 20;
      final Offset currentPosition = Offset(
        (particle.position.dx + yOffset) % size.width,
        (particle.position.dy + particle.speed) % size.height,
      );
      
      // Draw particle
      paint.color = particle.color;
      canvas.drawCircle(currentPosition, particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Particle {
  final Offset position;
  final double radius;
  final Color color;
  final double speed;
  
  _Particle({
    required this.position,
    required this.radius,
    required this.color,
    required this.speed,
  });
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
      body: Stack(
        children: [
          // Animated gradient background
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.primaryDark,
                  AppColors.primary,
                  Color(0xFFF58A42), // Slightly lighter orange for gradient
                ],
              ),
            ),
          ),
          
          // Decorative circles
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          
          // Floating particles
          CustomPaint(
            painter: _ParticlesPainter(),
            size: Size.infinite,
          ),
          
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.9),
                    border: Border.all(
                      width: 3,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'images/Gravity-Logo.png',
                    height: 120,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Text
                const Text(
                  'Gravity Rewards',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                const Text(
                  'Jump higher, earn more!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Loading indicator
                Container(
                  width: 60,
                  height: 60,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

