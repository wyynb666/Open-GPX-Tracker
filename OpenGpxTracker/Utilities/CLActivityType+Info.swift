//
//  CLActivityType+Info.swift
//  OpenGpxTracker
//

import CoreLocation

/// Extends each CLActivityType to have a description and a name.
extension CLActivityType {

    var name: String {
        switch self {
        case .other:                return NSLocalizedString("AT_AUTOMATIC", comment: "no comment")
        case .automotiveNavigation: return NSLocalizedString("AT_AUTOMOTIVE", comment: "no comment")
        case .fitness:              return NSLocalizedString("AT_FITNESS", comment: "no comment")
        case .otherNavigation:      return NSLocalizedString("AT_OTHER", comment: "no comment")
        case .airborne:             return NSLocalizedString("AT_FLIGHT", comment: "no comment")
        @unknown default:
            return "Unknown Type: \(self.rawValue)"
        }
    }

    var description: String {
        switch self {
        case .other:                return NSLocalizedString("AT_AUTOMATIC_DESC", comment: "no comment")
        case .automotiveNavigation: return NSLocalizedString("AT_AUTOMOTIVE_DESC", comment: "no comment")
        case .fitness:              return NSLocalizedString("AT_FITNESS_DESC", comment: "no comment")
        case .otherNavigation:      return NSLocalizedString("AT_OTHER_DESC", comment: "no comment")
        case .airborne:             return NSLocalizedString("AT_FLIGHT_DESC", comment: "no comment")
        @unknown default:
            return "Unknown Type: \(self.rawValue)"
        }
    }

    static var count: Int {
        return 5
    }
    
}
