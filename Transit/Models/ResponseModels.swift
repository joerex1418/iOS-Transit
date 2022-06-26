//
//  ResponseModels.swift
//  Transit
//
//  Created by Joseph Rechenmacher on 6/11/22.
//

import Foundation
import MyFirstPackage


let metraBaseString: String = "https://gtfsapi.metrarail.com/gtfs"
let metraClientKey = "<METRA API CLIENT KEY>"
let metraSecretKey = "<METRA API SECRET KEY"

let ctaBusBase = "http://www.ctabustracker.com/bustime/api/v2"
let ctaBusKey = "CTA BUS TRACKER KEY"
let ctaBusKeyAlt = "CTA BUS TRACKER ALT KEY"

let ctaTrainBase = "https://lapi.transitchicago.com/api/1.0"
let ctaTrainKey = "CTA TRAIN TRACKER KEY"
let ctaTrainKeyAlt = "CTA TRAIN TRACKER ALT KEY"

protocol IsPredictionResponseType {
    var isPrediction: Bool { get }
}

public enum UnknownType: Codable {
    case string(String)
    case int(Int)
    case bool(Bool)
    case double(Double)
    case float(Float)
    case array([UnknownType])
    case dict([String:UnknownType])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Float.self) {
            self = .float(value)
        } else if let value = try? container.decode(Array<UnknownType>.self) {
            self = .array(value)
        } else if let value = try? container.decode(Dictionary<String,UnknownType>.self) {
            self = .dict(value)
        } else {
            throw DecodingError.typeMismatch(UnknownType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not convert JSON value to supported type"))
        }
    }

}

public enum StringifiedUnknown: Codable {
    case string(String)
    case int(Int)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else {
            throw DecodingError.typeMismatch(StringifiedUnknown.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unable to determine value type in response"))
        }
    }
    
    public var string: String? {
        switch self {
        case .string(let value):
            return value
        case .int(let value):
            return String(value)
        default:
            return nil
        }
    }
    
}

struct ResponseModels {
    struct Bus {
        static var dateFormatter: DateFormatter {
            let df = DateFormatter()
            df.dateFormat = "yyyyMMdd HH:mm"
            return df
        }

//        init() {
//            dateFormatter.dateFormat = "yyyyMMdd HH:mm"
//        }
        // getstops
        struct StopsResponse: Codable {
            let bustime_response: StopsResponse.BusTimeResponse
            struct BusTimeResponse: Codable {
                let stops: [Stops?]
                struct Stops: Codable {
                    let stopId: String
                    let stopName: String
                    let lat: Double
                    let lon: Double
                    enum CodingKeys: String, CodingKey {
                        case stopId = "stpid"
                        case stopName = "stpnm"
                        case lat, lon
                    }
                }
            }
            enum CodingKeys: String, CodingKey {
                case bustime_response = "bustime-response"
            }
        }
        
        struct VehiclesResponse: Codable {
            let bustime_response: VehiclesResponse.BusTimeResponse
            struct BusTimeResponse: Codable {
                let vehicles: [Vehicle]
                struct Vehicle: Codable {
                    let vehicleId: String
                    let timestamp: String
                    let patternId: Int
                    let routeId: String
                    let destination: String
                    let patternDistance: Int
                    private let dly: Bool?
                    var isDelayed: Bool {
                        if let dly = dly {
                            return dly
                        }
                        return false
                    }
                    let ctaTripId: String
                    let ctaBlockId: String
                    let zone: String
                    let lat: String
                    let lon: String
                    let heading: String
                    
                    enum CodingKeys: String, CodingKey {
                        case vehicleId = "vid"
                        case timestamp = "tmstmp"
                        case patternId = "pid"
                        case routeId = "rt"
                        case destination = "des"
                        case patternDistance = "pdist"
                        case ctaTripId = "tatripid"
                        case ctaBlockId = "tablockid"
                        case heading = "hdg"
                        case dly, zone, lat, lon
                    }
                    
                }
                enum CodingKeys: String, CodingKey {
                    case vehicles = "vehicle"
                }
            }
            enum CodingKeys: String, CodingKey {
                case bustime_response = "bustime-response"
            }
        }
        
        struct PredictionsResponse: Codable {
            let bustime_response: PredictionData
            struct PredictionData: Codable {
                let predictions: [Prediction?]?
                struct Prediction: Codable, Identifiable {
                    let timestamp: String
                    let type: String
                    let stopName: String
                    let stopId: String
                    let vid: String
                    let linearDistance: Int
                    let routeId: String
                    let routedd: String
                    let routeDirection: String
                    let destinationName: String
                    let arrivalTime: String
                    let ctaBlockId: String
                    let ctaTripId: String
                    let isDelayed: Bool
                    let prediction: String
                    let zone: String
                    var id: String {
                        return "\(stopId)-\(vid)"
                    }
                    
                    enum CodingKeys: String, CodingKey {
                        case timestamp = "tmstmp"
                        case type = "typ"
                        case stopName = "stpnm"
                        case stopId = "stpid"
                        case vid, zone
                        case linearDistance = "dstp"
                        case routeId = "rt"
                        case routedd = "rtdd"
                        case routeDirection = "rtdir"
                        case destinationName = "des"
                        case arrivalTime = "prdtm"
                        case ctaBlockId = "tablockid"
                        case ctaTripId = "tatripid"
                        case isDelayed = "dly"
                        case prediction = "prdctdn"
                    }
                }
                
                let error: [ResponseError]?
                struct ResponseError: Codable, Identifiable {
                    let stopId: String
                    var id: String {
                        return stopId
                    }
                    let msg: String
                    
                    enum CodingKeys: String, CodingKey {
                        case stopId = "stpid"
                        case msg
                    }
                }
                
                enum CodingKeys: String, CodingKey {
                    case predictions = "prd"
                    case error
                }
                
                var isError: Bool {
                    if predictions != nil {
                        return false
                    }
                    return true
                }
                
            }
            
            enum CodingKeys: String, CodingKey {
                case bustime_response = "bustime-response"
            }
            
        }
    }
    struct Train {
        static let trainRouteIds = ["Red":"Red Line",
                                      "P":"Purple Line",
                                      "Org":"Orange Line",
                                      "Y":"Yellow Line",
                                      "Blue":"Blue Line",
                                      "Pink":"Pink Line",
                                      "G":"Green Line",
                                      "Brn":"Brown Line",
                                      "BLS-1":"Blue Line Shuttle",
                                      "GLS-1":"Green Line Shuttle"]
        
        static var dateFormatter: DateFormatter {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            return df
        }
        
        struct ArrivalsResponse: Codable {
            private let ctatt: ETAData
            var data: ETAData {
                return ctatt
            }
            struct ETAData: Codable {
                let timestamp: String
                let errorCode: String
                let errorName: String?
                let eta: [Arrival]
                struct Arrival: Codable, Identifiable {
                    let id = UUID()
                    let stationId: String
                    let stationName: String
                    let stopId: String
                    let stopDesc: String
                    let runNumber: String
                    let routeId: String
                    var routeName: String {
                        if let rtName = ResponseModels.Train.trainRouteIds[routeId] {
                            return rtName
                        }
                        return "-"
                            
                    }
                    let trainRouteDir: String
                    let destinationStationId: String
                    let destinationName: String
                    let predictedAt: String
                    let arrivalTime: String
                    
                    private let lat: String
                    private let lon: String
                    var vehicleLat: Double? {
                        do {
                            return try stringCoordToDouble(coord: lat)
                        } catch {
                            return nil
                        }
                    }
                    var vehicleLon: Double? {
                        do {
                            return try stringCoordToDouble(coord: lon)
                        } catch {
                            return nil
                        }
                    }
                    let heading: String
                    
                    private let isApp: String?
                    private let isDly: String?
                    private let isSch: String?
                    private let isFlt: String?
                    
                    var isApproaching: Bool {
                        if let isApp = isApp {
                            if isApp == "1" {
                                return true
                            }
                        }
                        return false
                    }
                    var isDelayed: Bool {
                        if let isDly = isDly {
                            if isDly == "1" {
                                return true
                            }
                        }
                        return false
                    }
                    var isScheduled: Bool {
                        if let isSch = isSch {
                            if isSch == "1" {
                                return true
                            }
                        }
                        return false
                    }
                    var isFault: Bool {
                        if let isFlt = isFlt {
                            if isFlt == "1" {
                                return true
                            }
                        }
                        return false
                    }
                    
                    enum CodingKeys: String, CodingKey {
                        case stationId = "staId"
                        case stationName = "staNm"
                        case stopId = "stpId"
                        case stopDesc = "stpDe"
                        case runNumber = "rn"
                        case routeId = "rt"
                        case trainRouteDir = "trDr"
                        case destinationStationId = "destSt"
                        case destinationName = "destNm"
                        case predictedAt = "prdt"
                        case arrivalTime = "arrT"
                        
                        case isApp, isDly, isSch, isFlt
                        case lat, lon, heading
                    }
                    
                }
                enum CodingKeys: String, CodingKey {
                    case timestamp = "tmst"
                    case errorCode = "errCd"
                    case errorName = "errNm"
                    case eta
                }
            }
        }
        
        struct PositionsResponse: Codable {
            private let ctatt: PositionData
            var data: PositionData {
                return ctatt
            }
            struct PositionData: Codable {
                let timestamp: String
                let errorCode: String
                let errorName: String?
                let route: [Route]
                
                enum CodingKeys: String, CodingKey {
                    case timestamp = "tmst"
                    case errorCode = "errCd"
                    case errorName = "errNm"
                    case route
                }
                
                struct Route: Codable {
                    let name: String
                    let train: [Train]
                    struct Train: Codable {
                        let runNumber: String
                        let destStation: String
                        let destName: String
                        let trainRouteDir: String
                        let nextStationId: String
                        let nextStopId: String
                        let nextStationName: String
                        let predictedAt: String
                        let arrivalTime: String

                        let lat: String
                        let lon: String
                        var vehicleLat: Double? {
                            do {
                                return try stringCoordToDouble(coord: lat)
                            } catch {
                                return nil
                            }
                        }
                        var vehicleLon: Double? {
                            do {
                                return try stringCoordToDouble(coord: lon)
                            } catch {
                                return nil
                            }
                        }
                        let heading: String
                        
                        private let isApp: String?
                        private let isDly: String?
                        var isApproaching: Bool {
                            if let isApp = isApp {
                                if isApp == "1" {
                                    return true
                                }
                            }
                            return false
                        }
                        var isDelayed: Bool {
                            if let isDly = isDly {
                                if isDly == "1" {
                                    return true
                                }
                            }
                            return false
                        }
                        
                        enum CodingKeys: String, CodingKey {
                            case runNumber = "rn"
                            case destStation = "destSt"
                            case destName = "destNm"
                            case trainRouteDir = "trDr"
                            case nextStationId = "nextStaId"
                            case nextStopId = "nextStpId"
                            case nextStationName = "nextStaNm"
                            case predictedAt = "prdt"
                            case arrivalTime = "arrT"
                            case isDly, isApp, lat, lon, heading
                        }
                        
                    }
                    enum CodingKeys: String, CodingKey {
                        case train
                        case name = "@name"
                    }
                }
            }
        }
        
        struct FollowResponse: Codable {}
    }
    
    struct Metra {
        struct Data {
            struct Stop: Codable {
            }
            
            struct Route: Codable {
                let routeId: String
                let routeShortName: String
                let routeLongName: String
                let routeDesc: String
                let agencyId: String
                let routeType: Int
                
                private let route_color: StringifiedUnknown
                var routeColor: String {
                    if let string = route_color.string {
                        if string == "8000" {
                            return "#800000"
                        } else {
                            return "#\(string)"
                        }
                    }
                    return "#000000"
                }
                
                private let route_text_color: StringifiedUnknown
                var routeTextColor: String {
                    if let string = route_text_color.string {
                        if string == "0" {
                            return "#000000"
                        } else {
                            return "#\(string)"
                        }
                    }
                    return "#FFFFFF"
                }
                
                let routeUrl: String
                
                enum CodingKeys: String, CodingKey {
                    case routeId = "route_id"
                    case routeShortName = "route_short_name"
                    case routeLongName = "route_long_name"
                    case routeDesc = "route_desc"
                    case agencyId = "agency_id"
                    case routeType = "route_type"
                    
                    case route_color
                    case route_text_color
                    
                    case routeUrl = "route_url"
                    
                }
                
                
            }
            
            struct StopTime: Codable {
                let tripId: String
                let arrivalTime: String
                let departureTime: String
                let stopId: String
                let stopSequence: Int
                let pickupType: Int
                let dropoffType: Int
                
                private let center_boarding: Int
                var centerBoarding: Bool { return center_boarding == 1 ? true : false }
                private let south_boarding: Int
                var southBoarding: Bool { return south_boarding == 1 ? true : false }
                private let bikes_allowed: Int
                var bikesAllowed: Bool { return bikes_allowed == 1 ? true : false }
//                private let notice: Int
                
                enum CodingKeys: String, CodingKey {
                    case tripId = "trip_id"
                    case arrivalTime = "arrival_time"
                    case departureTime = "departure_time"
                    case stopId = "stop_id"
                    case stopSequence = "stop_sequence"
                    case pickupType = "pickup_type"
                    case dropoffType = "drop_off_type"
                    
                    case center_boarding, south_boarding, bikes_allowed
                }
                
            }
            
        }
        
        
        struct VehiclePosition: Codable {
            let id: String
            let is_deleted: Bool?
            let trip_update: Bool?
            let vehicle: Vehicle?
        //    let alert: Alert?
        }

        struct Vehicle: Codable {
            let trip: Trip?
            let position: Position?
        }

        struct Trip: Codable {
            let trip_id: String
            let route_id: String
            let direction_id: String
            let start_time: String
            let start_date: String
            let schedule_relationship: Int
        }

        struct Position: Codable {
            let latitude: Double
            let longitude: Double
        }
        
        struct Stop: Codable {
            let stopId: String?
            let stopName: String?
            let stopDesc: String?
            let stopLat: Double?
            let stopLon: Double?
            let zoneId: String?
            let stopUrl: String?
            let wheelchairBoarding: Int?

            enum CodingKeys: String, CodingKey {
                case stopId = "stop_id"
                case stopName = "stop_name"
                case stopDesc = "stop_desc"
                case stopLat = "stop_lat"
                case stopLon = "stop_lon"
                case zoneId = "zone_id"
                case stopUrl = "stop_url"
                case wheelchairBoarding = "wheelchair_boarding"
            }
        }
    }
    
    
}
