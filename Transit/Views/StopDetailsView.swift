//
//  BusStopView.swift
//  Transit
//
//  Created by Joseph Rechenmacher on 6/20/22.
//

import SwiftUI
import MapKit

struct StopDetailsView: View {
    
    let stop: Stop
    var stopType: String {
        if stop.isBusStop {
            return "Bus Stop"
        }
        return "\"L\" Stop"
    }
    var latitude: CLLocationDegrees? {
        if let lat = stop.lat {
            return CLLocationDegrees(Float(lat)!)
        }
        return CLLocationDegrees(coords().lat)
    }
    var longitude: CLLocationDegrees? {
        if let lon = stop.lon {
            return CLLocationDegrees(Float(lon)!)
        }
        return CLLocationDegrees(coords().lon)
    }
    var coordRegion: MKCoordinateRegion? {
        if let latitude = latitude, let longitude = longitude {
            return MKCoordinateRegion(center:CLLocationCoordinate2D(latitude: latitude,longitude: longitude),
                                      span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
        }
        return nil
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var networkManager: NetworkManager
    
    var body: some View {
        ZStack {
            color.appBg.edgesIgnoringSafeArea(.all)
            VStack(spacing:8) {
                // HEADER
                viewHeader

                // MAP
                if let coordRegion = coordRegion {
                    Map(coordinateRegion: .constant(coordRegion))
                        .frame(maxWidth: .infinity, maxHeight: 200)
                        .background(color.appBg)
                        .cornerRadius(10)
                }
                
                // SUB-HEADER
                Text("Upcoming Arrivals")
                    .font(Font.custom("Roboto-Medium", size: 25))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // SCROLL CONTENT VIEW
                ScrollView {
                    VStack(spacing:8) {
                        if let predictions = networkManager.busPredictions {
                            ForEach(predictions) { prediction in
                                BusPredictionView(prediction)
                            }
                        } else if let arrivals = networkManager.trainArrivals {
                            ForEach(arrivals) { arrival in
                                TrainArrivalView(arrival)
                            }
                        } else if let predictionsError = networkManager.predictionsError {
                            Text(predictionsError)
                        } else {
                            ProgressView()
                        }
                    }
                    .padding(1)
                }
            }
            .padding(8)
        }
        .onAppear {
            if stop.isBusStop {
                networkManager.getBusPredictions(stpid: stop.id)
            } else if stop.isTrainStop {
                networkManager.getTrainArrivals(stopId: stop.parentId!)
            }
        }
        .onDisappear {
            networkManager.busPredictions = nil
            networkManager.predictionsError = nil
        }
        
        
    }
    
    var viewHeader: some View {
        VStack {
            Text(stop.name!)
                .font(Font.custom("Roboto-Medium", size: 30))
                .frame(maxWidth:.infinity, alignment:.leading)
            
            Text("\(stopType) #\(stop.id!)")
                .font(Font.custom("Roboto-Medium", size: 20))
                .frame(maxWidth:.infinity, alignment:.leading)
        }
        .frame(maxWidth:.infinity)
    }
    
    struct BusPredictionView: View {
        let prediction: BusPrediction
        
        var arrivalStatus: String {
            if prediction.prediction.lowercased() == "due" {
                return "Due"
            } else if prediction.isDelayed {
                return "Delayed"
            } else {
                return "\(prediction.prediction) min"
            }
        }
        
        var statusColor: Color {
            if prediction.isDelayed {
                return Color.red
            }
            return Color.white
        }
        
        init(_ prediction:BusPrediction) {
            self.prediction = prediction
        }
        
        var body: some View {
            HStack {
                HStack(spacing:4) {
                    HStack {
                        // Route ID
                        VStack {
                            Text(prediction.routeId)
                                .frame(width: 55, alignment: .center)
                                .font(Font.custom("Roboto-Medium", size: 18))
                                .padding(2)
//                                .background(Color.blue)
                                .background(color.coolBlue)
                                .cornerRadius(8)
                        }
                        .frame(minWidth: .leastNonzeroMagnitude, maxHeight: .infinity,alignment: .top)
                        
                        // Destination Name & Route Direction
                        VStack(spacing:2) {
                            Text(prediction.destinationName)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                .font(Font.custom("Roboto-Medium", size: 18))
                            Text(prediction.routeDirection)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                .font(Font.custom("Roboto-MediumItalic", size: 13))
                                .foregroundColor(Color.gray)
                        }
                        .frame(maxWidth:.infinity)
                    }
                    
                    VStack {
                        Text(arrivalStatus)
                            .frame(maxWidth: 50, alignment:.center)
                            .font(Font.custom("Roboto-Medium", size: 15))
                            .foregroundColor(statusColor)
                            .padding(2)
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .padding(8)
            .background(color.stopDisplay)
            .cornerRadius(8)
        }
    }
    
    struct TrainArrivalView: View {
        let arrival: TrainArrival
        
        var arrivalStatus: String {
            if arrival.isDelayed {
                return "DELAYED"
            }
            
            if arrival.isApproaching {
                return "Due"
            }
            
            let eta = ResponseModels.Train.dateFormatter.date(from: arrival.arrivalTime)
            
            if let eta = eta {
                let dueIn = Int((eta - Date()) / 60)
                if dueIn > 1 {
                    return "\(dueIn) min"
                } else {
                    return "Due"
                }
            } else {
                return "-"
            }
            
        }
        
        var routeColor: Color {
            return getRouteColors(arrival.routeId).0
        }
        
        var routeTextColor: Color {
            return getRouteColors(arrival.routeId).1
        }
        
        var statusColor: Color {
            if arrival.isDelayed {
                return Color.red
            }
            return Color.white
        }
        
        init(_ arrival:TrainArrival) {
            self.arrival = arrival
        }
        
        var body: some View {
            HStack {
                HStack(spacing:4) {
                    HStack {
                        // Route ID
//                        VStack {
//                            Text(arrival.routeId)
//                                .frame(width: 55, alignment: .center)
//                                .font(Font.custom("Roboto-Medium", size: 18))
//                                .padding(2)
//                                .background(color.coolBlue)
//                                .cornerRadius(8)
//                        }
//                        .frame(minWidth: .leastNonzeroMagnitude, maxHeight: .infinity,alignment: .top)
                        
                        // Destination Name & Route Direction
                        VStack(spacing:2) {
                            Text(arrival.destinationName)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                .font(Font.custom("Roboto-Medium", size: 20))
                            Text(arrival.stopDesc)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                .font(Font.custom("Roboto-MediumItalic", size: 16))
                        }
                        .frame(maxWidth:.infinity)
                    }
                    
                    VStack {
                        Text(arrivalStatus)
                            .frame(maxWidth: 50, alignment:.center)
                            .font(Font.custom("Roboto-Medium", size: 16))
                            .foregroundColor(statusColor)
                            .padding(2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .padding(8)
            .background(routeColor)
            .cornerRadius(8)
        }
    }
    
}

extension StopDetailsView {
    internal typealias BusPrediction = ResponseModels.Bus.PredictionsResponse.PredictionData.Prediction
    internal typealias TrainArrival = ResponseModels.Train.ArrivalsResponse.ETAData.Arrival
}

//struct BusStopView_Previews: PreviewProvider {
//    static var previews: some View {
//        BusStopView()
//    }
//}
