# Quick Start Guide - Zippy

## 🚀 Get Started in 3 Steps

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Run the App
```bash
flutter run
```

### Step 3: Start Using Zippy!

## 📝 First Time Usage

### Create Your First Archive
1. **Launch the app** - You'll see an empty screen with a message
2. **Tap the + button** in the bottom right corner
3. **Enter a name** for your archive (e.g., "Personal Documents")
4. **Create a password** (minimum 6 characters)
5. **Confirm your password**
6. **Tap "Create Archive"**

⚠️ **Remember your password!** There's no way to recover it if you forget.

### Add Files to Your Archive
1. **Tap on your archive** from the list
2. **Enter your password** to unlock it
3. **Tap the + button** to add files
4. **Select files** from your device using the file picker
5. **Wait** for the files to be encrypted and added
6. **Done!** Your files are now securely stored

### Remove Files
1. **Open an archive** and enter the password
2. **Tap the delete icon** (🗑) next to any file
3. **Confirm** the deletion
4. **File removed** from the archive

### Delete an Archive
1. **Tap the menu icon** (⋮) on any archive card
2. **Select "Delete"**
3. **Confirm** the deletion
4. **Archive deleted** along with all its files

## 🎯 Use Cases

### Personal Documents
Store sensitive documents like:
- ID cards and passports
- Bank statements
- Tax documents
- Medical records

### Work Files
Secure your work-related files:
- Contracts and agreements
- Financial reports
- Client information
- Project documentation

### Photo Albums
Keep private photos safe:
- Family photos
- Travel memories
- Special occasions
- Personal snapshots

### Important Files
Protect any file type:
- Videos
- Audio recordings
- Spreadsheets
- Presentations

## 💡 Tips & Tricks

### Password Best Practices
- Use a mix of letters, numbers, and symbols
- Make it at least 8-12 characters long
- Don't use common words or personal information
- Use different passwords for different archives

### Organizing Archives
- Create separate archives for different categories
- Name archives clearly (e.g., "2024 Tax Documents")
- Don't put too many files in one archive
- Delete old archives you no longer need

### Performance
- The app stores archives in your device's internal storage
- Each archive is encrypted independently
- Adding large files may take a few seconds
- File types are automatically detected

## 🔒 Security Features

### What's Protected
✅ All files are encrypted within the archive  
✅ Passwords are hashed (not stored in plain text)  
✅ Archives are stored in app-private directory  
✅ No internet connection required  
✅ Files never leave your device  

### What to Remember
⚠️ If you forget your password, files cannot be recovered  
⚠️ Uninstalling the app will delete all archives  
⚠️ Current encryption is for demonstration (XOR-based)  
⚠️ For production use, implement AES-256 encryption  

## ❓ Troubleshooting

### Can't Open Archive
**Problem**: "Invalid password" message  
**Solution**: Make sure you're entering the correct password. Passwords are case-sensitive.

### Files Not Adding
**Problem**: Files don't appear after selection  
**Solution**: Wait a moment - large files take time to encrypt. Look for the loading indicator.

### App Crashes
**Problem**: App closes unexpectedly  
**Solution**: Check you have enough storage space. Try restarting the app.

### No File Picker Appears
**Problem**: Nothing happens when tapping + to add files  
**Solution**: Ensure the app has necessary permissions. Try restarting the app.

## 📱 System Requirements

- **Platform**: Android 5.0 (API level 21) or higher
- **Storage**: Minimum 50 MB free space
- **RAM**: Minimum 2 GB recommended
- **Permissions**: File access (handled by system file picker)

## 🛠 Development Requirements

- **Flutter SDK**: 3.0.0 or higher
- **Dart SDK**: Included with Flutter
- **Android Studio** or **VS Code** with Flutter extensions
- **Android device** or **emulator** for testing

## 📚 Additional Resources

- **README.md**: Comprehensive project documentation
- **FEATURES.md**: Technical architecture overview
- **UI_FLOW.md**: Visual interface design guide

## 🤝 Need Help?

If you encounter issues:
1. Check the documentation files
2. Review the code comments
3. Open an issue on GitHub
4. Contact the developer

---

**Happy Archiving! 🎉**  
Keep your files safe with Zippy!
