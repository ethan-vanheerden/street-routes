//
//  WaypointViewModel.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/6/23.
//

import Foundation
import CoreLocation
import Combine

final class WaypointViewModel: ObservableObject {
    @Published var viewState: WaypointViewState = .loading("Enabling your team...")
    @Published var navigationState: NavigationViewState = .loading("Loading map information...")
    @Published var isNavigating = false
    private var locationManager = LocationManager()
    private var route: Route?
    private var cancellables: Set<AnyCancellable> = []
    
    private var teamName: String
    
    init(teamName: String) {
        self.teamName = teamName
        locationManager.requestSingleLocationUpdate()
        locationManager.$currentLocation
            .sink { [weak self] updatedLocation in
                self?.updateUserLocation(currentLocation: updatedLocation)
            }
            .store(in: &cancellables)
    }
    
    func load() async {
        if let currentLocation = locationManager.currentLocation {
            let coordinate = currentLocation.coordinate
            // First register the team
            do {
                try await registerTeam(currentLocation: coordinate)
                updateViewState(new: .loading("🔎 Finding next waypoint. Hang tight..."))
                
                // Get the team's first route
                let display = try await getRoute(currentLocation: coordinate)
                updateViewState(new: .loaded(display))
            } catch let error {
                updateViewState(new: .error("Error getting waypoint: \(error)"))
            }
        } else {
            updateViewState(new: .error("Unable to get device location."))
        }
    }
    
    func startNavigating() {
        isNavigating = true
        updateNavigationState(new: updateNavigation())
    }
}

// MARK: - Private

private extension WaypointViewModel {
    
    func updateViewState(new: WaypointViewState) {
        Task(priority: .userInitiated) {
            await MainActor.run {
                self.viewState = new
            }
        }
    }
    
    func updateNavigationState(new: NavigationViewState) {
        Task(priority: .userInitiated) {
            await MainActor.run {
                self.navigationState = new
            }
        }
    }
    
    func registerTeam(currentLocation: CLLocationCoordinate2D) async throws {
        let enableTeamBody = EnableTeamRequestBody(teamName: teamName,
                                                   longitude: currentLocation.longitude.magnitude,
                                                   latitude: currentLocation.latitude.magnitude)
        let enableTeamRequest = EnableTeamRequest(requestBody: enableTeamBody)
        
        let response = try await APIInteractor.performRequest(with: enableTeamRequest)
        let responseBody = response.responseObject
        let status = StatusParser.parseStatus(responseBody.status)
        
        switch status {
            // Don't throw error if we get the already registered error
        case .error(let message) where message != "4":
            throw "Error enabling your team: \(message)"
        default:
            break
        }
    }
    
    func getRoute(currentLocation: CLLocationCoordinate2D) async throws -> WaypointPreviewDisplay {
        let requestBody = RequestRouteRequestBody(teamName: teamName,
                                                  longitude: currentLocation.longitude.magnitude,
                                                  latitude: currentLocation.latitude.magnitude)
        let request = RequestRouteRequest(requestBody: requestBody)
        
        while true {
            // Put in while loop since "ERROR 3" means it's still be calculated
            let response = try await APIInteractor.performRequest(with: request)
            let responseBody = response.responseObject
            let status = StatusParser.parseStatus(responseBody.status)
            
            switch status {
            case .ok:
                route = responseBody.route
                return getWaypointDisplay(from: responseBody)
            case .error(let message) where message != "3":
                throw "Error getting next waypoint: \(message)"
            default:
                continue // Try again
            }
        }
    }
    
    func getWaypointDisplay(from response: RequestRouteResponse) -> WaypointPreviewDisplay {
        return .init(teamName: teamName,
                     clueName: response.clueName,
                     clueLongitude: String(response.clueLongitude),
                     clueLatitude: String(response.clueLatitude),
                     clueInfo: response.clueInfo)
    }
    
    func updateUserLocation(currentLocation: CLLocation?) {
        updateNavigationState(new: updateNavigation(currentLocation: currentLocation))
    }
    
    func updateNavigation(currentLocation: CLLocation? = nil) -> NavigationViewState {
        // Grab current location from manager if not given
        guard let currentLocation = currentLocation ?? locationManager.currentLocation,
              let route = self.route else {
            return .error("Unable to start navigation.")
        }
        
        let currentCoord = currentLocation.coordinate
        let currentLocation2D: CLLocationCoordinate2D = .init(latitude: currentCoord.latitude,
                                                              longitude: currentCoord.longitude)
        
        let coords: [CLLocationCoordinate2D] = route.coordinates.map {
            return .init(latitude: $0.latitude, longitude: $0.longitude)
        }
        
        let display = NavigationDisplay(userLocation: currentLocation2D,
                                        polyLine: coords)
        
        return .loaded(display)
    }
}

enum WaypointViewState {
    case loading(_ message: String)
    case error(_ description: String)
    case loaded(WaypointPreviewDisplay)
}

struct WaypointPreviewDisplay {
    let teamName: String
    let clueName: String
    let clueLongitude: String
    let clueLatitude: String
    let clueInfo: String
}

enum NavigationViewState {
    case loading(_ message: String)
    case error(_ description: String)
    case loaded(NavigationDisplay)
}

struct NavigationDisplay {
    let userLocation: CLLocationCoordinate2D
    let polyLine: [CLLocationCoordinate2D]
}
