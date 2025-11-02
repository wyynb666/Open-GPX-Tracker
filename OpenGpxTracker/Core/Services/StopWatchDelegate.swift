//
//  StopWatchDelegate.swift
//  OpenGpxTracker
//

import Foundation

protocol StopWatchDelegate: AnyObject {
    func stopWatch(_ stropWatch: StopWatch, didUpdateElapsedTimeString elapsedTimeString: String)
}
