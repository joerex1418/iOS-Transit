//
//  DataManager.swift
//  Transit
//
//  Created by Joseph Rechenmacher on 6/11/22.
//

import CoreData
import Foundation

import SwiftCSV

class CoreDataManager: ObservableObject {
    let container = NSPersistentContainer(name: "TransitDataModel")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
            
        }
    }
    
}

class DataManager {
    var routes: [DataModels.Route] = []
    var stops: [DataModels.Stop] = []
    var trainStops: [DataModels.TrainStop] = []
    init() {
        let routesUrl = Bundle.main.url(forResource: "routes", withExtension: "txt")
        if let routesUrl = routesUrl {
            do {
                let routesData = try Data(contentsOf: routesUrl)
                let dataString = String(data: routesData, encoding: .utf8)
                var allRoutes: Array<DataModels.Route> = []
                if let dataString = dataString {
                    let csv = try CSV(string: dataString)
                    for row in csv.namedRows {
                        let newRoute = DataModels.Route(row)
                        allRoutes.append(newRoute)
                    }
                }
                self.routes = allRoutes
            } catch {
                print("Failed to load \"routes\" data: \(error.localizedDescription)")
            }
        }
        
        let stopsUrl = Bundle.main.url(forResource: "stops", withExtension: "txt")
        if let stopsUrl = stopsUrl {
            do {
                let stopsData = try Data(contentsOf: stopsUrl)
                let dataString = String(data: stopsData, encoding: .utf8)
                var allStops: [DataModels.Stop] = []
                if let dataString = dataString {
                    let csv = try CSV(string: dataString)
                    for row in csv.namedRows {
                        let newStop = DataModels.Stop(row)
                        allStops.append(newStop)
                        self.stops = allStops
                    }
                }
            } catch {
                print("Failed to load \"stops\" data: \(error.localizedDescription)")
            }
        }
        
        let trainStopsUrl = Bundle.main.url(forResource: "train_stops", withExtension: "txt")
        if let trainStopsUrl = trainStopsUrl {
            do {
                let trainStopsData = try Data(contentsOf: trainStopsUrl)
                let dataString = String(data: trainStopsData, encoding: .utf8)
                var allTrainStops: [DataModels.TrainStop] = []
                if let dataString = dataString {
                    let csv = try CSV(string: dataString)
                    for row in csv.namedRows {
                        let newStop = DataModels.TrainStop(row)
                        allTrainStops.append(newStop)
                        self.trainStops = allTrainStops
                    }
                }
            } catch {
                print("Failed to load \"train_stops\" data: \(error.localizedDescription)")
            }
        }
        
        
        
        
    }
}



