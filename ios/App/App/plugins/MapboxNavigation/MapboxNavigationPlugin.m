#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

CAP_PLUGIN(MapboxNavigationPlugin, "MapboxNavigation",
        CAP_PLUGIN_METHOD(checkLocationPermissions, CAPPluginReturnPromise);
        CAP_PLUGIN_METHOD(requestLocationPermissions, CAPPluginReturnPromise);
        CAP_PLUGIN_METHOD(launchNavigation, CAPPluginReturnPromise);
)
