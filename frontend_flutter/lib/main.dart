import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pages/dashboard_page.dart';
import 'pages/landing_page.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';
import 'pages/reference_sheets_view.dart';
import 'pages/task_editor_page.dart';
import 'pages/training_detail_page.dart';
import 'config/app_features.dart';
import 'config/runtime_config.dart';
import 'models/user_session.dart';
import 'services/api_client.dart';
import 'state/app_state.dart';
import 'theme/stitch_theme.dart';
import 'theme/stitch_tokens.dart';
import 'widgets/app_bottom_nav.dart';
import 'theme/app_bar_title_override.dart';
import 'widgets/app_header.dart';
import 'widgets/admin_password_dialog.dart';
import 'widgets/daily_shift_reports_view.dart';
import 'widgets/dashboard_hub_card.dart';
import 'widgets/global_chat_widget.dart';
import 'widgets/manager_portal_nav.dart';
import 'widgets/shift_selection_cards.dart';

part 'app/main_shell.dart';

const String _feedbackFormUrl =
    'https://docs.google.com/forms/d/e/1FAIpQLSdpUPvjK-C2K9TbxKC0-L57WfJe2OFBVqHQpXwuFklC8DNI_Q/viewform?usp=header';

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
  late final ApiClient _chatApiClient = ApiClient(
    runtimeConfig: _runtimeConfig,
  );
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _state.initialize();
  }

  String _dashboardTrack = '';
  bool _dashboardTrackConfirmed = false;
  String _dashboardMode = '';
  bool _dashboardRoleConfirmed = false;
  int _dashboardResetSignal = 0;
  int _dashboardBackSignal = 0;
  _DashboardView _dashboardView = _DashboardView.hub;
  bool _adminModeEnabled = false;
  final ManagerPortalBackController _managerPortalBack =
      ManagerPortalBackController();
  final ReferenceSheetsBackController _referenceBack =
      ReferenceSheetsBackController();
  final ReferenceSheetsBackController _findItemBack =
      ReferenceSheetsBackController();

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
    return _defaultShiftTracks;
  }

  List<String> _lineModesForRole(String role) {
    // Line flow roles are an operational mode selector, not a strict mirror of
    // the authenticated account role. Always present all three options.
    return const ['Supervisor', 'Lead Trainer', 'Employee'];
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
    _dashboardTrack = '';
    _dashboardTrackConfirmed = false;
    _dashboardView = _DashboardView.hub;
    _dashboardMode = '';
    _dashboardRoleConfirmed = false;
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
    // Manager Portal owns an inner stack (tool grid ↔ sub-pane). Let it pop
    // one level first; only leave the portal entirely on the next press.
    if (effectiveDashboardView == _DashboardView.managerPortal) {
      if (_managerPortalBack.tryPop()) return;
      _dashboardView = _DashboardView.hub;
      return;
    }

    if (effectiveDashboardView == _DashboardView.reference) {
      if (_referenceBack.tryPop()) return;
      _dashboardView = _DashboardView.hub;
      return;
    }

    if (effectiveDashboardView == _DashboardView.findItem) {
      if (_findItemBack.tryPop()) return;
      _dashboardView = _DashboardView.hub;
      return;
    }

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
    if (role == null) {
      setState(() => _selectedIndex = index);
      return;
    }

    // Every bottom-nav tap — including re-taps of the current tab — returns
    // the user to the root of that tab. This makes the footer behave
    // predictably no matter how deep you are in a sub-view.
    _managerPortalBack.tryPop();
    setState(() => _selectedIndex = index);
    _returnToDashboardHubAndReset(role);
  }

  void _applyTrackSelection(String role, String track) {
    final modes = _modesForSelection(role, track);
    _dashboardTrack = track;
    _dashboardTrackConfirmed = true;
    if (modes.length == 1) {
      _dashboardMode = modes.first;
      _dashboardRoleConfirmed = true;
    } else if (modes.isEmpty) {
      _dashboardMode = '';
      _dashboardRoleConfirmed = true;
    } else {
      _dashboardMode = '';
      _dashboardRoleConfirmed = false;
    }

    // Opening supervisor mode needs the latest board data immediately because
    // finish gating depends on the selected meal's current state.
    if (_dashboardTrack == 'Line' && _dashboardMode == 'Supervisor') {
      _state.refreshSupervisorBoard();
    }
    if (_dashboardTrack == 'Line' && _dashboardMode == 'Employee') {
      _state.refreshTaskBoard();
    }
    if (_dashboardTrack == 'Line' && _dashboardMode == 'Lead Trainer') {
      _state.refreshTrainerBoard();
    }
    if (_dashboardTrack == 'Student Manager Portal') {
      _state.refreshPointCenter();
    }
  }

  Future<void> _confirmAndLogout(BuildContext context) async {
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
      _dashboardMode = '';
      _dashboardRoleConfirmed = false;
      _dashboardView = _DashboardView.hub;
    });
  }

  Future<void> _openReferenceOverlay(
    BuildContext context, {
    String initialSection = 'Select',
    bool lockSection = false,
  }) async {
    final backController = ReferenceSheetsBackController();
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
                    IconButton(
                      tooltip: 'Back',
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () {
                        if (!backController.tryPop()) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                    ),
                    Expanded(
                      child: Text(
                        lockSection ? initialSection : 'Guides',
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
                  key: ValueKey(
                    'reference-overlay-$initialSection-${lockSection ? 'locked' : 'free'}',
                  ),
                  initialSection: initialSection,
                  lockSection: lockSection,
                  useOuterCard: false,
                  adminModeEnabled: _adminModeEnabled,
                  backController: backController,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _enableAdminMode(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final approved = await promptForAdminPassword(
      context,
      title: 'Enter Student Manager Password',
    );
    if (!approved || !mounted) return;
    try {
      await _state.enterStudentManagerMode();
      if (!mounted) return;
      _updateUi(() {
        _adminModeEnabled = true;
      });
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not unlock the Student Manager Portal.'),
        ),
      );
    }
  }

  Future<void> _disableAdminMode(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _state.restoreSharedSession();
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not return to the shared session.'),
        ),
      );
      return;
    }
    if (!mounted) return;
    _updateUi(() {
      _adminModeEnabled = false;
      if (_dashboardView == _DashboardView.managerPortal) {
        _dashboardView = _DashboardView.hub;
      }
    });
  }

  /// Opens the task/job editor. Access is already gated by the Student
  /// Manager Portal password, so there is no second prompt here.
  Future<void> _openTaskEditor(BuildContext context) async {
    final navigator = Navigator.of(context);
    final authToken = _state.authToken;
    if (authToken == null || authToken.isEmpty) return;
    if (!mounted) return;
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => TaskEditorPage(authToken: authToken),
      ),
    );
  }

  Future<void> _openFeedbackForm(BuildContext context) async {
    final opened = await launchUrl(
      Uri.parse(_feedbackFormUrl),
      webOnlyWindowName: '_blank',
    );
    if (opened || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the feedback form.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = StitchColors.surface;

    final stitchTheme = buildStitchTheme();

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

        final canOpenManagerPortal = _adminModeEnabled;
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

        // Every screen in the app uses the same header style: the page name on
        // the left (with an optional back button) and the menu button on the
        // right. No brand lockup. This keeps typography identical everywhere.
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
          backHeaderTitle = 'Student Manager Portal';
        } else if (effectiveDashboardView == _DashboardView.workflow) {
          if (!_dashboardTrackConfirmed) {
            backHeaderTitle = 'Select Area';
          } else if (!_dashboardRoleConfirmed && availableModes.length > 1) {
            backHeaderTitle = 'Select Role';
          } else if (_dashboardTrack == 'Line') {
            if (_dashboardMode == 'Supervisor') {
              backHeaderTitle = 'Supervisor Checkoff';
            } else if (_dashboardMode == 'Lead Trainer') {
              backHeaderTitle = 'Lead Trainer';
            } else {
              backHeaderTitle = 'Line Worker';
            }
          } else {
            backHeaderTitle = _dashboardTrack;
          }
        }

        String rootHeaderTitle;
        if (!isLoggedIn) {
          rootHeaderTitle = 'Sign In';
        } else if (_selectedIndex == 0) {
          rootHeaderTitle = 'Announcements';
        } else if (_selectedIndex == 2) {
          rootHeaderTitle = 'Profile';
        } else {
          rootHeaderTitle = 'Dashboard';
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MTC Dining',
          theme: stitchTheme,
          home: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 760;
              final textScaler = isMobile
                  ? const TextScaler.linear(1.08)
                  : MediaQuery.of(context).textScaler;

              final headerTitle = showDashboardBack
                  ? backHeaderTitle
                  : rootHeaderTitle;

              return Scaffold(
                appBar: AppBar(
                  toolbarHeight: appHeaderToolbarHeight(context),
                  centerTitle: true,
                  titleSpacing: 0,
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
                  automaticallyImplyLeading: false,
                  title: ValueListenableBuilder<String?>(
                    valueListenable: appBarTitleOverride,
                    builder: (context, override, _) {
                      return buildAppHeaderTitle(
                        context,
                        override ?? headerTitle,
                      );
                    },
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
                            _disableAdminMode(context);
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
                                  navIndex: _selectedIndex,
                                  onSelectNav: _handleBottomNavTap,
                                ),
                              ),
                            );
                            return;
                          }

                          if (value == 'logout') {
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
                                  _adminModeEnabled ? 'Hide Admin' : 'Admin',
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
                                  Text('Guides'),
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
                                  Text('Find Item'),
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
                                  Text('Map'),
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
                body: Stack(
                  children: [
                    ColoredBox(
                      color: bg,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isMobile
                                ? StitchLayout.mobileMaxWidth
                                : StitchLayout.desktopMaxWidth,
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              isMobile
                                  ? StitchLayout.pagePaddingHMobile
                                  : StitchLayout.pagePaddingH,
                              isMobile ? 16 : 20,
                              isMobile
                                  ? StitchLayout.pagePaddingHMobile
                                  : StitchLayout.pagePaddingH,
                              isMobile ? 20 : 28,
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
                                canViewDailyShiftReports:
                                    canViewDailyShiftReports,
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
                    if (isLoggedIn && _features.chatbotEnabled)
                      GlobalChatWidget(
                        loadHealth: _chatApiClient.getChatbotHealth,
                        sendMessage: (message, sessionId) =>
                            _chatApiClient.sendChatbotMessage(
                              _state.authToken ?? '',
                              message,
                              sessionId: sessionId,
                            ),
                      ),
                  ],
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
