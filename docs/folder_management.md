# Folder Management in Stashly

This document outlines how folder management is implemented in the Stashly bookmark app.

## Overview

Folder management allows users to organize their bookmarks into customizable folders.
In the free version, users can create up to 3 folders.

## Implementation Details

### Data Model

Folders are represented by the `Folder` class:

- `id`: Unique identifier
- `name`: Display name of the folder
- `description`: Optional description
- `iconName`: Optional icon identifier
- `color`: Optional color in hex format (e.g., "#2196F3")

### Storage

Folders are stored using the Prf package:

- `_foldersPrf = Prf<String>('folders')` stores a JSON string containing all folders

### Services and Controllers

1. **FolderService**: Handles persistence operations

   - Loads and saves folders
   - Manages folder limits
   - Prevents duplicate folder names

2. **FolderController**: Handles UI logic
   - Provides reactive folder lists
   - Manages selected folders
   - Handles CRUD operations
   - Enforces business rules (e.g., free user limits)

### UI Components

1. **FoldersView**: Main screen showing all folders

   - Lists all folders with their icons/colors
   - Shows bookmark count in each folder
   - Allows adding/editing/deleting folders
   - Enforces folder limits for free users

2. **FolderFormView**: Form for creating or editing folders

   - Validates folder names
   - Provides customization options (icons, colors)
   - Reports success/failure with snackbars

3. **HomeView Integration**:

   - Drawer navigation to folders
   - Folder selection persists across sessions
   - Shows folder badges on bookmarks
   - Filters bookmarks by selected folder

4. **BookmarkDetailView Integration**:
   - Shows folder information on bookmark details
   - Allows navigation to the folder view

## User Flow

1. User creates a folder from the Folders screen
2. User adds/edits a bookmark and assigns it to a folder
3. User can filter bookmarks by selecting a folder from the drawer or folders screen
4. User can remove the folder filter by clicking the X in the filter indicator

## Limitations

- Free users are limited to 3 folders
- When a folder is deleted, bookmarks remain but are no longer assigned to any folder
- Folder names must be unique

## Future Enhancements

- Allow reordering of folders
- Nested folder support for premium users
- Color-coded folder views
- Folder-specific settings (e.g., sort order)
