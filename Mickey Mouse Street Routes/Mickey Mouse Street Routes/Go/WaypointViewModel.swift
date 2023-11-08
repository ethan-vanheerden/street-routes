//
//  WaypointViewModel.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/6/23.
//

import Foundation
import CoreLocation

final class WaypointViewModel: ObservableObject {
    @Published var viewState: WaypointViewState = .loading(message: "Enabling your team...")
    private var locationManager = LocationManager()
    
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
                teamName = try await registerTeam(currentLocation: coordinate)
                updateViewState(new: .loading(message: "🔎 Finding next waypoint. Hang tight..."))
                
                // Then get the next waypoint
                let display = try await getWaypoint(currentLocation: coordinate)
                updateViewState(new: .loaded(display))
            } catch let error {
                updateViewState(new: .error("Error getting waypoint: \(error)"))
            }
        } else {
            updateViewState(new: .error("Unable to get device location."))
        }
    }
    
    private func updateViewState(new: WaypointViewState) {
        Task(priority: .userInitiated) {
            await MainActor.run {
                self.viewState = new
            }
        }
    }
}

// MARK: - Private

private extension WaypointViewModel {
    /// Returns the registered team name if the operation was successful, otherwise throws
    func registerTeam(currentLocation: CLLocationCoordinate2D) async throws -> String {
        let enableTeamBody = EnableTeamRequestBody(teamName: teamName,
                                                   longitude: currentLocation.longitude.magnitude,
                                                   latitude: currentLocation.latitude.magnitude)
        let enableTeamRequest = EnableTeamRequest(requestBody: enableTeamBody)
        
        let response = try await APIInteractor.performRequest(with: enableTeamRequest)
        let responseBody = response.responseObject
        let status = StatusParser.parseStatus(responseBody.status)
        
        switch status {
        case .ok:
            return responseBody.teamName
        case .error(let message):
            throw "Error enabling your team: \(message)"
        }
    }
    
    func getWaypoint(currentLocation: CLLocationCoordinate2D) async throws -> WaypointPreviewDisplay {
        let requestBody = RequestRouteRequestBody(teamName: teamName,
                                                  longitude: currentLocation.longitude.magnitude,
                                                  latitude: currentLocation.latitude.magnitude)
        let request = RequestRouteRequest(requestBody: requestBody)
        
        let response = try await APIInteractor.performRequest(with: request)
        let responseBody = response.responseObject
        let status = StatusParser.parseStatus(responseBody.status)
        
        switch status {
        case .ok:
            return getWaypointDisplay(from: responseBody)
        case .error(let message):
            throw "Error getting next waypoint: \(message)"
        }
    }
    
    func getWaypointDisplay(from response: RequestRouteResponse) -> WaypointPreviewDisplay {
        return .init(teamName: response.teamName,
                     clueName: response.clueName,
                     clueLongitude: String(response.clueLongitude),
                     clueLatitude: String(response.clueLatitude),
                     clueInfo: response.clueInfo)
    }
}

enum WaypointViewState {
    case loading(message: String)
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
