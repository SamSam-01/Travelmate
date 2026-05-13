import 'package:flutter/material.dart';
import 'package:front/domain/entities/place_search_suggestion.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/styles/colors.dart';

class MapPlaceSearchPanel extends StatelessWidget {
  const MapPlaceSearchPanel({
    required this.controller,
    required this.onSuggestionSelected,
    required this.onClear,
    required this.suggestions,
    required this.isEnabled,
    required this.isLoading,
    this.errorMessage,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onClear;
  final ValueChanged<PlaceSearchSuggestion> onSuggestionSelected;
  final List<PlaceSearchSuggestion> suggestions;
  final bool isEnabled;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: CrazerColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: CrazerColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: TextField(
                    controller: controller,
                    enabled: isEnabled,
                    style: const TextStyle(color: CrazerColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: localizations.mapsSearchHint,
                      hintStyle: const TextStyle(
                        color: CrazerColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      icon: const Icon(Icons.search, color: CrazerColors.lime),
                      suffixIcon: isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: CrazerColors.lime,
                                ),
                              ),
                            )
                          : controller.text.trim().isEmpty
                          ? null
                          : IconButton(
                              onPressed: onClear,
                              icon: const Icon(
                                Icons.close,
                                color: CrazerColors.textPrimary,
                              ),
                            ),
                    ),
                  ),
                ),
                if (!isEnabled)
                  _PanelMessage(
                    message: localizations.mapsSearchDisabledMessage,
                  )
                else if (errorMessage != null)
                  _PanelMessage(message: errorMessage!)
                else if (controller.text.trim().length >= 2 &&
                    suggestions.isEmpty &&
                    !isLoading)
                  _PanelMessage(message: localizations.mapsSearchEmpty)
                else if (suggestions.isNotEmpty)
                  _SuggestionsList(
                    suggestions: suggestions,
                    onSuggestionSelected: onSuggestionSelected,
                  ),
                const Divider(height: 1, color: CrazerColors.border),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      localizations.mapsSearchPoweredByGoogle,
                      style: const TextStyle(
                        color: CrazerColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionsList extends StatelessWidget {
  const _SuggestionsList({
    required this.suggestions,
    required this.onSuggestionSelected,
  });

  final List<PlaceSearchSuggestion> suggestions;
  final ValueChanged<PlaceSearchSuggestion> onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: suggestions.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: CrazerColors.border),
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];

        return ListTile(
          onTap: () => onSuggestionSelected(suggestion),
          leading: const Icon(Icons.place_outlined, color: CrazerColors.lime),
          title: Text(
            suggestion.title,
            style: const TextStyle(color: CrazerColors.textPrimary),
          ),
          subtitle: suggestion.subtitle == null
              ? null
              : Text(
                  suggestion.subtitle!,
                  style: const TextStyle(color: CrazerColors.textSecondary),
                ),
        );
      },
    );
  }
}

class _PanelMessage extends StatelessWidget {
  const _PanelMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          message,
          style: const TextStyle(color: CrazerColors.textSecondary),
        ),
      ),
    );
  }
}
