# Zippy - Secure File Locker

A Flutter Android application that provides secure file archiving with password protection.

## Features

- 🔒 **Password-Protected Archives**: Create secure zip archives with password encryption
- 📁 **Multiple Archives**: Manage multiple archives like folders
- ➕ **Add Files**: Easily add files to your archives using the built-in file picker
- 📤 **Add Files During Creation**: Select files while creating a new archive (NEW!)
- 👁️ **File Preview**: Preview images and text files directly in the app (NEW!)
- 📥 **Extract Files**: Export individual files or extract all files at once (NEW!)
- ➖ **Remove Files**: Remove files from archives when no longer needed
- 📊 **Archive Management**: View archive details, file counts, and sizes
- 🎨 **Modern UI**: Clean, Material Design 3 interface

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android Studio or VS Code with Flutter extensions
- Android device or emulator (API level 21+)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/anubhavkrishna1/zippy.git
cd zippy
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Usage

### Creating an Archive

1. Tap the **+** button on the home screen
2. Enter a name for your archive
3. Set a strong password (minimum 6 characters)
4. **(Optional)** Select files to add during creation
5. Tap **Create Archive**

⚠️ **Important**: Remember your password! If you forget it, you will not be able to access your files.

### Adding Files During Archive Creation (NEW!)

When creating a new archive, you can now add files immediately:

1. In the "Add Files (Optional)" section, tap **Select Files**
2. Choose one or more files from your device
3. Review the selected files (you can remove any before creating)
4. The files will be automatically added when you create the archive

### Previewing Files (NEW!)

You can now preview files before extracting them:

1. Open an archive and enter the password
2. Tap on any file in the list
3. For images: View with zoom and pan support
4. For text files: Read content with monospace formatting
5. For other files: View file info and export option

### Extracting Files (NEW!)

Export files from your archives to device storage:

**Single File Export:**
1. Open an archive
2. Tap the download icon (📥) next to any file
3. File will be exported to Downloads folder

**Extract All Files:**
1. Open an archive
2. Tap the download icon (📥) in the app bar
3. All files will be extracted to `Downloads/{archive-name}/`

Exported files are saved in unencrypted form.

### Adding Files to an Archive

1. Tap on an archive from the list
2. Enter the password to unlock it
3. Tap the **+** button
4. Select files to add from your device
5. Files will be encrypted and added to the archive

### Removing Files from an Archive

1. Open an archive
2. Tap the delete icon next to any file
3. Confirm the removal

### Deleting an Archive

1. Tap the three-dot menu on an archive card
2. Select **Delete**
3. Confirm the deletion

## Security

The app uses XOR-based encryption with SHA-256 password hashing for demonstration purposes. For production use, consider implementing stronger encryption methods such as AES-256.

## Dependencies

- `archive`: ZIP file compression and decompression
- `path_provider`: Access to device storage directories
- `file_picker`: File selection from device storage (uses scoped storage)
- `crypto`: Cryptographic hashing for password protection
- `shared_preferences`: Local data persistence

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
