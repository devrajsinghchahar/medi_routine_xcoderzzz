import Foundation
import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var latitude: Double = 28.6139
    @Published var longitude: Double = 77.2090
    @Published var addressString: String = "Connaught Place, New Delhi, India"
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isUpdating: Bool = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestPermissionAndLocate() {
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            startUpdating()
        }
    }
    
    func startUpdating() {
        isUpdating = true
        locationManager.requestLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            self.isUpdating = false
            self.reverseGeocode(location: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isUpdating = false
        }
    }
    
    private func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self, let place = placemarks?.first, error == nil else { return }
            DispatchQueue.main.async {
                let name = place.name ?? ""
                let locality = place.locality ?? ""
                let adminArea = place.administrativeArea ?? ""
                let country = place.country ?? ""
                
                let parts = [name, locality, adminArea, country].filter { !$0.isEmpty }
                if !parts.isEmpty {
                    self.addressString = parts.joined(separator: ", ")
                }
            }
        }
    }
    
    var appleMapsURL: URL? {
        let urlString = "https://maps.apple.com/?ll=\(latitude),\(longitude)&q=Emergency+Patient+Location"
        return URL(string: urlString)
    }
    
    var formattedCoordinates: String {
        let latDirection = latitude >= 0 ? "N" : "S"
        let lonDirection = longitude >= 0 ? "E" : "W"
        return String(format: "%.4f° %@, %.4f° %@", abs(latitude), latDirection, abs(longitude), lonDirection)
    }
}
