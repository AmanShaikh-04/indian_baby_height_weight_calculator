import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/custom_drawer.dart';
import '../widgets/growth_cards.dart';
import '../widgets/profile_bar.dart';
import '../widgets/input_form.dart';

class GrowthCalculatorScreen extends StatefulWidget {
  const GrowthCalculatorScreen({super.key});

  @override
  State<GrowthCalculatorScreen> createState() => _GrowthCalculatorScreenState();
}

class _GrowthCalculatorScreenState extends State<GrowthCalculatorScreen> {
  String _system = 'metric';
  String _ageUnit = 'months';

  List<Map<String, dynamic>> _profiles = [];
  String? _activeProfileId;
  String _quickCheckGender = 'boys';

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  Map<String, dynamic>? _growthData;
  bool _isLoading = true;
  bool _hasCalculated = false;

  double? _inputWeight;
  double? _inputHeight;
  String _weightStatus = '';
  String _heightStatus = '';

  double _idealWeightMin = 0, _idealWeightMax = 0, _idealWeightTarget = 0;
  double _idealHeightMin = 0, _idealHeightMax = 0, _idealHeightTarget = 0;
  double _p3Weight = 0, _p97Weight = 0;
  double _p3Height = 0, _p97Height = 0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadSettingsAndProfiles();
    await _loadGrowthDataBundle();
  }

  Future<void> _loadSettingsAndProfiles() async {
    final prefs = await SharedPreferences.getInstance();

    _system = prefs.getString('setting_system') ?? 'metric';
    _ageUnit = prefs.getString('setting_age_unit') ?? 'months';

    List<String> rawProfiles = prefs.getStringList('ibhwc_profiles') ?? [];

    setState(() {
      _profiles = rawProfiles.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
      _activeProfileId = prefs.getString('active_profile_id');

      if (_activeProfileId != null && !_profiles.any((p) => p['id'] == _activeProfileId)) {
        _activeProfileId = null;
      }
    });
  }

  Future<void> _loadGrowthDataBundle() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/iap_data.json');
      setState(() {
        _growthData = jsonDecode(jsonString);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String get _currentGender {
    if (_activeProfileId == null) return _quickCheckGender;
    return _profiles.firstWhere((p) => p['id'] == _activeProfileId)['gender'];
  }

  String _formatWeight(double kgVal) => _system == 'imperial' ? '${(kgVal * 2.20462).toStringAsFixed(1)} lbs' : '${kgVal.toStringAsFixed(1)} kg';
  String _formatHeight(double cmVal) => _system == 'imperial' ? '${(cmVal / 2.54).toStringAsFixed(1)} in' : '${cmVal.toStringAsFixed(1)} cm';

  void _calculateMetrics() {
    FocusScope.of(context).unfocus();
    if (_growthData == null) return;

    final double? rawAge = double.tryParse(_ageController.text);
    final double? rawWeight = double.tryParse(_weightController.text);
    final double? rawHeight = double.tryParse(_heightController.text);

    if (rawAge == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Please enter the child\'s age.')));
      return;
    }

    double ageInYears = _ageUnit == 'months' ? (rawAge / 12) : rawAge;
    if (ageInYears < 0 || ageInYears > 18.5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ This app uses WHO/IAP data which is strictly for children aged 0 to 18 years.')));
      return;
    }

    double? calcWeightKg = rawWeight;
    double? calcHeightCm = rawHeight;

    if (_system == 'imperial') {
      if (calcWeightKg != null) calcWeightKg = rawWeight! / 2.20462;
      if (calcHeightCm != null) calcHeightCm = rawHeight! * 2.54;
    }

    if (calcWeightKg != null && (calcWeightKg < 1 || calcWeightKg > 150)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Please enter a realistic weight.')));
      return;
    }

    if (calcHeightCm != null && (calcHeightCm < 30 || calcHeightCm > 250)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Please enter a realistic height.')));
      return;
    }

    final int ageMonths = (ageInYears * 12).round();

    final List<dynamic> weightChart = _growthData![_currentGender]['weight'];
    final List<dynamic> heightChart = _growthData![_currentGender]['height'];

    final matchedWeightRow = weightChart.firstWhere((row) => row['age_months'] >= ageMonths, orElse: () => weightChart.last);
    final matchedHeightRow = heightChart.firstWhere((row) => row['age_months'] >= ageMonths, orElse: () => heightChart.last);

    setState(() {
      _hasCalculated = true;
      _inputWeight = rawWeight;
      _inputHeight = rawHeight;

      _p3Weight = (matchedWeightRow['p3'] as num).toDouble();
      _idealWeightMin = (matchedWeightRow['p15'] as num).toDouble();
      _idealWeightTarget = (matchedWeightRow['p50'] as num).toDouble();
      _idealWeightMax = (matchedWeightRow['p85'] as num).toDouble();
      _p97Weight = (matchedWeightRow['p97'] as num).toDouble();

      _p3Height = (matchedHeightRow['p3'] as num).toDouble();
      _idealHeightMin = (matchedHeightRow['p15'] as num).toDouble();
      _idealHeightTarget = (matchedHeightRow['p50'] as num).toDouble();
      _idealHeightMax = (matchedHeightRow['p85'] as num).toDouble();
      _p97Height = (matchedHeightRow['p97'] as num).toDouble();

      if (calcWeightKg != null) {
        if (calcWeightKg < _p3Weight) _weightStatus = 'Needs Doctor\'s Advice (Very Low)';
        else if (calcWeightKg < _idealWeightMin) _weightStatus = 'On the Lighter Side';
        else if (calcWeightKg <= _idealWeightMax) _weightStatus = 'Perfectly Healthy Weight 🌟';
        else if (calcWeightKg <= _p97Weight) _weightStatus = 'On the Heavier Side';
        else _weightStatus = 'Needs Doctor\'s Advice (High Weight)';
      }

      if (calcHeightCm != null) {
        if (calcHeightCm < _p3Height) _heightStatus = 'Needs Doctor\'s Advice (Very Short)';
        else if (calcHeightCm < _idealHeightMin) _heightStatus = 'On the Shorter Side';
        else if (calcHeightCm <= _idealHeightMax) _heightStatus = 'Perfectly Healthy Height 🌟';
        else if (calcHeightCm <= _p97Height) _heightStatus = 'Taller than Average';
        else _heightStatus = 'Very Tall for their Age';
      }
    });
  }

  Future<void> _saveRecord() async {
    if (_inputWeight == null || _inputHeight == null || _ageController.text.isEmpty) return;

    if (_activeProfileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select or create a profile at the top to save.')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('ibhwc_diary') ?? [];

    double saveWeightKg = _system == 'imperial' ? (_inputWeight! / 2.20462) : _inputWeight!;
    double saveHeightCm = _system == 'imperial' ? (_inputHeight! * 2.54) : _inputHeight!;
    double saveAgeYears = _ageUnit == 'months' ? (double.parse(_ageController.text) / 12) : double.parse(_ageController.text);

    final profile = _profiles.firstWhere((p) => p['id'] == _activeProfileId);
    final today = DateTime.now();
    bool isDuplicate = false;

    for (var entry in history) {
      final log = jsonDecode(entry);
      final logDate = DateTime.parse(log['date']);

      if (log['profileId'] == _activeProfileId &&
          (log['age'] as num).toDouble() == saveAgeYears &&
          (log['weight'] as num).toDouble() == saveWeightKg &&
          (log['height'] as num).toDouble() == saveHeightCm &&
          logDate.year == today.year && logDate.month == today.month && logDate.day == today.day) {
        isDuplicate = true;
        break;
      }
    }

    if (isDuplicate) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('⚠️ This exact reading is already saved today.'), backgroundColor: Colors.orange.shade700, behavior: SnackBarBehavior.floating));
      return;
    }

    final newLog = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'profileId': _activeProfileId,
      'name': profile['name'],
      'gender': profile['gender'],
      'date': DateTime.now().toIso8601String(),
      'age': saveAgeYears,
      'weight': saveWeightKg,
      'height': saveHeightCm,
    };

    history.add(jsonEncode(newLog));
    await prefs.setStringList('ibhwc_diary', history);

    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Saved to ${profile['name']}\'s Diary!'), backgroundColor: Colors.green.shade600, behavior: SnackBarBehavior.floating));
  }

  void _showCreateProfileDialog() {
    String tempName = '';
    String tempGender = 'boys';

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setStateDialog) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('New Child Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(decoration: InputDecoration(labelText: 'Child\'s Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50), onChanged: (val) => tempName = val),
                      const SizedBox(height: 16),
                      SegmentedButton<String>(
                        segments: const [ButtonSegment(value: 'boys', label: Text('Boy'), icon: Icon(Icons.boy)), ButtonSegment(value: 'girls', label: Text('Girl'), icon: Icon(Icons.girl))],
                        selected: {tempGender},
                        onSelectionChanged: (Set<String> newSelection) => setStateDialog(() => tempGender = newSelection.first),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () async {
                        if (tempName.trim().isEmpty) return;
                        final newProfile = {'id': DateTime.now().millisecondsSinceEpoch.toString(), 'name': tempName.trim(), 'gender': tempGender};
                        final prefs = await SharedPreferences.getInstance();
                        _profiles.add(newProfile);
                        await prefs.setStringList('ibhwc_profiles', _profiles.map((p) => jsonEncode(p)).toList());
                        await prefs.setString('active_profile_id', newProfile['id']!);
                        setState(() { _activeProfileId = newProfile['id']; _hasCalculated = false; });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
                      child: const Text('Create'),
                    ),
                  ],
                );
              }
          );
        }
    );
  }

  void _showEditProfileDialog(String profileId) {
    final profileIndex = _profiles.indexWhere((p) => p['id'] == profileId);
    if (profileIndex == -1) return;

    String tempName = _profiles[profileIndex]['name'];
    String tempGender = _profiles[profileIndex]['gender'];

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setStateDialog) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                          initialValue: tempName,
                          decoration: InputDecoration(labelText: 'Child\'s Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50),
                          onChanged: (val) => tempName = val
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<String>(
                        segments: const [ButtonSegment(value: 'boys', label: Text('Boy'), icon: Icon(Icons.boy)), ButtonSegment(value: 'girls', label: Text('Girl'), icon: Icon(Icons.girl))],
                        selected: {tempGender},
                        onSelectionChanged: (Set<String> newSelection) => setStateDialog(() => tempGender = newSelection.first),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: () => _confirmDeleteProfile(profileId),
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        label: const Text('Delete Profile', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), minimumSize: const Size.fromHeight(45)),
                      )
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () async {
                        if (tempName.trim().isEmpty) return;

                        final prefs = await SharedPreferences.getInstance();

                        _profiles[profileIndex]['name'] = tempName.trim();
                        _profiles[profileIndex]['gender'] = tempGender;
                        await prefs.setStringList('ibhwc_profiles', _profiles.map((p) => jsonEncode(p)).toList());

                        List<String> rawDiary = prefs.getStringList('ibhwc_diary') ?? [];
                        List<String> updatedDiary = rawDiary.map((entry) {
                          final log = jsonDecode(entry) as Map<String, dynamic>;
                          if (log['profileId'] == profileId) {
                            log['name'] = tempName.trim();
                            log['gender'] = tempGender;
                          }
                          return jsonEncode(log);
                        }).toList();
                        await prefs.setStringList('ibhwc_diary', updatedDiary);

                        setState(() { _hasCalculated = false; });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
                      child: const Text('Save Changes'),
                    ),
                  ],
                );
              }
          );
        }
    );
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
                  final prefs = await SharedPreferences.getInstance();

                  _profiles.removeWhere((p) => p['id'] == profileId);
                  await prefs.setStringList('ibhwc_profiles', _profiles.map((p) => jsonEncode(p)).toList());

                  List<String> rawDiary = prefs.getStringList('ibhwc_diary') ?? [];
                  rawDiary.removeWhere((entry) => jsonDecode(entry)['profileId'] == profileId);
                  await prefs.setStringList('ibhwc_diary', rawDiary);

                  if (_activeProfileId == profileId) {
                    _activeProfileId = null;
                    await prefs.remove('active_profile_id');
                  }

                  setState(() { _hasCalculated = false; });

                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('Delete Permanently', style: TextStyle(color: Colors.red))
            ),
          ],
        )
    );
  }

  void _switchProfile(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) await prefs.remove('active_profile_id');
    else await prefs.setString('active_profile_id', id);
    setState(() { _activeProfileId = id; _hasCalculated = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: CustomDrawer(onReturn: _loadSettingsAndProfiles),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/logo.png', height: 28, width: 28),
              const SizedBox(width: 8),
              Text('Growth Calculator', style: TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary))
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
                onEditProfile: _showEditProfileDialog,
                onCreateNew: _showCreateProfileDialog,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade100)),
                      child: Row(children: [Icon(Icons.settings, size: 20, color: Colors.blue.shade700), const SizedBox(width: 12), Expanded(child: Text('Using ${(_system == 'metric' ? 'Metric (kg/cm)' : 'Imperial (lbs/in)')} System. Change this in the Settings Menu.', style: TextStyle(fontSize: 12, color: Colors.blue.shade900)))]),
                    ),
                    const SizedBox(height: 16),

                    InputFormCard(
                      ageController: _ageController, weightController: _weightController, heightController: _heightController,
                      system: _system, ageUnit: _ageUnit, quickCheckGender: _quickCheckGender, isQuickCheck: _activeProfileId == null,
                      onAgeUnitChanged: (val) => setState(() => _ageUnit = val),
                      onGenderChanged: (val) => setState(() => _quickCheckGender = val),
                      onCalculate: _calculateMetrics,
                    ),

                    const SizedBox(height: 24),
                    if (_hasCalculated) _buildResultsSection(),
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

  Widget _buildResultsSection() {
    bool canSave = _inputWeight != null && _inputHeight != null;
    String wUnit = _system == 'imperial' ? 'lbs' : 'kg';
    String hUnit = _system == 'imperial' ? 'in' : 'cm';
    String saveBtnText = _activeProfileId == null ? 'Select Profile to Save' : 'Save to Profile Diary';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canSave) ...[
          ElevatedButton.icon(
            onPressed: () {
              if (_activeProfileId == null) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select or create a profile at the top to save data.')));
              else _saveRecord();
            },
            icon: const Icon(Icons.bookmark_add_rounded),
            label: Text(saveBtnText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), backgroundColor: _activeProfileId == null ? Colors.orange.shade600 : Colors.green.shade600, foregroundColor: Colors.white, elevation: 3, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 24),
        ],

        const Padding(padding: EdgeInsets.only(left: 8.0, bottom: 12), child: Text('Assessment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),

        if (_inputWeight != null) AssessmentCard(title: 'Weight Check', value: '$_inputWeight $wUnit', status: _weightStatus, isHealthy: _weightStatus.contains('Healthy'), rangeText: 'Healthy range: ${_formatWeight(_idealWeightMin)} to ${_formatWeight(_idealWeightMax)}', currentVal: _system == 'imperial' ? _inputWeight! / 2.20462 : _inputWeight!, minLimit: _p3Weight, maxLimit: _p97Weight)
        else GuidanceCard(title: 'Ideal Target Weight', targetValue: _formatWeight(_idealWeightTarget), rangeText: 'Healthy range: ${_formatWeight(_idealWeightMin)} to ${_formatWeight(_idealWeightMax)}', icon: Icons.monitor_weight_outlined, color: Colors.blue),

        const SizedBox(height: 16),

        if (_inputHeight != null) AssessmentCard(title: 'Height Check', value: '$_inputHeight $hUnit', status: _heightStatus, isHealthy: _heightStatus.contains('Healthy'), rangeText: 'Healthy range: ${_formatHeight(_idealHeightMin)} to ${_formatHeight(_idealHeightMax)}', currentVal: _system == 'imperial' ? _inputHeight! * 2.54 : _inputHeight!, minLimit: _p3Height, maxLimit: _p97Height)
        else GuidanceCard(title: 'Ideal Target Height', targetValue: _formatHeight(_idealHeightTarget), rangeText: 'Healthy range: ${_formatHeight(_idealHeightMin)} to ${_formatHeight(_idealHeightMax)}', icon: Icons.height, color: Colors.teal),
      ],
    );
  }
}