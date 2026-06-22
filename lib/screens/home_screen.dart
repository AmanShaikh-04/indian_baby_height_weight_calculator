import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../models/assessment_data.dart';
import '../services/growth_engine.dart';
import '../services/storage_service.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/profile_bar.dart';
import '../widgets/input_form.dart';
import '../widgets/results_section.dart';
import '../dialogs/profile_dialogs.dart';

class GrowthCalculatorScreen extends StatefulWidget {
  const GrowthCalculatorScreen({super.key});

  @override
  State<GrowthCalculatorScreen> createState() => _GrowthCalculatorScreenState();
}

class _GrowthCalculatorScreenState extends State<GrowthCalculatorScreen> {
  String _system = 'metric';
  String _calcMode = 'full';

  List<Map<String, dynamic>> _profiles = [];
  String? _activeProfileId;
  String _quickCheckGender = 'boys';

  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _monthsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  Map<String, dynamic>? _growthData;
  bool _isLoading = true;
  bool _hasCalculated = false;

  AssessmentData? _currentAssessment;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadSettingsAndProfiles();
    await _loadGrowthDataBundle();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    bool isFirst = await StorageService.checkAndSetFirstLaunch();
    if (isFirst) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ProfileDialogs.showWelcomeProfile(context, onCreate: _saveProfileChanges);
      });
    }
  }

  Future<void> _loadSettingsAndProfiles() async {
    _system = await StorageService.getSystemSetting();
    List<Map<String, dynamic>> loadedProfiles = await StorageService.getProfiles();
    String? activeId = await StorageService.getActiveProfileId();

    setState(() {
      _profiles = loadedProfiles;
      _activeProfileId = activeId;
      if (_activeProfileId != null && !_profiles.any((p) => p['id'] == _activeProfileId)) {
        _activeProfileId = null;
      }
    });
    _updateAgeFromProfile();
  }

  void _updateAgeFromProfile() {
    if (_activeProfileId != null) {
      final profile = _profiles.firstWhere((p) => p['id'] == _activeProfileId);
      if (profile.containsKey('birthdate') && profile['birthdate'] != null) {
        DateTime dob = DateTime.parse(profile['birthdate']);
        DateTime now = DateTime.now();
        int years = now.year - dob.year;
        int months = now.month - dob.month;
        if (now.day < dob.day) months--;
        if (months < 0) { years--; months += 12; }
        _yearsController.text = years.toString();
        _monthsController.text = months.toString();
      }
    } else {
      _yearsController.clear();
      _monthsController.clear();
    }
  }

  Future<void> _loadGrowthDataBundle() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/iap_data.json');
      setState(() { _growthData = jsonDecode(jsonString); _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String get _currentGender {
    if (_activeProfileId == null) return _quickCheckGender;
    return _profiles.firstWhere((p) => p['id'] == _activeProfileId)['gender'];
  }

  void _calculateMetrics() {
    FocusScope.of(context).unfocus();
    if (_growthData == null) return;

    final int years = int.tryParse(_yearsController.text) ?? 0;
    final int months = int.tryParse(_monthsController.text) ?? 0;
    final double? rawWeight = _calcMode != 'ideal_weight' ? double.tryParse(_weightController.text) : null;
    final double? rawHeight = _calcMode != 'ideal_height' ? double.tryParse(_heightController.text) : null;

    if (_yearsController.text.isEmpty && _monthsController.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Please enter the child\'s age in years and/or months.'))); return; }
    if (months > 11) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Months should be between 0 and 11. Increase the Year instead.'))); return; }
    if (_calcMode == 'full' && (rawWeight == null || rawHeight == null)) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Please provide both weight and height for a full check.'))); return; }
    if (_calcMode == 'ideal_height' && rawWeight == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Please enter the weight to find the ideal height.'))); return; }
    if (_calcMode == 'ideal_weight' && rawHeight == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Please enter the height to find the ideal weight.'))); return; }

    double ageInYears = years + (months / 12.0);
    final int ageMonths = (years * 12) + months;

    if (ageInYears < 0 || ageInYears > 18.5) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ This app uses WHO/IAP data strictly for children aged 0 to 18 years.'))); return; }

    try {
      final AssessmentData result = GrowthEngine.evaluate(
        growthData: _growthData!,
        gender: _currentGender,
        ageMonths: ageMonths,
        rawWeight: rawWeight,
        rawHeight: rawHeight,
        system: _system,
      );

      setState(() {
        _hasCalculated = true;
        _currentAssessment = result;
      });
    } catch (errorMsg) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg.toString())));
    }
  }

  void _shareResults() {
    if (_currentAssessment == null) return;
    String childName = _activeProfileId != null ? _profiles.firstWhere((p) => p['id'] == _activeProfileId)['name'] : 'My child';

    String msg = GrowthEngine.generateBragMessage(
      data: _currentAssessment!,
      childName: childName,
      gender: _currentGender,
      system: _system,
      isForSocialShare: true,
    );
    Share.share(msg, subject: 'Baby Growth Milestone!');
  }

  Future<void> _saveRecord() async {
    if (_currentAssessment == null || _currentAssessment!.inputWeight == null || _currentAssessment!.inputHeight == null) return;
    if (_yearsController.text.isEmpty && _monthsController.text.isEmpty) return;
    if (_activeProfileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select or create a profile at the top to save.')));
      return;
    }

    List<Map<String, dynamic>> history = await StorageService.getDiary();

    double saveWeightKg = _system == 'imperial' ? (_currentAssessment!.inputWeight! / 2.20462) : _currentAssessment!.inputWeight!;
    double saveHeightCm = _system == 'imperial' ? (_currentAssessment!.inputHeight! * 2.54) : _currentAssessment!.inputHeight!;
    final int years = int.tryParse(_yearsController.text) ?? 0;
    final int months = int.tryParse(_monthsController.text) ?? 0;
    double saveAgeYears = years + (months / 12.0);

    final profile = _profiles.firstWhere((p) => p['id'] == _activeProfileId);
    final today = DateTime.now();

    bool isDuplicate = history.any((log) {
      final logDate = DateTime.parse(log['date']);
      return log['profileId'] == _activeProfileId &&
          (log['age'] as num).toDouble().toStringAsFixed(2) == saveAgeYears.toStringAsFixed(2) &&
          (log['weight'] as num).toDouble() == saveWeightKg &&
          (log['height'] as num).toDouble() == saveHeightCm &&
          logDate.year == today.year && logDate.month == today.month && logDate.day == today.day;
    });

    if (isDuplicate) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('⚠️ This exact reading is already saved today.'), backgroundColor: Colors.orange.shade700));
      return;
    }

    history.add({'id': DateTime.now().millisecondsSinceEpoch.toString(), 'profileId': _activeProfileId, 'name': profile['name'], 'gender': profile['gender'], 'date': DateTime.now().toIso8601String(), 'age': saveAgeYears, 'weight': saveWeightKg, 'height': saveHeightCm});
    await StorageService.saveDiary(history);

    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Saved to ${profile['name']}\'s Diary!'), backgroundColor: Colors.green.shade600));
  }

  Future<void> _saveProfileChanges(String name, String gender, DateTime date, {String? existingId}) async {
    if (existingId == null) {
      final newProfile = {'id': DateTime.now().millisecondsSinceEpoch.toString(), 'name': name, 'gender': gender, 'birthdate': date.toIso8601String()};
      _profiles.add(newProfile);
      await StorageService.setActiveProfileId(newProfile['id']!);
      _activeProfileId = newProfile['id'];
    } else {
      final idx = _profiles.indexWhere((p) => p['id'] == existingId);
      _profiles[idx]['name'] = name;
      _profiles[idx]['gender'] = gender;
      _profiles[idx]['birthdate'] = date.toIso8601String();

      List<Map<String, dynamic>> diary = await StorageService.getDiary();
      for (var log in diary) {
        if (log['profileId'] == existingId) {
          log['name'] = name;
          log['gender'] = gender;
        }
      }
      await StorageService.saveDiary(diary);
    }

    await StorageService.saveProfiles(_profiles);
    setState(() => _hasCalculated = false);
    _updateAgeFromProfile();
  }

  void _confirmDeleteProfile(String profileId) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('This will permanently delete this child and all their saved growth records.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
                onPressed: () async {
                  _profiles.removeWhere((p) => p['id'] == profileId);
                  await StorageService.saveProfiles(_profiles);

                  List<Map<String, dynamic>> diary = await StorageService.getDiary();
                  diary.removeWhere((log) => log['profileId'] == profileId);
                  await StorageService.saveDiary(diary);

                  if (_activeProfileId == profileId) {
                    _activeProfileId = null;
                    await StorageService.setActiveProfileId(null);
                  }

                  setState(() => _hasCalculated = false);
                  _updateAgeFromProfile();
                  Navigator.pop(ctx);
                },
                child: const Text('Delete Permanently', style: TextStyle(color: Colors.red))
            ),
          ],
        )
    );
  }

  void _switchProfile(String? id) async {
    await StorageService.setActiveProfileId(id);
    setState(() { _activeProfileId = id; _hasCalculated = false; });
    _updateAgeFromProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // Pull dynamic colors from the active theme
    final themeColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: CustomDrawer(onReturn: _loadSettingsAndProfiles),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: themeColor),
        title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/logo.png', height: 28, width: 28),
              const SizedBox(width: 8),
              Text('Growth Calculator', style: TextStyle(color: themeColor)) // Inherits weight from AppBarTheme
            ]
        ),
        centerTitle: true,
        actions: const [SizedBox(width: 48)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHorizontalBar(
                profiles: _profiles,
                activeProfileId: _activeProfileId,
                onProfileSelected: _switchProfile,
                onCreateNew: () => ProfileDialogs.showCreateProfile(context, onCreate: _saveProfileChanges),
                onEditProfile: (id) {
                  final p = _profiles.firstWhere((p) => p['id'] == id);
                  ProfileDialogs.showEditProfile(
                      context,
                      initialName: p['name'],
                      initialGender: p['gender'],
                      initialDate: p['birthdate'] != null ? DateTime.parse(p['birthdate']) : null,
                      onSave: (n, g, d) => _saveProfileChanges(n, g, d, existingId: id),
                      onDelete: () { Navigator.pop(context); _confirmDeleteProfile(id); }
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // Adaptive Settings Info Box - Updated for Fun Theme Shapes
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(24), // Increased from 12 to 24 for the bouncy look
                          border: Border.all(color: themeColor.withOpacity(0.2), width: 2) // Thicker border
                      ),
                      child: Row(
                          children: [
                            Icon(Icons.settings_rounded, size: 24, color: themeColor), // Used rounded icon
                            const SizedBox(width: 16),
                            Expanded(
                                child: Text(
                                    'Using ${(_system == 'metric' ? 'Metric (kg/cm)' : 'Imperial (lbs/in)')} System. Change this in Settings.',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: themeColor.withOpacity(0.9),
                                        fontWeight: FontWeight.w700 // Bolder text
                                    )
                                )
                            )
                          ]
                      ),
                    ),
                    const SizedBox(height: 16),

                    InputFormCard(
                      yearsController: _yearsController, monthsController: _monthsController, weightController: _weightController, heightController: _heightController,
                      system: _system, quickCheckGender: _quickCheckGender, isQuickCheck: _activeProfileId == null, calcMode: _calcMode,
                      onCalcModeChanged: (val) => setState(() { _calcMode = val; _hasCalculated = false; if (val == 'ideal_height') _heightController.clear(); if (val == 'ideal_weight') _weightController.clear(); }),
                      onGenderChanged: (val) => setState(() => _quickCheckGender = val),
                      onCalculate: _calculateMetrics,
                    ),

                    const SizedBox(height: 24),

                    if (_hasCalculated && _currentAssessment != null)
                      ResultsSection(
                        system: _system,
                        hasActiveProfile: _activeProfileId != null,
                        data: _currentAssessment!,
                        bragSnippet: GrowthEngine.generateBragMessage(
                          data: _currentAssessment!,
                          childName: _activeProfileId != null ? _profiles.firstWhere((p) => p['id'] == _activeProfileId)['name'] : 'My child',
                          gender: _currentGender,
                          system: _system,
                          isForSocialShare: false,
                        ),
                        onSave: _saveRecord,
                        onShare: _shareResults,
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}