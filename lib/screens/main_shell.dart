import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/user_model.dart';
import '../providers/app_state.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/cart_drawer.dart';

import 'buyer/discovery_screen.dart';
import 'buyer/explore_screen.dart';
import 'buyer/orders_screen.dart';
import 'buyer/profile_screen.dart';
import 'common/direct_message_screen.dart';

import 'seller/seller_dashboard_screen.dart';
import 'seller/seller_menu_screen.dart';
import 'seller/seller_orders_screen.dart';

class MainShell extends StatefulWidget {
  final AppState state;

  const MainShell({super.key, required this.state});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isBuyer = state.activeRole == UserRole.buyer;

    Widget currentBody;
    if (isBuyer) {
      switch (state.currentTabIndex) {
        case 0:
          currentBody = DiscoveryScreen(state: state);
          break;
        case 1:
          currentBody = ExploreScreen(state: state);
          break;
        case 2:
          currentBody = OrdersScreen(state: state);
          break;
        case 3:
          currentBody = DirectMessageScreen(state: state);
          break;
        case 4:
          currentBody = ProfileScreen(state: state);
          break;
        default:
          currentBody = DiscoveryScreen(state: state);
      }
    } else {
      switch (state.currentTabIndex) {
        case 0:
          currentBody = SellerDashboardScreen(state: state);
          break;
        case 1:
          currentBody = SellerMenuScreen(state: state);
          break;
        case 2:
          currentBody = SellerOrdersScreen(state: state);
          break;
        case 3:
          currentBody = DirectMessageScreen(state: state);
          break;
        default:
          currentBody = SellerDashboardScreen(state: state);
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.canvas,
      endDrawer: CartDrawer(state: state),
      body: Row(
        children: [
          // Desktop Fixed Left Sidebar
          AppSidebar(
            state: state,
            onTabSelected: (index) => state.setTabIndex(index),
          ),

          // Main View Area
          Expanded(
            child: Column(
              children: [
                // Desktop Top Navigation Bar
                AppTopBar(
                  state: state,
                  onOpenCart: () {
                    _scaffoldKey.currentState?.openEndDrawer();
                  },
                ),

                // Active Screen Body with Animated Transition
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: KeyedSubtree(
                      key: ValueKey('${isBuyer ? "buyer" : "seller"}_${state.currentTabIndex}'),
                      child: currentBody,
                    ),
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
