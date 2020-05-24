//
//  SocketManager.swift
//  TapNGo Driver
//
//  Created by Spextrum on 30/11/17.
//  Copyright © 2017 nPlus. All rights reserved.
//

import UIKit
import SocketIO

class SocketManager: NSObject
{
     static let sharedInstance = SocketManager()
    
    override init()
    {
        super.init()
    }
    
    var paramdict : NSDictionary = ["nsp": "swift"]
    var socket: SocketIOClient = SocketIOClient(socketURL: HelperClass.socketUrl)
    
    
    func establishConnection()
    {
        
        socket.nsp = "/driver/home"
        self.socket.on("connect") {data, ack in
            print("socket connected",data,ack)
        }
        socket.on(clientEvent: SocketClientEvent(rawValue: "connect")!, callback: { ( dataArray, ack) -> Void in
            print("Hi Natarajan",dataArray,ack)

            let jsonObject: NSMutableDictionary = NSMutableDictionary()
            
            jsonObject.setValue("11.635910034179682", forKey: "lat")
            jsonObject.setValue("78.153457641601534", forKey: "lng")
            jsonObject.setValue("110.0", forKey: "bearing")
            jsonObject.setValue("31", forKey: "id")
            
            let jsonData: NSData
            var jsonString = NSString()
            
            do
            {
                jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
                jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String as String as NSString
                print("json string = \(jsonString)")
                
            } catch _
            {
                print ("JSON Failure")
            }

            self.socket.emit("set_location", jsonString)
            
        })
        socket.on(clientEvent: SocketClientEvent(rawValue: "reconnect")!, callback: { ( dataArray, ack) -> Void in
            print("Hi",dataArray)
        })
        socket.on(clientEvent: SocketClientEvent(rawValue: "reconnectAttempt")!, callback: { ( dataArray, ack) -> Void in
            print("Hi",dataArray)
        })
        socket.on(clientEvent: SocketClientEvent(rawValue: "error")!, callback: { ( dataArray, ack) -> Void in
            print("Hi No Connection in Socket",dataArray)
        })
        socket.on(clientEvent: SocketClientEvent(rawValue: "disconnect")!, callback: { ( dataArray, ack) -> Void in
            print("Hi",dataArray)
        })
        socket.on("message", callback: { ( dataArray, ack) -> Void in
            print("Hi",dataArray)
        })
        socket.connect()
        print("Socket Data",socket)
        print("Socket Connected")
    }
    func closeConnection()
    {
        socket.disconnect()
        print("Socket Dis-Connected")
    }
    
    func SendDriverLocationDetailsFromHomeVC(MessageKey:String,MessageValue:NSString)
    {
        print("Try Emitting Data")
        self.socket.emit(MessageKey, MessageValue)
    }
}
