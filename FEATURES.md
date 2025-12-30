# Zippy App - Feature Overview

## Application Structure

### Core Components

#### 1. Models (`lib/models/`)
- **Archive**: Represents a password-protected archive with metadata (id, name, creation date, file count, total size)
- **FileItem**: Represents individual files within archives with size formatting utilities

#### 2. Services (`lib/services/`)
- **StorageService**: Manages local persistence using SharedPreferences and path_provider
  - Stores archive metadata
  - Manages file lists for each archive
  - Provides paths for archive storage
  
- **ArchiveService**: Handles ZIP operations and encryption
  - Creates password-protected archives
  - Adds/removes files from archives
  - Encrypts/decrypts archive contents
  - Verifies passwords

#### 3. Screens (`lib/screens/`)
- **HomeScreen**: Displays all archives in a list
  - Shows archive metadata (name, file count, size, modified date)
  - Pull-to-refresh functionality
  - Delete archives with confirmation
  
- **CreateArchiveScreen**: Create new password-protected archives
  - Name input validation
  - Password strength validation (minimum 6 characters)
  - Password confirmation
  - Security warning about password recovery
  
- **ArchiveDetailScreen**: Manage files within an archive
  - Password authentication on open
  - Display file list with icons
  - Add multiple files at once
  - Remove files with confirmation
  - Archive statistics display

#### 4. Widgets (`lib/widgets/`)
- **ArchiveCard**: Reusable card component for archive list items
- **FileItemCard**: Reusable card component for file list items with type-specific icons

#### 5. Utilities (`lib/utils/`)
- **FormatUtils**: Shared formatting functions
  - formatSize: Convert bytes to human-readable format (B, KB, MB, GB)
  - formatDate: Format date as DD/MM/YYYY HH:MM
  - formatRelativeDate: Format as relative time (e.g., "2h ago", "Yesterday")

## Key Features

### 🔒 Security
- Password-protected archives using SHA-256 hashing
- XOR-based encryption (demonstration - production should use AES-256)
- No password storage - verified on each access
- Secure local storage using app-private directories

### 📁 Archive Management
- Create unlimited archives (like folders)
- Each archive is independent with its own password
- View archive statistics (file count, total size)
- Delete archives with confirmation dialog

### 📄 File Operations
- Add multiple files at once using system file picker
- Support for any file type
- File type detection with appropriate icons (PDF, images, videos, documents, etc.)
- Remove individual files from archives
- View file sizes in human-readable format

### 🎨 User Interface
- Material Design 3 with custom theme
- Clean, intuitive navigation
- Empty state guidance for new users
- Loading indicators for long operations
- Confirmation dialogs for destructive actions
- Pull-to-refresh on home screen

### 📱 Android Integration
- Scoped storage support (no special permissions needed)
- Uses file_picker for native file selection
- Stores archives in app-private directory
- Minimum API level 21 (Android 5.0+)

## Technical Highlights

### Dependencies
- `archive`: Industrial-strength ZIP compression
- `file_picker`: Native file selection with scoped storage
- `path_provider`: Access to app-specific directories
- `crypto`: SHA-256 hashing for passwords
- `shared_preferences`: Lightweight local data storage

### Architecture
- Clean separation of concerns (models, services, screens, widgets)
- Singleton pattern for services
- Stateful widgets for dynamic UI
- Async/await for I/O operations
- Error handling with try-catch and user feedback

### Code Quality
- Shared utility functions to reduce duplication
- Consistent naming conventions
- Type safety with Dart's type system
- Null safety enabled
- Flutter lints for code quality

## Future Enhancement Possibilities

1. **Enhanced Security**
   - Implement AES-256-GCM encryption
   - Add biometric authentication
   - Implement secure key derivation (PBKDF2/Argon2)

2. **Additional Features**
   - Export archives to external storage
   - Share encrypted archives
   - Search within archives
   - Sort and filter options
   - Archive renaming
   - File preview functionality

3. **UI/UX Improvements**
   - Dark mode support
   - Custom themes
   - Animations and transitions
   - Drag-and-drop file adding

4. **Cloud Integration**
   - Backup to cloud storage
   - Sync across devices
   - Share archives securely

## Getting Started

1. Install Flutter SDK (3.0.0+)
2. Clone the repository
3. Run `flutter pub get`
4. Connect an Android device or start an emulator
5. Run `flutter run`

The app is ready to use immediately - no additional setup required!
