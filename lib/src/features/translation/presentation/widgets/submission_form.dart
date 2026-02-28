import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate/src/features/translation/presentation/providers/submission_provider.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

class TranslationSubmissionForm extends StatefulWidget {
  const TranslationSubmissionForm({super.key});

  @override
  State<TranslationSubmissionForm> createState() =>
      _TranslationSubmissionFormState();
}

class _TranslationSubmissionFormState extends State<TranslationSubmissionForm> {
  // --- CONTROLLERS ---
  final _sourceController = TextEditingController();
  final _targetController = TextEditingController();

  // --- ML METADATA STATE ---
  String _selectedSourceLang = 'English';
  String _selectedTargetLang = 'Luganda';
  String _selectedContext = 'General';
  String _selectedDialect = 'Standard';

  // --- DROPDOWN OPTIONS ---

  // Comprehensive List of Ugandan Languages
  final List<String> _languages = [
    'English',
    'Swahili',
    'Luganda',
    'Runyankole',
    'Rukiga',
    'Runyoro',
    'Rutooro',
    'Lumasaba',
    'Lusoga',
    'Ateso',
    'Acholi',
    'Langi',
    'Alur',
    'Lugbara',
    'Japadhola',
    'Samia',
  ];

  final List<String> _contexts = [
    'General',
    'Medical',
    'Legal',
    'Marketplace',
    'Technology',
    'Religious',
  ];
  final List<String> _dialects = [
    'Standard',
    'Buddu',
    'Kooki',
    'Lango',
    'Padhola',
    'Kigezi',
    'Tooro',
  ];

  // Language Code Mapper for ML Kit (BCP-47)
  final Map<String, String> _langCodeMap = {
    'English': 'en',
    'Swahili': 'sw',
    'Luganda': 'lg',
  };

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  // --- HELPER: PROGRAMMATIC LANGUAGE PICKER ---
  // Since DropdownButton cannot be opened programmatically, we use a ModalBottomSheet
  // to simulate opening the list for the user to correct their selection.
  void _openLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Select Correct Target Language",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final lang = _languages[index];
                      final isSelected = lang == _selectedTargetLang;
                      return ListTile(
                        leading: Icon(
                          Icons.language,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).iconTheme.color,
                        ),
                        title: Text(
                          lang,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () {
                          setState(() => _selectedTargetLang = lang);
                          Navigator.pop(context); // Close picker
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- LAYER 1: ML KIT VERIFICATION ---
  Future<bool> _verifyLanguageWithML(
    String text,
    String selectedLangName,
  ) async {
    final expectedCode = _langCodeMap[selectedLangName];
    if (expectedCode == null) return true;

    try {
      final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
      final String detectedCode = await languageIdentifier.identifyLanguage(
        text,
      );
      languageIdentifier.close();

      if (detectedCode != 'und' && detectedCode != expectedCode) {
        return false;
      }
    } catch (e) {
      debugPrint("ML Kit Error: $e");
    }
    return true;
  }

  void _submitData() async {
    // 1. Basic Input Validation
    if (_sourceController.text.isEmpty || _targetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both text fields')),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    // --- 2. LAYER 1: INTELLIGENT MISMATCH CHECK (ML KIT) ---
    if (_targetController.text.length > 10) {
      final isMatch = await _verifyLanguageWithML(
        _targetController.text,
        _selectedTargetLang,
      );

      if (!isMatch && mounted) {
        // SHOW WARNING DIALOG
        final bool? overrideWarning = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Possible Mismatch",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: Text(
              "We detected that the text you typed might not be '$_selectedTargetLang'.\n\nSubmitting incorrect languages hurts the community database.\n\nAre you sure you want to proceed?",
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx, false); // Close warning
                  _openLanguagePicker(); // [ACTION] Let user fix it
                },
                child: const Text("Let me fix it"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true), // Proceed
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text("Ignore Warning"),
              ),
            ],
          ),
        );

        if (overrideWarning != true) return; // Stop if user wants to fix it
      }
    }

    // --- 3. LAYER 2: MANUAL CONFIRMATION DIALOG (ALWAYS SHOWN) ---
    if (mounted) {
      final bool? confirmFinal = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Confirm Submission",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You are contributing to the:",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedTargetLang.toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      "Dictionary",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text("Is this the correct language?"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false); // Close confirmation
                _openLanguagePicker(); // [ACTION] Let user change selection
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurface,
              ),
              child: const Text("Check Again"), // Implies opening the list
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true), // Proceed
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Yes, Submit"),
            ),
          ],
        ),
      );

      if (confirmFinal != true) return; // Stop if user is changing selection
    }

    // --- 4. SUBMISSION ---
    if (!mounted) return;
    final provider = Provider.of<SubmissionProvider>(context, listen: false);

    final success = await provider.submit(
      sourceText: _sourceController.text,
      translatedText: _targetController.text,
      sourceLang: _selectedSourceLang,
      targetLang: _selectedTargetLang,
      context: _selectedContext,
      dialect: _selectedDialect,
    );

    // --- 5. HANDLE RESULT ---
    if (mounted) {
      if (success) {
        _sourceController.clear();
        _targetController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Translation submitted successfully!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(provider.error ?? 'Submission failed'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<SubmissionProvider, bool>(
      (p) => p.isLoading,
    );
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ---
          Text(
            'Contribute',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Help your community grow by adding a new translation.',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 30),

          // --- SECTION 1: LANGUAGE CONFIGURATION ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Language Swap Row
                Row(
                  children: [
                    Expanded(
                      child: _buildFancyDropdown(
                        label: 'Source',
                        value: _selectedSourceLang,
                        items: _languages,
                        icon: Icons.translate,
                        onChanged: (val) =>
                            setState(() => _selectedSourceLang = val!),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.swap_horiz_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildFancyDropdown(
                        label: 'Target',
                        value: _selectedTargetLang,
                        items: _languages,
                        icon: Icons.language,
                        onChanged: (val) =>
                            setState(() => _selectedTargetLang = val!),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                // Metadata Row
                Row(
                  children: [
                    Expanded(
                      child: _buildFancyDropdown(
                        label: 'Context',
                        value: _selectedContext,
                        items: _contexts,
                        icon: Icons.category_outlined,
                        isSmall: true,
                        onChanged: (val) =>
                            setState(() => _selectedContext = val!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFancyDropdown(
                        label: 'Dialect',
                        value: _selectedDialect,
                        items: _dialects,
                        icon: Icons.record_voice_over_outlined,
                        isSmall: true,
                        onChanged: (val) =>
                            setState(() => _selectedDialect = val!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- SECTION 2: TEXT INPUTS ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _buildCleanTextField(
                        controller: _sourceController,
                        hint: 'Type original text here...',
                        label: 'Original Text',
                      ),
                      const SizedBox(height: 20),
                      _buildCleanTextField(
                        controller: _targetController,
                        hint: 'Type translation here...',
                        label: 'Translated Text',
                        isHero: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // --- SUBMIT BUTTON ---
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Submit Contribution',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildFancyDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
    bool isSmall = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: Theme.of(context).iconTheme.color,
              ),
              dropdownColor: Theme.of(context).cardColor,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: isSmall ? 13 : 14,
                fontWeight: isSmall ? FontWeight.w500 : FontWeight.w600,
              ),
              items: items.map((String val) {
                return DropdownMenuItem(value: val, child: Text(val));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCleanTextField({
    required TextEditingController controller,
    required String hint,
    required String label,
    bool isHero = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isHero
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: null,
          minLines: isHero ? 2 : 1,
          style: TextStyle(
            fontSize: isHero ? 18 : 16,
            fontWeight: isHero ? FontWeight.bold : FontWeight.normal,
            color: isHero
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: isHero ? 16 : 14,
              fontWeight: FontWeight.normal,
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
          ),
        ),
        if (!isHero) Divider(color: Theme.of(context).dividerColor),
      ],
    );
  }
}
