//
//  MapView.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/13/23.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    var routeCoordinates: [CLLocationCoordinate2D]
    var userLocation: CLLocationCoordinate2D?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: routeCoordinates[0],
                                        span: span)

        uiView.setRegion(region, animated: true)
        updateMapOverlay(uiView)
        updateUserLocation(uiView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func updateMapOverlay(_ mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        
        let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        mapView.addOverlay(polyline)
    }
    
    private func updateUserLocation(_ mapView: MKMapView) {
        if let location = userLocation {
            print("user locatin: \(userLocation)")
            let userAnnotation = MKPointAnnotation()
            userAnnotation.coordinate = location
            mapView.addAnnotation(userAnnotation)
        }
    }
}

final class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView
    
    init(_ parent: MapView) {
        self.parent = parent
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 3
            return renderer
        }
        
        return MKOverlayRenderer()
    }
}
