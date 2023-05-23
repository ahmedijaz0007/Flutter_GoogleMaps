Test Project to integrate Google Maps API using Flutter.

The code is mostly self explanatory but I will soon include step by step guide. You need to configure Google map apis from Google cloud platform.

**Features:**

Current location detection.
Start and Destination address marking on google map.
Route Calcuator using Google Direction Api (Note: you have to enable billing to use it). 
Distance Calculator.
The project was implemented using Flutter version 3.0.3 Android Configs:

**How to run:**
Before we start, we need to configure our API keys for our app to work with Google Maps. The general instructions are given here in the package and follow them to set your project up.

Create a Google Maps API key here.
https://developers.google.com/maps/documentation/android-sdk/get-api-key

**Add key to the Android manifest.xml:**
<application...
  <meta-data android:name="com.google.android.geo.API_KEY"
      android:value="YOUR API KEY"/>
**3. Add key to iOS:**
Add the GoogleMaps import to Runner -> AppDelegate.m and add the API Key. Your file should look like this:

#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GMSServices provideAPIKey:@"YOUR API KEY"];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
**4. Add this to Info.plist
**
<key>io.flutter.embedded_views_preview</key>
<string>YES</string>

**You need to add folowing properties to android->localproperties file**

flutter.minSdkVersion=20
flutter.compileSdkVersion=33
flutter.targetSdkVersion=31
Library used

**Add following Dependencies to your pybspec.ymal file**

  google_maps_flutter: ^2.2.7
  geolocator: ^9.0.2
  permission_handler: ^10.2.0
  flutter_polyline_points: ^1.0.0
  geocoding: ^2.1.0
