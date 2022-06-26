//
//  ContentView.swift
//  Transit
//
//  Created by Joseph Rechenmacher on 6/3/22.
//

import SwiftCSV

import SwiftUI
import MapKit
import CoreLocationUI

let wiz = MathWiz()
let color = AppColor()

struct coords {
    let lat = 41.884770
    let lon = -87.636320
}

let sampleStops = "15049,4623,3946,15020,445,4630,15009,4632,5028,18124"
let stopList = ["15049","4623","3946","15020","445","4630","15009","4632","5028","18124"]



struct ContentView: View {
    
    @FetchRequest(sortDescriptors: []) var routes: FetchedResults<Route>
    @FetchRequest(sortDescriptors: []) var stops: FetchedResults<Stop>
    @FetchRequest(sortDescriptors: []) var trainStops: FetchedResults<TrainStop>
    @FetchRequest(sortDescriptors: []) var routeTransfers: FetchedResults<RouteTransfer>
    
    @Environment(\.managedObjectContext) var moc
    
    @StateObject var networkManager = NetworkManager()
    @StateObject var locationManager = LocationManager()
    
    let coordRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coords().lat, longitude: coords().lon),span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    @State private var mapIsVisible: Bool = false
    
//    let dataManager = DataManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing:0) {

                TopNavBar
                    .frame(maxWidth:.infinity)
                    .padding(8)
                    .background(color.appBg)
//                    .modifier(AccentBorder(.bottom, height: 1, opacity: 0.30))
                
                ScrollContentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                BottomNavBar
                    .frame(maxWidth: .infinity, minHeight: 30)
                    .padding(8)
                    .background(color.appBg)
                    .modifier(AccentBorder(.top, height: 1, opacity: 0.30))
                
            }
            .frame(maxWidth: .infinity,maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .background(color.appBg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            
            Task {
                locationManager.getClosestStops(useTestCoords: false, stopType: .both, stops: stops)
            }
        
            let locAuthStatus = locationManager.authorizationStatus
            if locAuthStatus == .notDetermined || locAuthStatus == .denied {
                locationManager.requestAuthorization(always: false)
            } else {
                locationManager.requestLocation()
            }
        }
        
    }
    
    var TopNavBar: some View {
        HStack {
            Text("Transit")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(Font.custom("Roboto-Medium",size:30))
            
            AppButton("Bus") {
                locationManager.getClosestStops(useTestCoords: false, stopType: .bus, stops: stops)
            }
            .frame(width: 80,alignment: .center)
            
            AppButton("Train") {
                locationManager.getClosestStops(useTestCoords: false, stopType: .train, stops: stops)
            }
            .frame(width: 80,alignment: .center)
        }
    }
    
    var ScrollContentView: some View {
        ScrollView {
            if locationManager.location != nil {
                if let closestStops = locationManager.closestStops {
                    VStack(spacing:15) {
                        ForEach(closestStops[0...15]) { stop in
    //                        let trainStops: [TrainStop] = trainStops.filter { TrainStop in
    //                            TrainStop.mapId! == stop.id!
    //                        }
                            if (stop.isBusStop) || (stop.isTrainStop && !(stop.isParentStation)) {
                                let routeTransfers: [RouteTransfer] = routeTransfers.filter { RouteTransfer in
                                    RouteTransfer.stopId == stop.id
                                }
                                NavigationLink {
                                    StopDetailsView(stop:stop, networkManager: networkManager)
                                } label: {
                                    StopDisplay(stop:stop, routeTransfers:routeTransfers,trainStops: trainStops)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    
                } else {
                    ProgressView()
                }
            } else {
                ProgressView()
            }
        }
    }
    
    var BottomNavBar: some View {
        HStack {
            MapButton {
                print("Hello")
            }
            
            AppButton("Find Me") {
//                locationManager.requestLocation()
                if let loc = locationManager.fetchLocation() {
                    let _ = print(loc)
                }
            }
            
            AppButton("Metra Routes") {
                networkManager.getMetraRoutes()
            }
            
        }
    }
    
}

//struct HeaderView: View {
//    @ObservedObject var locationManager: LocationManager
//
//    var body: some View {
//        HStack {
//            Text("Transit")
//                .font(Font.custom("Roboto-Medium",size:30))
//
//            AppButton("Bus") {
//                locationManager.getClosestStops(useTestCoords: false, stopType: .bus, stops: stops)
//            }
//
//            AppButton("Train") {
//                locationManager.getClosestStops(useTestCoords: false, stopType: .train, stops: stops)
//            }
//        }
//        .frame(maxWidth:.infinity)
//        .padding(8)
//        .background(color.appBg)
////        .modifier(AccentBorder(.bottom, height: 1, opacity: 0.30))
//    }
//}

struct ServicedRoute: Identifiable {
    let id: String = UUID().uuidString
    let routeId: String
    
    let routeColor: Color
    let routeTextColor: Color
    
    init(routeId:String) {
        self.routeId = routeId
        let colors = getRouteColors(routeId)
        self.routeColor = colors.0
        self.routeTextColor = colors.1
    }
    init(_ routeId:String) {
        self.routeId = routeId
        let colors = getRouteColors(routeId)
        self.routeColor = colors.0
        self.routeTextColor = colors.1
    }
}

struct StopDisplay: View {
//    @State private var collapsed: Bool = true
    
    let stop: Stop
    let servicedRoutes: [ServicedRoute]
    var stopName: String
    
    init(stop:Stop, routeTransfers:Array<RouteTransfer>, trainStops:FetchedResults<TrainStop>) {
        
        self.stop = stop
        self.stopName = stop.name!
        var routeList: [ServicedRoute] = []
        
        if stop.isBusStop {
            // BUS STOP
            for transfer in routeTransfers {
                if !(routeList.contains(where: { ServicedRoute in transfer.routeId! == ServicedRoute.routeId })) {
                    routeList.append(ServicedRoute(transfer.routeId!))
                }
            }
            self.servicedRoutes = routeList
            
        } else {
            // TRAIN STOP
            let filteredTrainStops = trainStops.filter { TrainStop in
                stop.id! == TrainStop.id
            }
            
            if filteredTrainStops.count == 1 {
                self.stopName = filteredTrainStops[0].stopName ?? stop.name!
                self.servicedRoutes = getServicedLines(filteredTrainStops[0])
            } else {
                self.stopName = stop.name!
                self.servicedRoutes = []
            }
        }
    }
    let columns = [
        GridItem(.fixed(55)),
        GridItem(.fixed(55)),
        GridItem(.fixed(55)),
        GridItem(.fixed(55)),
        GridItem(.fixed(55)),
    ]
    var body: some View {
        VStack {
            VStack {
                VStack {
                    Text(self.stopName)
                        .font(Font.custom("Roboto-Bold",size:18))
                        .foregroundColor(color.primaryText)
                        .frame(maxWidth:.infinity, alignment: .topLeading)
                    Text("#\(stop.id!)")
                        .font(Font.custom("Roboto-MediumItalic",size:16))
                        .foregroundColor(Color.gray)
                        .frame(maxWidth:.infinity, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity)
                
                LazyVGrid(columns: columns,alignment: .leading) {
                    ForEach(servicedRoutes) { route in
                        Text(route.routeId)
                            .frame(maxWidth:.infinity)
                            .font(Font.custom("Roboto-Medium",size:16))
                            .foregroundColor(route.routeTextColor)
                            .padding(2)
                            .background(route.routeColor)
                            .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(8)
        }
        .frame(maxWidth:.infinity)
        .padding(8)
        .background(color.stopDisplay)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.15), radius: 5)
        
    }
}

struct AppButton: View {
    let icon: String?
    let label: String?
    let action: () -> Void
    
    
    init(_ label: String, _ action: @escaping () -> Void) {
        self.label = label
        self.action = action
        self.icon = nil
    }
    
    init(label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
        self.icon = nil
    }
    
    init(icon: String, action: @escaping () -> Void) {
        self.label = nil
        self.action = action
        self.icon = icon
    }
    
    var body: some View {
        if let label = label {
            Button(label,action: action)
                .font(Font.custom("Roboto-Regular",size:15))
                .frame(maxWidth: 100)
                .foregroundColor(Color.white)
                .padding(8)
                .background(color.darkRed)
                .cornerRadius(30)
        } else if let icon = icon {
            Button(action: action) {
                Image(systemName: icon)
            }
                .font(Font.custom("Roboto-Regular",size:15))
                .frame(maxWidth: 100)
                .foregroundColor(Color.white)
                .padding(8)
                .background(color.darkRed)
                .cornerRadius(30)
        }
        
        
        }
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//            .previewDevice("iPhone 12")
//            .preferredColorScheme(.light)
//    }
//}


