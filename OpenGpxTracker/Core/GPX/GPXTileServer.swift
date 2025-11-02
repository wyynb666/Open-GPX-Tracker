import Foundation

enum GPXTileServer: Int {
    case apple
    case appleSatellite
    case openStreetMap
    case cartoDB
    case cartoDBRetina
    case openTopoMap
    case openSeaMap

    var name: String {
        switch self {
        case .apple: return "Apple Mapkit (no offline cache)"
        case .appleSatellite: return "Apple Satellite (no offline cache)"
        case .openStreetMap: return "OpenStreetMap"
        case .cartoDB: return "Carto DB"
        case .cartoDBRetina: return "Carto DB (Retina resolution)"
        case .openTopoMap: return "OpenTopoMap"
        case .openSeaMap: return "OpenSeaMap"
        }
    }

    var templateUrl: String {
        switch self {
        case .apple: return ""
        case .appleSatellite: return ""
        case .openStreetMap: return "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        case .cartoDB: return "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png"
        case .cartoDBRetina: return "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png"
        case .openTopoMap: return "https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png"
        case .openSeaMap: return "https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png"
        }
    }

    var subdomains: [String] {
        switch self {
        case .apple: return []
        case .appleSatellite: return []
        case .openStreetMap: return ["a", "b", "c"]
        case .cartoDB, .cartoDBRetina: return ["a", "b", "c"]
        case .openTopoMap: return ["a", "b", "c"]
        case .openSeaMap: return []
        }
    }

    var maximumZ: Int {
        switch self {
        case .apple:
            return -1
        case .appleSatellite: 
            return -1
        case .openStreetMap:
            return 19
        case .cartoDB, .cartoDBRetina:
            return 21
        case .openTopoMap:
            return 17
        case .openSeaMap:
            return 16
        }
    }

    var minimumZ: Int {
        switch self {
        case .apple:
            return 0
        case .appleSatellite:
            return 0
        case .openStreetMap:
            return 0
        case .cartoDB, .cartoDBRetina:
            return 0
        case .openTopoMap:
            return 0
        case .openSeaMap:
            return 0
        }
    }

    var canReplaceMapContent: Bool {
        switch self {
        case .openSeaMap: return false
        default: return true
        }
    }

    var tileSize: Int {
        switch self {
        case .cartoDBRetina: return 512
        default: return 256
        }
    }
    
    var needForceDarkMode: Bool {
        return self == .appleSatellite
    }

    static var count: Int { return GPXTileServer.openSeaMap.rawValue + 1}
}
