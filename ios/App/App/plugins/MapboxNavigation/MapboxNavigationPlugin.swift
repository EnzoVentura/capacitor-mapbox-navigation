import Foundation
import Capacitor
import CoreLocation

import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation

enum LocationPermissionStatus {
    case GRANTED, DENIED, PROMPT
}

enum NavigationError : String {
    case INVALID_ROUTES
    case INVALID_PROFILE
}

protocol ILocation {
    var longitude: Int {get}
    var latitude: Int {get}
}

var routes = [NSDictionary]();

@objc(MapboxNavigationPlugin)
public class MapboxNavigationPlugin : CAPPlugin, NavigationViewControllerDelegate {
    @objc public func checkLocationPermissions(_ call: CAPPluginCall){
        let locationStatus: LocationPermissionStatus
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationStatus = LocationPermissionStatus.PROMPT
        case .restricted, .denied:
            locationStatus = LocationPermissionStatus.DENIED
        case .authorizedAlways, .authorizedWhenInUse:
            locationStatus = LocationPermissionStatus.GRANTED
        @unknown default:
            locationStatus = LocationPermissionStatus.PROMPT
        }
        print("checkLocation Swift", locationStatus)
        call.resolve(["location": locationStatus])
    }

    @objc public func requestLocationPermissions(_ call: CAPPluginCall){
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        call.resolve()
    }
    
    @objc public func launchNavigation(_ call : CAPPluginCall) {
        routes = call.getArray("routes", NSDictionary.self) ?? [NSDictionary]()
        let profile = call.getString("profile") ?? ".cycling"
        
        var waypoints = [Waypoint]();
        
        for route in routes {
            waypoints.append(Waypoint(coordinate: CLLocationCoordinate2DMake(route["latitude"] as! CLLocationDegrees, route["longitude"] as! CLLocationDegrees)))
        }
        
        if (waypoints.count < 2) {
            call.reject(NavigationError.INVALID_ROUTES.rawValue)
            return
        }
        
        let profileValue : ProfileIdentifier = ProfileIdentifier(rawValue: profile)
        print("Profile :", profile, profileValue)
        let routeOptions = NavigationRouteOptions(waypoints: waypoints, profileIdentifier: profileValue )
        
        
    
        Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let response):
                    guard let strongSelf = self else {
                        return
                    }
                
                    let indexedRouteResponse = IndexedRouteResponse(routeResponse: response, routeIndex: 0);
                    let navigationService = MapboxNavigationService(indexedRouteResponse: indexedRouteResponse, customRoutingProvider: NavigationSettings.shared.directions, credentials: NavigationSettings.shared.directions.credentials, simulating: .always)
                
                    let navigationOptions = NavigationOptions(navigationService: navigationService)
                    let viewController = NavigationViewController(for: indexedRouteResponse, navigationOptions: navigationOptions)
                    
                    viewController.modalPresentationStyle = .fullScreen
                    // Render part of the route that has been traversed with full transparency, to give the illusion of a disappearing route.
                    viewController.routeLineTracksTraversal = true
                    
                    viewController.waypointStyle = .extrudedBuilding;
                    viewController.delegate = strongSelf;
                    
                    DispatchQueue.main.async {
                        self?.setCenteredPopover(viewController)
                        self?.bridge?.viewController?.present(viewController, animated: true, completion: nil)
                    }
                }
            }
        call.resolve()
    }
    
}
