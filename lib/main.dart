import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/gifting_catalog_screen.dart';
import 'screens/group_funds_screen.dart';
import 'screens/home_calculator_screen.dart';
import 'screens/more_screen.dart';
import 'screens/my_orders_screen.dart';
import 'screens/order_status_screen.dart';
import 'screens/referral_screen.dart';
import 'screens/tutorial_screen.dart';
import 'services/cart_service.dart';
import 'services/order_service.dart';
import 'services/prefs_service.dart';
import 'theme/app_theme.dart';
import 'widgets/navbar_header.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.pureBlack,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final prefs = PrefsService();
  await prefs.init();

  final cart = CartService();
  await cart.init();

  final orderService = OrderService();
  await orderService.init();

  runApp(VesselBloxApp(
    prefs: prefs,
    cart: cart,
    orderService: orderService,
  ));
}

class VesselBloxApp extends StatelessWidget {
  final PrefsService prefs;
  final CartService cart;
  final OrderService orderService;

  const VesselBloxApp({
    super.key,
    required this.prefs,
    required this.cart,
    required this.orderService,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: prefs,
      builder: (context, _) {
        return MaterialApp(
          title: 'VesselBlox',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: MainShell(
            prefs: prefs,
            cart: cart,
            orderService: orderService,
          ),
        );
      },
    );
  }
}

class MainShell extends StatefulWidget {
  final PrefsService prefs;
  final CartService cart;
  final OrderService orderService;

  const MainShell({
    super.key,
    required this.prefs,
    required this.cart,
    required this.orderService,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _setTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _pushOrderStatus([String? orderId]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderStatusScreen(
          prefs: widget.prefs,
          orderService: widget.orderService,
          initialOrderId: orderId,
        ),
      ),
    );
  }

  void _pushTutorial() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TutorialScreen(
          prefs: widget.prefs,
          onGoHome: () {
            Navigator.pop(context);
            _setTab(0);
          },
        ),
      ),
    );
  }

  void _pushReferral() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReferralScreen(
          prefs: widget.prefs,
          onUseCode: () {
            Navigator.pop(context);
            _setTab(0);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isId = widget.prefs.lang == 'id';

    final screens = [
      HomeCalculatorScreen(
        prefs: widget.prefs,
        orderService: widget.orderService,
        onOpenGifting: () => _setTab(1),
        onOpenGroupFunds: () => _setTab(2),
        onOpenMyOrders: () => _setTab(3),
        onOpenOrderStatus: () => _pushOrderStatus(),
      ),
      GiftingCatalogScreen(
        prefs: widget.prefs,
        cart: widget.cart,
        orderService: widget.orderService,
        onOpenMyOrders: () => _setTab(3),
        onOpenOrderStatus: () => _pushOrderStatus(),
      ),
      GroupFundsScreen(
        prefs: widget.prefs,
        orderService: widget.orderService,
        onOpenTutorial: _pushTutorial,
        onOpenMyOrders: () => _setTab(3),
        onOpenOrderStatus: () => _pushOrderStatus(),
      ),
      MyOrdersScreen(
        prefs: widget.prefs,
        orderService: widget.orderService,
        onGoHome: () => _setTab(0),
      ),
      MoreScreen(
        prefs: widget.prefs,
        onOpenOrderStatus: () => _pushOrderStatus(),
        onOpenMyOrders: () => _setTab(3),
        onOpenTutorial: _pushTutorial,
        onOpenReferral: _pushReferral,
        onOpenCalculator: () => _setTab(0),
        onOpenGifting: () => _setTab(1),
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.voidBg,
      body: Column(
        children: [
          // Top Global Navbar
          NavbarHeader(prefs: widget.prefs),

          // Active Tab Screen
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.pureBlack,
          border: Border(
            top: BorderSide(color: AppTheme.hairline, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _setTab,
          backgroundColor: AppTheme.pureBlack,
          selectedItemColor: Colors.white,
          unselectedItemColor: AppTheme.textAshDim,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.bolt),
              activeIcon: const Icon(Icons.bolt, color: AppTheme.purplePrimary),
              label: isId ? 'Home' : 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.card_giftcard),
              activeIcon: const Icon(Icons.card_giftcard, color: AppTheme.purplePrimary),
              label: isId ? 'Gifting' : 'Gifting',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.groups),
              activeIcon: const Icon(Icons.groups, color: AppTheme.purplePrimary),
              label: isId ? 'Group Funds' : 'Group Funds',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long),
              activeIcon: const Icon(Icons.receipt_long, color: AppTheme.purplePrimary),
              label: isId ? 'Pesanan' : 'Orders',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.grid_view_rounded),
              activeIcon: const Icon(Icons.grid_view_rounded, color: AppTheme.purplePrimary),
              label: isId ? 'Lainnya' : 'More',
            ),
          ],
        ),
      ),
    );
  }
}
