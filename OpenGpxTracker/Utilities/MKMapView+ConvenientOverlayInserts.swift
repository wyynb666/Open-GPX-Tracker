//
//  MKMapView+ConvenientOverlayInserts.swift
//  OpenGpxTracker
//

import MapKit
import UIKit

extension MKMapView {
    func addOverlayOnTop(_ overlay: MKOverlay) {
        if let last = self.overlays.last {
            self.insertOverlay(overlay, above: last)
        } else {
            self.addOverlay(overlay)
        }
    }
    
    func addOverlayOnBottom(_ overlay: MKOverlay) {
        if let first = self.overlays.first {
            self.insertOverlay(overlay, above: first)
        } else {
            self.addOverlay(overlay, level: .aboveLabels)
        }
    }
}
