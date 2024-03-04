import Capacitor
import MapboxNavigation
import MapboxMaps

class CustomNavigationViewController : NavigationViewController, NavigationViewControllerDelegate {
    private var mapView: MapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("TEST CUSTOM CONTROLLER")
        modifyMapStyle()
    }
    
    func modifyMapStyle() {
        guard let mapView = mapView else { return }

        mapView.backgroundColor = UIColor.red
        
    }
}
