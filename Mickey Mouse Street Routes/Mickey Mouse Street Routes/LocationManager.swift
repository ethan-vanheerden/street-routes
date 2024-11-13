//
//  LocationManager.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/7/23.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentLocation: CLLocation?
    private var locationManager = CLLocationManager()
//    let teamId: Int
    
    init(teamId: Int) {
//        self.teamId = teamId
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.distanceFilter = 25
    }
    
    func requestSingleLocationUpdate() {
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            Task {
                let teamId = UserDefaults().object(forKey: "team_name") as? Int
                print("sending location update to" + String(describing: location) + String(teamId ?? -1))
                await (currentLocation != nil && teamId != nil) ? sendLocationUpdate(location: location.coordinate, teamId: teamId!) : nil
            }
        }
        
        
    }
    
    func sendLocationUpdate(location: CLLocationCoordinate2D, teamId: Int) async {
        do {
            let updateLocationBody = UpdateTeamLocationRequestBody(teamId: teamId, longitude: location.longitude, latitude: location.latitude)
            let updateRequest = UpdateTeamLocationRequest(requestBody: updateLocationBody)
            
            let response = try await APIInteractor.performRequest(with: updateRequest)
            let status = StatusParser.parseStatus(response.responseObject.status)
            
            switch status {
                // Don't throw error if we get the already registered error
            case .error(let message) where message != "4":
                throw "Error enabling your team: \(message)"
            default:
                break
            }
        } catch let error {
            print("Error sending location update: \(error), contact HQ.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
