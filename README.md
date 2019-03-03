# flutter_zsdk

Zebra Link OS SDK Flutter Bindings

## Getting Started

### IOS
	- This class will only work with Zebra printers which have the Made For iPod/iPhone certification. 
    - You need to include the External Accessory framework in your project to be able to use this class 
    - You need to include the Zebra printer protocol string "com.zebra.rawport" in your info.plist file under "Supported external accessory protocols" 
    - You need to Set the key "Required Background modes" to "App Communicates with an accessory" in your app's plist file

### ANDROID
	- Android 6 and higher (API 23+) requires user permission ACCESS_COARSE_LOCATION or ACCESS_FINE_LOCATION in your application manifest.
	
This project is a starting point for a Flutter
[plug-in package](https://flutter.io/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.io/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
