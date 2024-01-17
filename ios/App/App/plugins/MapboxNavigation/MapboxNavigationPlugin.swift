import Foundation
import Capacitor
import CoreLocation

import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation

enum LocationPermissionStatus{
    case GRANTED, DENIED, PROMPT
}

struct Location: Codable {
    var _id: String = ""
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    var when: String = ""
}

protocol ILocation {
    var longitude: Int {get}
    var latitude: Int {get}
}

var lastLocation: Location?;
var locationHistory: NSMutableArray?;
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
    
//    func extractPosition(data: [String: Double]) -> [Double]? {
//        if let longitude = data["longitude"], let latitude = data["latitude"] {
//            let output = Waypoint(coordinate: CLLO)
//            
//            
//            let output = [longitude, latitude]
//            
//            
//            
//            
//            print(output)
//            return (output)
//        } else {
//            print("The 'longitude' and 'latitude' keys are required.")
//            return nil
//        }
//    }
    
    @objc public func launchNavigation(_ call : CAPPluginCall) {lastLocation = Location(longitude: 0.0, latitude: 0.0);
        routes = call.getArray("routes", NSDictionary.self) ?? [NSDictionary]()
        var waypoints = [Waypoint]();
        
        print("SWIFT: routes ", routes)
        
        for route in routes {
            waypoints.append(Waypoint(coordinate: CLLocationCoordinate2DMake(route["latitude"] as! CLLocationDegrees, route["longitude"] as! CLLocationDegrees)))
        }
        
        let routeOptions = NavigationRouteOptions(waypoints: waypoints, profileIdentifier: .cycling)
    
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
