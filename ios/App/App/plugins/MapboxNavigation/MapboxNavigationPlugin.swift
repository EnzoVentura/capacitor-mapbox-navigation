import Foundation
import Capacitor
import CoreLocation
import UIKit

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
    private var navigationViewController: NavigationViewController!
    
    @objc public func visualizeRoute(_ call : CAPPluginCall) {
        routes = call.getArray("routes", NSDictionary.self) ?? [NSDictionary]()
        
        let waypoints = routes.compactMap { route -> Waypoint? in
            guard let latitude = route["latitude"] as? CLLocationDegrees,
                  let longitude = route["longitude"] as? CLLocationDegrees else {
                return nil
            }
            return Waypoint(coordinate: CLLocationCoordinate2DMake(latitude, longitude))
        }
        guard waypoints.count >= 2 else {
            call.reject(NavigationError.INVALID_ROUTES.rawValue)
            return
        }
        
        let routeOptions = NavigationRouteOptions(waypoints: waypoints, profileIdentifier: .cycling)
        
        Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
            guard let strongSelf = self else { return }
            
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                    call.reject("Error calculating route")
                case .success(let response):
                    
                    let indexedRouteResponse = IndexedRouteResponse(routeResponse: response, routeIndex: 0);
                
                    
                    strongSelf.navigationViewController = NavigationViewController(for: indexedRouteResponse)
                    let mapView = NavigationMapView(frame: UIScreen.main.bounds)
                    strongSelf.navigationViewController.view.addSubview(mapView)
                
                    strongSelf.navigationViewController.modalPresentationStyle = .fullScreen
                    
                    // Render part of the route that has been traversed with full transparency, to give the illusion of a disappearing route.
                    strongSelf.navigationViewController.waypointStyle = .extrudedBuilding;
                    
                    strongSelf.navigationViewController.delegate = strongSelf;
                    if let route = response.routes?.first {
                        mapView.show([route])
                        mapView.showWaypoints(on: route)
                    }
                
                    DispatchQueue.main.async {
                        self?.setCenteredPopover(strongSelf.navigationViewController)
                        self?.bridge?.viewController?.present(strongSelf.navigationViewController, animated: true, completion: nil)
                    }
                }
            }
        call.resolve()
    }
    
    
    
    @objc public func launchNavigation(_ call : CAPPluginCall) {
        routes = call.getArray("routes", NSDictionary.self) ?? [NSDictionary]()
        
        let waypoints = routes.compactMap { route -> Waypoint? in
            guard let latitude = route["latitude"] as? CLLocationDegrees,
                  let longitude = route["longitude"] as? CLLocationDegrees else {
                return nil
            }
            return Waypoint(coordinate: CLLocationCoordinate2DMake(latitude, longitude))
        }
        guard waypoints.count >= 2 else {
            call.reject(NavigationError.INVALID_ROUTES.rawValue)
            return
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

                    let indexedRouteResponse = IndexedRouteResponse(routeResponse: response, routeIndex: 0)
                    let navigationService = MapboxNavigationService(
                        indexedRouteResponse: indexedRouteResponse,
                        customRoutingProvider: NavigationSettings.shared.directions,
                        credentials: NavigationSettings.shared.directions.credentials,
                        simulating: .onPoorGPS
                    )
                
                    let bottomBanner = CustomBottomBarViewController()
            
                    let navigationOptions = NavigationOptions(navigationService: navigationService, bottomBanner: bottomBanner)
                    let viewController = NavigationViewController(for: indexedRouteResponse, navigationOptions: navigationOptions)
                                
                    viewController.modalPresentationStyle = .fullScreen
                    viewController.routeLineTracksTraversal = true
                    viewController.waypointStyle = .extrudedBuilding
                
                    viewController.floatingButtons = []
                    viewController.showsSpeedLimits = false
                    viewController.delegate = strongSelf
                
                    DispatchQueue.main.async {
                        strongSelf.setCenteredPopover(viewController)
                        strongSelf.bridge?.viewController?.present(viewController, animated: true, completion: nil)
                    }
                }
            }
        call.resolve()
    }
    
    public func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
          self.bridge?.triggerWindowJSEvent(eventName: "navigation_closed");
          navigationViewController.dismiss(animated: true);
    }
}
    

// MARK: - CustomBottomBarViewController

class CustomBottomBarViewController: ContainerViewController, CustomBottomBannerViewDelegate {
    weak var navigationViewController: NavigationViewController?
    
    lazy var bannerView: CustomBottomBannerView = {
        let banner = CustomBottomBannerView()
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.delegate = self
        return banner
    }()
    
    override func loadView() {
        super.loadView()
     
        view.addSubview(bannerView)
         
        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bannerView.heightAnchor.constraint(equalToConstant: 132) // height of bottom banner
       ])
    }
         
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - NavigationServiceDelegate implementation
     
    func navigationService(_ service: NavigationService, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        bannerView.eta = "~\(Int(round(progress.durationRemaining / 60))) min"
    }
     
    // MARK: - CustomBottomBannerViewDelegate implementation
    func customBottomBannerDidCancel(_ banner: CustomBottomBannerView) {
        navigationViewController?.dismiss(animated: true, completion: nil)
    }
}
