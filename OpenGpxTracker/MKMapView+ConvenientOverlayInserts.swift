//
//  MKMapView+ConvenientOverlayInserts.swift
//  OpenGpxTracker
//

import MapKit
import UIKit

extension MKMapView {
    
    func addOverlayOnTop(_ overlay: MKOverlay) {
        if let last = self.overlays.last {                  // its not the first overlay
            self.insertOverlay(overlay, above: last)        // make sure to add it above all
        } else {                                            // its the first one
            self.addOverlay(overlay)                        // just add it
        }
    }
    
    func addOverlayOnBottom(_ overlay: MKOverlay) {
        if let first = self.overlays.first {                  // its the first overlay
            self.insertOverlay(overlay, above: first)         // make sure to add it below all
        } else {                                              // its the first one
            self.addOverlay(overlay, level: .aboveLabels)     // just add it
        }
    }

}
