import Foundation
import UIKit
import MapKit


open class DistanceLabel: UILabel {
    
    /// Internal variable that keeps the actual distance
    private var _distance = 0.0
    
    /// Internal variable to keep the use of imperial units
    private var _useImperial = false
    
    /// Use imperial units (miles)? False by default.
    /// If true, displays meters and kilometers
    open var useImperial: Bool {
        get {
            return _useImperial
        }
        set {
            _useImperial = newValue
            distance = _distance // Updates text displayed to reflect the new units
        }
    }
    
    /// Distance in meters
    open var distance: CLLocationDistance {
        get {
            return _distance
        }
        set {
            _distance = newValue
            text = newValue.toDistance(useImperial: _useImperial)
        }
    }
}
