#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

CAP_PLUGIN(MapboxNavigationPlugin, "MapboxNavigation",
        CAP_PLUGIN_METHOD(launchNavigation, CAPPluginReturnPromise);
        CAP_PLUGIN_METHOD(visualizeRoute, CAPPluginReturnPromise);
)
