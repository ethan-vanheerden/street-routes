//
//  WaypointView.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/6/23.
//

import SwiftUI
import MapKit

struct WaypointView: View {
    @ObservedObject private var viewModel: WaypointViewModel
    
    init(teamName: String) {
        self.viewModel = WaypointViewModel(teamName: teamName)
        Task(priority: .userInitiated) { [self] in
            await self.viewModel.load()
        }
    }
    
    var body: some View {
        NavigationStack {
            viewStateView
        }
        .navigationTitle("📍 Next Waypoint")
        .fullScreenCover(isPresented: $viewModel.isNavigating) {
            navigationView
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    @ViewBuilder
    private var viewStateView: some View {
        switch viewModel.viewState {
        case .loading(let message):
            loadingView(message: message)
        case .error(let description):
            CalloutView(emoji: "😵", message: description)
        case .loaded(let display):
            WaypointPreviewView(display: display) { viewModel.startNavigating() }
                .padding(.horizontal, Layout.size(2))
        }
    }
    
    @ViewBuilder
    private func loadingView(message: String) -> some View {
        VStack {
            ProgressView()
                .padding(.bottom)
            Text(message)
                .font(.headline)
        }
    }
    
    @ViewBuilder
    private var navigationView: some View {
        switch viewModel.navigationState {
        case .loading(let message):
            loadingView(message: message)
        case .error(let description):
            CalloutView(emoji: "😵", message: description)
        case .loaded(let display):
            mapView(display: display)
        }
    }
    
    @ViewBuilder
    private func mapView(display: NavigationDisplay) -> some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(
            center: .init(latitude: 37.334_900,longitude: -122.009_020),
            span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )),
            showsUserLocation: true,
            userTrackingMode: .constant(.follow))
//        MapView(routeCoordinates: display.polyLine,
//                userLocation: display.userLocation)
    }
}
