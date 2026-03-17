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
import 'state/app_state.dart';
import 'widgets/daily_shift_reports_view.dart';
import 'widgets/dashboard_hub_card.dart';
import 'widgets/shift_selection_cards.dart';

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
  final int _dashboardResetSignal = 0;
  _DashboardView _dashboardView = _DashboardView.hub;

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
          return const ['Supervisor', 'Employee'];
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

  void _openDashboardHub(String role) {
    _resetDashboardSelectorsForRole(role);
    _dashboardView = _DashboardView.hub;
    _selectedIndex = 1;
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
        // Always enter dashboard from a clean hub state.
        _openDashboardHub(role);
        return;
      }

      // Any non-dashboard tab clears dashboard transient state.
      _resetDashboardSelectorsForRole(role);
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
      _selectedIndex = 0;
      _dashboardTrack = 'Line';
      _dashboardTrackConfirmed = false;
      _dashboardMode = 'Employee';
      _dashboardRoleConfirmed = false;
      _dashboardView = _DashboardView.hub;
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
          backHeaderTitle = 'Reference';
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
                borderRadius: BorderRadius.circular(10),
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
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: primary.withValues(alpha: 0.22)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: primary.withValues(alpha: 0.22)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                borderSide: BorderSide(color: primary, width: 2),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
                  borderRadius: BorderRadius.circular(8),
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
                  toolbarHeight: isMobile ? 108 : 96,
                  centerTitle: showDashboardBack,
                  leading: showDashboardBack
                      ? IconButton(
                          key: const ValueKey('dashboard-back-button'),
                          tooltip: 'Back',
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            setState(() {
                              if (_dashboardView != _DashboardView.workflow) {
                                _dashboardView = _DashboardView.hub;
                                return;
                              }

                              if (!_dashboardTrackConfirmed) {
                                _dashboardView = _DashboardView.hub;
                                return;
                              }

                              if (!_dashboardRoleConfirmed) {
                                _dashboardTrackConfirmed = false;
                                return;
                              }

                              if (availableModes.length > 1) {
                                _dashboardRoleConfirmed = false;
                              } else {
                                _dashboardTrackConfirmed = false;
                                _dashboardRoleConfirmed = false;
                              }
                            });
                          },
                        )
                      : null,
                  title: showDashboardBack
                      ? Text(
                          backHeaderTitle,
                          style: TextStyle(
                            fontSize: isMobile ? 26 : 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                            color: text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
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
                      PopupMenuButton<String>(
                        key: const ValueKey('app-menu-button'),
                        tooltip: 'Menu',
                        padding: EdgeInsets.only(
                          left: 8,
                          right: isMobile ? 14 : 10,
                        ),
                        icon: Icon(Icons.menu, size: isMobile ? 32 : 28),
                        onSelected: (value) {
                          if (value == 'trainings' && canViewTrainings) {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => TrainingDetailPage(
                                  today: _state.trainingDate,
                                  todaysTraining: _state.todaysTraining,
                                  trainings: _state.trainings,
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
                          child: !isLoggedIn
                              ? _runtimeConfig.isPilotProfile
                                    ? PilotAccessPage(
                                        isLoading: _state.isLoading,
                                        error: _state.error,
                                        onRetry: () => _state.initialize(),
                                      )
                                    : LoginPage(
                                        isLoading: _state.isLoading,
                                        error: _state.error,
                                        onLogin: (email, password) async {
                                          await _state.login(email, password);
                                          if (_state.isAuthenticated &&
                                              mounted) {
                                            setState(() {
                                              _selectedIndex = 0;
                                              _resetDashboardSelectorsForRole(
                                                _state.user!.role,
                                              );
                                            });
                                          }
                                        },
                                      )
                              : _selectedIndex == 0
                              ? LandingPage(
                                  items: _state.landingItems,
                                  canManage: user!.canManageLanding,
                                  onCreate: (payload) =>
                                      _state.createLandingItem(payload),
                                  onUpdate: (id, payload) =>
                                      _state.updateLandingItem(id, payload),
                                  onDelete: (id) =>
                                      _state.deleteLandingItem(id),
                                )
                              : _selectedIndex == 1
                              ? effectiveDashboardView == _DashboardView.hub
                                    ? DashboardHubCard(
                                        canOpenReference: canViewReference,
                                        canOpenFindItem: canViewReference,
                                        canOpenDiningMap: canViewReference,
                                        canOpenManagerPortal:
                                            canOpenManagerPortal,
                                        canViewTrainings: canViewTrainings,
                                        canAssignPoints: canAssignPoints,
                                        canViewDailyShiftReports:
                                            canViewDailyShiftReports,
                                        onOpenWorkflow: () {
                                          setState(() {
                                            _dashboardView =
                                                _DashboardView.workflow;
                                          });
                                        },
                                        onOpenFindItem: () {
                                          if (!canViewReference) return;
                                          setState(() {
                                            _dashboardView =
                                                _DashboardView.findItem;
                                          });
                                        },
                                        onOpenDiningMap: () {
                                          if (!canViewReference) return;
                                          setState(() {
                                            _dashboardView =
                                                _DashboardView.diningMap;
                                          });
                                        },
                                        onOpenManagerPortal: () {
                                          if (!canOpenManagerPortal) return;
                                          setState(() {
                                            _dashboardView =
                                                _DashboardView.managerPortal;
                                            _state.refreshPointCenter();
                                          });
                                        },
                                        onOpenTrainings: () {
                                          if (!canViewTrainings) return;
                                          Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (_) =>
                                                  TrainingDetailPage(
                                                    today: _state.trainingDate,
                                                    todaysTraining:
                                                        _state.todaysTraining,
                                                    trainings: _state.trainings,
                                                  ),
                                            ),
                                          );
                                        },
                                        onOpenPoints: () {
                                          if (!canAssignPoints) return;
                                          setState(() {
                                            _dashboardView =
                                                _DashboardView.points;
                                          });
                                          _state.refreshPointCenter();
                                        },
                                        onOpenReference: () {
                                          if (!canViewReference) return;
                                          setState(() {
                                            _dashboardView =
                                                _DashboardView.reference;
                                          });
                                        },
                                        onOpenDailyShiftReports: () {
                                          if (!canViewDailyShiftReports) return;
                                          setState(() {
                                            _dashboardView = _DashboardView
                                                .dailyShiftReports;
                                          });
                                          _state.refreshDailyShiftReports();
                                        },
                                      )
                                    : effectiveDashboardView ==
                                          _DashboardView.reference
                                    ? const ReferenceSheetsView()
                                    : effectiveDashboardView ==
                                          _DashboardView.findItem
                                    ? const ReferenceSheetsView(
                                        initialSection: 'Find an Item',
                                        lockSection: true,
                                      )
                                    : effectiveDashboardView ==
                                          _DashboardView.diningMap
                                    ? const ReferenceSheetsView(
                                        initialSection: 'Dining Map',
                                        lockSection: true,
                                      )
                                    : effectiveDashboardView ==
                                          _DashboardView.dailyShiftReports
                                    ? DailyShiftReportsView(
                                        reports: _state.dailyShiftReports,
                                        error: _state.dailyShiftReportsError,
                                        onRefresh:
                                            _state.refreshDailyShiftReports,
                                      )
                                    : effectiveDashboardView ==
                                              _DashboardView.workflow &&
                                          showTrackSelection
                                    ? ShiftTrackSelectionCard(
                                        availableTracks: availableTracks,
                                        selectedTrack: _dashboardTrack,
                                        onTrackChanged: (track) => setState(
                                          () => _dashboardTrack = track,
                                        ),
                                        onContinue: () {
                                          if (user == null) return;
                                          setState(() {
                                            _applyTrackSelection(
                                              user.role,
                                              _dashboardTrack,
                                            );
                                          });
                                        },
                                      )
                                    : effectiveDashboardView ==
                                              _DashboardView.workflow &&
                                          showModeSelection
                                    ? ShiftRoleSelectionCard(
                                        title: _dashboardTrack == 'Dishroom'
                                            ? 'Select Dishroom Role'
                                            : 'Select Role',
                                        availableModes: availableModes,
                                        selectedMode: _dashboardMode,
                                        onModeChanged: (mode) => setState(
                                          () => _dashboardMode = mode,
                                        ),
                                        onContinue: () {
                                          setState(() {
                                            _dashboardRoleConfirmed = true;
                                          });
                                          if (_dashboardTrack == 'Line' &&
                                              _dashboardMode == 'Supervisor') {
                                            _state.refreshSupervisorBoard();
                                          }
                                        },
                                      )
                                    : DashboardPage(
                                        user: user!,
                                        resetFlowSignal: _dashboardResetSignal,
                                        selectedTrack:
                                            effectiveDashboardView ==
                                                _DashboardView.managerPortal
                                            ? 'Student Manager Portal'
                                            : effectiveDashboardView ==
                                                  _DashboardView.points
                                            ? 'Student Manager Portal'
                                            : _dashboardTrack,
                                        selectedMode:
                                            effectiveDashboardView ==
                                                _DashboardView.managerPortal
                                            ? 'Student Manager'
                                            : effectiveDashboardView ==
                                                  _DashboardView.points
                                            ? 'Leadership'
                                            : _dashboardMode,
                                        trainings: _state.trainings,
                                        todaysTraining: _state.todaysTraining,
                                        trainingDate: _state.trainingDate,
                                        taskBoard: _state.taskBoard,
                                        trainerBoard: _state.trainerBoard,
                                        supervisorBoard: _state.supervisorBoard,
                                        supervisorJobTaskBoard:
                                            _state.supervisorJobTaskBoard,
                                        supervisorSelectedJobId:
                                            _state.supervisorSelectedJobId,
                                        supervisorPanelMode:
                                            _state.supervisorPanelMode,
                                        supervisorSecondaries:
                                            _state.supervisorSecondaries,
                                        supervisorDeepCleanChecked:
                                            _state.isSupervisorDeepCleanChecked,
                                        currentLineShiftReport:
                                            _state.currentLineShiftReport,
                                        onSelectMeal: (meal) =>
                                            _state.selectMealKeepJob(meal),
                                        onSelectJob: (jobId) =>
                                            _state.refreshTaskBoard(
                                              meal: _state
                                                  .taskBoard
                                                  ?.selectedMeal,
                                              jobId: jobId,
                                            ),
                                        onTaskToggle: (taskId, completed) =>
                                            _state.setTaskCompletion(
                                              taskId: taskId,
                                              completed: completed,
                                            ),
                                        onSelectTrainerMeal: (meal) => _state
                                            .refreshTrainerBoard(meal: meal),
                                        trainerTraineeCount:
                                            _state.trainerTraineeCount,
                                        trainerSelectedTraineeSlot:
                                            _state.trainerSelectedTraineeSlot,
                                        trainerTraineeJobBySlot:
                                            _state.trainerTraineeJobBySlot,
                                        trainerSlotTasks:
                                            _state.trainerSlotTasks,
                                        onSetTrainerTraineeCount: (count) =>
                                            _state.setTrainerTraineeCount(
                                              count,
                                            ),
                                        onSetTrainerTraineeJob: (slot, jobId) =>
                                            _state.setTrainerTraineeJob(
                                              slot: slot,
                                              jobId: jobId,
                                            ),
                                        onSelectTrainerTraineeSlot: (slot) =>
                                            _state.selectTrainerTraineeSlot(
                                              slot,
                                            ),
                                        onTrainerSlotTaskToggle:
                                            (slot, taskId, completed) => _state
                                                .setTrainerSlotTaskCompletion(
                                                  slot: slot,
                                                  taskId: taskId,
                                                  completed: completed,
                                                ),
                                        onSelectTrainerJobs: (jobIds) async {},
                                        onTrainerTaskToggle:
                                            (
                                              traineeUserId,
                                              taskId,
                                              completed,
                                            ) async {},
                                        onSelectSupervisorMeal: (meal) => _state
                                            .refreshSupervisorBoard(meal: meal),
                                        onSupervisorOpenJob: (jobId) => _state
                                            .openSupervisorJobTasks(jobId),
                                        onSupervisorCloseJob: () =>
                                            _state.closeSupervisorJobTasks(),
                                        onSupervisorTaskToggle:
                                            (taskId, checked) =>
                                                _state.setSupervisorTaskCheck(
                                                  taskId: taskId,
                                                  checked: checked,
                                                ),
                                        onSupervisorBulkTaskToggle:
                                            (taskIds, checked) => _state
                                                .setSupervisorTaskChecksBulk(
                                                  taskIds: taskIds,
                                                  checked: checked,
                                                ),
                                        onSupervisorPanelModeChanged: (mode) =>
                                            _state.setSupervisorPanelMode(mode),
                                        onSupervisorSecondaryToggle:
                                            (index, checked) =>
                                                _state.toggleSecondaryJob(
                                                  index,
                                                  checked,
                                                ),
                                        onSupervisorDeepCleanToggle:
                                            (checked) => _state
                                                .toggleSupervisorDeepClean(
                                                  checked,
                                                ),
                                        onSupervisorResetSecondaries: () =>
                                            _state.resetSecondaryJobs(),
                                        onResetSupervisorChecks: () =>
                                            _state.resetSupervisorChecks(),
                                        onReloadSupervisorBoard: () =>
                                            _state.refreshSupervisorBoard(),
                                        onLoadCurrentLineShiftReport: (meal) =>
                                            _state.loadCurrentLineShiftReport(
                                              meal: meal,
                                            ),
                                        onSaveCurrentLineShiftReport:
                                            (meal, payload) => _state
                                                .saveCurrentLineShiftReportDraft(
                                                  meal: meal,
                                                  payload: payload,
                                                ),
                                        onSubmitCurrentLineShiftReport:
                                            (meal, payload) => _state
                                                .submitCurrentLineShiftReport(
                                                  meal: meal,
                                                  payload: payload,
                                                ),
                                        pendingAssignments: _state.pointInbox,
                                        pointSentAssignments: _state.pointSent,
                                        pointApprovalAssignments:
                                            _state.pointApprovalQueue,
                                        pointAssignableUsers:
                                            _state.pointAssignableUsers,
                                        pointInboxError: _state.pointInboxError,
                                        pointSentError: _state.pointSentError,
                                        pointAssignableUsersError:
                                            _state.pointAssignableUsersError,
                                        pointApprovalQueueError:
                                            _state.pointApprovalQueueError,
                                        onAcceptPointAssignment:
                                            (assignmentId, initials) =>
                                                _state.acceptAssignedPoints(
                                                  assignmentId: assignmentId,
                                                  initials: initials,
                                                ),
                                        onAssignPoints:
                                            ({
                                              required assignedToUserId,
                                              required pointsDelta,
                                              required assignmentDate,
                                              required reason,
                                              required assignmentDescription,
                                            }) => _state.assignPoints(
                                              assignedToUserId:
                                                  assignedToUserId,
                                              pointsDelta: pointsDelta,
                                              assignmentDate: assignmentDate,
                                              reason: reason,
                                              assignmentDescription:
                                                  assignmentDescription,
                                            ),
                                        onApprovePointAssignment:
                                            (assignmentId) =>
                                                _state.approvePointAssignment(
                                                  assignmentId: assignmentId,
                                                ),
                                        onRefreshPointCenter: () =>
                                            _state.refreshPointCenter(),
                                      )
                              : !_runtimeConfig.isPilotProfile &&
                                    _selectedIndex == 2
                              ? ProfilePage(user: user!)
                              : LandingPage(
                                  items: _state.landingItems,
                                  canManage: user!.canManageLanding,
                                  onCreate: (payload) =>
                                      _state.createLandingItem(payload),
                                  onUpdate: (id, payload) =>
                                      _state.updateLandingItem(id, payload),
                                  onDelete: (id) =>
                                      _state.deleteLandingItem(id),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                bottomNavigationBar: isLoggedIn
                    ? Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FBFF),
                          border: Border(
                            top: BorderSide(color: Color(0xFFD1DFEE)),
                          ),
                        ),
                        child: SafeArea(
                          top: false,
                          minimum: const EdgeInsets.only(bottom: 2),
                          child: BottomNavigationBar(
                            type: BottomNavigationBarType.fixed,
                            currentIndex:
                                _runtimeConfig.isPilotProfile &&
                                    _selectedIndex > 1
                                ? 0
                                : _selectedIndex,
                            onTap: _handleBottomNavTap,
                            iconSize: 24,
                            selectedFontSize: 14,
                            unselectedFontSize: 14,
                            backgroundColor: const Color(0xFFF8FBFF),
                            selectedItemColor: const Color(0xFF1A4E8A),
                            unselectedItemColor: const Color(0xFF5A7090),
                            selectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                            items: _runtimeConfig.isPilotProfile
                                ? const [
                                    BottomNavigationBarItem(
                                      icon: Icon(Icons.home_outlined),
                                      activeIcon: Icon(Icons.home),
                                      label: 'Home',
                                    ),
                                    BottomNavigationBarItem(
                                      icon: Icon(Icons.dashboard_outlined),
                                      activeIcon: Icon(Icons.dashboard),
                                      label: 'Dashboard',
                                    ),
                                  ]
                                : const [
                                    BottomNavigationBarItem(
                                      icon: Icon(Icons.home_outlined),
                                      activeIcon: Icon(Icons.home),
                                      label: 'Home',
                                    ),
                                    BottomNavigationBarItem(
                                      icon: Icon(Icons.dashboard_outlined),
                                      activeIcon: Icon(Icons.dashboard),
                                      label: 'Dashboard',
                                    ),
                                    BottomNavigationBarItem(
                                      icon: Icon(Icons.person_outline),
                                      activeIcon: Icon(Icons.person),
                                      label: 'Profile',
                                    ),
                                  ],
                          ),
                        ),
                      )
                    : null,
              );
            },
          ),
        );
      },
    );
  }
}
