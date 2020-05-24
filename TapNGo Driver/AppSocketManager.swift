//
//  AppSocketManager.swift
//  TapNGo Driver
//
//  Created by Admin on 13/04/18.
//  Copyright © 2018 nPlus. All rights reserved.
//

import Foundation
import UIKit
import SocketIO
import CoreLocation

@objc protocol MySocketManagerDelegate {
    @objc optional func driverRequestResponseReceived(_ response:NSDictionary)
    @objc optional func tripStatusDriverResponseReceived(_ response:[String:AnyObject])
    @objc optional func cancelledRequestResponseReceived(_ response:[String:AnyObject])
    @objc optional func requestHandlerResponseReceived(_ response:[String:AnyObject])
}

class AppSocketManager:NSObject, AppLocationManagerDelegate

{
    enum EmitType {
        case setLocation
        case tripLocation
        case none
    }
    
    weak var socketDelegate:MySocketManagerDelegate?
    var currentEmitType = EmitType.setLocation
    var locationTimer: Timer?
    let lbl = UILabel(frame: CGRect(x: UIScreen.main.bounds.width/4, y: 20, width: UIScreen.main.bounds.width/2, height: 20))

    static let shared = AppSocketManager()
    
    let socket = SocketIOClient(socketURL: HelperClass.socketUrl, config: SocketIOClientConfiguration(arrayLiteral: .reconnects(true),.reconnectAttempts(-1),.nsp("/driver/home")))
    var setLocationJsonStr = String()

    private override init() {
        super.init()
        self.updateStatus()
        locationTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    func establishConnection() {
        //        self.socket.nsp = "/driver/home"
        self.socket.on("connect") { data, _ in
            print("socket connected")
            self.addObservers()
           if HelperClass.shared.userID != "" {
             let jsonObj = ["id":HelperClass.shared.userID] as [String:Any]
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj, options: JSONSerialization.WritingOptions()) {
                let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                print("start_connect = \(jsonString)")
                self.socket.emit("start_connect", jsonString)
                AppLocationManager.shared.delegate=self
            }
            }
           
        }
        self.socket.connect()
    }
    
    @objc func update() {
        if AppSocketManager.shared.currentEmitType == .setLocation {
            self.emitSetLocation()
        } else if AppSocketManager.shared.currentEmitType == .tripLocation {
            self.emitTripLocation()
        } else {
            print("Location not sent to server")
        }
    }
    
    func updateStatus() {
        socket.on(clientEvent: .statusChange) { (dataArr, _) in
            guard let status = dataArr.first as? SocketIOClientStatus else {
                return
            }
            guard let window = UIApplication.shared.keyWindow else {
                return
            }
            if !window.subviews.contains(self.lbl) {
                window.addSubview(self.lbl)
            }
            self.lbl.isHidden = true
            self.lbl.textAlignment = .center
            self.lbl.isUserInteractionEnabled = true
            self.lbl.backgroundColor = .red
            self.lbl.textColor = .black
            switch status {
            case .connected: self.lbl.text = "socket connected"
            case .notConnected: self.lbl.text = "socket notConnected";self.socket.reconnect()
            case .connecting: self.lbl.text = "socket connecting"
            case .disconnected: self.lbl.text = "socket disconnected"
            }
        }
    }
    
    func appLocationManager(didUpdateLocations locations: [CLLocation]) {
        if AppSocketManager.shared.currentEmitType == .setLocation {
            self.emitSetLocation()
        } else if AppSocketManager.shared.currentEmitType == .tripLocation {
            self.emitTripLocation()
        } else {
            print("Location not sent to server")
        }
    }
    func appLocationManager(didUpdateHeading newHeading: CLHeading) {
//        if AppSocketManager.shared.currentEmitType == .setLocation {
//            self.emitSetLocation()
//        }
    }
    private func emitSetLocation() {
        guard let currentLocation = AppLocationManager.shared.locationManager.location else
        {
            return
        }
        let heading = AppLocationManager.shared.currentHeading?.trueHeading ?? currentLocation.course
        let jsonObject = ["lat":currentLocation.coordinate.latitude,"lng":currentLocation.coordinate.longitude,"bearing":heading,"id":HelperClass.shared.userID] as [String:Any]
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) {
            let newJsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
            if newJsonString != self.setLocationJsonStr {
                if AppSocketManager.shared.socket.status == .connected {
                    print("emit set_location = \(newJsonString)")
                    self.setLocationJsonStr = newJsonString
                    AppSocketManager.shared.socket.emit("set_location", self.setLocationJsonStr)
                } else {
                    print("socket not connected")
                }
            }
        }
    }
    private func emitTripLocation() {
        guard let currentLocation = AppLocationManager.shared.locationManager.location else
        {
            return
        }
        var jsonObject = [String:Any]()
        jsonObject["lat"] = currentLocation.coordinate.latitude
        jsonObject["lng"] = currentLocation.coordinate.longitude
        jsonObject["bearing"] = AppLocationManager.shared.currentHeading?.trueHeading ?? currentLocation.course
        jsonObject["id"] = HelperClass.shared.userID
        jsonObject["request_id"] = HelperClass.shared.currentTripDetail.acceptedRequestId
        jsonObject["user_id"] = HelperClass.shared.currentTripDetail.requestCustomerId
        jsonObject["trip_start"] = HelperClass.shared.currentTripDetail.requestIsTripStarted
        jsonObject["is_share"] = "0"
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()),
            let JsonStringToServer = String(data: jsonData, encoding: String.Encoding.utf8) {
            if AppSocketManager.shared.socket.status == .connected {
                print("emit trip_location = \(JsonStringToServer)")
                AppSocketManager.shared.socket.emit("trip_location", JsonStringToServer)
            } else {
                print("socket not connected")
            }
        }
        
        
    }
}

extension AppSocketManager {
    func addObservers() {
        self.socket.on("driver_request") { data, _ in
            guard let response = data.first as? NSDictionary else {
                return
            }
            DispatchQueue.main.async {
                self.socketDelegate?.driverRequestResponseReceived?(response)
            }
        }
        self.socket.on("trip_status_driver") { data, _ in
            guard let response = data.first as? [String:AnyObject] else {
                return
            }
            DispatchQueue.main.async {
                self.socketDelegate?.tripStatusDriverResponseReceived?(response)
            }
        }
        self.socket.on("cancelled_request") { data, _ in
            guard let response = data.first as? [String:AnyObject] else {
                return
            }
            DispatchQueue.main.async {
                self.socketDelegate?.cancelledRequestResponseReceived?(response)
            }
        }
        self.socket.on("request_handler") { data, _ in
            guard let response = data.first as? [String:AnyObject] else {
                return
            }
            DispatchQueue.main.async {
                self.socketDelegate?.requestHandlerResponseReceived?(response)
            }
        }
    }
}
