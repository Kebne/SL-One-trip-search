//
//  MapDelegate.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-11-09.
//  Copyright © 2018 Kebne. All rights reserved.
//

import MapKit

class MapDelegate: NSObject {
    
    private let viewModel: MapViewModelType
    
    init(_ viewModel: MapViewModelType) {
        self.viewModel = viewModel
        super.init()
    }

}

extension MapDelegate : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return viewModel.renderer(for: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return viewModel.viewFor(annotation: annotation)
    }
}
