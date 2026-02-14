import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/forensic_theme.dart';
import '../widgets/tactical_scaffold.dart';
import '../widgets/corner_bracket_container.dart';
import '../widgets/glitch_text.dart';

import '../features/forensic_cases/presentation/screens/cases_list_screen.dart';
import 'account_screen.dart';
import 'services_screen.dart';
import 'activity_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ["CASES", "ANALYSIS", "ACTIVITY", "PROFILE"];
  
  // Fake terminal logs
  final List<String> _logs = [
    "SYSTEM_INIT... OK",
    "CONNECTING_TO_SECURE_SERVER... OK",
    "ENCRYPTION_KEY_EXCHANGE... COMPLETE",
    "BIOMETRIC_VERIFICATION... BYPASSED (DEV_MODE)",
    "MOUNTING_DRIVE_C... OK",
    "CHECKING_INTEGRITY... 100%",
  ];
  String _currentLog = "SYSTEM_READY";
  Timer? _logTimer;
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _startLogSimulation();
    _startClock();
  }

  void _startLogSimulation() {
    _logTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentLog = _logs[timer.tick % _logs.length];
        });
      }
    });
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _logTimer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TacticalScaffold(
      body: Column(
        children: [
          // ───────── COMMAND HEADER ─────────
          _buildHeader(),

          // ───────── MAIN WORKSPACE ─────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                    // Module Selector
                  _buildModuleSelector(),
                  
                  const SizedBox(height: 12),

                  // Content Area
                  Expanded(
                    child: CornerBracketContainer(
                      color: ForensicColors.neonGreen.withOpacity(0.3),
                      padding: EdgeInsets.zero,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ForensicColors.panelBackground.withOpacity(0.8),
                          border: Border.all(color: ForensicColors.borderDim),
                        ),
                        child: TabBarView(
                          controller: _tabController,
                          children: const [
                            CasesListScreen(),
                            ServicesScreen(),
                            ActivityScreen(),
                            AccountScreen(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ───────── STATUS FOOTER ─────────
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(color: ForensicColors.neonGreen, width: 2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: ForensicColors.neonGreen, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlitchText(
                  "EXIF.FORENSICS.WORKBENCH",
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: ForensicColors.neonGreen,
                  ),
                ),
                Text(
                  "V2.0.0 :: CLASS_4_RESTRICTED // OPERATOR: ADMIN",
                  style: GoogleFonts.shareTechMono(
                    fontSize: 10,
                    color: ForensicColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Time/Status
           Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}",
                style: GoogleFonts.shareTechMono(
                  color: ForensicColors.cyberCyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 2.0
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                      color: ForensicColors.neonGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "SECURE",
                    style: GoogleFonts.shareTechMono(
                      fontSize: 10,
                      color: ForensicColors.neonGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleSelector() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: ForensicColors.cardBackground.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(color: ForensicColors.borderDim),
          top: BorderSide(color: ForensicColors.borderDim),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: ForensicColors.neonGreen,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.black,
        unselectedLabelColor: ForensicColors.textSecondary,
        labelStyle: GoogleFonts.shareTechMono(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
        // Custom Indicator to look like a highlighted block? 
        // For now, simpler standard indicator but with a background color for selected tab?
        indicator: BoxDecoration(
          color: ForensicColors.neonGreen,
          border: Border.all(color: ForensicColors.neonGreen),
        ),
        tabs: _tabs.map((t) => Tab(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("[$t]"),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.black,
      child: Row(
        children: [
          Text(
            ">",
            style: GoogleFonts.shareTechMono(color: ForensicColors.neonGreen),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
               "LOG :: $_currentLog",
               style: GoogleFonts.shareTechMono(
                 color: ForensicColors.textSecondary, 
                 fontSize: 12
               ),
               overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
