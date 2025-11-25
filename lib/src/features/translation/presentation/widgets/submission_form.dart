import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate/src/features/translation/presentation/providers/submission_provider.dart';

class TranslationSubmissionForm extends StatefulWidget {
  const TranslationSubmissionForm({super.key});

  @override
  State<TranslationSubmissionForm> createState() => _TranslationSubmissionFormState();
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
  final List<String> _languages = ['English', 'Rukiga', 'Luganda', 'Acholi', 'Runyankole', 'Ateso', 'Lugbara'];
  final List<String> _contexts = ['General', 'Medical', 'Legal', 'Marketplace', 'Technology', 'Religious'];
  final List<String> _dialects = ['Standard', 'Buddu', 'Kooki', 'Lango', 'Padhola'];

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _submitData() async {
    // 1. Basic Validation
    if (_sourceController.text.isEmpty || _targetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both text fields')),
      );
      return;
    }

    // 2. Close Keyboard
    FocusScope.of(context).unfocus();

    // 3. Call the Provider
    final provider = Provider.of<SubmissionProvider>(context, listen: false);

    final success = await provider.submit(
      sourceText: _sourceController.text,
      translatedText: _targetController.text,
      sourceLang: _selectedSourceLang,
      targetLang: _selectedTargetLang,
      context: _selectedContext,
      dialect: _selectedDialect,
    );

    // 4. Handle Result
    if (mounted) {
      if (success) {
        _sourceController.clear();
        _targetController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text('Translation submitted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(provider.error ?? 'Submission failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<SubmissionProvider, bool>((p) => p.isLoading);
    final primaryColor = const Color(0xFF1E3A8A);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ---
          Text(
            'Contribute',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: primaryColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Help your community grow by adding a new translation.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 30),

          // --- SECTION 1: LANGUAGE CONFIGURATION ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 4)),
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
                        onChanged: (val) => setState(() => _selectedSourceLang = val!),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.swap_horiz_rounded, color: Colors.amber.shade700),
                      ),
                    ),
                    Expanded(
                      child: _buildFancyDropdown(
                        label: 'Target',
                        value: _selectedTargetLang,
                        items: _languages,
                        icon: Icons.language,
                        onChanged: (val) => setState(() => _selectedTargetLang = val!),
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
                        onChanged: (val) => setState(() => _selectedContext = val!),
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
                        onChanged: (val) => setState(() => _selectedDialect = val!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- SECTION 2: TEXT INPUTS (Design mimics the TranslationCard) ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.amber.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The Amber Decor Line (Consistency with Feed Card)
                Container(
                  width: 4,
                  height: 160, // Approximate height to cover both fields
                  decoration: BoxDecoration(
                    color: Colors.amber.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),

                // Fields
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
                        isHero: true, // Makes it look bolder
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
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: primaryColor.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: isLoading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Submit Contribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

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
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Colors.grey.shade600),
              dropdownColor: Colors.white,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: isSmall ? 13 : 14,
                  fontWeight: isSmall ? FontWeight.w500 : FontWeight.w600),
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
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isHero ? const Color(0xFF1E3A8A) : Colors.grey.shade600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: null,
          minLines: isHero ? 2 : 1,
          style: TextStyle(
            fontSize: isHero ? 18 : 16,
            fontWeight: isHero ? FontWeight.bold : FontWeight.normal,
            color: isHero ? const Color(0xFF1E3A8A) : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: isHero ? 16 : 14, fontWeight: FontWeight.normal),
            filled: true,
            fillColor: isHero ? Colors.indigo.shade50.withOpacity(0.3) : Colors.grey.shade50,
            contentPadding: const EdgeInsets.all(12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.amber.shade400, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
