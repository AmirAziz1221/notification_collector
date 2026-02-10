# notification_collector

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# notification_collector

A research-focused Flutter application designed to capture, log, and analyze mobile notifications. This tool is built to support studies on digital distraction and user behavior patterns.

## 📌 Features
* **Real-time Capture:** Intercepts incoming notifications.
* **Data Logging:** Saves notification metadata for analysis.
* **Research Ready:** Optimized for distraction-related research projects.

---

## 🛠️ Prerequisites
Before running this project, ensure you have the following installed on your machine:

* **Flutter SDK:** [Download Flutter](https://docs.flutter.dev/get-started/install) (Version 3.10 or higher recommended).
* **Dart SDK:** Included automatically with Flutter.
* **IDE:** Android Studio or VS Code (Install the **Flutter** and **Dart** plugins).
* **Git:** [Download Git](https://git-scm.com/downloads).

---

## 🚀 Setup & Installation

Follow these steps exactly to get the project running on your local machine

### 1. Clone the Repository
Open your terminal and run
bash
git clone [https://github.com/AmirAziz1221/notification_collector.git](https://github.com/AmirAziz1221/notification_collector.git)
cd notification_collector

### 2. Verify Environment
Check if your Flutter setup is complete

bash
flutter doctor

### 3. Install Dependencies
Download the necessary packages defined in the project

bash
flutter pub get

### 4. Connect a Device
* **Physical Android Device:** Required for notification testing (emulators often struggle with notification listeners).
* **Enable Developer Options:** Go to `Settings` > `About Phone` and tap **Build Number** 7 times.
* **Enable USB Debugging:** Found in `Settings` > `System` > `Developer Options`.

### 5. Run the App
To compile and install the app on your connected device, run

bash
flutter run

## Important: Notification Permissions

This app requires a special permission that **cannot** be granted automatically by the code due to Android security policies. Without this, the app will not be able to "see" or log incoming notifications.

### How to Enable:
1. **Open the app** on your phone.
2. If prompted, click **Allow** for Notification Access.
3. If the prompt does not appear, manually navigate to:
   > `Settings` → `Apps` → `Special app access` → `Notification access`
4. Find **Notification Collector** in the list and toggle it **ON**.
