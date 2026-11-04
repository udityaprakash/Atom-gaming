import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/alarm_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../features/sessions/presentation/screens/alarm_trigger_screen.dart';
import '../../features/sessions/providers/session_provider.dart';

class AppScaffold extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({super.key, required this.navigationShell});

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  final Set<String> _alarmedSessionIds = {};

  @override
  Widget build(BuildContext context) {
    // Live tick listener to detect session expirations and fire the alarm screen
    ref.listen(liveTimerTickerProvider, (prev, nowAsync) async {
      final now = nowAsync.value ?? DateTime.now();
      final activeSessions = ref.read(activeRoomSessionsStreamProvider).value;
      if (activeSessions == null || activeSessions.isEmpty) {
        _alarmedSessionIds.clear();
        return;
      }

      final activeIds = activeSessions.map((s) => s.session.id).toSet();
      _alarmedSessionIds.removeWhere((id) => !activeIds.contains(id));

      for (final active in activeSessions) {
        // If session was extended into future, remove from alarmed set so it alarms again later
        if (now.isBefore(active.session.scheduledEndAt)) {
          _alarmedSessionIds.remove(active.session.id);
          continue;
        }

        // Session has reached or passed scheduled end time
        if (!_alarmedSessionIds.contains(active.session.id)) {
          _alarmedSessionIds.add(active.session.id);

          final alarmService = ref.read(alarmServiceProvider);
          final autoOvertime = await alarmService.isAutoOvertimeEnabled();

          // If auto overtime is disabled (default), automatically pause session so overtime timer does not tick
          if (!autoOvertime && active.session.status == AppConstants.sessionActive) {
            await ref.read(sessionRepositoryProvider).pauseSession(sessionId: active.session.id);
          }

          // Show immediate lockscreen/status bar notification
          await alarmService.showImmediateAlert(
            sessionId: active.session.id,
            roomName: active.room.roomName,
            title: "TIME'S UP: ${active.room.roomName}",
            body: 'Gaming session duration has completed for ${active.room.roomName}!',
          );

          // Push full-screen buzzing alarm screen
          if (mounted) {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => AlarmTriggerScreen(activeSession: active),
                fullscreenDialog: true,
              ),
            );
          }
          break; // Show one alarm screen at a time
        }
      }
    });

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: widget.navigationShell.currentIndex,
          onTap: (index) {
            widget.navigationShell.goBranch(
              index,
              initialLocation: index == widget.navigationShell.currentIndex,
            );
          },
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: GoogleFonts.rajdhani(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: GoogleFonts.rajdhani(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.meeting_room_outlined),
              activeIcon: Icon(Icons.meeting_room),
              label: 'Rooms',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              activeIcon: Icon(Icons.timer),
              label: 'Sessions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
