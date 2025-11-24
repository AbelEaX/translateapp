import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate/src/features/translation/presentation/providers/submission_provider.dart';

// We change this to a Stateful Widget to hold the Controllers and Dropdown state
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
    // listen: false because we don't want to rebuild the widget, we just want to call a function
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
    // Listen to provider state to show loading spinner
    final isLoading = context.select<SubmissionProvider, bool>((p) => p.isLoading);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          const Text('To add a translation: Fill in the form below',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 30),

          // --- ROW 1: Languages ---
          Row(
            children: [
              Expanded(
                child: _buildDropdown('Source', _selectedSourceLang, _languages, (val) => setState(() => _selectedSourceLang = val!)),
              ),
              const SizedBox(width: 15),
              const Icon(Icons.arrow_forward, color: Colors.grey),
              const SizedBox(width: 15),
              Expanded(
                child: _buildDropdown('Target', _selectedTargetLang, _languages, (val) => setState(() => _selectedTargetLang = val!)),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // --- ROW 2: ML Metadata (Context & Dialect) ---
          // This is the "Secret Sauce" for your future AI Model
          Row(
            children: [
              Expanded(
                child: _buildDropdown('Context', _selectedContext, _contexts, (val) => setState(() => _selectedContext = val!)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildDropdown('Dialect', _selectedDialect, _dialects, (val) => setState(() => _selectedDialect = val!)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- TEXT INPUTS ---
          const Text('Source Text', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _sourceController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'e.g. How are you?',
              filled: true,
              fillColor: Colors.grey.shade50, // Slightly darker than white to stand out
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),

          const Text('Translation', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _targetController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'e.g. Oli otya?',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 30),

          // --- SUBMIT BUTTON ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A), // kPrimaryColor
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF1E3A8A).withAlpha(25),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Submit for Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // Helper Widget to keep code clean
  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((String val) {
                return DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 13)));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}