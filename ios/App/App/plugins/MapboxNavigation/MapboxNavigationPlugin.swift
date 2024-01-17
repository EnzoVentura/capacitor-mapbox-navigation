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
    
    @objc public func simulateNavigation(_ call : CAPPluginCall) {
        lastLocation = Location(longitude: 50.66321307606863, latitude: 3.0497136739770494);
        locationHistory?.removeAllObjects()
        routes = call.getArray("routes", NSDictionary.self) ?? [NSDictionary]()

        
        let origin = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 50.66321307606863, longitude: 3.0497136739770494), name: "House")
        let destination = Waypoint(coordinate: CLLocationCoordinate2D(latitude:50.63426855813194 , longitude: 3.0213107053877764), name: "Work")
        var waypoints = [Waypoint]([origin, destination]);
        
        for route in routes {
            print(route["latitude"] as! CLLocationDegrees)
            waypoints.append(Waypoint(coordinate: CLLocationCoordinate2DMake(route["latitude"] as! CLLocationDegrees, route["longtitude"] as! CLLocationDegrees)))
        }
        let isSimulate = call.getBool("simulating") ?? false
        let routeOptions = NavigationRouteOptions(waypoints: waypoints, profileIdentifier: .automobile)
        
        print(isSimulate)
        print(routeOptions)
        
        Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let response):
                    guard let route = response.routes?.first, let strongSelf = self else {
                        return
                    }
                            
                    let navigationService = MapboxNavigationService(routeResponse: response, routeIndex: 0, routeOptions: routeOptions, simulating: isSimulate ? .always : .never)
                    let navigationOptions = NavigationOptions(navigationService: navigationService)
                            
                    let viewController = NavigationViewController(for: response, routeIndex: 0, routeOptions: routeOptions, navigationOptions: navigationOptions)
                    viewController.modalPresentationStyle = .fullScreen
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
