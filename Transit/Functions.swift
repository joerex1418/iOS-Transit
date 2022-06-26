//
//  Functions.swift
//  Transit
//
//  Created by Joseph Rechenmacher on 6/11/22.
//

import Foundation
import SwiftCSV
import CoreData
import SwiftUI

enum TransitFile: String {
    case calendar
    case calendar_dates
    case frequencies
    case routes
    case shapes
    case stops
    case stopTimes = "stop_times"
    case transfers
    case trips
}

func stringCoordToDouble(coord:String) throws -> Double {
    return Double(coord)!
}

func getServicedLines(_ stop: TrainStop) -> Array<ServicedRoute> {
    var servicedLines: [ServicedRoute] = []
    
    if stop.blue {
        servicedLines.append(ServicedRoute("Blue"))
    }
    if stop.brown {
        servicedLines.append(ServicedRoute("Brown"))
    }
    if stop.green {
        servicedLines.append(ServicedRoute("Green"))
    }
    if stop.orange {
        servicedLines.append(ServicedRoute("Orange"))
    }
    if stop.pink {
        servicedLines.append(ServicedRoute("Pink"))
    }
    if stop.red {
        servicedLines.append(ServicedRoute("Red"))
    }
    if stop.yellow {
        servicedLines.append(ServicedRoute("Yellow"))
    }
    
    return servicedLines
    
//    if stop.purple {
//        servicedLines.append(ServicedRoute("Purple"))
//    }
//    if stop.purpleExp {
//        servicedLines.append(ServicedRoute("Purple Exp"))
//    }
}

func getRouteColors(_ route: String) -> (Color,Color) {
    switch route {
    case "GLS-1":
        return (color.green, Color("whiteATB"))
    case "Green Line Shuttle":
        return (color.green, Color("whiteATB"))
    case "BLS-1":
        return (color.blue, Color("whiteATB"))
    case "Blue Line Shuttle":
        return (color.blue, Color("whiteATB"))
    case "Blue":
        return (color.blue, Color("whiteATB"))
    case "Brown":
        return (color.brown, Color("whiteATB"))
    case "Brn":
        return (color.brown, Color("whiteATB"))
    case "Green":
        return (color.green, Color("whiteATB"))
    case "G":
        return (color.green, Color("whiteATB"))
    case "Orange":
        return (color.orange, Color("whiteATB"))
    case "Org":
        return (color.orange, Color("whiteATB"))
    case "Pink":
        return (color.pink, Color("whiteATB"))
    case "Red":
        return (color.red, Color("whiteATB"))
    case "Yellow":
        return (color.yellow, Color.black)
    case "Y":
        return (color.yellow, Color.black)
    case "Purple":
        return (color.purple, Color("whiteATB"))
    case "Purple Exp":
        return (color.purple, Color("whiteATB"))
    case "P":
        return (color.purple, Color("whiteATB"))
    default:
        return (color.coolBlue, Color("whiteATB"))
    }
}
