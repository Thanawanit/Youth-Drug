import 'package:flutter/foundation.dart';

class AppState {
  final bool isDarkMode;
  final bool isReadingMode;
  final double fontScale;
  final Set<String> bookmarkedFactIds;

  AppState({
    required this.isDarkMode,
    required this.isReadingMode,
    required this.fontScale,
    required this.bookmarkedFactIds,
  });

  factory AppState.initial() {
    return AppState(
      isDarkMode: false,
      isReadingMode: false,
      fontScale: 1.0,
      bookmarkedFactIds: {},
    );
  }

  AppState copyWith({
    bool? isDarkMode,
    bool? isReadingMode,
    double? fontScale,
    Set<String>? bookmarkedFactIds,
  }) {
    return AppState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isReadingMode: isReadingMode ?? this.isReadingMode,
      fontScale: fontScale ?? this.fontScale,
      bookmarkedFactIds: bookmarkedFactIds ?? Set<String>.from(this.bookmarkedFactIds),
    );
  }
}

class AppStateNotifier extends ValueNotifier<AppState> {
  AppStateNotifier() : super(AppState.initial());

  void toggleDarkMode() {
    value = value.copyWith(isDarkMode: !value.isDarkMode);
  }

  void toggleReadingMode() {
    value = value.copyWith(isReadingMode: !value.isReadingMode);
  }

  void setFontScale(double scale) {
    value = value.copyWith(fontScale: scale);
  }

  void toggleBookmark(String factId) {
    final updatedBookmarks = Set<String>.from(value.bookmarkedFactIds);
    if (updatedBookmarks.contains(factId)) {
      updatedBookmarks.remove(factId);
    } else {
      updatedBookmarks.add(factId);
    }
    value = value.copyWith(bookmarkedFactIds: updatedBookmarks);
  }

  void reset() {
    value = AppState.initial();
  }
}
