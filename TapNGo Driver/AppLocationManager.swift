//
//  AppLocationManager.swift
//  TapNGo Driver
//
//  Created by Admin on 12/04/18.
//  Copyright © 2018 nPlus. All rights reserved.
//

import Foundation
import CoreLocation

@objc protocol AppLocationManagerDelegate {
    func appLocationManager(didUpdateLocations locations: [CLLocation])
    @objc optional func appLocationManager(didUpdateHeading newHeading: CLHeading)
}
class AppLocationManager:NSObject,CLLocationManagerDelegate
{
    static let shared = AppLocationManager()
    var delegate:AppLocationManagerDelegate?
    var locationManager:CLLocationManager = CLLocationManager()
    var currentHeading: CLHeading?

    
    private override init() {
        super.init()
        locationManager.delegate = self
//        locationManager.distanceFilter = 1.0
        locationManager.allowsBackgroundLocationUpdates = true
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = false
        } else {
            // Fallback on earlier versions
        }
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }    
    func startTracking()
    {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    func stopTracking()
    {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("locationManagerDidPauseLocationUpdates")
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("locationManagerDidResumeLocationUpdates")
    }
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        print("locationManager didVisit")
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager didFailWithError")
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("locationManager didExitRegion")
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("locationManager didEnterRegion")
    }
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        print("locationManagerShouldDisplayHeadingCalibration")
        return false
    }
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("locationManager didStartMonitoringFor")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {        
        print("locationManager didUpdateHeading")
        self.currentHeading = newHeading
        delegate?.appLocationManager?(didUpdateHeading: newHeading)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locationManager didUpdateLocations")
        delegate?.appLocationManager(didUpdateLocations: locations)
    }
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        print("locationManager didFinishDeferredUpdatesWithError")
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("locationManager didChangeAuthorization")
    }
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("locationManager didDetermineState")
    }
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("locationManager didRangeBeacons")
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("locationManager monitoringDidFailFor")
    }
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("locationManager rangingBeaconsDidFailFor")
    }

}
