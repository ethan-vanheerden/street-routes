//
//  WaypointViewModel.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/6/23.
//

import Foundation
import CoreLocation
import MapKit

final class WaypointViewModel: ObservableObject {
    @Published var viewState: WaypointViewState = .loading("Enabling your team...")
    @Published var isNavigating = false
    private var locationManager = LocationManager()
    private var route: Route?
    
    private var teamName: String
    
    init(teamName: String) {
        self.teamName = teamName
        locationManager.requestSingleLocationUpdate()
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
        openMaps()
    }
    
    func markClueVisited() async {
        // TODO: implement
    }
    
    func getNewClue() async {
        // TODO: implement
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
    
    func registerTeam(currentLocation: CLLocationCoordinate2D) async throws {
        let enableTeamBody = EnableTeamRequestBody(teamName: teamName,
                                                   longitude: currentLocation.longitude,
                                                   latitude: currentLocation.latitude)
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
                                                  longitude: currentLocation.longitude,
                                                  latitude: currentLocation.latitude)
        let request = RequestRouteRequest(requestBody: requestBody)
        
        while true {
            // Put in while loop since "ERROR 3" means it's still be calculated
            do {
                let response = try await APIInteractor.performRequest(with: request)
                let responseBody = response.responseObject
                let status = StatusParser.parseStatus(responseBody.status)
                
                switch status {
                case .ok:
                    route = responseBody.route
                    return getWaypointDisplay(from: responseBody)
                default:
                    continue // Try again
                }
            } catch {
                continue
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
    
    func openMaps() {
        guard let location = locationManager.currentLocation else {
            updateViewState(new: .error("Could not get current location"))
            return
        }
        let coordinate = location.coordinate
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: .init(latitude: coordinate.latitude,
                                                                         longitude: coordinate.longitude)))
        mapItem.name = "Clue name" // Set a name for the location

        // You can also specify various options for launching the map
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]

        // Open the Maps app with the specified location
        mapItem.openInMaps(launchOptions: launchOptions)
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
