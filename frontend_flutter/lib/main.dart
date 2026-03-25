import 'package:flutter/material.dart';
import 'pages/dashboard_page.dart';
import 'pages/landing_page.dart';
import 'pages/login_page.dart';
import 'pages/pilot_access_page.dart';
import 'pages/profile_page.dart';
import 'pages/reference_sheets_view.dart';
import 'pages/training_detail_page.dart';
import 'config/app_features.dart';
import 'config/runtime_config.dart';
import 'models/user_session.dart';
import 'state/app_state.dart';
import 'theme/app_ui_tokens.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/app_header.dart';
import 'widgets/admin_password_dialog.dart';
import 'widgets/daily_shift_reports_view.dart';
import 'widgets/dashboard_hub_card.dart';
import 'widgets/shift_selection_cards.dart';

part 'app/main_shell.dart';

void main() {
  runApp(const MtcCafeteriaApp());
}

/// Top-level dashboard surfaces reachable from the shell.
enum _DashboardView {
  hub,
  workflow,
  managerPortal,
  points,
  reference,
  findItem,
  diningMap,
  dailyShiftReports,
}

/// App bootstrap, theme, and top-level shell for the Flutter web client.
class MtcCafeteriaApp extends StatefulWidget {
  const MtcCafeteriaApp({super.key});

  @override
  State<MtcCafeteriaApp> createState() => _MtcCafeteriaAppState();
}

class _MtcCafeteriaAppState extends State<MtcCafeteriaApp> {
  final AppRuntimeConfig _runtimeConfig = AppRuntimeConfig.fromEnvironment;
  late final AppFeatures _features = AppFeatures.fromRuntimeConfig(
    _runtimeConfig,
  );
  late final AppState _state = AppState(runtimeConfig: _runtimeConfig);
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _state.initialize();
  }

  String _dashboardTrack = 'Line';
  bool _dashboardTrackConfirmed = false;
  String _dashboardMode = 'Employee';
  bool _dashboardRoleConfirmed = false;
  int _dashboardResetSignal = 0;
  int _dashboardBackSignal = 0;
  _DashboardView _dashboardView = _DashboardView.hub;
  bool _adminModeEnabled = false;

  static final DateTime _mealRotationAnchor = DateTime(2026, 3, 16);
  static const List<String> _mealWeekOrder = [
    'Pink',
    'Yellow',
    'Green',
    'Blue',
  ];

  void _updateUi(VoidCallback action) {
    if (!mounted) return;
    setState(action);
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  String _currentMealWeekLabel() {
    final today = _dateOnly(DateTime.now());
    final daysFromAnchor = today.difference(_mealRotationAnchor).inDays;
    final weekOffset = daysFromAnchor >= 0
        ? daysFromAnchor ~/ 7
        : -(((-daysFromAnchor - 1) ~/ 7) + 1);
    final index =
        ((weekOffset % _mealWeekOrder.length) + _mealWeekOrder.length) %
        _mealWeekOrder.length;
    return _mealWeekOrder[index];
  }

  Color _mealWeekAccent(String label) {
    switch (label) {
      case 'Pink':
        return const Color(0xFFC34F7B);
      case 'Yellow':
        return const Color(0xFFAF8B00);
      case 'Green':
        return const Color(0xFF2D7A55);
      case 'Blue':
      default:
        return const Color(0xFF2E69A6);
    }
  }

  static const List<String> _defaultShiftTracks = [
    'Line',
    'Dishroom',
    'Kitchen Jobs',
    'Night Custodial',
  ];

  List<String> _availableTracksForRole(String role) {
    // Pilot mode intentionally exposes only the tracks being tested.
    if (_runtimeConfig.isPilotProfile) {
      return const ['Line', 'Kitchen Jobs'];
    }
    return _defaultShiftTracks;
  }

  List<String> _lineModesForRole(String role) {
    if (_runtimeConfig.isPilotProfile) {
      switch (role) {
        case 'Supervisor':
        case 'Student Manager':
          return const ['Supervisor', 'Lead Trainer', 'Employee'];
        default:
          return const ['Employee'];
      }
    }

    switch (role) {
      case 'Lead Trainer':
        return const ['Lead Trainer', 'Employee'];
      case 'Supervisor':
        return const ['Supervisor', 'Lead Trainer', 'Employee'];
      case 'Student Manager':
        return const ['Supervisor', 'Lead Trainer', 'Employee'];
      default:
        return const ['Employee'];
    }
  }

  List<String> _dishroomModesForRole(String role) {
    if (role == 'Dishroom Lead Trainer') {
      return const ['Dishroom Lead Trainer', 'Dishroom Worker'];
    }
    return const ['Dishroom Worker'];
  }

  List<String> _modesForSelection(String role, String track) {
    switch (track) {
      case 'Line':
        return _lineModesForRole(role);
      case 'Dishroom':
        return _dishroomModesForRole(role);
      case 'Kitchen Jobs':
      case 'Night Custodial':
      default:
        return const [];
    }
  }

  bool _modeRequiresAdmin(String track, String mode) {
    if (track == 'Line' && (mode == 'Supervisor' || mode == 'Lead Trainer')) {
      return true;
    }
    if (track == 'Dishroom' && mode == 'Dishroom Lead Trainer') {
      return true;
    }
    return false;
  }

  void _resetDashboardSelectorsForRole(String role) {
    // Returning to the dashboard hub should clear any partial workflow state so
    // users never land mid-flow after changing tabs.
    final tracks = _availableTracksForRole(role);
    _dashboardTrack = tracks.first;
    _dashboardTrackConfirmed = false;
    _dashboardView = _DashboardView.hub;

    final modes = _modesForSelection(role, _dashboardTrack);
    _dashboardMode = modes.isEmpty ? _dashboardTrack : modes.first;
    _dashboardRoleConfirmed = modes.length <= 1;
  }

  Future<void> _resetActiveDashboardFlowState() async {
    final currentTrack = _dashboardTrack;
    final currentMode = _dashboardMode;

    if (currentTrack == 'Line' && currentMode == 'Supervisor') {
      await _state.resetSupervisorChecks();
    } else if (currentTrack == 'Line' && currentMode == 'Employee') {
      final board = _state.taskBoard;
      final jobId = board?.selectedJobId;
      if (board != null && jobId != null) {
        await _state.resetCurrentTaskFlow(
          meal: board.selectedMeal,
          jobId: jobId,
        );
      }
    } else if (currentTrack == 'Line' && currentMode == 'Lead Trainer') {
      _state.resetTrainerFlow();
    }
  }

  Future<void> _returnToDashboardHubAndReset(String role) async {
    await _resetActiveDashboardFlowState();
    _updateUi(() {
      _dashboardResetSignal += 1;
      _dashboardBackSignal = 0;
      _resetDashboardSelectorsForRole(role);
    });
  }

  void _handleDashboardBack({required _DashboardView effectiveDashboardView}) {
    // Non-workflow dashboard surfaces always return to the hub in one press.
    if (effectiveDashboardView != _DashboardView.workflow) {
      _dashboardView = _DashboardView.hub;
      return;
    }

    // Workflow back navigates exactly one level at a time.
    if (!_dashboardTrackConfirmed) {
      _dashboardView = _DashboardView.hub;
      return;
    }
    if (!_dashboardRoleConfirmed) {
      _dashboardTrackConfirmed = false;
      return;
    }

    // Inside an active flow, defer to section-local step handling.
    _dashboardBackSignal += 1;
  }

  void _handleBottomNavTap(int index) {
    final role = _state.user?.role;
    final effectiveIndex = _runtimeConfig.isPilotProfile && index > 1
        ? 1
        : index;
    if (role == null) {
      setState(() => _selectedIndex = effectiveIndex);
      return;
    }

    setState(() {
      if (effectiveIndex == 1) {
        _selectedIndex = 1;
        _returnToDashboardHubAndReset(role);
        return;
      }
      _selectedIndex = effectiveIndex;
    });
  }

  void _applyTrackSelection(String role, String track) {
    final modes = _modesForSelection(role, track);
    _dashboardTrack = track;
    _dashboardTrackConfirmed = true;
    _dashboardMode = modes.isEmpty ? track : modes.first;
    _dashboardRoleConfirmed = modes.length <= 1;

    // Opening supervisor mode needs the latest board data immediately because
    // finish gating depends on the selected meal's current state.
    if (_dashboardTrack == 'Line' && _dashboardMode == 'Supervisor') {
      _state.refreshSupervisorBoard();
    }
    if (_dashboardTrack == 'Student Manager Portal') {
      _state.refreshPointCenter();
    }
  }

  Future<void> _confirmAndLogout(BuildContext context) async {
    if (_runtimeConfig.isPilotProfile) {
      // Pilot mode intentionally behaves like a kiosk flow with no explicit
      // logout affordance.
      return;
    }

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;
    _state.logout();
    setState(() {
      _adminModeEnabled = false;
      _selectedIndex = 0;
      _dashboardTrack = 'Line';
      _dashboardTrackConfirmed = false;
      _dashboardMode = 'Employee';
      _dashboardRoleConfirmed = false;
      _dashboardView = _DashboardView.hub;
    });
  }

  Future<void> _openReferenceOverlay(
    BuildContext context, {
    String initialSection = 'Select',
    bool lockSection = false,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFFF4F8FE),
      builder: (sheetContext) {
        final mediaQuery = MediaQuery.of(sheetContext);
        final isWide = mediaQuery.size.width >= 760;
        return FractionallySizedBox(
          heightFactor: isWide ? 0.9 : 0.96,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 12, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        lockSection ? initialSection : 'Search Guides',
                        style: Theme.of(sheetContext).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ReferenceSheetsView(
                  initialSection: initialSection,
                  lockSection: lockSection,
                  useOuterCard: false,
                  adminModeEnabled: _adminModeEnabled,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _enableAdminMode(BuildContext context) async {
    final approved = await promptForAdminPassword(
      context,
      title: 'Enter Admin Password',
    );
    if (!approved || !mounted) return;
    _updateUi(() {
      _adminModeEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1A4E8A);
    const bg = Color(0xFFE1EAF7);
    const text = Color(0xFF0D2A4A);

    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: const Color(0xFF3E79B8),
      surface: Colors.white,
      onSurface: text,
      brightness: Brightness.light,
    );

    final baseText = ThemeData.light().textTheme;

    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        final user = _state.user;
        final isLoggedIn = _state.isAuthenticated;
        final availableTracks = user == null
            ? const <String>[]
            : _availableTracksForRole(user.role);

        final availableModes = user == null
            ? const <String>[]
            : _modesForSelection(user.role, _dashboardTrack);

        final canOpenManagerPortal =
            _features.managerPortalEnabled && (user?.canManageLanding ?? false);
        final canViewTrainings =
            _features.trainingsEnabled && (user?.canViewTrainings ?? false);
        final canAssignPoints =
            _features.pointsEnabled && (user?.canSubmitPointRequests ?? false);
        final canViewDailyShiftReports =
            _features.dailyShiftReportsEnabled &&
            (user?.canViewDailyShiftReports ?? false);
        final canViewReference = _features.referencesEnabled;

        // Guard hidden routes as well as hidden buttons so hot reloads or stale
        // state cannot leave the UI inside a disabled module.
        var effectiveDashboardView = _dashboardView;
        if (effectiveDashboardView == _DashboardView.reference &&
            !canViewReference) {
          effectiveDashboardView = _DashboardView.hub;
        }
        if (effectiveDashboardView == _DashboardView.findItem &&
            !canViewReference) {
          effectiveDashboardView = _DashboardView.hub;
        }
        if (effectiveDashboardView == _DashboardView.diningMap &&
            !canViewReference) {
          effectiveDashboardView = _DashboardView.hub;
        }
        if (effectiveDashboardView == _DashboardView.points &&
            !canAssignPoints) {
          effectiveDashboardView = _DashboardView.hub;
        }
        if (effectiveDashboardView == _DashboardView.managerPortal &&
            !canOpenManagerPortal) {
          effectiveDashboardView = _DashboardView.hub;
        }
        if (effectiveDashboardView == _DashboardView.dailyShiftReports &&
            !canViewDailyShiftReports) {
          effectiveDashboardView = _DashboardView.hub;
        }
        if (effectiveDashboardView != _dashboardView) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _dashboardView = effectiveDashboardView);
          });
        }

        final showTrackSelection =
            isLoggedIn &&
            _selectedIndex == 1 &&
            effectiveDashboardView == _DashboardView.workflow &&
            !_dashboardTrackConfirmed;

        final showModeSelection =
            isLoggedIn &&
            _selectedIndex == 1 &&
            effectiveDashboardView == _DashboardView.workflow &&
            _dashboardTrackConfirmed &&
            availableModes.length > 1 &&
            !_dashboardRoleConfirmed;

        final showDashboardBack =
            isLoggedIn &&
            _selectedIndex == 1 &&
            effectiveDashboardView != _DashboardView.hub;

        // Back-header labels reflect the current subview so mobile layouts can
        // drop the full brand lockup and still stay orienting.
        String backHeaderTitle = 'Dashboard';
        if (effectiveDashboardView == _DashboardView.reference) {
          backHeaderTitle = 'Guides';
        } else if (effectiveDashboardView == _DashboardView.findItem) {
          backHeaderTitle = 'Find an Item';
        } else if (effectiveDashboardView == _DashboardView.diningMap) {
          backHeaderTitle = 'Dining Map';
        } else if (effectiveDashboardView == _DashboardView.dailyShiftReports) {
          backHeaderTitle = 'Daily Shift Reports';
        } else if (effectiveDashboardView == _DashboardView.points) {
          backHeaderTitle = 'Assign Points';
        } else if (effectiveDashboardView == _DashboardView.managerPortal) {
          backHeaderTitle = 'Manager Portal';
        } else if (effectiveDashboardView == _DashboardView.workflow) {
          if (!_dashboardTrackConfirmed) {
            backHeaderTitle = 'Shift Area';
          } else if (!_dashboardRoleConfirmed && availableModes.length > 1) {
            backHeaderTitle = 'Role';
          } else if (_dashboardTrack == 'Line') {
            backHeaderTitle = _dashboardMode == 'Employee'
                ? 'Line Worker'
                : _dashboardMode;
          } else {
            backHeaderTitle = _dashboardTrack;
          }
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MTC Dining',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: scheme,
            scaffoldBackgroundColor: bg,
            fontFamily: 'Noto Sans',
            textTheme: baseText.copyWith(
              headlineSmall: baseText.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: text,
              ),
              titleMedium: baseText.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: text,
              ),
              bodyLarge: baseText.bodyLarge?.copyWith(
                color: const Color(0xFF1F3A5A),
                fontSize: 17,
                height: 1.38,
              ),
              bodyMedium: baseText.bodyMedium?.copyWith(
                color: const Color(0xFF274564),
                fontSize: 16,
                height: 1.38,
              ),
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: false,
              backgroundColor: Color(0xFFF8FBFF),
              foregroundColor: text,
              surfaceTintColor: Colors.transparent,
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shadowColor: const Color(0xFF0A2F53).withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppUiTokens.cardRadius),
                side: BorderSide(color: primary.withValues(alpha: 0.32)),
              ),
              margin: EdgeInsets.zero,
              surfaceTintColor: Colors.transparent,
              color: const Color(0xFFFBFDFF),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFFDFEFF),
              labelStyle: const TextStyle(color: Color(0xFF48607D)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppUiTokens.inputRadius),
                borderSide: BorderSide(color: primary.withValues(alpha: 0.22)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppUiTokens.inputRadius),
                borderSide: BorderSide(color: primary.withValues(alpha: 0.22)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(AppUiTokens.inputRadius),
                ),
                borderSide: BorderSide(color: primary, width: 2),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppUiTokens.buttonRadius),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                minimumSize: const Size(0, 54),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1F5E9C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppUiTokens.buttonRadius),
                ),
                side: BorderSide(color: primary.withValues(alpha: 0.25)),
                minimumSize: const Size(0, 54),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            navigationBarTheme: NavigationBarThemeData(
              height: 64,
              backgroundColor: const Color(0xFFF8FBFF),
              surfaceTintColor: Colors.transparent,
              indicatorColor: const Color(0xFFD7E8FC),
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
                states,
              ) {
                final selected = states.contains(WidgetState.selected);
                return TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? primary : const Color(0xFF5A7090),
                );
              }),
            ),
          ),
          home: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 760;
              final textScaler = isMobile
                  ? const TextScaler.linear(1.12)
                  : MediaQuery.of(context).textScaler;

              final mobileLogoSize = showDashboardBack ? 60.0 : 72.0;
              final mobileTitleSize = showDashboardBack ? 26.0 : 32.0;

              return Scaffold(
                appBar: AppBar(
                  toolbarHeight: appHeaderToolbarHeight(context),
                  centerTitle: showDashboardBack,
                  leading: showDashboardBack
                      ? IconButton(
                          key: const ValueKey('dashboard-back-button'),
                          tooltip: 'Back',
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            setState(() {
                              _handleDashboardBack(
                                effectiveDashboardView: effectiveDashboardView,
                              );
                            });
                          },
                        )
                      : null,
                  title: showDashboardBack
                      ? buildAppHeaderTitle(context, backHeaderTitle)
                      : Row(
                          children: [
                            Image.asset(
                              'assets/branding/mtc_logo_clean.jpg',
                              height: isMobile ? mobileLogoSize : 64,
                              width: isMobile ? mobileLogoSize : 64,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.grid_view_rounded),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'MTC Dining',
                                    style: TextStyle(
                                      fontSize: isMobile ? mobileTitleSize : 30,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.2,
                                      color: text,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                  actions: [
                    if (isLoggedIn)
                      AppHeaderMenuButton(
                        key: const ValueKey('app-menu-button'),
                        onSelected: (value) {
                          if (value == 'enter-admin') {
                            _enableAdminMode(context);
                            return;
                          }

                          if (value == 'exit-admin') {
                            _updateUi(() {
                              _adminModeEnabled = false;
                            });
                            return;
                          }

                          if (value == 'search-guides' && canViewReference) {
                            _openReferenceOverlay(context);
                            return;
                          }

                          if (value == 'find-item' && canViewReference) {
                            _openReferenceOverlay(
                              context,
                              initialSection: 'Find an Item',
                              lockSection: true,
                            );
                            return;
                          }

                          if (value == 'dining-map' && canViewReference) {
                            _openReferenceOverlay(
                              context,
                              initialSection: 'Dining Map',
                              lockSection: true,
                            );
                            return;
                          }

                          if (value == 'trainings' && canViewTrainings) {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => TrainingDetailPage(
                                  isPilotProfile: _runtimeConfig.isPilotProfile,
                                  navIndex:
                                      _runtimeConfig.isPilotProfile &&
                                          _selectedIndex > 1
                                      ? 0
                                      : _selectedIndex,
                                  onSelectNav: _handleBottomNavTap,
                                ),
                              ),
                            );
                            return;
                          }

                          if (value == 'logout') {
                            if (_runtimeConfig.isPilotProfile) return;
                            _confirmAndLogout(context);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            enabled: false,
                            height: 40,
                            value: 'meal-week',
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Color(0xFF244668),
                                  fontSize: 14,
                                  height: 1.1,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Week: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _currentMealWeekLabel(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: _mealWeekAccent(
                                        _currentMealWeekLabel(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            key: const ValueKey('menu-admin-mode'),
                            value: _adminModeEnabled
                                ? 'exit-admin'
                                : 'enter-admin',
                            child: Row(
                              children: [
                                Icon(
                                  _adminModeEnabled
                                      ? Icons.lock_open_outlined
                                      : Icons.lock_outline,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _adminModeEnabled
                                      ? 'Hide Admin Buttons'
                                      : 'Enter Admin Password',
                                ),
                              ],
                            ),
                          ),
                          if (canViewReference)
                            const PopupMenuItem<String>(
                              key: ValueKey('menu-search-guides'),
                              value: 'search-guides',
                              child: Row(
                                children: [
                                  Icon(Icons.menu_book_outlined, size: 18),
                                  SizedBox(width: 10),
                                  Text('Search Guides'),
                                ],
                              ),
                            ),
                          if (canViewReference)
                            const PopupMenuItem<String>(
                              key: ValueKey('menu-find-item'),
                              value: 'find-item',
                              child: Row(
                                children: [
                                  Icon(Icons.search, size: 18),
                                  SizedBox(width: 10),
                                  Text('Find an Item'),
                                ],
                              ),
                            ),
                          if (canViewReference)
                            const PopupMenuItem<String>(
                              key: ValueKey('menu-dining-map'),
                              value: 'dining-map',
                              child: Row(
                                children: [
                                  Icon(Icons.map_outlined, size: 18),
                                  SizedBox(width: 10),
                                  Text('Dining Map'),
                                ],
                              ),
                            ),
                          if (canViewTrainings &&
                              _selectedIndex == 1 &&
                              !showTrackSelection &&
                              !showModeSelection &&
                              _dashboardTrack == 'Line' &&
                              _dashboardMode == 'Lead Trainer')
                            const PopupMenuItem<String>(
                              key: ValueKey('menu-trainings'),
                              value: 'trainings',
                              child: Row(
                                children: [
                                  Icon(Icons.school, size: 18),
                                  SizedBox(width: 10),
                                  Text('2-minute Trainings'),
                                ],
                              ),
                            ),
                          if (!_runtimeConfig.isPilotProfile)
                            const PopupMenuItem<String>(
                              key: ValueKey('menu-logout'),
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(Icons.logout, size: 18),
                                  SizedBox(width: 10),
                                  Text('Logout'),
                                ],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
                body: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFF9FCFF), Color(0xFFE7EEF9)],
                    ),
                  ),
                  child: Align(
                    alignment: isLoggedIn && _selectedIndex == 1
                        ? Alignment.center
                        : Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isMobile ? 640 : 1240,
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          isMobile ? 16 : 20,
                          isMobile ? 14 : 14,
                          isMobile ? 16 : 20,
                          isMobile ? 16 : 18,
                        ),
                        child: MediaQuery(
                          data: MediaQuery.of(
                            context,
                          ).copyWith(textScaler: textScaler),
                          child: _buildMainShellContent(
                            context: context,
                            isLoggedIn: isLoggedIn,
                            user: user,
                            canViewReference: canViewReference,
                            canOpenManagerPortal: canOpenManagerPortal,
                            canViewTrainings: canViewTrainings,
                            canAssignPoints: canAssignPoints,
                            canViewDailyShiftReports: canViewDailyShiftReports,
                            effectiveDashboardView: effectiveDashboardView,
                            showTrackSelection: showTrackSelection,
                            showModeSelection: showModeSelection,
                            availableTracks: availableTracks,
                            availableModes: availableModes,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                bottomNavigationBar: _buildBottomNav(isLoggedIn),
              );
            },
          ),
        );
      },
    );
  }
}
