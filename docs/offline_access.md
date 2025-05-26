# Offline Access Implementation for Stashly App

This document explains how offline access has been implemented in the Stashly app.

## Overview

Offline access allows users to view bookmarks even when they have no internet connection. This is implemented by tracking which bookmarks have been accessed by the user and marking them as "available offline". The implementation uses the Prf package for efficient and persistent local storage.

## Key Components

### 1. Prf Package Implementation

- **Preferences Service**: A dedicated service using `Prf` for type-safe preferences storage
- **Bookmark Repository**: Uses `Prf` to store bookmarks, folders, and access timestamps
- **Offline Tracking**: Keeps track of which bookmarks have been accessed recently

### 2. Access Timestamp Mechanism

The app tracks when a user accesses a bookmark (views its details). This timestamp is stored using:

```dart
// In BookmarkRepository
Future<void> updateAccessTimestamp(String bookmarkId) async {
  final timestamps = await loadAccessTimestamps();
  timestamps[bookmarkId] = DateTime.now();
  await saveAccessTimestamps(timestamps);
}
```

```dart
// In BookmarkService
Future<void> recordBookmarkAccess(String bookmarkId) async {
  final now = DateTime.now();
  accessTimestamps[bookmarkId] = now;
  await _repository.updateAccessTimestamp(bookmarkId);
}
```

### 3. Offline Mode

Users can toggle "Offline Mode" in the app, which filters the bookmarks to only show those that have been accessed recently:

```dart
// In BookmarkController
void toggleOfflineMode() {
  isOfflineMode.value = !isOfflineMode.value;
}

List<Bookmark> getFilteredBookmarks() {
  var filtered = List<Bookmark>.from(bookmarks);

  // Filter by offline if in offline mode
  if (isOfflineMode.value) {
    filtered = filtered.where((b) => isBookmarkOfflineAvailable(b.id)).toList();
  }

  // ...other filters
}
```

### 4. UI Components

- **OfflineIndicator**: A widget that shows when offline mode is active and allows toggling it
- **OfflineAvailableBadge**: A small badge that appears on bookmarks that are available offline

## How It Works

1. When a user views a bookmark's details, the app records the access timestamp
2. Bookmarks accessed within the last 30 days are considered "available offline"
3. In offline mode, only these recently accessed bookmarks are shown
4. Visual indicators show which bookmarks are available offline

## Data Storage Details

All data is stored locally using the `Prf` package, which is a wrapper around SharedPreferences with improved APIs:

- Bookmarks: Stored as JSON strings in `Prf<String>('bookmarks')`
- Folders: Stored as JSON strings in `Prf<String>('folders')`
- Access timestamps: Stored as JSON map in `Prf<String>('last_access_timestamps')`
- App preferences: Stored using typed `Prf` objects like `Prf.enumerated<ThemeMode>('theme_mode')`

## Benefits

- **Seamless Experience**: Users can access important bookmarks even without internet
- **Privacy-Focused**: All data is stored locally on the device
- **Battery Efficient**: No need to constantly sync with a server
- **Type-Safe Storage**: Using `Prf` package ensures type safety and code clarity
