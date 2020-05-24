//
//  AppDelegate.swift
//  TapNGo Driver
//
//  Created by Spextrum on 03/10/17.
//  Copyright © 2017 nPlus. All rights reserved.
//

import UIKit
//import CoreData
import UserNotifications
import UserNotificationsUI
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift
import SWRevealViewController
import Foundation
import SystemConfiguration
import SocketIO
import Fabric
import Crashlytics
import Localize
import Alamofire


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{

    var window: UIWindow?
    var DeviceToken = String()
//    var USER_NAME = String()
//    var User_ID = String()
//    var User_Token = String()
//    var DriverMobile = String()

//    var tripRequestID = String()
//    var TripIsDriverArrived = String()
//    var TripIsStarted = String()
//    var TripIsCompleted = String()
    var NetworkFlag = Bool()

    var historyrequestid = String()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.disabledToolbarClasses = [ForgetPasswordVC.self]
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Done".localize()

        self.addNetWorkListener()


        Localize.shared.update(language: HelperClass.currentAppLanguage)
        print(Localize.shared.currentLanguage)
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
        application.registerForRemoteNotifications()

        UIApplication.shared.applicationIconBadgeNumber = 0
        center.removeAllDeliveredNotifications()
        
        AppLocationManager.shared.locationManager.requestWhenInUseAuthorization()

        GMSServices.provideAPIKey("AIzaSyCkNVoPSgCiH2WYZBv64DEctInk1BbXCmI")
        GMSPlacesClient.provideAPIKey("AIzaSyCkNVoPSgCiH2WYZBv64DEctInk1BbXCmI")

        Fabric.with([Crashlytics.self])

        HelperClass.shared.delegate = self
        HelperClass.shared.fetchUsersDetails()
        HelperClass.shared.fetchTripDetails()
        self.checkLogin()


        UITableView.appearance().tintColor = UIColor.themeColor
        UINavigationBar.appearance().barTintColor = UIColor.themeColor
//        UIApplication.shared.statusBarStyle = .lightContent
        UINavigationBar.appearance().tintColor = UIColor.secondaryColor
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.appBoldTitleFont(ofSize: 18),NSAttributedString.Key.foregroundColor:UIColor.secondaryColor]
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.appBoldTitleFont(ofSize: 15),NSAttributedString.Key.foregroundColor:UIColor.secondaryColor], for: UIControl.State())
        return true
    }    

    func applicationWillResignActive(_ application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//       SocketManager.sharedInstance.closeConnection()
    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        //        DeviceToken = deviceTokenString
        print("APNs device token: \(deviceTokenString)")
        DeviceToken = deviceTokenString

    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
    }
    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any])
//    {
//
//            self.performActions(userInfo)
//            print(userInfo)
//       // UIApplication.shared.applicationIconBadgeNumber = 0
//    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
  
        print("Notification resp: ", userInfo)
        self.performActions(userInfo)
        UIApplication.shared.applicationIconBadgeNumber = 0
              completionHandler(UIBackgroundFetchResult.newData)
    }
    
  
    func applicationWillTerminate(_ application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        HelperClass.shared.saveContext()
        SocketManager.sharedInstance.closeConnection()
    }
    
    // ******** Network Reachablity *********
    
       
    
    // ***** Check Login *****
    
    func checkLogin()
    {
        print("userIdStr is: ",HelperClass.shared.userID)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if HelperClass.shared.userName != ""
        {

            AppLocationManager.shared.startTracking()
           AppSocketManager.shared.establishConnection()
            let mainViewController = SWRevealViewController()
            let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            mainViewController.frontViewController = UINavigationController(rootViewController:homeVC)
            mainViewController.rightViewController = storyboard.instantiateViewController(withIdentifier: "LeftSideSliderVC") as! LeftSideSliderVC
            mainViewController.rearViewController = storyboard.instantiateViewController(withIdentifier: "LeftSideSliderVC") as! LeftSideSliderVC

            if HelperClass.shared.currentTripDetail != nil
            {
                if HelperClass.shared.currentTripDetail.requestIsTripCompleted == "1"
                {
                    let tripInvoiceVC = storyboard.instantiateViewController(withIdentifier: "TripInvoiceVC")
                    tripInvoiceVC.navigationItem.hidesBackButton = true
                    (mainViewController.frontViewController as! UINavigationController).pushViewController(tripInvoiceVC, animated: false)
                }
                else if HelperClass.shared.currentTripDetail.requestIsTripCompleted == "0"
                {
                    let arrivedMapVC = storyboard.instantiateViewController(withIdentifier: "ArrivedMapVC")
                    arrivedMapVC.navigationItem.hidesBackButton = true
                    (mainViewController.frontViewController as! UINavigationController).pushViewController(arrivedMapVC, animated: false)
                }
            } else {
                homeVC.fromAppLaunch = true
            }

            self.window?.rootViewController = mainViewController
        }
        else
        {
            let mainViewController = storyboard.instantiateViewController(withIdentifier: "LoginBaseVC") as! LoginBaseVC
            self.window?.rootViewController = UINavigationController(rootViewController: mainViewController)
        }
        self.window?.makeKeyAndVisible()
    }

//    func getContext () -> NSManagedObjectContext
//    {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        return appDelegate.persistentContainer.viewContext
//    }
    
//    func GetCompletedTripBillDetails()
//    {
//        //create a fetch request, telling it about the entity
//        let fetchRequest: NSFetchRequest<Request_AcceptedData> = Request_AcceptedData.fetchRequest()
//
//        do
//        {
//            //go get the results
//            let Array_BillDetails = try getContext().fetch(fetchRequest)
//
//            //I like to check the size of the returned results!
//            print ("num of Trips = \(Array_BillDetails.count)")
//
//            //You need to convert to NSManagedObject to use 'for' loops
//            for trip in Array_BillDetails as [NSManagedObject]
//            {
//                print(trip.entity)
//                print(trip.entity.attributesByName)
//                //get the Key Value pairs (although there may be a better way to do that...
//
//                print("\(String(describing: trip.value(forKey: "accepted_request_id")))")
//                tripRequestID = (String(describing: trip.value(forKey: "accepted_request_id")!))
//                TripIsDriverArrived = (String(describing: trip.value(forKey: "request_is_driver_arrived")!))
//                TripIsStarted = (String(describing: trip.value(forKey: "request_is_trip_started")!))
//                TripIsCompleted = (String(describing: trip.value(forKey: "request_is_trip_completed")!))
//                print("Trip ID =",tripRequestID , TripIsCompleted)
//            }
//        }
//        catch
//        {
//            print("Error with request: \(error)")
//        }
//
//    }

//    func fetchTripRequestDetails()
//    {
//        //create a fetch request, telling it about the entity
//        let fetchRequest: NSFetchRequest<Request_AcceptedData> = Request_AcceptedData.fetchRequest()
//        do
//        {
//            //go get the results
//            let Array_TripDetails = try HelperClass.shared.persistentContainer.viewContext.fetch(fetchRequest)
//            
//            //I like to check the size of the returned results!
//            print ("num of Trips = \(Array_TripDetails.count)")
//            
//            //You need to convert to NSManagedObject to use 'for' loops
//            for trip in Array_TripDetails as [NSManagedObject]
//            {
//                //get the Key Value pairs (although there may be a better way to do that...
//                trip.entity.attributesByName.forEach({
//                    print($0.key + " = ")
//                        print(trip.value(forKey: $0.key))
//                })
//
//                print("\(String(describing: trip.value(forKey: "accepted_request_id")))")
//                tripRequestID = (String(describing: trip.value(forKey: "accepted_request_id")!))
//                TripIsDriverArrived = (String(describing: trip.value(forKey: "request_is_driver_arrived")!))
//                TripIsStarted = (String(describing: trip.value(forKey: "request_is_trip_started")!))
//                TripIsCompleted = (String(describing: trip.value(forKey: "request_is_trip_completed")!))
//                print("User ID =",tripRequestID)
//            }
//        }
//        catch
//        {
//            print("Error with request: \(error)")
//        }
//
//    }
    
//    func getUsers ()
//    {
//        //create a fetch request, telling it about the entity
//        let fetchRequest: NSFetchRequest<Login_UserData> = Login_UserData.fetchRequest()
//
//        do
//        {
//            //go get the results
//            let array_users = try getContext().fetch(fetchRequest)
//
//            //I like to check the size of the returned results!
//            print ("num of users = \(array_users.count)")
//
//            //You need to convert to NSManagedObject to use 'for' loops
//            for user in array_users as [NSManagedObject]
//            {
//                //get the Key Value pairs (although there may be a better way to do that...
//                print("\(String(describing: user.value(forKey: "loginuser_firstname")))")
//                USER_NAME = (String(describing: user.value(forKey: "loginuser_firstname")!))
//                User_ID = (String(describing: user.value(forKey: "loginuser_ID")!))
//                User_Token = (String(describing: user.value(forKey: "loginuser_token")!))
//                DriverMobile = (String(describing: user.value(forKey: "loginuser_phone")!))
//                print("User ID =",User_ID)
//            }
//        }
//        catch
//        {
//            print("Error with request: \(error)")
//        }
//    }

    // MARK: - Core Data stack


    
    

}

extension AppDelegate:LogoutDelegate
{
    func logedOut() {
        self.checkLogin()
    }
}
extension AppDelegate
{
    func addNetWorkListener()
    {
        let networkManager = NetworkReachabilityManager()
        networkManager?.startListening()
        print(networkManager?.isReachable)
        print(networkManager?.isReachable)
        if !(networkManager?.isReachable ?? false)
        {
            print("The network is not reachable")
            self.window?.showToast("The network is not reachable. Please check your Internet Connection.", backgroundColor: UIColor.white.withAlphaComponent(0.6), textColor:.black)

        }
        networkManager?.listener = { status in
            if networkManager?.isReachable ?? false {
                switch status {
                case .reachable(.ethernetOrWiFi):
                    print("The network is reachable over the WiFi connection")
                case .reachable(.wwan):
                    print("The network is reachable over the WWAN connection")
                case .notReachable:
                    print("The network is not reachable")
                case .unknown :
                    print("It is unknown whether the network is reachable")
                }
            } else {
                print("The network is not reachable")
                self.window?.showToast("The network is not reachable. Please check your Internet Connection.")
            }
        }
    }
}
extension AppDelegate:UNUserNotificationCenterDelegate
{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        let userdict=notification.request.content.userInfo
        print(userdict)
        self.performActions(userdict)
        completionHandler([.alert,.sound,.badge,])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Handle push from background or closed")
        print("\(response.notification.request.content.userInfo)")
    }


    func performActions(_ userdict: [AnyHashable:Any]) {

        guard let aps = userdict[AnyHashable("aps")] as? [String:AnyObject],
            let apsdata = userdict[AnyHashable("data")] as? [String:AnyObject],
            let title = aps["alert"] as? String else {
                return
        }

        if title == "Trip cancelled by User"
        {
            if let pushcancelleddatadict = apsdata["body"] as? [String:AnyObject] {
                print(pushcancelleddatadict)
                NotificationCenter.default.post(name: Notification.Name("TripCancelledNotification"), object: nil, userInfo: pushcancelleddatadict)
            }
        }
    }
}
