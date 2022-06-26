//
//  LocationManager.swift
//  Transit
//
//  Created by Joseph Rechenmacher on 6/11/22.
//

import Foundation
import CoreLocation
import SwiftUI


struct Coords {
    let lat: Double
    let lon: Double
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus? = nil
    @Published var closestStops: Array<Stop>? = nil
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
//        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.requestLocation()
//        manager.startUpdatingLocation()
    }
    
    func getClosestStops(useTestCoords: Bool = false, stopType: CtaStopType? = nil, stops: FetchedResults<Stop>) {
        
        var lat: Double? = nil
        var lon: Double? = nil
        
        if useTestCoords {
            lat = coords().lat
            lon = coords().lon
        } else {
            if let location = self.location {
                print("Using actual location")
                lat = location.latitude
                lon = location.longitude
            } else {
//                print("Using custom location")
//                lat = coords().lat
//                lon = coords().lon
            }
        }
        
        if let lat = lat, let lon = lon {
            let sortedStops = stops.sorted { lhs, rhs in
                let distanceOne = wiz.distance(lat1:lat, //lat1: location.latitude,
                                               lon1:lon, //lon1: location.longitude,
                                               lat2: Double(lhs.lat!)!,
                                               lon2: Double(lhs.lon!)!,
                                               unit: "M")
                let distanceTwo = wiz.distance(lat1:lat, //lat1: location.latitude,
                                               lon1:lon, //lon1: location.longitude,
                                               lat2: Double(rhs.lat!)!,
                                               lon2: Double(rhs.lon!)!,
                                               unit: "M")
                return distanceOne < distanceTwo
            }
            
            if stopType == .bus {
                DispatchQueue.main.async {
                    self.closestStops = sortedStops.filter({ Stop in
                        Stop.isBusStop
                    })
                }
            } else if stopType == .train {
                DispatchQueue.main.async {
                    self.closestStops = sortedStops.filter({ Stop in
                        Stop.isTrainStop || Stop.isParentStation
                    })
                }
            } else {
                DispatchQueue.main.async {
                    self.closestStops = sortedStops
                }
            }
        }
        
    }
    
    func fetchLocation() -> CLLocationCoordinate2D? {
        if let location = location {
            print("Before \(location)")
        }
        manager.startUpdatingLocation()
        manager.stopUpdatingLocation()
        if let location = location {
            print("After \(location)")
        }
//        requestLocation()
        if let location = location {
            return location
        }
        return nil
    }
    
    func requestLocation() {
//        manager.startUpdatingLocation()
//        manager.stopUpdatingLocation()
        manager.requestLocation()
    }
    
    func requestAuthorization(always: Bool = false) {
        if always {
            manager.requestAlwaysAuthorization()
        } else {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
    
}

extension LocationManager {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status
    }
}
