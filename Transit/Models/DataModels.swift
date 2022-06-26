//
//  DataModels.swift
//  Transit
//
//  Created by Joseph Rechenmacher on 6/11/22.
//

import CoreData
import Foundation


struct DataModels {
    struct ctaRouteTransfer: Identifiable {
        init(_ csvRow:Dictionary<String,String>) {
            self.routeId = csvRow["routeId"]!
            self.locationType = Int(csvRow["locationType"]!) ?? 0
            self.stopId = csvRow["stopId"]!
            self.stopName = csvRow["stopName"]!
            self.lat = Double(csvRow["lat"]!)!
            self.lon = Double(csvRow["lon"]!)!
            self.transfers = csvRow["transfers"]!
            self.id = "\(routeId)-\(stopId)"
        }
        
        let id: String
        let routeId: String
        let locationType: Int
        let stopId: String
        let stopName: String
        let lat: Double
        let lon: Double
        let transfers: String
        
        
        
    }
    
    struct Route: Identifiable {
        let id, name, color, textColor: String
        let type: Int
        init(_ csvRow:Dictionary<String,String>) {
            self.id = csvRow["route_id"]!
            self.name = csvRow["route_long_name"]!
            self.color = csvRow["route_color"]!
            self.textColor = csvRow["route_text_color"]!
            self.type = Int(csvRow["route_type"]!) ?? 0
        }
    }
    
    struct Stop: Identifiable {
        let id, name, desc, lat, lon, locationType, parentId: String
        let isTrainStop, isBusStop, isParentStation, wheelchairBoarding: Bool
        init(_ csvRow:Dictionary<String,String>) {
            self.id = csvRow["stop_id"]!
            self.name = csvRow["stop_name"]!
            self.desc = csvRow["stop_desc"]!
            self.lat = csvRow["stop_lat"]!
            self.lon = csvRow["stop_lon"]!
            self.locationType = csvRow["location_type"]!
            self.parentId = csvRow["parent_station"]!
            
            
            if Int(csvRow["wheelchair_boarding"]!) ?? 0 == 1 {
                self.wheelchairBoarding = true
            } else {
                self.wheelchairBoarding = false
            }
            
            if let stop_id_num = Int(id) {
                if stop_id_num >= 30000 {
                    self.isTrainStop = true
                    self.isBusStop = false
                } else {
                    self.isTrainStop = false
                    self.isBusStop = true
                }
            } else {
                self.isTrainStop = false
                self.isBusStop = true
            }
            
            if let stop_id_num = Int(id) {
                if stop_id_num >= 40000 {
                    self.isParentStation = true
                } else {
                    self.isParentStation = false
                }
            } else {
                self.isParentStation = false
            }
        }
    }
    
    struct TrainStop {
        let id, directionId, stopName, stationName: String
        let descriptiveName, mapId: String
        let ada,red,blue,green,brown: Bool
        let yellow, pink, orange: Bool
        
        init(_ csvRow:Dictionary<String,String>) {
            self.id = csvRow["stop_id"]!
            self.directionId = csvRow["direction_id"]!
            self.stopName = csvRow["stop_name"]!
            self.stationName = csvRow["station_name"]!
            self.descriptiveName = csvRow["station_descriptive_name"]!
            self.mapId = csvRow["map_id"]!
            
            self.ada = Bool(csvRow["ada"]!) ?? false
            self.red = Bool(csvRow["red"]!) ?? false
            self.blue = Bool(csvRow["blue"]!) ?? false
            self.green = Bool(csvRow["p"]!) ?? false
            self.brown = Bool(csvRow["pexp"]!) ?? false
            self.yellow = Bool(csvRow["y"]!) ?? false
            self.pink = Bool(csvRow["pnk"]!) ?? false
            self.orange = Bool(csvRow["o"]!) ?? false
        }
        
        
    }
    
    struct StopTime {
        init(_ csvRow: Dictionary<String,String>) {
            self.trip_id = csvRow["trip_id"]!
            self.arrival_time = csvRow["arrival_time"]!
            self.stop_id = csvRow["stop_id"]!
            self.stop_sequence = csvRow["stop_sequence"]!
            self.stop_headsign = csvRow["stop_headsign"]!
        }
        
        let trip_id: String
        let arrival_time: String
        let stop_id: String
        let stop_sequence: String
        let stop_headsign: String
        
    }
    
    struct Trip {
        init(_ csvRow: Dictionary<String,String>) {
            self.route_id = csvRow["route_id"]!
            self.service_id = csvRow["service_id"]!
            self.trip_id = csvRow["trip_id"]!
            self.direction_id = csvRow["direction_id"]!
            self.block_id = csvRow["block_id"]!
            self.shape_id = csvRow["shape_id"]!
            self.direction = csvRow["direction"]!
            if csvRow["wheelchair_accessible"]! == "1" {
                self.wheelchair_accessible = true
            } else {
                self.wheelchair_accessible = false
            }
            self.schd_trip_id = csvRow["schd_trip_id"]!
        }
        
        let route_id: String
        let service_id: String
        let trip_id: String
        let direction_id: String
        let block_id: String
        let shape_id: String
        let direction: String
        let wheelchair_accessible: Bool
        let schd_trip_id: String
        
        
    }
    
}

