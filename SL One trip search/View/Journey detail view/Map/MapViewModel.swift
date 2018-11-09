//
//  MapViewModel.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-11-09.
//  Copyright © 2018 Kebne. All rights reserved.
//

import MapKit

struct MapViewModel {
    let region: MKCoordinateRegion
    private let legs: [Leg]
    
    var overlays: [MKOverlay] {return legs.map({$0.polyline})}
    var annotations: [MKAnnotation] {
        var anno = [MKAnnotation]()
        legs.forEach({(leg) in
            anno.append(contentsOf: leg.startStopAnnotations)
        })
        
        return anno
    }
    
    var circleAnnotations: [StopAnnotation] {
        var circles = [StopAnnotation]()
        legs.forEach({circles.append(contentsOf: $0.stopAnnotations)})
        return circles
    }
    
    func renderer(for overlay: MKOverlay) ->MKOverlayRenderer {
        if let line = overlay as? MKPolyline {
            guard let leg = legs.first(where: {$0.polyline.coordinate.latitude == line.coordinate.latitude && $0.polyline.coordinate.longitude == line.coordinate.longitude}) else {
                return MKOverlayRenderer()
            }
            return leg.renderer(for:overlay)
        } else if let circle = overlay as? MKCircle {
            guard let leg = legs.first(where: {$0.stops.contains(where: {$0.latitude == circle.coordinate.latitude && $0.longitude == circle.coordinate.longitude})}) else {
                return MKOverlayRenderer()
            }
            return leg.renderer(for:overlay)
        }
        return MKOverlayRenderer()
    }
    
    func viewFor(annotation: MKAnnotation) ->MKAnnotationView? {
        guard let point = annotation as? StopAnnotation else {
            return nil
        }
        return StartStopAnnotationView(point)
    }
    
    init(trip: Trip) {
        legs = trip.legList
        region = trip.mkRegion
    }
    
    init() {
        legs = [Leg]()
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 59.332790, longitude: 18.064490), latitudinalMeters: 1000.0, longitudinalMeters: 1000.0)
    }
}
