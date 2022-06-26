//
//  NetworkManager.swift
//  Transit
//
//  Created by Joseph Rechenmacher on 6/3/22.
//

import Foundation
import SwiftCSV
import CoreData
import SwiftUI

//let metraBaseString: String = "https://gtfsapi.metrarail.com/gtfs"
//let metraClientKey = "2fbb8926df23765437c88363a228d70a"
//let metraSecretKey = "aa81976c54adda9c316e9bb34cdcba31"
//
//let ctaBusBase = "http://www.ctabustracker.com/bustime/api/v2"
//let ctaBusKey = "tRdG7PFxURAeggSdNVRrX2KMh"
//let ctaBusKeyAlt = "mBgpGDuwnvHnkyun6S3k9zX8j"
//
//let ctaTrainBase = "http://lapi.transitchicago.com/api/1.0"
//let ctaTrainKey = "3fcd1fa1dd4c4d7aa38454cc83b11ea0"
//let ctaTrainKeyAlt = "f2d8efbe05d5480a98d1f6a7655bb91c"

// let ctaTrainStopsBase = "https://data.cityofchicago.org/resource/8pix-ypme.json"

//let dateformatter = DateFormatter()
//let stringformatter = DateFormatter()


class NetworkManager: ObservableObject {
    @FetchRequest(sortDescriptors: []) var routes: FetchedResults<Route>
    @FetchRequest(sortDescriptors: []) var stops: FetchedResults<Stop>
    @FetchRequest(sortDescriptors: []) var trainStops: FetchedResults<TrainStop>
    @FetchRequest(sortDescriptors: []) var routeTransfers: FetchedResults<RouteTransfer>
    
    @Environment(\.managedObjectContext) var moc
    
    let decoder = JSONDecoder()
    let session: URLSession = URLSession(configuration: .default)
    
    @Published var data: Data? = nil
    @Published var retrievedRtXfers: [DataModels.ctaRouteTransfer]? = nil
    
    @Published var busPredictions: Array<BusPrediction>? = nil
    @Published var trainArrivals: Array<TrainArrival>? = nil
    @Published var predictionsError: String? = nil
    
    @Published var metraStops: MetraDataRoutes? = nil
    
    /// Basic fetch request to the BusTracker API
    func get(_ endpoint:Endpoint, params:Dictionary<String,String>? = nil) {
        var urlString: String
        var apiKey: String
        var formatKey: String
        var formatValue: String
        if endpoint.rawValue.contains(".aspx") {
            apiKey = ctaTrainKey
            formatKey = "outputType"
            formatValue = "JSON"
            urlString = "\(ctaTrainBase)/\(endpoint.rawValue)"
        } else {
            apiKey = ctaBusKey
            formatKey = "format"
            formatValue = "json"
            urlString = "\(ctaBusBase)/\(endpoint.rawValue)"
        }

        if var urlComponents = URLComponents(string: urlString) {
            var queryItems: [URLQueryItem] = [
                URLQueryItem(name: formatKey, value: formatValue),
                URLQueryItem(name: "key", value: apiKey)
            ]
            if let params = params {
                for (key, val) in params {
                    queryItems.append(URLQueryItem(name: key, value: val))
                }
                urlComponents.queryItems = queryItems
            }
            if let url = urlComponents.url {
                print(url)
                let session = URLSession(configuration: .default)
                let task = session.dataTask(with: url) { data, response, error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    if let safeData = data {
                        do {
                            let decodedData = try self.decoder.decode(ResponseModels.Train.PositionsResponse.self, from: safeData)
                            for route in decodedData.data.route {
                                for train in route.train {
                                    print(train.destName)
                                }
                            }
                        } catch {
                            print("Failed to decode data: \(error.localizedDescription)")
                        }
                        DispatchQueue.main.async {
                            self.data = safeData
                        }
                    }
                }
                task.resume()
            }


        }
    }
    
    /// Get all bus stops serviced by a specific route and direction
    /// - Parameters:
    ///   - route: Bus Route Number (22, 156, J14)
    ///   - direction: general direction of the bus route
    func getBusStops(route:String,direction:BusDirection) {
        let urlString = "\(ctaBusBase)/getstops?rt=\(route)&dir=\(direction)&format=json&key=\(ctaBusKey)"
        let url = URL(string: urlString)!
    
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if error != nil {
                print("Error when creating task")
                return
            }
            if let safeData = data {
                do {
                    let decodedData = try self.decoder.decode(ResponseModels.Bus.StopsResponse.self, from: safeData)
                    
                    for stop in decodedData.bustime_response.stops {
                        if let stop = stop {
                            print(stop.stopName)
                            
                        }
                    }
                } catch {
                    print("ERROR decoding Bus Stops Data")
                }
            }
        }
        task.resume()
        
    }
    
    func getBusVehicles(vid:String? = nil, rt:String? = nil, tmres:String? = nil) {
        var urlComponents = URLComponents(string: "\(ctaBusBase)/getvehicles")!
        
        var queryItems = [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "key", value: getBusKey())
        ]
        
        if let vid = vid {
            queryItems.append(URLQueryItem(name: "vid", value: vid))
        } else if let rt = rt {
            queryItems.append(URLQueryItem(name: "rt", value: rt))
        }
        if let tmres = tmres {
            queryItems.append(URLQueryItem(name: "tmres", value: tmres))
        }
        urlComponents.queryItems = queryItems
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: urlComponents.url!) { data, response, error in
            if let error = error {
                print("Failed to retrieve bus vehicle data: \(error.localizedDescription)")
            }
            if let safeData = data {
                do {
                    let decodedData = try self.decoder.decode(ResponseModels.Bus.VehiclesResponse.self, from: safeData)
                    print(decodedData.bustime_response)
                } catch {
                    print("Failed to decode bus vehicle data: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
        
    }
    
    func getBusPredictions(stpid: String? = nil,rt: String? = nil, vid: String? = nil) {
        
        let urlString = "\(ctaBusBase)/getpredictions"

        if var urlComponents = URLComponents(string: urlString) {
            var queryItems: [URLQueryItem] = [
                URLQueryItem(name: "key", value: ctaBusKey),
                URLQueryItem(name: "format", value: "json")
            ]
            if let vid = vid {
                queryItems.append(URLQueryItem(name: "vid", value: vid))
            } else {
                if let stpid = stpid {
                    queryItems.append(URLQueryItem(name: "stpid", value: stpid))
                }
                if let rt = rt {
                    queryItems.append(URLQueryItem(name: "rt", value: rt))
                }
            }
            urlComponents.queryItems = queryItems
            if let url = urlComponents.url {
                let session = URLSession(configuration: .default)
                let task = session.dataTask(with: url) { data, response, error in
                    print(url)
                    if let error = error {
                        print("Failed to retrieve Bus Stop Arrivals: \(error.localizedDescription)")
                    }
                    if let safeData = data {

                        let decodedData = try? self.decoder.decode(ResponseModels.Bus.PredictionsResponse.self, from: safeData)
                        
                        if let decodedData = decodedData {
                            if let err = decodedData.bustime_response.error {
                                print(err)
                                DispatchQueue.main.async {
                                    self.predictionsError = err[0].msg
                                }
                            } else if let response = decodedData.bustime_response.predictions {
                                var allPredictions: Array<ResponseModels.Bus.PredictionsResponse.PredictionData.Prediction> = []
                                for prediction in response {
                                    if let prediction = prediction {
                                        allPredictions.append(prediction)
                                    }
                                }
                                DispatchQueue.main.async {
                                    self.busPredictions = allPredictions
                                }
                            }
                            
//                            if let response = decodedData.bustime_response.predictions
                        }
                        
                        
                    }
                }
                task.resume()
            }
            
        }
    }
    
    func getTrainArrivals(stopId: String, routeId: String? = nil) {
        let urlString = "\(ctaTrainBase)/ttarrivals.aspx"
        
        var urlComponents = URLComponents(string: urlString)!
        
        var queryItems: Array<URLQueryItem> = [
            URLQueryItem(name: "key", value: getTrainKey()),
            URLQueryItem(name:"outputType", value: "JSON")
        ]
        
        if let stopId = Int(stopId) {
            if stopId >= 40000 {
                queryItems.append(URLQueryItem(name: "mapid", value: String(stopId)))
            } else if stopId >= 30000 {
                queryItems.append(URLQueryItem(name: "stpid", value: String(stopId)))
            }
        }
        
        if let routeId = routeId {
            queryItems.append(URLQueryItem(name: "rt", value: routeId))
        }
        urlComponents.queryItems = queryItems
        print(urlComponents.url!.absoluteString)
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: urlComponents.url!) { data, response, error in
            if let error = error {
                print("Failed to retrieve Train Arrivals data: \(error.localizedDescription)")
            }
            if let safeData = data {
                do {
                    let decodedData = try self.decoder.decode(ResponseModels.Train.ArrivalsResponse.self, from: safeData)
                    
                    DispatchQueue.main.async {
                        self.trainArrivals = decodedData.data.eta
                    }
//                    let upcomingArrivals: Array<TrainArrival> = decodedData.data.eta
//
//                    for trainArrival in upcomingArrivals {
//                        print("\(trainArrival.routeName) - \(trainArrival.destinationName)")
//                        print("\(trainArrival.stopId) (\(trainArrival.stationId))")
//                    }
                } catch {
                    print("Failed to decode Train Arrivals data: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
        
        
    }
    
    func getCtaRouteTransfers() {
        let url = URL(string: "https://www.transitchicago.com/downloads/sch_data/CTA_STOP_XFERS.txt")!
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Could not retrieve CTA Route Transfer data: \(error.localizedDescription)")
                return
            }
            if let safeData = data {
                do {
                    if var dataString = String(data: safeData, encoding: .utf8) {
                        dataString = "routeId,locationType,stopName,stopId,lat,lon,transfers\n\(dataString)"
                        var allRouteTransfers: [DataModels.ctaRouteTransfer] = []
                        let csv = try CSV(string: dataString)
                        for row in csv.namedRows {
                            let newRow = DataModels.ctaRouteTransfer(row)
//                            print(newRow.stopName)
                            allRouteTransfers.append(newRow)
                        }
                        DispatchQueue.main.async {
                            self.retrievedRtXfers = allRouteTransfers
                        }
                    }
                } catch {
                    print("Could not create CSV object from CTA Route Transfer data: \(error.localizedDescription)")
                }
                
                
            }
        }
        task.resume()
        
    }
    
    func getMetraStops() {
        let urlString = "\(metraBaseString)/schedule/routes"
        let urlComponents = URLComponents(string: urlString)!
        
        let basicLogin = "\(metraClientKey):\(metraSecretKey)".data(using: .utf8)!.base64EncodedString()
        var request = URLRequest(url: urlComponents.url!)
        request.addValue("Basic \(basicLogin)", forHTTPHeaderField: "Authorization")
        
        let task = self.session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching Metra Routes: \(error.localizedDescription)")
            }
            if let safeData = data {
                do {
                    let decodedData = try self.decoder.decode(MetraDataRoutes.self, from: safeData)
                    
                    
                } catch {
                    print("Failed to decode Metra Routes: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
        
    }
    
    func getMetraRoutes() {
        let urlString = "\(metraBaseString)/schedule/routes"
        let urlComponents = URLComponents(string: urlString)!
        
        let basicLogin = "\(metraClientKey):\(metraSecretKey)".data(using: .utf8)!.base64EncodedString()
        var request = URLRequest(url: urlComponents.url!)
        request.addValue("Basic \(basicLogin)", forHTTPHeaderField: "Authorization")
        
        let task = self.session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching Metra Routes: \(error.localizedDescription)")
            }
            if let safeData = data {
                do {
                    let _ = try self.decoder.decode(MetraDataRoutes.self, from: safeData)
                    
                    
                } catch {
                    print("Failed to decode Metra Routes: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
        
    }
    
    func getMetraStopTimes() {
        let urlString = "\(metraBaseString)/schedule/stop_times"
        let urlComponents = URLComponents(string: urlString)!
        
        let basicLogin = "\(metraClientKey):\(metraSecretKey)".data(using: .utf8)!.base64EncodedString()
        var request = URLRequest(url: urlComponents.url!)
        request.addValue("Basic \(basicLogin)", forHTTPHeaderField: "Authorization")
        
        self.session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching Metra Routes: \(error.localizedDescription)")
            }
            
            if let safeData = data {
                let dataString = String(data: safeData, encoding: .utf8)!
                print(dataString)
            }
        }.resume()
        
        
    }
    
    private func getBusKey() -> String {
        let currentDateCompontents = Calendar.current.dateComponents([.hour,.minute], from: Date())
        let cutoffDateComponents = DateComponents(hour:12,minute: 0)
        let currentTime = Calendar.current.date(from: currentDateCompontents)
        let cutoffTime = Calendar.current.date(from: cutoffDateComponents)
        
        if cutoffTime! < currentTime! {
            return ctaBusKey
        }
        return ctaBusKeyAlt
    }
    
    private func getTrainKey() -> String {
        let currentDateCompontents = Calendar.current.dateComponents([.hour,.minute], from: Date())
        let cutoffDateComponents = DateComponents(hour:12,minute: 0)
        let currentTime = Calendar.current.date(from: currentDateCompontents)
        let cutoffTime = Calendar.current.date(from: cutoffDateComponents)
        
        if cutoffTime! < currentTime! {
            return ctaTrainKey
        }
        return ctaTrainKeyAlt
    }
    
}

extension NetworkManager {
    internal typealias BusPrediction = ResponseModels.Bus.PredictionsResponse.PredictionData.Prediction
    internal typealias TrainArrival = ResponseModels.Train.ArrivalsResponse.ETAData.Arrival
    
    internal typealias MetraDataRoutes = [ResponseModels.Metra.Data.Route]
}
