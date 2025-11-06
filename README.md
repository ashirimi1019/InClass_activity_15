# Inventory Management App - inclass15

A comprehensive Flutter application for Georgia State University CSC 4360/6360 Mobile App Development course that demonstrates advanced Firebase integration with clean architecture, real-time CRUD operations, and enhanced features.

## 🎓 Student Information
- **Course**: CSC 4360/6360 – Mobile App Development
- **Activity**: In-Class Activity 15 – Inventory Management App
- **Student**: Ashir Imran (aimran6)

## 📱 Features

### Core CRUD Operations
- ✅ Create, Read, Update, Delete inventory items
- 🔄 Real-time data synchronization with Firestore
- 📱 Clean architecture with separate models, services, and UI layers

### Enhanced Features Implemented

#### 🟩 A. Search & Filter
- 🔍 Real-time search by item name (case-insensitive)
- 📂 Category filtering (Electronics, Clothing, Food, Books, Other)
- 💰 Price range filtering with min/max inputs
- 🔄 Combined search and filter capabilities

#### 🟩 B. Dashboard / Insights
- � Total number of inventory items
- 💵 Total inventory value (quantity × price)
- ⚠️ Out-of-stock items tracking
- 📈 Real-time dashboard updates

## 🏗️ Project Structure
```
lib/
├─ main.dart                          # App entry point with Firebase initialization
├─ firebase_options.dart              # Generated Firebase configuration
├─ models/
│  └─ item.dart                      # Enhanced Item data model
├─ services/
│  └─ firestore_service.dart         # Complete Firestore operations layer
└─ screens/
   ┣ inventory_home_page.dart        # Main screen with dashboard and list
   └─ add_edit_item_screen.dart      # Add/edit form with validation
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- Firebase CLI installed
- Android Studio or VS Code with Flutter extensions

### Setup Instructions

1. **Clone and navigate to the project**:
   ```bash
   cd inclass15
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (REQUIRED):
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli

   # Configure Firebase project
   flutterfire configure
   ```
   - Create/select Firebase project named `inventory-app-yourname`
   - Choose platforms (Android, iOS, etc.)
   - This generates the correct `firebase_options.dart` file

4. **Enable Firestore**:
   - Go to Firebase Console > Firestore Database
   - Create database in **test mode** (important!)

5. **Run the app**:
   ```bash
   flutter run
   ```

## 🔧 Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.0
  cloud_firestore: ^4.9.5
```

## 📝 Usage

### Dashboard Overview
- View total items count, inventory value, and out-of-stock alerts
- Dashboard updates automatically when items are added/modified

### Managing Items

#### Adding New Items
- Tap the ➕ floating action button
- Fill in: name, quantity, price, category
- Form validation ensures data integrity
- Items appear instantly in the list

#### Editing Items
- Tap the ✏️ edit icon on any item
- Modify any field (name, quantity, price, category)
- Changes save automatically to Firestore

#### Deleting Items
- Tap the 🗑️ delete icon
- Confirm deletion in dialog
- Item removed from Firestore and UI instantly

### Search & Filter Features

#### Search by Name
- Type in the search bar at the top
- Results filter in real-time as you type
- Case-insensitive matching

#### Category Filter
- Use dropdown to select category
- Filters items by selected category
- "All" shows all items

#### Price Range Filter
- Enter minimum and maximum prices
- Tap "Filter" to apply price range
- Tap "Reset" to clear all filters

## 🏃‍♂️ Running the App

### Using VS Code
1. Open the project in VS Code
2. Press `Ctrl+Shift+P` and select "Flutter: Select Device"
3. Press `F5` or use "Run and Debug" panel

### Using Terminal
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in debug mode
flutter run --debug

# Run in release mode
flutter run --release
```

### Using VS Code Tasks
A Flutter Run task has been configured. Use `Ctrl+Shift+P` → "Tasks: Run Task" → "Flutter Run"

## 🔥 Firebase Configuration Notes

The app includes a placeholder `firebase_options.dart` that will show configuration errors until you run `flutterfire configure`. This is intentional - the file will be replaced with your actual Firebase project configuration.

## 🧪 Testing Features

### CRUD Operations
1. **Create**: Add items with different categories and prices
2. **Read**: Verify items appear in real-time list
3. **Update**: Edit items and confirm changes persist
4. **Delete**: Remove items and verify they're gone

### Enhanced Features
1. **Search**: Test name-based search functionality
2. **Category Filter**: Test filtering by Electronics, Clothing, etc.
3. **Price Filter**: Test min/max price filtering
4. **Dashboard**: Verify total counts and values update correctly
5. **Out-of-Stock**: Add items with quantity 0 and check dashboard

## 📱 Supported Platforms
- ✅ Android (primary target)
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🎨 UI Features
- Material 3 design system
- Responsive dashboard cards
- Real-time data streaming
- Form validation with error messages
- User feedback with SnackBars
- Clean card-based item list
- Intuitive navigation between screens

## 🔧 Development

### Project Architecture
- **Model Layer**: `Item` class with Firestore serialization
- **Service Layer**: `FirestoreService` handles all database operations
- **UI Layer**: Separate screens for home and add/edit functionality
- **Navigation**: Proper screen transitions with result handling

### Key Classes

#### Item Model
```dart
class Item {
  String? id;
  String name;
  int quantity;
  double price;
  String category;
  DateTime createdAt;

  // Firestore serialization methods
  Map<String, dynamic> toMap();
  factory Item.fromMap(String id, Map<String, dynamic> map);
}
```

#### FirestoreService
```dart
class FirestoreService {
  // CRUD operations
  Future<void> addItem(Item item);
  Stream<List<Item>> getItemsStream();
  Future<void> updateItem(Item item);
  Future<void> deleteItem(String id);

  // Enhanced features
  Stream<List<Item>> searchItems(String query);
  Stream<List<Item>> filterByCategory(String category);
  Stream<List<Item>> filterByPriceRange(double min, double max);
  Future<Map<String, dynamic>> getDashboardData();
}
```

## 📚 Learning Objectives

This project demonstrates:
- Advanced Firebase Firestore integration
- Clean architecture principles
- Real-time data streaming
- Complex state management
- Form validation and error handling
- Material Design 3 implementation
- Enhanced user experience features
- Professional app development practices

## 🚀 Build & Deployment

### Android APK Build
```bash
flutter build apk --release
```

The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

### Submission Requirements
- ✅ GitHub repository (public)
- ✅ Complete source code with proper structure
- ✅ Working Firebase integration
- ✅ Both enhanced features implemented
- ✅ Android APK for testing
- ✅ Comprehensive README documentation

## 🔄 Migration from Activity #14

This app evolved from a simple Product CRUD app to a full Inventory Management system with:
- Enhanced Item model (added quantity, category, createdAt)
- Service layer architecture (FirestoreService)
- Multiple screens (Home + Add/Edit)
- Dashboard with insights
- Advanced search and filtering
- Professional UI/UX improvements

---

**Ready for submission!** 🚀
