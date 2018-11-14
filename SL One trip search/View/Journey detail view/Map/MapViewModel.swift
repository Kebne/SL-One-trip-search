//
//  MapViewModel.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-11-09.
//  Copyright © 2018 Kebne. All rights reserved.
//

import MapKit

extension MKOverlayRenderer {
    static func renderer(for overlay: MKOverlay, color: UIColor) ->MKOverlayRenderer {
        if overlay is MKPolyline { return lineRenderer(for:overlay, color: color)}
        else if let circle = overlay as? MKCircle {return circleRenderer(for: circle, color: color)}
        return MKOverlayRenderer()
    }
    
    private static func lineRenderer(for overlay: MKOverlay, color: UIColor) ->MKOverlayRenderer {
        let lineRenderer = MKPolylineRenderer(overlay: overlay)
        lineRenderer.lineWidth = 2.0
        lineRenderer.strokeColor = color
        return lineRenderer
    }
    
    private static func circleRenderer(for circleOverlay: MKCircle, color: UIColor) ->MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.fillColor = color
        return circleRenderer
    }
}

extension CLLocationCoordinate2D : Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) ->Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == lhs.longitude
    }
}

protocol MapViewModelType {
    var region: MKCoordinateRegion {get}
    var overlays: [MKOverlay] {get}
    var annotations: [MKAnnotation] {get}
    var circleAnnotations: [StopAnnotation] {get}
    func renderer(for overlay: MKOverlay) ->MKOverlayRenderer
    func viewFor(annotation: MKAnnotation) ->MKAnnotationView?
}


struct MapViewModel : MapViewModelType {
    var region: MKCoordinateRegion {
        return mkRegionFrom(legList: legs)
    }
    private let legs: [Leg]
    
    var overlays: [MKOverlay] {return legs.map({MKPolyline(coordinates: $0.coordinates, count: $0.coordinates.count)})}
    
    var annotations: [MKAnnotation] {
        var anno = [MKAnnotation]()
        legs.forEach({(leg) in
            let start = StopAnnotation(UIColor.color(for: leg.transportType), letter: leg.transportType.singleLetterDescription, coordinate: leg.origin.coordinate, title: leg.origin.name, subtitle: leg.origin.time.hourMinuteTimeString)
            let end = StopAnnotation(UIColor.color(for: leg.transportType), letter: leg.transportType.singleLetterDescription, coordinate: leg.destination.coordinate, title: leg.destination.name, subtitle: leg.destination.time.hourMinuteTimeString)
            anno.append(start)
            anno.append(end)
        })
        
        return anno
    }
    
    var circleAnnotations: [StopAnnotation] {
        var circles = [StopAnnotation]()
        
        legs.forEach({(leg) in
           let stops = leg.stops.filter({$0.latitude != leg.origin.latitude && $0.longitude != leg.origin.longitude}).filter(({$0.latitude != leg.destination.latitude && $0.longitude != leg.destination.longitude}))
            let annotations = stops.map({StopAnnotation(UIColor.color(for: leg.transportType), letter: "", coordinate: $0.coordinate, title: $0.name, subtitle: $0.timeString)})
            circles.append(contentsOf: annotations)
            
        })
        return circles
    }
    
    func renderer(for overlay: MKOverlay) ->MKOverlayRenderer {
        if let line = overlay as? MKPolyline {
            guard let leg = legs.first(where: {MKPolyline(coordinates: $0.coordinates, count: $0.coordinates.count).coordinate == line.coordinate}) else {
                return MKOverlayRenderer()
            }
            return MKOverlayRenderer.renderer(for: line, color: UIColor.color(for: leg.transportType))
        } else if let circle = overlay as? MKCircle {
            guard let leg = legs.first(where: {$0.stops.contains(where: {$0.latitude == circle.coordinate.latitude && $0.longitude == circle.coordinate.longitude})}) else {
                return MKOverlayRenderer()
            }
            return MKOverlayRenderer.renderer(for: circle, color: UIColor.color(for: leg.transportType))
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
    }
    
    init() {
        legs = [Leg]()
    }
}


extension MapViewModel {
    fileprivate func mkRegionFrom(legList: [Leg]) ->MKCoordinateRegion {
        guard let minLat = legList.sorted(by: {$0.minLatitude < $1.minLatitude}).first?.minLatitude,
            let maxLat = legList.sorted(by: {$0.maxLatitude > $1.maxLatitude}).first?.maxLatitude,
            let minLong = legList.sorted(by: {$0.minLongitude < $1.minLongitude}).first?.minLongitude,
            let maxLong = legList.sorted(by: {$0.minLongitude > $1.minLongitude}).first?.maxLongitude else {
                return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 59.332790, longitude: 18.064490), latitudinalMeters: 10000.0, longitudinalMeters: 10000.0)
        }
        
        let latitudeDelta = (maxLat - minLat)
        let longitudeDelta = (maxLong - minLong)
        let centerCoordinate = CLLocationCoordinate2D(latitude: minLat + (latitudeDelta / 2.0), longitude: minLong + (longitudeDelta / 2.0))
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta * 1.3, longitudeDelta: longitudeDelta * 1.3)
        
        return MKCoordinateRegion(center: centerCoordinate, span: span)
    }
}
