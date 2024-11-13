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
    @Published var viewState: WaypointViewState
    @Published var isNavigating = false
    private var locationManager : LocationManager
    private var currentClueName: String = ""
    private var currentClueLat: Double = 0
    private var currentClueLong: Double = 0
    
    private var teamId: Int
    
    init(teamId: Int) {
        self.teamId = teamId
        self.locationManager = LocationManager(teamId: self.teamId)
        locationManager.requestSingleLocationUpdate()
        self.viewState = .loading("Enabling your team...")
    }
    
    func load() async {
        if let currentLocation = locationManager.currentLocation {
            let coordinate = currentLocation.coordinate
            print(coordinate)
            // First register the team
            do {
                try await registerTeam(currentLocation: coordinate)
                await updateViewState(new: .loading("🔎 Finding next waypoint. Hang tight..."))
                
                // Get the team's first route
                let display = try await getRoute(currentLocation: coordinate)
                await updateViewState(new: .loaded(display))
            } catch let error {
                await updateViewState(new: .error("Error getting waypoint: \(error)"))
            }
        } else {
            await updateViewState(new: .error("Unable to get device location."))
        }
    }
    
    func startNavigating() async {
        await MainActor.run {
            isNavigating = true
        }
        openMaps()
    }
    
    func markClueVisited() async {
        guard let currentLocation = locationManager.currentLocation else {
            await updateViewState(new: .error("Unable to get device location."))
            return
        }
        do {
            let coordinate = currentLocation.coordinate
            let visitBody = VisitClueRequestBody(teamId: teamId,
                                                 clueName: currentClueName,
                                                 longitude: coordinate.longitude,
                                                 latitude: coordinate.latitude)
            
            let visitRequest = VisitClueRequest(requestBody: visitBody)
            
            let response = try await APIInteractor.performRequest(with: visitRequest)
            let status = StatusParser.parseStatus(response.responseObject.status)
            
            switch status {
                // Don't throw error if we get the already registered error
            case .error(let message):
                throw message
            default:
                await MainActor.run {
                    isNavigating = false
                }
            }
        } catch let error {
            await updateViewState(new: .error("Error marking clue as visited: \(error), contact HQ."))
        }
        
        await getNewClue()
    }
    
    func getNewClue() async {
        guard let currentLocation = locationManager.currentLocation else {
            await updateViewState(new: .error("Unable to get device location."))
            return
        }
        
        await updateViewState(new: .loading("🔎 Finding next waypoint. Hang tight..."))
        
        do {
            let coordinate = currentLocation.coordinate
            let display = try await getRoute(currentLocation: coordinate)
            await updateViewState(new: .loaded(display))
        } catch let error {
            await updateViewState(new: .error("Error getting waypoint: \(error)"))
        }
    }
}

// MARK: - Private

private extension WaypointViewModel {
    
    func updateViewState(new: WaypointViewState) async {
        await MainActor.run {
            self.viewState = new
        }
    }
    
    func registerTeam(currentLocation: CLLocationCoordinate2D) async throws {
        let enableTeamBody = EnableTeamRequestBody(teamId: teamId,
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
        while true {
            // Put in while loop since "ERROR 3" means it's still be calculated
            do {
                let requestBody = RequestRouteRequestBody(teamId: teamId,
                                                          longitude: currentLocation.longitude,
                                                          latitude: currentLocation.latitude)
                let request = RequestRouteRequest(requestBody: requestBody)
                
                let response = try await APIInteractor.performRequest(with: request)
                let responseBody = response.responseObject
                let status = StatusParser.parseStatus(responseBody.status)
                
                switch status {
                case .ok:
                    currentClueName = responseBody.clueName
                    currentClueLat = responseBody.clueLatitude
                    currentClueLong = responseBody.clueLongitude
                    return getWaypointDisplay(from: responseBody)
                default:
                    let _ = try? await Task.sleep(nanoseconds: 20_000_000_000)
                    continue // Try again
                }
            } catch {
                let _ = try? await Task.sleep(nanoseconds: 20_000_000_000)
                continue
            }
            
        }
    }
    
    func getWaypointDisplay(from response: RequestRouteResponse) -> WaypointPreviewDisplay {
        return .init(teamId: teamId,
                     clueName: response.clueName,
                     clueLongitude: String(response.clueLongitude),
                     clueLatitude: String(response.clueLatitude),
                     clueInfo: response.clueInfo)
    }
    
    func openMaps() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: .init(latitude: currentClueLat,
                                                                         longitude: currentClueLong)))
        mapItem.name = currentClueName// Set a name for the location
        
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
    let teamId: Int
    let clueName: String
    let clueLongitude: String
    let clueLatitude: String
    let clueInfo: String
}
