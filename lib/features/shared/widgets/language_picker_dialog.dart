import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lingua_floor/core/translation/language_code_mapper.dart';

class LanguagePickerSection {
  const LanguagePickerSection({required this.title, required this.languages});

  final String title;
  final List<String> languages;
}

const continentLanguagePickerSections = <LanguagePickerSection>[
  LanguagePickerSection(
    title: 'North America',
    languages: ['English', 'Spanish', 'French'],
  ),
  LanguagePickerSection(title: 'South America', languages: ['Portuguese']),
  LanguagePickerSection(
    title: 'Europe',
    languages: [
      'German',
      'Italian',
      'Dutch',
      'Greek',
      'Polish',
      'Romanian',
      'Czech',
      'Hungarian',
      'Ukrainian',
      'Russian',
    ],
  ),
  LanguagePickerSection(
    title: 'Africa',
    languages: ['Arabic', 'Swahili', 'Amharic', 'Somali', 'Afrikaans', 'Zulu'],
  ),
  LanguagePickerSection(
    title: 'Asia',
    languages: [
      'Mandarin Chinese',
      'Hindi',
      'Bengali',
      'Japanese',
      'Korean',
      'Indonesian',
      'Malay',
      'Filipino',
      'Vietnamese',
      'Thai',
      'Urdu',
      'Punjabi',
      'Tamil',
      'Telugu',
      'Burmese',
      'Hebrew',
      'Persian',
      'Turkish',
    ],
  ),
  LanguagePickerSection(title: 'Oceania', languages: ['Tok Pisin']),
];

final Map<String, String> _curatedLanguageLookup = <String, String>{
  for (final section in continentLanguagePickerSections)
    for (final language in section.languages) language.toLowerCase(): language,
};

Future<String?> showSingleLanguagePickerDialog({
  required BuildContext context,
  required String title,
  String? initialSelection,
  Iterable<String>? availableLanguages,
  bool allowCustomLanguageEntry = true,
}) async {
  final result = await showDialog<List<String>>(
    context: context,
    builder: (_) => _LanguagePickerDialog(
      title: title,
      initialSelection: initialSelection == null
          ? const []
          : [initialSelection],
      multiSelect: false,
      availableLanguages: availableLanguages,
      allowCustomLanguageEntry: allowCustomLanguageEntry,
    ),
  );

  if (result == null || result.isEmpty) {
    return null;
  }

  return result.first;
}

Future<List<String>?> showMultiLanguagePickerDialog({
  required BuildContext context,
  required String title,
  Iterable<String> initialSelection = const [],
  Iterable<String>? availableLanguages,
  bool allowCustomLanguageEntry = true,
}) {
  return showDialog<List<String>>(
    context: context,
    builder: (_) => _LanguagePickerDialog(
      title: title,
      initialSelection: initialSelection,
      multiSelect: true,
      availableLanguages: availableLanguages,
      allowCustomLanguageEntry: allowCustomLanguageEntry,
    ),
  );
}

class _LanguagePickerDialog extends StatefulWidget {
  const _LanguagePickerDialog({
    required this.title,
    required this.initialSelection,
    required this.multiSelect,
    required this.availableLanguages,
    required this.allowCustomLanguageEntry,
  });

  final String title;
  final Iterable<String> initialSelection;
  final bool multiSelect;
  final Iterable<String>? availableLanguages;
  final bool allowCustomLanguageEntry;

  @override
  State<_LanguagePickerDialog> createState() => _LanguagePickerDialogState();
}

class _LanguagePickerDialogState extends State<_LanguagePickerDialog> {
  late final TextEditingController _searchController;
  late final TextEditingController _customLanguageController;
  late final LinkedHashSet<String> _selectedLanguages;
  late final Map<String, String> _availableLanguageLookup;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _customLanguageController = TextEditingController();
    _availableLanguageLookup = <String, String>{
      for (final language in widget.availableLanguages ?? const <String>[])
        if (language.trim().isNotEmpty)
          language.trim().toLowerCase(): language.trim(),
    };
    _selectedLanguages = LinkedHashSet<String>.from(
      widget.initialSelection.map(_canonicalInitialLanguage),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customLanguageController.dispose();
    super.dispose();
  }

  String _canonicalInitialLanguage(String rawLanguage) {
    final trimmed = rawLanguage.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }

    final availableMatch = _availableLanguageLookup[trimmed.toLowerCase()];
    if (availableMatch != null) {
      return availableMatch;
    }

    final curatedMatch = _curatedLanguageLookup[trimmed.toLowerCase()];
    return curatedMatch ?? trimmed;
  }

  String _canonicalLanguage(String rawLanguage) {
    final trimmed = rawLanguage.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }

    final availableMatch = _availableLanguageLookup[trimmed.toLowerCase()];
    if (availableMatch != null) {
      return availableMatch;
    }

    final curatedMatch = _curatedLanguageLookup[trimmed.toLowerCase()];
    if (curatedMatch != null) {
      return curatedMatch;
    }

    for (final selected in _selectedLanguages) {
      if (selected.toLowerCase() == trimmed.toLowerCase()) {
        return selected;
      }
    }

    return trimmed;
  }

  bool _isAvailable(String language) {
    return widget.availableLanguages == null ||
        _availableLanguageLookup.containsKey(language.trim().toLowerCase());
  }

  bool _isSelected(String language) {
    return _selectedLanguages.any(
      (selected) => selected.toLowerCase() == language.toLowerCase(),
    );
  }

  void _setSelected(String language, bool selected) {
    final existing = _selectedLanguages.firstWhere(
      (entry) => entry.toLowerCase() == language.toLowerCase(),
      orElse: () => '',
    );

    if (selected) {
      if (existing.isEmpty) {
        _selectedLanguages.add(language);
      }
      return;
    }

    if (existing.isNotEmpty) {
      _selectedLanguages.remove(existing);
    }
  }

  void _toggleLanguage(String language) {
    if (!widget.multiSelect) {
      Navigator.of(context).pop([language]);
      return;
    }

    setState(() {
      _setSelected(language, !_isSelected(language));
    });
  }

  void _addCustomLanguage() {
    if (!widget.allowCustomLanguageEntry) {
      return;
    }

    final language = _canonicalLanguage(_customLanguageController.text);
    if (language.isEmpty) {
      return;
    }

    if (!widget.multiSelect) {
      Navigator.of(context).pop([language]);
      return;
    }

    setState(() {
      _setSelected(language, true);
      _customLanguageController.clear();
    });
  }

  bool _matchesQuery(String language, String query) {
    if (query.isEmpty) {
      return true;
    }

    final displayLabel = languageDisplayLabelFor(language).toLowerCase();
    return language.toLowerCase().contains(query) ||
        displayLabel.contains(query);
  }

  List<LanguagePickerSection> _visibleSections(String query) {
    return continentLanguagePickerSections
        .map(
          (section) => LanguagePickerSection(
            title: section.title,
            languages: section.languages
                .where(
                  (language) =>
                      _isAvailable(language) && _matchesQuery(language, query),
                )
                .toList(growable: false),
          ),
        )
        .where((section) => section.languages.isNotEmpty)
        .toList(growable: false);
  }

  List<String> _visibleSupplementalLanguages(String query) {
    final languages = <String>{};

    if (widget.availableLanguages != null) {
      for (final language in widget.availableLanguages!) {
        final canonicalLanguage = _canonicalInitialLanguage(language);
        if (!_curatedLanguageLookup.containsKey(
              canonicalLanguage.toLowerCase(),
            ) &&
            _matchesQuery(canonicalLanguage, query)) {
          languages.add(canonicalLanguage);
        }
      }
    }

    if (widget.allowCustomLanguageEntry) {
      for (final language in _selectedLanguages) {
        if (!_curatedLanguageLookup.containsKey(language.toLowerCase()) &&
            _matchesQuery(language, query)) {
          languages.add(language);
        }
      }
    }

    return languages.toList(growable: false);
  }

  String get _supplementalSectionTitle {
    if (widget.availableLanguages != null && widget.allowCustomLanguageEntry) {
      return 'Other available or custom';
    }
    if (widget.availableLanguages != null) {
      return 'Other available in this room';
    }

    return 'Custom selections';
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final visibleSections = _visibleSections(query);
    final visibleSupplementalLanguages = _visibleSupplementalLanguages(query);
    final hasVisibleOptions =
        visibleSections.isNotEmpty || visibleSupplementalLanguages.isNotEmpty;
    final screenSize = MediaQuery.sizeOf(context);

    return AlertDialog(
      key: const Key('language-picker-dialog'),
      title: Text(widget.title),
      content: SizedBox(
        width: math.min(screenSize.width * 0.92, 720),
        height: math.min(screenSize.height * 0.72, 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('language-picker-search-field'),
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search languages',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (widget.multiSelect) ...[
              const SizedBox(height: 8),
              Text(
                _selectedLanguages.isEmpty
                    ? widget.allowCustomLanguageEntry
                          ? 'Select one or more languages, or add a custom one below.'
                          : 'Select one or more available languages.'
                    : '${_selectedLanguages.length} language(s) selected',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  if (visibleSupplementalLanguages.isNotEmpty)
                    _LanguagePickerSectionView(
                      title: _supplementalSectionTitle,
                      languages: visibleSupplementalLanguages,
                      isSelected: _isSelected,
                      onPressed: _toggleLanguage,
                    ),
                  for (final section in visibleSections)
                    _LanguagePickerSectionView(
                      title: section.title,
                      languages: section.languages,
                      isSelected: _isSelected,
                      onPressed: _toggleLanguage,
                    ),
                  if (!hasVisibleOptions)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.allowCustomLanguageEntry
                            ? 'No languages match your search. Add a custom language below.'
                            : 'No available languages match your search.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),
            ),
            if (widget.allowCustomLanguageEntry) ...[
              const SizedBox(height: 12),
              Text(
                'Can’t find the language you need? Add it here.',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('language-picker-custom-language-field'),
                      controller: _customLanguageController,
                      decoration: const InputDecoration(
                        labelText: 'Custom language',
                        hintText: 'Example: Klingon',
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addCustomLanguage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    key: const Key('language-picker-add-custom-button'),
                    onPressed: _addCustomLanguage,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('language-picker-cancel-button'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (widget.multiSelect)
          FilledButton(
            key: const Key('language-picker-apply-button'),
            onPressed: () => Navigator.of(
              context,
            ).pop(_selectedLanguages.toList(growable: false)),
            child: const Text('Apply'),
          ),
      ],
    );
  }
}

class _LanguagePickerSectionView extends StatelessWidget {
  const _LanguagePickerSectionView({
    required this.title,
    required this.languages,
    required this.isSelected,
    required this.onPressed,
  });

  final String title;
  final List<String> languages;
  final bool Function(String language) isSelected;
  final ValueChanged<String> onPressed;

  @override
  Widget build(BuildContext context) {
    if (languages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 8.0;
              final columns = constraints.maxWidth >= 840
                  ? 3
                  : constraints.maxWidth >= 480
                  ? 2
                  : 1;
              final buttonWidth =
                  (constraints.maxWidth - (spacing * (columns - 1))) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final language in languages)
                    SizedBox(
                      width: buttonWidth,
                      child: _LanguageOptionButton(
                        key: Key('language-picker-option-$language'),
                        label: languageDisplayLabelFor(language),
                        selected: isSelected(language),
                        onPressed: () => onPressed(language),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LanguageOptionButton extends StatelessWidget {
  const _LanguageOptionButton({
    required this.label,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final child = Align(
      alignment: Alignment.centerLeft,
      child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
    );

    if (selected) {
      return FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          shape: const StadiumBorder(),
        ),
        child: child,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        shape: const StadiumBorder(),
      ),
      child: child,
    );
  }
}
