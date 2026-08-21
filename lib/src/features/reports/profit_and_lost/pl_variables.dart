import 'dart:async';

import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/date_range_picker.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/flush_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/yes_and_no.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/cost_capital_service.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PandLVariables extends StatefulWidget {
  const PandLVariables({super.key, this.uid});
  final String? uid;

  @override
  State<PandLVariables> createState() => _PandLVariablesState();
}

class _PandLVariablesState extends State<PandLVariables> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false;
  DatabaseService db = DatabaseService();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  ErrorClass errorClass = ErrorClass();
  YesAndNoDialog ynDialog = YesAndNoDialog();
  CostCapitalService ccs = CostCapitalService();
  int? start, end;
  DateTimeRange? selectedRange;
  final number = NumberFormat("#,##0.00", "en_US");
  Timer? _debounceTimer;
  Future<UserDetails>? getCurrentUser;
  UserDetails? currentUser;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, Map<String, dynamic>> _selectedOptions = {
    'Operating Expenses': {
      'selected': false,
      'value': 0.0,
      'subOptions': {
        'Selling & Marketing': {'selected': false, 'value': 0.0},
        'Research & Development (R&D)': {'selected': false, 'value': 0.0},
        'General & Administrative': {'selected': false, 'value': 0.0},
        'Depreciation & Amortization': {'selected': false, 'value': 0.0},
      }
    },
    'Operating Income': {'selected': false, 'value': 0.0},
    'Interest Expense': {'selected': false, 'value': 0.0},
    'Foreign Exchange Gain/Loss': {'selected': false, 'value': 0.0},
    'Investment Income': {'selected': false, 'value': 0.0},
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
  }

  @override
  void initState() {
    snackbarWidget.context = context;
    if (widget.uid != null) getCurrentUser = fetchUser();
    _initializeControllers();
    super.initState();
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  // ── Design helpers ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: responsive!.scaleHeight(10),
        top: responsive!.scaleHeight(4),
      ),
      child: MyText(
        text: text.toUpperCase(),
        fontScale: responsive!.scaleFont(11),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _groupCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
                Divider(
                  height: 0,
                  thickness: 0.5,
                  indent: responsive!.scaleWidth(14),
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: MyText(
            text: appLoc!.plVariables,
            fontScale: responsive!.scaleFont(18),
            fontWeight: FontWeight.w500,
          ),
          actions: [
            TextButton(
              onPressed: () async => await exportData(),
              child: MyText(
                text: appLoc!.export,
                fontScale: responsive!.scaleFont(13),
                fontWeight: FontWeight.w500,
                fontColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        body: FutureBuilder(
          future: getCurrentUser,
          builder: (context, usershot) {
            if (usershot.hasError) {
              return Center(
                child: MyText(
                  text: errorClass.userNoTFoundError(
                      e: usershot.error.toString()),
                ),
              );
            }
            if (usershot.connectionState == ConnectionState.waiting) {
              return const GradientSkeleton();
            }
            currentUser = usershot.data;
            return Stack(
              children: [
                _buildPandLVariablesBody(),
                if (isLoading)
                  StreamBuilder<double>(
                    stream: Stream.periodic(
                      const Duration(milliseconds: 100),
                      (_) => ProgressManager.progress,
                    ),
                    builder: (context, progressshot) {
                      final progress = progressshot.data ?? 0.0;
                      return Center(
                        child: AnimatedArcLoader(
                          progress: progress,
                          size: 150,
                          fontSize: responsive!.scaleFont(15),
                          color: Colors.blueAccent,
                          showPercentage: true,
                          onTimeout: () {
                            setState(() => isLoading = false);
                            ProgressManager.stopLoading();
                            snackbarWidget.content = appLoc!.operationTimedOut;
                            snackbarWidget.showSnack();
                          },
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildPandLVariablesBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(responsive!.scaleWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dateRange(),
          SizedBox(height: responsive!.scaleHeight(4)),
          optionSelections(),
          SizedBox(height: responsive!.scaleHeight(4)),
          savedRecord(),
          SizedBox(height: responsive!.scaleHeight(32)),
        ],
      ),
    );
  }

  // ── Date range — same card pattern as sales report ─────────────────────────

  Widget dateRange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(appLoc!.selectDate),
        _groupCard(children: [
          // Info hint
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive!.scaleWidth(14),
              vertical: responsive!.scaleHeight(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: responsive!.scaleHeight(15),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: responsive!.scaleWidth(8)),
                Expanded(
                  child: MyText(
                    text: appLoc!.selectDatePL,
                    fontScale: responsive!.scaleFont(12),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
          // Date + select button — logic unchanged
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive!.scaleWidth(14),
              vertical: responsive!.scaleHeight(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: responsive!.scaleHeight(18),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: responsive!.scaleWidth(10)),
                Expanded(
                  child: selectedRange != null
                      ? MyText(
                          text:
                              '${_formatDate(selectedRange!.start)}  →  ${_formatDate(selectedRange!.end)}',
                          fontScale: responsive!.scaleFont(13),
                          fontWeight: FontWeight.w500,
                        )
                      : MyText(
                          text: appLoc!.selectDateRange,
                          fontScale: responsive!.scaleFont(13),
                        ),
                ),
                GestureDetector(
                  onTap: () async => await _selectDateRange(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive!.scaleWidth(14),
                      vertical: responsive!.scaleHeight(7),
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: MyText(
                      text: appLoc!.select,
                      fontScale: responsive!.scaleFont(12),
                      fontWeight: FontWeight.w500,
                      fontColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  // ── Options — checkboxes + value inputs, all logic unchanged ──────────────

  Widget optionSelections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(appLoc!.selectOptions),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Column(
            children: _selectedOptions.entries.map((entry) {
              final optionName = entry.key;
              final optionData = entry.value;
              final isLast = entry.key == _selectedOptions.keys.last;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main option row
                  _optionRow(
                    label: optionName,
                    checked: optionData['selected'],
                    onChanged: (value) {
                      setState(() {
                        _selectedOptions[optionName]!['selected'] =
                            value ?? false;
                      });
                    },
                    valueInput: optionData['selected'] &&
                            optionData['subOptions'] == null
                        ? _buildValueInputField(optionName, null)
                        : null,
                  ),

                  // Sub-options
                  if (optionData['subOptions'] != null)
                    _buildSubOptions(optionName),

                  // Divider between items
                  if (!isLast)
                    Divider(
                      height: 0,
                      thickness: 0.5,
                      indent: responsive!.scaleWidth(14),
                      color: Theme.of(context)
                          .dividerColor
                          .withValues(alpha: 0.25),
                    ),
                ],
              );
            }).toList(),
          ),
        ),

        SizedBox(height: responsive!.scaleHeight(20)),

        // Summary card
        _buildSummaryCard(),
      ],
    );
  }

  Widget _optionRow({
    required String label,
    required bool checked,
    required ValueChanged<bool?> onChanged,
    Widget? valueInput,
    bool isSubOption = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: isSubOption
            ? responsive!.scaleWidth(32)
            : responsive!.scaleWidth(14),
        right: responsive!.scaleWidth(14),
        top: responsive!.scaleHeight(4),
        bottom: responsive!.scaleHeight(4),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: checked,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              SizedBox(width: responsive!.scaleWidth(6)),
              Expanded(
                child: MyText(
                  text: label,
                  fontScale: responsive!.scaleFont(isSubOption ? 12 : 13),
                  fontWeight: isSubOption ? FontWeight.normal : FontWeight.w500,
                ),
              ),
            ],
          ),
          if (valueInput != null) valueInput,
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final summaryItems = _buildSummaryList();
    if (summaryItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(appLoc!.optionsSummary),
        _groupCard(
          children: summaryItems.map((item) => item).toList(),
        ),
      ],
    );
  }

  List<Widget> _buildSummaryList() {
    List<Widget> summaryItems = [];

    _selectedOptions.forEach((optionName, optionData) {
      if (optionData['selected']) {
        if (optionData['subOptions'] != null) {
          final subOptions = optionData['subOptions'] as Map<String, dynamic>;
          subOptions.forEach((subOptionName, subOptionData) {
            if (subOptionData['selected']) {
              summaryItems.add(
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(14),
                    vertical: responsive!.scaleHeight(11),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: MyText(
                          text: subOptionName,
                          fontScale: responsive!.scaleFont(13),
                          softWrap: true,
                        ),
                      ),
                      MyText(
                        text:
                            '${currentUser?.currency?['symbol'] ?? '\$'} ${number.format(subOptionData['value'])}',
                        fontScale: responsive!.scaleFont(13),
                        fontWeight: FontWeight.w500,
                        fontColor: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              );
            }
          });
        } else {
          summaryItems.add(
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive!.scaleWidth(14),
                vertical: responsive!.scaleHeight(11),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: MyText(
                      text: optionName,
                      fontScale: responsive!.scaleFont(13),
                    ),
                  ),
                  MyText(
                    text:
                        '${currentUser?.currency?['symbol'] ?? '\$'} ${number.format(optionData['value'])}',
                    fontScale: responsive!.scaleFont(13),
                    fontWeight: FontWeight.w500,
                    fontColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          );
        }
      }
    });

    return summaryItems;
  }

  // ── Saved records — StreamBuilder + logic unchanged, rows restyled ─────────

  Widget savedRecord() {
    int recordLength = 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(appLoc!.pandLReport),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: db.streamSaveFinancialRecord(uid: widget.uid),
          builder: (context, recordshot) {
            if (recordshot.hasError) {
              return Center(
                child: MyText(text: '${appLoc!.error}:\n${recordshot.error}'),
              );
            }
            if (recordshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (recordshot.data == null || recordshot.data!.isEmpty) {
              return _groupCard(children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(14),
                    vertical: responsive!.scaleHeight(14),
                  ),
                  child: MyText(
                    text: appLoc!.noPreviousRecordSaved,
                    fontScale: responsive!.scaleFont(13),
                  ),
                ),
              ]);
            }

            recordLength = recordshot.data!.length;
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recordLength,
                separatorBuilder: (_, __) => Divider(
                  height: 0,
                  thickness: 0.5,
                  indent: responsive!.scaleWidth(14),
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
                ),
                itemBuilder: (context, index) {
                  var record = recordshot.data![index];
                  var date = record['createdAt']?.toDate();

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (record['recordData'] != null) {
                        populateSelectedOptionsFromRecord(record['recordData']);
                        GoRouter.of(context).pushNamed(
                          'plSummary',
                          pathParameters: {
                            'uid': widget.uid!,
                            'start': record['startDate'].toDate().toString(),
                            'end': record['endDate'].toDate().toString(),
                          },
                          extra: _selectedOptions,
                        );
                      } else {
                        snackbarWidget.content = appLoc!.failedToRetrieveData;
                        snackbarWidget.showSnack();
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive!.scaleWidth(14),
                        vertical: responsive!.scaleHeight(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: responsive!.scaleWidth(32),
                            height: responsive!.scaleWidth(32),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF3DE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.analytics_outlined,
                              size: responsive!.scaleHeight(16),
                              color: const Color(0xFF3B6D11),
                            ),
                          ),
                          SizedBox(width: responsive!.scaleWidth(12)),
                          Expanded(
                            child: MyText(
                              text: appLoc!.pandLReport,
                              fontScale: responsive!.scaleFont(13),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (date != null)
                            MyText(
                              text: '${date.day}/${date.month}/${date.year}',
                              fontScale: responsive!.scaleFont(11),
                            ),
                          SizedBox(width: responsive!.scaleWidth(8)),
                          Icon(
                            Icons.chevron_right,
                            size: responsive!.scaleHeight(16),
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Value input — FlushTextField replacing MyTextField, logic unchanged ─────

  Widget _buildValueInputField(String optionName, String? subOptionName) {
    String controllerKey =
        subOptionName != null ? '$optionName-$subOptionName' : optionName;

    if (!_selectedOptions.containsKey(optionName)) {
      return const SizedBox.shrink();
    }

    TextEditingController controller = _controllers[controllerKey]!;

    if (!_controllers.containsKey(controllerKey)) {
      String controllerKey =
          subOptionName != null ? '$optionName-$subOptionName' : optionName;
      if (!_selectedOptions.containsKey(optionName)) {
        return const SizedBox.shrink();
      }

      double currentValue;
      if (subOptionName != null) {
        if (_selectedOptions[optionName]!['subOptions'] == null ||
            !(_selectedOptions[optionName]!['subOptions']
                    as Map<String, dynamic>)
                .containsKey(subOptionName)) {
          return const SizedBox.shrink();
        }
        currentValue = _selectedOptions[optionName]!['subOptions']![
            subOptionName]!['value'];
      } else {
        currentValue = _selectedOptions[optionName]!['value'];
      }

      TextEditingController controller;
      if (!_controllers.containsKey(controllerKey)) {
        controller = TextEditingController(
          text: currentValue > 0 ? currentValue.toStringAsFixed(2) : '',
        );
        _controllers[controllerKey] = controller;
        _setupControllerListener(controllerKey, optionName, subOptionName);
      } else {
        controller = _controllers[controllerKey]!;
        final controllerValue = double.tryParse(controller.text) ?? 0.0;
        if ((controllerValue - currentValue).abs() > 0.001) {
          controller.text =
              currentValue > 0 ? currentValue.toStringAsFixed(2) : '';
        }
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        left: subOptionName != null
            ? responsive!.scaleWidth(10)
            : responsive!.scaleWidth(0),
        bottom: responsive!.scaleHeight(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: FlushTextField(
              controller: controller,
              hintText: '0.00',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              fontSize: responsive!.scaleFont(13),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sub-options — Checkbox logic unchanged, styling updated ───────────────

  Widget _buildSubOptions(String optionName) {
    if (!_selectedOptions[optionName]!['selected'] ||
        _selectedOptions[optionName]!['subOptions'] == null) {
      return const SizedBox.shrink();
    }

    final subOptions =
        _selectedOptions[optionName]!['subOptions'] as Map<String, dynamic>;

    return Container(
      margin: EdgeInsets.only(
        left: responsive!.scaleWidth(14),
        bottom: responsive!.scaleHeight(4),
      ),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: subOptions.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _optionRow(
                label: entry.key,
                checked: entry.value['selected'],
                isSubOption: true,
                onChanged: (value) {
                  setState(() => entry.value['selected'] = value ?? false);
                },
                valueInput: entry.value['selected']
                    ? _buildValueInputField(optionName, entry.key)
                    : null,
              ),
              if (entry.key != subOptions.keys.last)
                Divider(
                  height: 0,
                  thickness: 0.5,
                  indent: responsive!.scaleWidth(14),
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── All logic — completely unchanged ──────────────────────────────────────

  Future<UserDetails> fetchUser() async => db.getCurrentUser(uid: widget.uid);

  void _initializeControllers() {
    _selectedOptions.forEach((optionName, optionData) {
      final mainKey = optionName;
      _controllers[mainKey] = TextEditingController(
        text: optionData['value'] > 0
            ? optionData['value'].toStringAsFixed(2)
            : '',
      );
      _setupControllerListener(mainKey, optionName, null);
      if (optionData['subOptions'] != null) {
        final subOptions = optionData['subOptions'] as Map<String, dynamic>;
        subOptions.forEach((subOptionName, subOptionData) {
          final subKey = '$optionName-$subOptionName';
          _controllers[subKey] = TextEditingController(
            text: subOptionData['value'] > 0
                ? subOptionData['value'].toStringAsFixed(2)
                : '',
          );
          _setupControllerListener(subKey, optionName, subOptionName);
        });
      }
    });
  }

  void _initializeOperatingExpenseControllers() {
    if (!_selectedOptions.containsKey('Operating Expenses')) return;
    var operatingExpense = _selectedOptions['Operating Expenses']!;
    Map<String, dynamic> subOptions = {};
    if (operatingExpense['subOptions'] is Map) {
      subOptions =
          Map<String, dynamic>.from(operatingExpense['subOptions'] as Map);
    }
    subOptions.forEach((subOptionName, subOptionData) {
      final subKey = 'Operating Expenses-$subOptionName';
      _controllers[subKey]?.dispose();
      double value = 0.0;
      if (subOptionData is Map && subOptionData.containsKey('value')) {
        value = (subOptionData['value'] as num).toDouble();
      }
      _controllers[subKey] = TextEditingController(
        text: value > 0 ? value.toStringAsFixed(2) : '',
      );
      _setupControllerListener(subKey, 'Operating Expenses', subOptionName);
    });
  }

  void _setupControllerListener(
      String controllerKey, String optionName, String? subOptionName) {
    _controllers[controllerKey]!.addListener(() {
      final value = _controllers[controllerKey]!.text;
      double newValue = double.tryParse(value) ?? 0.0;
      if (subOptionName != null) {
        _selectedOptions[optionName]!['subOptions']![subOptionName]!['value'] =
            newValue;
      } else {
        _selectedOptions[optionName]!['value'] = newValue;
      }
      _debounceUpdate();
    });
  }

  void _debounceUpdate() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() {});
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await DateRangePickerUtil.show(
      context: context,
      initialDateRange: selectedRange,
      primaryColor: Theme.of(context).colorScheme.primary,
      saveText: appLoc!.apply,
      cancelText: appLoc!.cancel,
      helpText: appLoc!.selectDateRange,
    );
    if (picked != null) {
      setState(() => selectedRange = picked);
      if (selectedRange != null) {
        start = selectedRange!.start.millisecondsSinceEpoch;
        end = selectedRange!.end.millisecondsSinceEpoch;
      }
    }
    String recordId =
        '${selectedRange?.start.day}${selectedRange?.start.month}${selectedRange?.start.year}${selectedRange?.end.day}${selectedRange?.end.month}${selectedRange?.end.year}';
    if (await db.checkIfRecordIdExists(uid: widget.uid, recordId: recordId)) {
      var result =
          await db.futureRecordData(uid: widget.uid, recordId: recordId);
      if (result.isEmpty) return;
      setState(() {
        _selectedOptions.clear();
        _selectedOptions.addAll(result);
        result.forEach((optionName, optionData) {
          final mainKey = optionName;
          _controllers[mainKey] = TextEditingController(
            text: optionData['value'] > 0
                ? number.format(optionData['value'])
                : '',
          );
          _setupControllerListener(mainKey, optionName, null);
          if (optionData['subOptions'] != null) {
            final subOptions = optionData['subOptions'] as Map<String, dynamic>;
            subOptions.forEach((subOptionName, subOptionData) {
              final subKey = '$optionName-$subOptionName';
              _controllers[subKey] = TextEditingController(
                text: subOptionData['value'] > 0
                    ? number.format(subOptionData['value'])
                    : '',
              );
              _setupControllerListener(subKey, optionName, subOptionName);
            });
          }
        });
      });
    }
    var result = await ccs.getMultipleExpensesByDate(
        uid: widget.uid, start: start, end: end);
    if (result.isNotEmpty) {
      _selectedOptions['Operating Expenses'] = {
        'selected': true,
        'value': 0.0,
        'subOptions': <String, dynamic>{},
      };
      var operatingExpense = _selectedOptions['Operating Expenses']!;
      var subOptions = operatingExpense['subOptions'] as Map<String, dynamic>;
      Map<String, double> expenseSums = {};
      for (var expense in result) {
        if (expense.category != null && expense.value != null) {
          expenseSums[expense.category!] =
              (expenseSums[expense.category!] ?? 0.0) + expense.value!;
        }
      }
      expenseSums.forEach((category, totalValue) {
        subOptions[category] = <String, dynamic>{
          'selected': true,
          'value': totalValue,
        };
      });
      _initializeOperatingExpenseControllers();
      setState(() {});
    }
  }

  Future<void> exportData() async {
    if (selectedRange == null) {
      snackbarWidget.content = appLoc!.dateRangeisCrucial;
      snackbarWidget.showSnack();
      return;
    }
    var result = await ynDialog.showYNDialog(
        context, appLoc!, appLoc!.saveRecord,
        content: appLoc!.saveFinancialRecord);
    if (result) {
      setState(() => isLoading = true);
      ProgressManager.startLoading(
        onTimeout: () {
          if (mounted) {
            setState(() => isLoading = false);
            snackbarWidget.content = appLoc!.operationTimedOut;
            snackbarWidget.showSnack();
          }
        },
        timeoutDuration: const Duration(seconds: 30),
      );
      String recordId =
          '${selectedRange?.start.day}${selectedRange?.start.month}${selectedRange?.start.year}${selectedRange?.end.day}${selectedRange?.end.month}${selectedRange?.end.year}';
      try {
        await db.addFinancialRecord(
            uid: widget.uid,
            recordId: recordId,
            record: _selectedOptions,
            startDate: selectedRange?.start,
            endDate: selectedRange?.end);
        ProgressManager.completeLoading();
      } on Exception catch (e) {
        ProgressManager.stopLoading();
        snackbarWidget.content = '${appLoc!.reportGenFailed}\n$e';
        snackbarWidget.showSnack();
        if (mounted) setState(() => isLoading = false);
      }
    } else {
      ProgressManager.completeLoading();
      if (mounted) setState(() => isLoading = false);
      // ignore: use_build_context_synchronously
      GoRouter.of(context).pushNamed('plSummary',
          pathParameters: {
            'uid': widget.uid!,
            'start': selectedRange!.start.toString(),
            'end': selectedRange!.end.toString()
          },
          extra: _selectedOptions);
    }
    if (mounted) setState(() => isLoading = false);
    // ignore: use_build_context_synchronously
    GoRouter.of(context).pushNamed('plSummary',
        pathParameters: {
          'uid': widget.uid!,
          'start': selectedRange!.start.toString(),
          'end': selectedRange!.end.toString()
        },
        extra: _selectedOptions);
  }

  void populateSelectedOptionsFromRecord(Map<String, dynamic> recordData) {
    _selectedOptions.forEach((key, value) {
      if (value.containsKey('subOptions')) {
        value['selected'] = false;
        value['value'] = 0.0;
        (value['subOptions'] as Map<String, dynamic>)
            .forEach((subKey, subValue) {
          subValue['selected'] = false;
          subValue['value'] = 0.0;
        });
      } else {
        value['selected'] = false;
        value['value'] = 0.0;
      }
    });
    recordData.forEach((key, value) {
      if (_selectedOptions.containsKey(key)) {
        if (value is Map<String, dynamic>) {
          if (value.containsKey('subOptions')) {
            _selectedOptions[key]?['selected'] = value['selected'] ?? false;
            _selectedOptions[key]?['value'] = value['value'] ?? 0.0;
            if (value['subOptions'] is Map<String, dynamic>) {
              (value['subOptions'] as Map<String, dynamic>)
                  .forEach((subKey, subValue) {
                if (_selectedOptions[key]?['subOptions'] is Map &&
                    (_selectedOptions[key]!['subOptions'] as Map)
                        .containsKey(subKey)) {
                  var subOptionMap =
                      (_selectedOptions[key]!['subOptions'] as Map)[subKey];
                  if (subOptionMap is Map) {
                    subOptionMap['selected'] = subValue['selected'] ?? false;
                    subOptionMap['value'] =
                        (subValue['value'] ?? 0.0).toDouble();
                  }
                }
              });
            }
          } else {
            _selectedOptions[key]?['selected'] = value['selected'] ?? false;
            _selectedOptions[key]?['value'] =
                (value['value'] ?? 0.0).toDouble();
          }
        }
      }
    });
    if (mounted) setState(() {});
  }
}
