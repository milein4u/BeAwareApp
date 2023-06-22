# BeAware Mobile App

A new Flutter mobile app destined for street safety.

## Project Description

  The BeAware mobile application was developed using the Flutter framework, the Android Sudio IDE and the Firebase database, namely Firestore.
  
  The BeAware Mobile Application aims to increase safety in urban environments by encouraging user participation and real-time information exchange. By providing users with a platform to mark the points on the map, the application encourages community vigilance by drawing attention to potentially dangerous regions. It is easy for users to indicate risky locations, such as poorly lit streets, regions with high levels of crime or places with dangerous circumstances. By identifying these sites, users can work together to raise awareness and encourage others to be cautious. Users are free to check their list of markings and to remove them, if necessary. Reflecting the changing nature of the urban environment, this feature ensures that information is relevant and relevant.

  The essential characteristic of this application is the “SOS ” functionality. When the user is in an uncertain situation, he can convey a predefined message to his emergency contacts within the application, which contains a Google Maps link to his exact location.
  
  The purpose of the application is to create a safer environment for all users, based on constant and up-to-date transmission of information. The app uses the accessibility of mobile phones and digital maps to promote community involvement and foster a shared sense of responsibility for urban safety. By using this application, users can actively contribute to the overall safety of their environment, while having quick access to help when needed.

   With regard to the development of the application, as well as future directions, a functionality that can make its users more efficient and reliable is the input of a shortcut for the "SOS" button in cases where the use of the telon is not accessible at the time. Another functionality would be the introduction of notifications from the application to its users when a new marking was recently indicated in their surroundings.

## How to install and Run the Project

### Prerequisite

1. Install Android Studio(if you don't have it allready), here is a guide for this: https://developer.android.com/studio/install
2. Install the Flutter and Dart plugins( if you don't have them allready), here is a guide for this: https://docs.flutter.dev/get-started/editor?tab=androidstudio
3. Generate API Key for Maps and add it to the project, if you don't have one, follow steps 1-5 from here: https://www.fluttercampus.com/guide/72/how-to-add-goolge-map-in-flutter-app/
5. Clone this repository, check these links if you have trouble doing this step: https://www.geeksforgeeks.org/how-to-clone-android-project-from-github-in-android-studio/ ; 
https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository
6. Open the project in Android Studio, then run `flutter pub get` in terminal to get all the dependencies from the pubspec.yaml

### Running the Project in Android Studio emulator with Virtual Device 
   
1. If you want to run the project in the Android Studio emulator, open the Device Manager and create a new virtual device if you don't have one, by clicking `Create Device`
2. Launch the device AVD in the emulator
3. Select the created device from the dropdown list Flutter Device Selection , usually appears with `<no device selected>` if you don't have the device selected
4. Make sure you have selected `main.dart` from the Edit Run/Debug configuration dialog
5. Run `flutter run --no-sound-null-safety` in Terminal and you're done 
   

### Running the Project on a Phisical Device

  Here are 2 options, you can either install it on your phone by transfering the .apk file through a USB cable or you can use Developer options on your phone.

### Option 1: Using the .apk file

1. Connect your phone to your computer using a USB cable
2. run `flutter build apk --no-sound-null-safety` in Terminal to generate the .apk file
3. Transfer the .apk file from `build\app\outputs\flutter-apk\app-release.apk ` to your phone
4. Disconnect your phone from the computer and navigate to the folder where you copied the .apk file
5. Tap the .apk file and wait for the installation process to complete
6. After installation you can open the app

### Option 2: Using Developer Options

1. Connect your phone to your computer using a USB cable
2. On your phone, follow these steps to enable Developer Options: https://developer.android.com/studio/debug/dev-options
3. In Android Studio, select `Physical` from Device Manager and your device's name from `Flutter Device Selection`
4. Run `flutter run --no-sound-null-safety` in Terminal and wait for the app to load on your mobile device 



