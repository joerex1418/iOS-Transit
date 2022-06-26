//
//  utils.swift
//  Transit
//
//  Created by Joseph Rechenmacher on 6/3/22.
//

import SwiftCSV
import Foundation
import SwiftUI

public extension String {
    func slice(_ start:Int, _ end:Int) -> String {
        var startIndex: String.Index
        if end < 0 {
            startIndex = String.Index(utf16Offset: (self.count + start), in: self)
        } else {
            startIndex = String.Index(utf16Offset: start, in: self)
        }
        
        var endIndex: String.Index
        if end < 0 {
            endIndex = String.Index(utf16Offset: (self.count + end), in: self)
        } else {
            endIndex = String.Index(utf16Offset: end, in: self)
        }
        
        return String(self[startIndex...endIndex])
    }
    
    func charAt(_ idx: Int) -> String {
        if idx < 0 {
            return String(self[String.Index(utf16Offset: (self.count + idx), in: self)])
        }
        return String(self[String.Index(utf16Offset: idx, in: self)])
    }
    
}

public extension Color {
    static func fromHex(_ hexString: String) -> Color {
        var firstPair: String
        var secondPair: String
        let thirdPair: String = String(hexString.suffix(2))
        
        if hexString.charAt(0) == "#" {
            firstPair = hexString.slice(1, 3)
            secondPair = hexString.slice(3, 5)
        } else {
            firstPair = String(hexString.prefix(2))
            secondPair = hexString.slice(2, 4)
        }
        
        var redValue: Int {
            let char1 = hexDecimals[firstPair.charAt(0)]
            let char2 = hexDecimals[firstPair.charAt(1)]
            
            let val1 = (char1 ?? 0) * 16
            let val2 = char2 ?? 0
            
            return (val1 + val2)
        }
        
        var greenValue: Int {
            let char1 = hexDecimals[secondPair.charAt(0)]
            let char2 = hexDecimals[secondPair.charAt(1)]
            
            let val1 = (char1 ?? 0) * 16
            let val2 = char2 ?? 0
            
            return (val1 + val2)
        }
        
        var blueValue: Int {
            let char1 = hexDecimals[thirdPair.charAt(0)]
            let char2 = hexDecimals[thirdPair.charAt(1)]
            
            let val1 = (char1 ?? 0) * 16
            let val2 = char2 ?? 0
            
            return (val1 + val2)
        }
        
        let redValueDecimal = round((Double(redValue) / 255.0) * 1000) / 1000.0
        let greenValueDecimal = round((Double(greenValue) / 255.0) * 1000) / 1000.0
        let blueValueDecimal = round((Double(blueValue) / 255.0) * 1000) / 1000.0
        
        return Color(red: redValueDecimal, green: greenValueDecimal, blue: blueValueDecimal)
    }
}

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}

let hexDecimals = ["0":0,"1":1,"2":2,"3":3,"4":4,
                   "5":5,"6":6,"7":7,"8":8,"9":9,
                   "A":10,"B":11,"C":12,"D":13,"E":14,"F":15]

struct AppColor {
    let darkBlue = Color(red: 0.17, green: 0.18, blue: 0.26)
    let coolBlue = Color(red: 0.55, green: 0.60, blue: 0.68)
    let whiteBlue = Color(red: 0.93, green: 0.95, blue: 0.96)
    let lightRed = Color(red: 0.94, green: 0.14, blue: 0.24)
    let darkRed = Color(red: 0.85, green: 0.02, blue: 0.16)
    
    let red = Color(red: 0.78, green: 0.05, blue: 0.19)
    let purple = Color(red: 0.32, green: 0.14, blue: 0.60)
    let yellow = Color(red: 0.98, green: 0.89, blue: 0.00)
    let blue = Color(red: 0.00, green: 0.63, blue: 0.87)
    let pink = Color(red: 0.89, green: 0.49, blue: 0.65)
    let green = Color(red: 0.00, green: 0.61, blue: 0.23)
    let orange = Color(red: 0.98, green: 0.27, blue: 0.11)
    let brown = Color(red: 0.38, green: 0.21, blue: 0.11)
    
    let primaryText = Color("primaryText")
    let secondaryText = Color("secondaryText")
    let predictionCardBorder = Color("secondaryText")
    let appBg = Color("appBg")
    let stopDisplay = Color("stopDisplay")
}

struct MathWiz {
    private func deg2rad(deg:Double) -> Double {
        return deg * Double.pi / 180
    }

    private func rad2deg(rad:Double) -> Double {
        return rad * 180.0 / Double.pi
    }

    func distance(lat1:Double, lon1:Double, lat2:Double, lon2:Double, unit:String) -> Double {
        let theta = lon1 - lon2
        var dist = sin(deg2rad(deg: lat1)) * sin(deg2rad(deg: lat2)) + cos(deg2rad(deg: lat1)) * cos(deg2rad(deg: lat2)) * cos(deg2rad(deg: theta))
        dist = acos(dist)
        dist = rad2deg(rad: dist)
        dist = dist * 60 * 1.1515
        if (unit == "K") {
            dist = dist * 1.609344
        }
        else if (unit == "N") {
            dist = dist * 0.8684
        }
        return dist
    }
}

enum CtaStopType: String {
    case bus
    case train
    case both
}

enum BusDirection: String {
    case Northbound
    case Southbound
    case Eastbound
    case Westbound
}

enum TrainRoute: String {
    case blue = "Blue"
    case brown = "Brn"
    case green = "G"
    case orange = "Org"
    case pink = "Pink"
    case purple = "P"
    case purpleExp = "Pexp"
    case red = "Red"
    case yellow = "Y"
}

enum Endpoint: String {
    case busStops = "getstops"
    case busPredictions = "getpredictions"
    case busDirections = "getdirections"
    case busPatterns = "getpatterns"
    case busRoutes = "getroutes"
    case busVehicles = "getvehicles"
    
    case trainFollow = "ttfollow.aspx"
    case trainPredictions = "ttarrivals.aspx"
    case trainPositions = "ttpositions.aspx"
}




func hexToRgb(_ hexString: String) -> Color {
    var firstPair: String
    
    var secondPair: String
    
    let thirdPair: String = String(hexString.suffix(2))
    
    if hexString.charAt(0) == "#" {
        firstPair = hexString.slice(1, 3)
        secondPair = hexString.slice(3, 5)
    } else {
        firstPair = String(hexString.prefix(2))
        secondPair = hexString.slice(2, 4)
    }
    
    var redValue: Int {
        let char1 = hexDecimals[firstPair.charAt(0)]
        let char2 = hexDecimals[firstPair.charAt(1)]
        
        let val1 = (char1 ?? 0) * 16
        let val2 = char2 ?? 0
        
        return (val1 + val2)
    }
    
    var greenValue: Int {
        let char1 = hexDecimals[secondPair.charAt(0)]
        let char2 = hexDecimals[secondPair.charAt(1)]
        
        let val1 = (char1 ?? 0) * 16
        let val2 = char2 ?? 0
        
        return (val1 + val2)
    }
    
    var blueValue: Int {
        let char1 = hexDecimals[thirdPair.charAt(0)]
        let char2 = hexDecimals[thirdPair.charAt(1)]
        
        let val1 = (char1 ?? 0) * 16
        let val2 = char2 ?? 0
        
        return (val1 + val2)
    }
    
    let redValueDecimal = round((Double(redValue) / 255.0) * 1000) / 1000.0
    let greenValueDecimal = round((Double(greenValue) / 255.0) * 1000) / 1000.0
    let blueValueDecimal = round((Double(blueValue) / 255.0) * 1000) / 1000.0
    
    return Color(red: redValueDecimal, green: greenValueDecimal, blue: blueValueDecimal)
}

func getTrainDirectionHead(trdrCode:String, route:TrainRoute) -> String {
    
    switch trdrCode {
    case "1":
        switch route {
        case .red:
            return "Howard-bound"
        case .blue:
            return "O'Hare-bound"
        case .brown:
            return "Kimball-bound"
        case .green:
            return "Harlem/Lake-bound"
        case .orange:
            return "Loop-bound"
        case .purple:
            return "Linden-bound"
        case .purpleExp:
            return "Linden-bound"
        case .pink:
            return "Loop-bound"
        case .yellow:
            return "Skokie-bound"
        }
        
    case "5":
        switch route {
        case .red:
            return "95th/Dan Ryan-bound"
        case .blue:
            return "Forest Park-bound"
        case .brown:
            return "Loop-bound"
        case .green:
            return "Ashland/63rd-bound" // Ashland/63rd- or Cottage Grove-bound (toward 63rd St destinations)
        case .orange:
            return "Midway-bound"
        case .purple:
            return "Howard-bound" // Howard- or Loop-bound
        case .purpleExp:
            return "Loop-bound"
        case .pink:
            return "54th/Cermak-bound"
        case .yellow:
            return "Howard-bound"
        }
    default:
        return "-"
    }
}

func generateCoreDataEntries() {
    let dataManager = DataManager()

    @Environment(\.managedObjectContext) var moc
     
     //    for rt in routeTransfers {
     //        let newRouteTransfer = RouteTransfer(context: moc)
     //        newRouteTransfer.id = rt.id
     //        newRouteTransfer.routeId = rt.routeId
     //        newRouteTransfer.stopName = rt.stopName
     //        newRouteTransfer.stopId = rt.stopId
     //        newRouteTransfer.locationType = Int16(rt.locationType)
     //        newRouteTransfer.lat = rt.lat
     //        newRouteTransfer.lon = rt.lon
     //        newRouteTransfer.transfers = rt.transfers
     //
     //        ct += 1
     //
     //        do {
     //            try moc.save()
     //        } catch {
     //            print("Error saving new RouteTransfer: \(error.localizedDescription)")
     //        }
     //
     //     }
     //    print("Stored \(ct) new Route Transfers")
     
    
    var ct = 0
    ct = 0
    for route in dataManager.routes {
        let newRoute = Route(context: moc)
        newRoute.id = route.id
        newRoute.name = route.name
        newRoute.type = Int16(route.type)
        newRoute.color = route.color
        newRoute.textColor = route.textColor
        
        ct += 1
        
        do {
            try moc.save()
        } catch {
            print("Error saving new Route: \(error.localizedDescription)")
        }
    }
    
    print("Stored \(ct) new Routes")
    ct = 0
    for stop in dataManager.stops {
        let newStop = Stop(context: moc)
        newStop.desc = stop.desc
        newStop.id = stop.id
        newStop.isBusStop = stop.isBusStop
        newStop.isTrainStop = stop.isTrainStop
        newStop.isParentStation = stop.isParentStation
        newStop.lat = stop.lat
        newStop.lon = stop.lon
        newStop.locationType = stop.locationType
        newStop.name = stop.name
        newStop.parentId = stop.parentId
        newStop.wheelchairBoarding = stop.wheelchairBoarding
        
        ct += 1
        
        do {
            try moc.save()
        } catch {
            print("Error saving new Stop: \(error.localizedDescription)")
        }
        
    }
    print("Stored \(ct) new Stops")
    ct = 0
    for stop in dataManager.trainStops {
        let newStop = TrainStop(context: moc)
        newStop.ada = stop.ada
        newStop.blue = stop.blue
        newStop.brown = stop.brown
        newStop.green = stop.green
        newStop.orange = stop.orange
        newStop.pink = stop.pink
        newStop.red = stop.red
        newStop.yellow = stop.yellow
        newStop.descriptiveName = stop.descriptiveName
        newStop.directionId = stop.directionId
        newStop.id = stop.id
        newStop.mapId = stop.mapId
        newStop.stationName = stop.stationName
        newStop.stopName = stop.stopName
        
        ct += 1
        
        do {
            try moc.save()
        } catch {
            print("Error saving new TrainStop: \(error.localizedDescription)")
        }
        
    }
    print("Stored \(ct) new Train Stops")
    
    print("CORE DATA CREATED")
}
