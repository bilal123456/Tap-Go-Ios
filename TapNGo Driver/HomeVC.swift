    //
//  HomeVC.swift
//  TapNGo Driver
//
//  Created by Spextrum on 07/10/17.
//  Copyright © 2017 nPlus. All rights reserved.
//

import UIKit
import SWRevealViewController
import GoogleMaps
import GooglePlaces
//import CoreData
import Alamofire
import NVActivityIndicatorView
import SocketIO
import Localize

import AVKit


class HomeVC: UIViewController
{
    @IBOutlet weak var requestDataView: RequestDataView!
    //    @IBOutlet weak var BGViewforAvailablityBtn: UIView!
//    @IBOutlet weak var BtnLeftMenu: UIBarButtonItem!
//    @IBOutlet weak var BtnRightMenu: UIBarButtonItem!
    @IBOutlet weak var offlineDriverView: OfflineDriverView!
    @IBOutlet weak var mapview: GMSMapView!


    var declinedView = UIView()
    var lblNotApproved = UILabel()

    let splashBgView = UIImageView()

    var layoutDic = [String:AnyObject]()
    var top:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var currentLayoutDirection = HelperClass.appLanguageDirection//TO REDRAW VIEWS IF DIRECTION IS CHANGED
    var driverStatusButton:UIBarButtonItem!
    let driverStatusView = UIView()
    let driverStatusLbl = UILabel()
    let driverStatusSwitch = UISwitch()
    var requestTimer:Timer!
    var count:Int = 60
    var previousLocUpdateTime:Date = Date()
    var currentLocUpdatedTime:Date = Date()

    
    var ActivityIndicator = NVActivityIndicatorView?.self
    static let activityData = ActivityData()
    
    let Pref = UserDefaults.standard
    
    let AppDelegates = UIApplication.shared.delegate as! AppDelegate
//    let HelperObject = HelperClass()
    var locationManager = CLLocationManager()
    let drivermarker = GMSMarker()
    var degrees = CLHeading()
    var headingVal = Double()
    var driversCurrentLatitude = Double()
    var driversCurrentLongitude = Double()

    var pickUpLat: String! = ""
    var pickUpLong: String! = ""

    var locValue:CLLocationCoordinate2D!

    var location=CLLocation()
    
    let socket = SocketIOClient(socketURL: HelperClass.socketUrl)
    var jsonString = NSString()
    var fromAppLaunch = false

    var tripSoundPlayer:AVAudioPlayer?

    var pref = UserDefaults.standard
    
    var acceptApiRequest:DataRequest?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: false)
        

      //  AppLocationManager.shared.delegate = self
        if let currentLocation = AppLocationManager.shared.locationManager.location
        {
            //location.course -> Moving Direction
            //newHeading -> Pointing Direction
            let bearing = AppLocationManager.shared.currentHeading?.trueHeading ?? currentLocation.course
            mapview.camera = GMSCameraPosition.camera(withTarget: currentLocation.coordinate, zoom: 18, bearing: bearing, viewingAngle: 45)
                CATransaction.begin()
                CATransaction.setValue(1, forKey: kCATransactionAnimationDuration)
                self.mapview.animate(toZoom: 18)
                CATransaction.commit()
        }

        mapview.isTrafficEnabled = true
        mapview.settings.compassButton = false
        mapview.isMyLocationEnabled = true
        mapview.settings.myLocationButton = true
        mapview.isBuildingsEnabled = true
        mapview.isIndoorEnabled = true
        mapview.delegate = self
//        mapview.animate(toZoom: 15)
//        mapview.animate(toViewingAngle: 45)


//        do {
//            // Set the map style by passing the URL of the local file.
//            if let styleURL = Bundle.main.url(forResource: "mapStyle", withExtension: "json") {
//                self.mapview.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
//            } else {
//                print("Unable to find mapStyle.json")
//            }
//        } catch {
//            print("One or more of the map styles failed to load. \(error)")
//        }


        if UserDefaults.standard.integer(forKey: "requestTimercount") != 0
        {
            self.count = UserDefaults.standard.integer(forKey: "requestTimercount")
        }
//        getUsersDetails()
//        getCurrentLocation()

        print("Home Logged in Data ID & Name =",HelperClass.shared.userID,HelperClass.shared.userName)
        print("Driver Availablity Details",Pref.object(forKey: "IsDriverApprove") as! NSNumber,Pref.object(forKey: "IsDriverActive") as! NSNumber,Pref.object(forKey: "IsDriverAvailable") as! NSNumber)
       print("Driver Availablity",HelperClass.shared.isUserApproved)
        
       // self.connectsocket()

        setUpViews()
        checkRequestinprogress()

    }



    @objc func driverStatusChanged(_ sender:UISwitch)
    {
        apiForChangingDriverAvailablity()
    }
    func setUpViews()
    {
        driverStatusLbl.textColor = .secondaryColor
        driverStatusLbl.font = UIFont.appFont(ofSize: driverStatusLbl.font!.pointSize)
        if self.Pref.bool(forKey: "IsDriverActive")
        {
            offlineDriverView.isHidden = true
            driverStatusLbl.text = "Online".localize()
            driverStatusSwitch.isOn = true
        }
        else
        {
            offlineDriverView.isHidden = false
            driverStatusLbl.text = "Offline".localize()
            driverStatusSwitch.isOn = false
        }
//        driverStatusSwitch.tintColor = .secondaryColor
////        driverStatusSwitch.onTintColor = .secondaryColor
//        driverStatusSwitch.thumbTintColor = .secondaryColor
        driverStatusSwitch.addTarget(self, action: #selector(driverStatusChanged(_:)), for: .valueChanged)


        driverStatusLbl.removeFromSuperview()
        driverStatusLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["driverStatusLbl"] = driverStatusLbl
        driverStatusView.addSubview(driverStatusLbl)

        declinedView.backgroundColor = UIColor.white
        declinedView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["declinedView"] = declinedView
        self.view.addSubview(declinedView)


        lblNotApproved.textColor = UIColor.gray
        lblNotApproved.text = "You are not approved. Please contact admin"
        lblNotApproved.numberOfLines = 0
        lblNotApproved.lineBreakMode = .byWordWrapping
        lblNotApproved.textAlignment = .center
        lblNotApproved.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["lblNotApproved"] = lblNotApproved
        self.declinedView.addSubview(lblNotApproved)
        self.view.bringSubviewToFront(self.declinedView)

        driverStatusSwitch.removeFromSuperview()
        driverStatusSwitch.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["driverStatusSwitch"] = driverStatusSwitch
        driverStatusView.addSubview(driverStatusSwitch)



        driverStatusView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[driverStatusLbl]-(5)-[driverStatusSwitch]|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        driverStatusView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[driverStatusLbl]|", options: [], metrics: nil, views: layoutDic))
        driverStatusView.sizeToFit()
//        driverStatusButton = nil
        driverStatusButton = UIBarButtonItem(customView: driverStatusView)

        if HelperClass.appLanguageDirection == .directionLeftToRight
        {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"menu"), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            self.navigationItem.rightBarButtonItem = driverStatusButton
        }
        else
        {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"menu"), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)))
            self.navigationItem.leftBarButtonItem = driverStatusButton
        }

      self.top = self.view.topAnchor
      mapview.translatesAutoresizingMaskIntoConstraints = false
      layoutDic["mapview"] = mapview
      offlineDriverView.translatesAutoresizingMaskIntoConstraints = false
      layoutDic["offlineDriverView"] = offlineDriverView
      offlineDriverView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
      requestDataView.translatesAutoresizingMaskIntoConstraints = false
      layoutDic["requestDataView"] = requestDataView
        
        
      self.mapview.topAnchor.constraint(equalTo: self.top, constant: 64).isActive = true
      self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[mapview]|", options: [], metrics: nil, views: layoutDic))
      self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[mapview]|", options: [], metrics: nil, views: layoutDic))
        
      self.offlineDriverView.topAnchor.constraint(equalTo: self.top, constant: 64).isActive = true
      self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[offlineDriverView]|", options: [], metrics: nil, views: layoutDic))
      self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[offlineDriverView]|", options: [], metrics: nil, views: layoutDic))

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[declinedView]|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[declinedView]|", options: [], metrics: nil, views: layoutDic))


        self.declinedView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-32-[lblNotApproved]-32-|", options: [], metrics: nil, views: layoutDic))
        self.declinedView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lblNotApproved(70)]", options: [], metrics: nil, views: layoutDic))
        self.declinedView.addConstraints([NSLayoutConstraint.init(item: lblNotApproved, attribute: .centerY, relatedBy: .equal, toItem: self.declinedView, attribute: .centerY, multiplier: 1.0, constant: 0)])

        self.view.bringSubviewToFront(declinedView)


        
        self.requestDataView.topAnchor.constraint(equalTo: self.top, constant: 64).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[requestDataView]|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[requestDataView]|", options: [], metrics: nil, views: layoutDic))
        if self.fromAppLaunch
        {
            self.revealAnimation()
        }
    }
    func revealAnimation()
    {
        layoutDic["splashBgView"] = splashBgView
        splashBgView.backgroundColor = .secondaryColor
        //        splashBgView.isHidden = true
        splashBgView.translatesAutoresizingMaskIntoConstraints = false
        //        splashBgView.image = UIImage(named:"Splash")
        self.navigationController?.view.addSubview(splashBgView)
        self.navigationController?.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[splashBgView]|", options: [], metrics: nil, views: layoutDic))
        self.navigationController?.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[splashBgView]|", options: [], metrics: nil, views: layoutDic))
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
        print(splashBgView.center)
        let path1 = CGMutablePath()
        path1.addArc(center: CGPoint(x: self.view.center.x, y: self.view.center.y), radius: 1, startAngle: 0.0, endAngle: 2.0 * CGFloat.pi, clockwise: false)
        path1.addRect(CGRect(origin: .zero, size: self.view.frame.size))

        let path2 = CGMutablePath()
        path2.addArc(center: CGPoint(x: self.view.center.x, y: self.view.center.y), radius: 1000, startAngle: 0.0, endAngle: 2.0 * CGFloat.pi, clockwise: false)
        path2.addRect(CGRect(origin: .zero, size: self.view.frame.size))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path1
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd

        let pathAnim = CABasicAnimation(keyPath: "path")
        pathAnim.fromValue = path1
        pathAnim.toValue = path2
        pathAnim.duration = 1.0
        maskLayer.add(pathAnim, forKey: "animateRadius")
        maskLayer.path = path2
        splashBgView.layer.mask = maskLayer
        splashBgView.clipsToBounds = true
        // Callback function
        CATransaction.setCompletionBlock {
            self.splashBgView.removeFromSuperview()
            print("end animation")
        }
        // Do the actual animation and commit the transaction
        maskLayer.add(pathAnim, forKey: "animateRadius")
        CATransaction.commit()
    }
    
    @objc func update(_ sender:Timer)
    {
        if(count > 0)
        {
            requestDataView.lblTimer.text = String(count)
            count -= 1
        }
        else
        {
            if self.requestTimer != nil
            {
                self.stopSound()
                self.requestTimer.invalidate()
                self.requestTimer = nil
            }
            count = 60
            APIToRejectTheUserRequest()
        }

    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
   
        AppLocationManager.shared.delegate = self
         AppSocketManager.shared.currentEmitType = .setLocation
        AppSocketManager.shared.socketDelegate = self
       
        
        self.title = "TapNgo Driver"
//        Change Localized text after changing language in settings
        if self.Pref.bool(forKey: "IsDriverActive")
        {
            driverStatusLbl.text = "Online".localize()
        }
        else
        {
            driverStatusLbl.text = "Offline".localize()
        }
//        Change Localized text after changing language direction in settings
        if currentLayoutDirection != HelperClass.appLanguageDirection
        {
            self.setUpViews()
            currentLayoutDirection = HelperClass.appLanguageDirection
        }
        self.setNavigationButtons()

//        self.BtnRightMenu.isEnabled = false
//        SideMenuButtons()
        customFormat()
        self.checkRequestinprogress()
        NotificationCenter.default.addObserver(self, selector: #selector(methodOfReceivedNotification(notification:)), name: Notification.Name("TripCancelledNotification"), object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("TripCancelledNotification"), object: nil)
        AppSocketManager.shared.socketDelegate = nil
    }
    
    @objc func methodOfReceivedNotification(notification: Notification)
    {
        guard let pushcancelleddatadict = notification.userInfo as? [String:AnyObject] else {
            return
        }
        print("Cancelled by User notification", pushcancelleddatadict)
        let JSON = pushcancelleddatadict// as! [String:AnyObject]
        print(JSON)

        if let isCancelled = JSON["is_cancelled"] as? Bool, isCancelled
        {
            self.showToast("Txt_TripCanceled".localize())
            UserDefaults.standard.set(60, forKey: "requestTimercount")
            self.count = 60
            if self.requestTimer != nil
            {
                self.stopSound()
                self.requestTimer.invalidate()
                self.requestTimer = nil
            }
            HelperClass.shared.deleteTripDetails()
            requestDataView.isHidden = true
            self.setNavigationButtons()
            acceptApiRequest?.cancel()
        }
        
    }
    func setNavigationButtons()
    {
        if self.navigationItem.leftBarButtonItem == nil && self.navigationItem.rightBarButtonItem == nil
        {
            if HelperClass.appLanguageDirection == .directionLeftToRight
            {
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"menu"), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
                self.navigationItem.rightBarButtonItem = driverStatusButton
            }
            else
            {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"menu"), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)))
                self.navigationItem.leftBarButtonItem = driverStatusButton
            }
        }
    }

    
//    func getCurrentLocation()
//    {
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.startUpdatingLocation()
//        locationManager.startUpdatingHeading()
//    }

    func connectsocket()
    {
        self.addHandlers()
        self.socket.connect()
       // self.getrequestdatadata()
    }
    

    

    
    func allowDeferredLocationUpdates(untilTraveled distance: CLLocationDistance,
                                      timeout: TimeInterval)
    {
        print("Location Difference found")
    }
    
    
    @IBAction func ChangeAvailablityBtn(_ sender: Any)
    {
        self.requestDataView.isHidden = false
        self.requestDataView.circleAnimationView.animateCircle(60, startFrom: 0)
        self.view.bringSubviewToFront(self.requestDataView)
        print("Availablity Changed")
        apiForChangingDriverAvailablity()
    }
    
//    func SideMenuButtons()
//    {
//        if revealViewController() != nil
//        {
//            BtnLeftMenu.target = revealViewController()
//            BtnLeftMenu.action = #selector(SWRevealViewController.revealToggle(_:))
//        }
//        if revealViewController() != nil
//        {
//            BtnRightMenu.target = revealViewController()
//            BtnRightMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
//        }
//    }

    func customFormat()
    {
//        self.navigationItem.hidesBackButton = true
        self.navigationItem.backBtnString = ""
        
        self.requestDataView.bgViewForAddress.layer.cornerRadius = 7
        self.requestDataView.bgViewForAddress.clipsToBounds = true

        self.requestDataView.isHidden = true
//        self.driverStatusSwitch.isEnabled = true
        HelperClass.shared.isUserApproved = String(describing: Pref.object(forKey: "IsDriverApprove") as! NSNumber)
        HelperClass.shared.isUserAvailable = String(describing: Pref.object(forKey: "IsDriverAvailable") as! NSNumber)
        HelperClass.shared.isUserActive = String(describing: Pref.object(forKey: "IsDriverActive") as! NSNumber)

//        if((Pref.object(forKey: "IsDriverActive") as! NSNumber).boolValue)
//        {
////            self.offlineDriverView.BtnChaneAvailablity.setTitle("GO OFFLINE".localize(), for: .normal)
//            self.offlineDriverView.isHidden = true
//        }
//        else
//        {
////            self.offlineDriverView.BtnChaneAvailablity.setTitle("GO ONLINE".localize(), for: .normal)
//            self.offlineDriverView.isHidden = false
//        }
    }
    
    func addHandlers()
    {
        socket.nsp = "/driver/home"
        self.socket.on("connect") {data, ack in
            print("socket connected")
            if HelperClass.shared.userID != "" {
                self.socket.emit("start_connect", HelperClass.shared.userID)
            }
            
            print("socket connected161")
            let jsonObject1: NSMutableDictionary = NSMutableDictionary()

            jsonObject1.setValue(self.driversCurrentLatitude, forKey: "lat")
            jsonObject1.setValue(self.driversCurrentLongitude, forKey: "lng")
            jsonObject1.setValue(self.headingVal, forKey: "bearing")
            jsonObject1.setValue(HelperClass.shared.userID, forKey: "id")

            let jsonData1: NSData
            do
            {
                jsonData1 = try JSONSerialization.data(withJSONObject: jsonObject1, options: JSONSerialization.WritingOptions()) as NSData
                self.jsonString = NSString(data: jsonData1 as Data, encoding: String.Encoding.utf8.rawValue)! //as String as String as NSString
                print("json string = \(self.jsonString)")
            }
            catch _
            {
                print ("JSON Failure")
            }
            if HelperClass.shared.userID != "" {
                 self.socket.emit("set_location", self.jsonString)
            }
            
           // self.getrequestdatadata()
            self.socket.on("driver_request")
            {
                data, ack in
                print("Request from a User for you! \(data[0])")
                let JSON = data[0] as! NSDictionary
                print(JSON)
                
                let theSuccess = (JSON.value(forKey: "success") as! Bool)
                if(theSuccess == true)
                {
                    guard self.requestTimer == nil else
                    {
                        print("Another Trip Request is in progress")
                        return
                    }
                    self.navigationItem.leftBarButtonItem = nil
                    self.navigationItem.rightBarButtonItem = nil
                    HelperClass.shared.receivedRequestData = JSON.value(forKey: "request") as! NSDictionary
                    HelperClass.shared.receivedRequestUserData = HelperClass.shared.receivedRequestData.value(forKey: "user") as! NSDictionary
                    self.requestDataView.lblCustomerName.text = (HelperClass.shared.receivedRequestUserData.value(forKey: "firstname") as! String)
                    HelperClass.shared.customerID = String(describing: (HelperClass.shared.receivedRequestUserData.value(forKey: "id") as! NSNumber))
                    HelperClass.shared.receivedRequestID = String(describing: (HelperClass.shared.receivedRequestData.value(forKey: "id") as! NSNumber))
                   
                    self.requestDataView.lblPickUpAddress.text! = HelperClass.shared.receivedRequestData.value(forKey: "pick_location") as! String
                    self.requestDataView.lblDropAddress.text! = HelperClass.shared.receivedRequestData.value(forKey: "drop_location") as! String

                    if let etaAmount = HelperClass.shared.receivedRequestData.value(forKey: "driver_eta") as? String {
                        self.requestDataView.lblEta.text = etaAmount
                    }

                    self.pref.set(self.requestDataView.lblPickUpAddress.text!, forKey: "PickAddress")
                    self.pref.set(self.requestDataView.lblDropAddress.text!, forKey: "DropAddress")

                    self.requestTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(HomeVC.update), userInfo: nil, repeats: true)

                    self.requestDataView.isHidden = false
                    self.requestDataView.circleAnimationView.animateCircle(60, startFrom: 0)
                        self.playSound()
//                    self.driverStatusSwitch.isEnabled = false
                    self.view.bringSubviewToFront(self.requestDataView)
                }
            }
        }
    }
//
//    func getrequestdatadata()
//    {
//        self.socket.on("driver_request")
//        {
//            data, ack in
//            print("Request from a User for you! \(data[0])")
//            let JSON = data[0] as! NSDictionary
//            print(JSON)
//
//            let theSuccess = (JSON.value(forKey: "success") as! Bool)
//            if(theSuccess == true)
//            {
//                HelperClass.shared.ReceivedRequestData = JSON.value(forKey: "request") as! NSDictionary
//                HelperClass.shared.ReceivedRequestUserData = HelperClass.shared.ReceivedRequestData.value(forKey: "user") as! NSDictionary
//                self.requestDataView.LblCustomerName.text = (HelperClass.shared.ReceivedRequestUserData.value(forKey: "firstname") as! String)
//                HelperClass.shared.Customer_ID = String(describing: (HelperClass.shared.ReceivedRequestUserData.value(forKey: "id") as! NSNumber))
//                HelperClass.shared.ReceivedRequest_ID = String(describing: (HelperClass.shared.ReceivedRequestData.value(forKey: "id") as! NSNumber))
//
//                self.requestDataView.LblPickUpAddress.text! = HelperClass.shared.ReceivedRequestData.value(forKey: "pick_location") as! String
//                self.requestDataView.LblDropAddress.text! = HelperClass.shared.ReceivedRequestData.value(forKey: "drop_location") as! String
//
//                var LTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(HomeVC.update), userInfo: nil, repeats: true)
//                self.requestDataView.isHidden = false
//                self.view.bringSubview(toFront: self.requestDataView)
//            }
//        }
//    }

    @IBAction func AcceptRequestBtn(_ sender: Any)
    {
        print("Accept Btn Pressed")
        APIToAcceptTheUserRequest()
    }
    
    func APIToAcceptTheUserRequest()
    {
        if ConnectionCheck.isConnectedToNetwork()
        {
            self.showLoadingIndicator()
            print("Connected")
            let url = HelperClass.BASEURL + HelperClass.RespondToRequestURL
            var paramdict = Dictionary<String, Any>()
            
            paramdict["id"] = HelperClass.shared.userID
            paramdict["token"] = HelperClass.shared.userToken
            paramdict["is_response"] = "1"
            paramdict["request_id"] = HelperClass.shared.receivedRequestID
            paramdict["reason"] = ""
            
            print("URL & Parameters for Accepting Request API =",url,paramdict)
            
          acceptApiRequest = Alamofire.request(url, method:.post, parameters: paramdict, encoding: JSONEncoding.default, headers:HelperClass.Header)
            
                .responseJSON
                { response in
                    print(response.result.value)
                    if case .failure(let error) = response.result
                    {
                        print(response.error! as NSError)
//                        self.showAlert("", message: error.localizedDescription)

                        print(error.localizedDescription)
                    }
                    else if case .success = response.result
                    {
                        print("accept request response",response.result.value)
                        if let JSON = response.result.value as? [String:AnyObject], let status = JSON["success"] as? Bool
                        {
                            if status
                            {
                                HelperClass.shared.saveTripDetails(JSON["request"] as! [String:AnyObject], currentTrip: nil)
                                if self.requestTimer != nil
                                {
                                    self.stopSound()
                                    self.requestTimer.invalidate()
                                    self.requestTimer = nil
                                }
                                UserDefaults.standard.set(60, forKey: "requestTimercount")
                                self.count = 60
                                let arrivedMapVC = self.storyboard?.instantiateViewController(withIdentifier: "ArrivedMapVC") as! ArrivedMapVC
                                arrivedMapVC.ReceivedRequestDetailsDict = HelperClass.shared.receivedRequestData
                                arrivedMapVC.CustomerDetailsDict = HelperClass.shared.receivedRequestUserData
                                arrivedMapVC.navigationItem.hidesBackButton = true
                                self.navigationController?.pushViewController(arrivedMapVC, animated: true)
//                                self.StoreAcceptedRequestDetails(Request_Local_Details: JSON["request"] as! [String:AnyObject])

                            }
                            else
                            {
                                if self.requestTimer != nil
                                {
                                    self.stopSound()
                                    self.requestTimer.invalidate()
                                    self.requestTimer = nil
                                }
                                UserDefaults.standard.set(60, forKey: "requestTimercount")
                                self.count = 60
                                print(JSON["error_message"] as! String)
                                self.requestDataView.isHidden = true
                                self.setNavigationButtons()
                                self.showAlert("Alert".localize(), message: JSON["error_message"] as! String)

                            }
                        }
                    }
                    self.stopLoadingIndicator()
            }
        }
        else
        {
            print("disConnected")
            stopLoadingIndicator()
            self.showAlert("No Internet".localize(), message: "Please Check Your Internet Connection".localize())
        }
    }
    
    @IBAction func rejectRequestBtn(_ sender: Any)
    {
        print("Reject Btn Pressed")
        self.APIToRejectTheUserRequest()
    }
    
    func APIToRejectTheUserRequest()
    {
        if ConnectionCheck.isConnectedToNetwork()
        {
            self.showLoadingIndicator()
            print("Connected")
            let url = HelperClass.BASEURL + HelperClass.RespondToRequestURL
            var paramdict = Dictionary<String, Any>()
            
            paramdict["id"] = HelperClass.shared.userID
            paramdict["token"] = HelperClass.shared.userToken
            paramdict["is_response"] = "0"
            paramdict["request_id"] = HelperClass.shared.receivedRequestData.value(forKey: "id")
            paramdict["reason"] = "Already in Trip"
            
            print("URL & Parameters for Rejecting Request API =",url,paramdict)
            
            Alamofire.request(url, method:.post, parameters: paramdict, encoding: JSONEncoding.default, headers:HelperClass.Header)
                .responseJSON
                { response in

                    if case .failure(let error) = response.result
                    {
                        self.showAlert("ERROR", message: error.localizedDescription)
                        print(error.localizedDescription)
                    }
                    else if case .success = response.result
                    {
                        if let JSON = response.result.value as? [String:AnyObject], let status = JSON["success"] as? Bool
                        {
                            if status
                            {
                                self.showToast("Request Rejected".localize())
                                UserDefaults.standard.set(60, forKey: "requestTimercount")
                                self.count = 60
                                if self.requestTimer != nil
                                {
                                    self.stopSound()
                                    self.requestTimer.invalidate()
                                    self.requestTimer = nil
                                }
                                self.requestDataView.isHidden = true
                                self.setNavigationButtons()
                            }
                            else
                            {
                                if let errorCode = JSON["error_code"] as? Int, errorCode == 727
                                {
                                    UserDefaults.standard.set(60, forKey: "requestTimercount")
                                    self.count = 60
                                    if self.requestTimer != nil
                                    {
                                        self.stopSound()
                                        self.requestTimer.invalidate()
                                        self.requestTimer = nil
                                    }
                                    self.requestDataView.isHidden = true
                                    self.setNavigationButtons()
                                }
                                print(JSON["error_message"] as! String)
                                self.showAlert("Alert".localize(), message: JSON["error_message"] as! String)

                            }
                        }
                    }
                    self.stopLoadingIndicator()
            }
        }
        else
        {
            print("disConnected")
            stopLoadingIndicator()
            self.showAlert("No Internet".localize(), message: "Please Check Your Internet Connection".localize())
        }

    }
//    
//    func getContext () -> NSManagedObjectContext
//    {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        return appDelegate.persistentContainer.viewContext
//    }
//    
//    func getUsersDetails ()
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
//                HelperClass.shared.userName = (String(describing: user.value(forKey: "loginuser_firstname")!))
//                HelperClass.shared.userLastName = (String(describing: user.value(forKey: "loginuser_lastname")!))
//                HelperClass.shared.userID = (String(describing: user.value(forKey: "loginuser_ID")!))
//                HelperClass.shared.userToken = (String(describing: user.value(forKey: "loginuser_token")!))
//                HelperClass.shared.isUserActive = (String(describing: user.value(forKey: "loginuser_is_active")!))
//                HelperClass.shared.isUserApproved = (String(describing: user.value(forKey: "loginuser_is_approve")!))
//                HelperClass.shared.isUserAvailable  = (String(describing: user.value(forKey: "loginuser_is_available")!))
//                print("User ID =",HelperClass.shared.userID)
//                
//            }
//        }
//        catch
//        {
//            print("Error with request: \(error)")
//        }
//    }
    
//    func StoreUserDetails(User_Details: NSDictionary)
//    {
//        let context = getContext()
//        print("userDictionary is: ",User_Details)
//
//
//        let w : Int = Int((User_Details.value(forKey: "is_available") as? NSNumber)!)
//        let isavailableString = String(w)
//        print("My New ID",isavailableString)
//
//        let x : Int = Int((User_Details.value(forKey: "is_active") as? NSNumber)!)
//        let isactiveString = String(x)
//        print("My New ID",isactiveString)
//
//        let y : Int = Int((User_Details.value(forKey: "is_approve") as? NSNumber)!)
//        let isapproveString = String(y)
//        print("My New ID",isapproveString)
//
//
//        let user = Login_UserData(context: getContext())
//        user.loginuser_is_approve = isapproveString
//        user.loginuser_is_active = isactiveString
//        user.loginuser_is_available = isavailableString
//
//
//        //save the object
//        do
//        {
//            try context.save()
//            print("saved!")
//        }
//        catch let error as NSError
//        {
//            print("Could not save \(error), \(error.userInfo)")
//        }
//        catch
//        {
//
//        }
//
//    }

//    func StoreAcceptedRequestDetails(Request_Local_Details: [String:AnyObject])
//    {
//        let context = HelperClass.shared.persistentContainer.viewContext
//        print("Request Local Dictionary is: ",Request_Local_Details)
//
//        let Accepted_Req_IDString = String(describing: (Request_Local_Details["id"] as! NSNumber))
//        print("My New ID",Accepted_Req_IDString)
//
//        let Req_isDriverArrivedString = String(describing: (Request_Local_Details["is_driver_arrived"] as! NSNumber))
//        print("My New ID",Req_isDriverArrivedString)
//
//        let Req_isTripStartedString = String(describing: (Request_Local_Details["is_trip_start"] as! NSNumber))
//        print("My New ID",Req_isTripStartedString)
//
//        let Req_isTripCompletedString = String(describing: (Request_Local_Details["is_completed"] as! NSNumber))
//        print("My New ID",Req_isTripCompletedString)
//
//        var LBCustomerDict = [String:AnyObject]()
//        LBCustomerDict = Request_Local_Details["user"] as! [String:AnyObject]
//
//
//        let Request_LocalDB_Data = Request_AcceptedData(context:HelperClass.shared.persistentContainer.viewContext)
//        Request_LocalDB_Data.accepted_request_id = Accepted_Req_IDString
//        Request_LocalDB_Data.request_is_driver_arrived = Req_isDriverArrivedString
//        Request_LocalDB_Data.request_is_trip_started = Req_isTripStartedString
//        Request_LocalDB_Data.request_is_trip_completed = Req_isTripCompletedString
//        Request_LocalDB_Data.request_customer_email = LBCustomerDict["email"] as? String
//        Request_LocalDB_Data.request_customer_id = String(describing: (LBCustomerDict["id"] as! NSNumber))
//        Request_LocalDB_Data.request_customer_review = LBCustomerDict["review"] as? String
//        Request_LocalDB_Data.request_customer_profilepicture = LBCustomerDict["profile_pic"] as? String
//        Request_LocalDB_Data.request_customer_phonenumber = LBCustomerDict["phone_number"] as? String
//        Request_LocalDB_Data.request_customer_firstname = LBCustomerDict["firstname"] as? String
//        Request_LocalDB_Data.request_customer_lastname = LBCustomerDict["lastname"] as? String
//
//        //save the object
//        do
//        {
//            try context.save()
//            print("saved!")
//            self.requestTimer.invalidate()
//            self.requestTimer = nil
//            let arrivedMapVC = self.storyboard?.instantiateViewController(withIdentifier: "ArrivedMapVC") as! ArrivedMapVC
//            arrivedMapVC.ReceivedRequestDetailsDict = HelperClass.shared.receivedRequestData
//            arrivedMapVC.CustomerDetailsDict = HelperClass.shared.receivedRequestUserData
//            arrivedMapVC.navigationItem.hidesBackButton = true
//            self.navigationController?.pushViewController(arrivedMapVC, animated: true)
////            self.performSegue(withIdentifier: "HomeVCToArrivedMapVC", sender: self)
//        }
//        catch let error as NSError
//        {
//            print("Could not save \(error), \(error.userInfo)")
//        }
//        catch
//        {
//
//        }
//
//    }

    func checkRequestinprogress()
    {
        if ConnectionCheck.isConnectedToNetwork()
        {
            //            NVActivityIndicatorPresenter.sharedInstance.startAnimating(HelperClass.shared.activityPulseData)
            print("Connected")
            let url = HelperClass.BASEURL + HelperClass.getrequestinprogress
            var paramdict = Dictionary<String, Any>()

            paramdict["id"] = HelperClass.shared.userID
            paramdict["token"] = HelperClass.shared.userToken

            print("URL & Parameters for Checking current Request API =",url,paramdict)

            Alamofire.request(url, method:.post, parameters: paramdict, encoding: JSONEncoding.default, headers:HelperClass.Header)
                .responseJSON
                { response in
                    print(response.response as Any) // URL response
                    print(response.result.value as AnyObject)
                    if let result = response.result.value as? [String:AnyObject]
                    {
                        print("Response for Login",result)
                        print(result["success"] as? Bool)
                        guard let status = result["success"] as? Bool else {
                            return
                        }
                        if status
                        {
                            print(result)
                            self.stopLoadingIndicator()


                            guard let statusarray = result["driver_status"] as? [String:AnyObject] else {
                                return
                            }
                            if(statusarray.count>0)
                            {
                                if let isDriverActive = statusarray["is_active"] as? Bool {
                                    if isDriverActive {
                                        self.driverStatusLbl.text = "Online".localize()
                                        self.driverStatusSwitch.isOn = true
                                        self.offlineDriverView.isHidden = true
                                    }
                                    else
                                    {
                                        self.driverStatusLbl.text = "Offline".localize()
                                        self.driverStatusSwitch.isOn = false
                                        self.offlineDriverView.isHidden = false
                                    }
                                }

                                if let isApprove = statusarray["is_approve"] as? Bool, !isApprove
                                {
                                    print("Driver Declined")

                                    if HelperClass.appLanguageDirection == .directionLeftToRight {
                                        self.navigationItem.rightBarButtonItem = nil
                                    } else {
                                        self.navigationItem.leftBarButtonItem = nil
                                    }
                                    self.declinedView.isHidden = false
                                    self.view.bringSubviewToFront(self.declinedView)
                                   // self.navigationController?.setNavigationBarHidden(true, animated: true)

                                }
                                else
                                {

                                    if HelperClass.appLanguageDirection == .directionLeftToRight {
                                        self.navigationItem.rightBarButtonItem = self.driverStatusButton
                                    } else {
                                        self.navigationItem.leftBarButtonItem = self.driverStatusButton
                                    }
                                    self.declinedView.isHidden = true
                                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                                }
                            }

                        }
                        else
                        {
                            if let errcodestr = result["error_code"] as? String, errcodestr == "606" {
                                HelperClass.shared.deleteUserDetails()
                            }
                        }
                    }
                    self.stopLoadingIndicator()
            }
        }
        else
        {
            print("disConnected")
            self.stopLoadingIndicator()
            self.showAlert("No Internet".localize(), message: "Please Check Your Internet Connection".localize())
        }
    }


    func apiForChangingDriverAvailablity()
    {
        if ConnectionCheck.isConnectedToNetwork()
        {
            self.showLoadingIndicator()
            print("Connected")
            let url = HelperClass.BASEURL + HelperClass.ChangeDriverAvailablityURL
            var paramdict = Dictionary<String, Any>()
            paramdict["id"] = HelperClass.shared.userID
            paramdict["token"] = HelperClass.shared.userToken
            
            print("URL & Parameters =",url,paramdict)
            
            Alamofire.request(url, method:.post, parameters: paramdict, encoding: JSONEncoding.default, headers:HelperClass.Header)
                .responseJSON
                { response in

                    if case .failure(let error) = response.result
                    {
                        self.driverStatusSwitch.isOn = !self.driverStatusSwitch.isOn //Back to previous state due to api failure
                        print(error.localizedDescription)
                    }
                    else if case .success = response.result
                    {
                        print(response.result.value)
                        if let JSON = response.result.value as? [String:AnyObject], let status = JSON["success"] as? Bool
                        {
                            if status
                            {
                                let UserDetails = JSON["driver"] as! [String:AnyObject]
                                self.Pref.set(UserDetails["is_available"], forKey: "IsDriverAvailable")
                                self.Pref.set(UserDetails["is_active"], forKey: "IsDriverActive")
                                self.Pref.set(UserDetails["is_approve"], forKey: "IsDriverApprove")
                                print(UserDetails)
                                print(UserDetails["is_active"] as! NSNumber)
                                if UserDetails["is_active"] as! Bool
                                {
                                    self.driverStatusLbl.text = "Online".localize()
                                    self.offlineDriverView.isHidden = true
                                }
                                else
                                {
                                    self.driverStatusLbl.text = "Offline".localize()
                                    self.offlineDriverView.isHidden = false
                                }

                            }
                            else
                            {
                                self.driverStatusSwitch.isOn = !self.driverStatusSwitch.isOn //Back to previous state due to api failure
                                print(JSON["error_message"] as! String)
                                self.showAlert("Alert".localize(), message: JSON["error_message"] as! String)

                            }
                        }
                    }
                    self.stopLoadingIndicator()
            }
        }
        else
        {
            self.driverStatusSwitch.isOn = !self.driverStatusSwitch.isOn //Back to previous state due to api failure
            print("disConnected")
            stopLoadingIndicator()
            self.showAlert("No Internet".localize(), message: "Please Check Your Internet Connection".localize())
        }
        
    }
    
    //    # pragma mark - NVActivityIndicatorView
    
    func showLoadingIndicator()
    {
        NVActivityIndicatorView.DEFAULT_TYPE = .ballClipRotatePulse
        NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE = CGSize(width: 180, height: 180)
        NVActivityIndicatorView.DEFAULT_COLOR = UIColor.lightGray
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(HomeVC.activityData)
    }
    
    func stopLoadingIndicator()
    {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }

    
 
    
    func getShadowMarker(_ rotaion:CLLocationDegrees) -> GMSMarker {
        let marker = GMSMarker()
        marker.rotation = rotaion
        let image = UIImageView(image: UIImage(named: "pin_driver"))
        marker.iconView = image
        marker.iconView?.contentMode = .center
        marker.iconView?.bounds.size.width *= 2
        marker.iconView?.bounds.size.height *= 2
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.75)

        marker.iconView?.layer.shadowColor = UIColor.black.cgColor
        marker.iconView?.layer.shadowOffset = CGSize.zero
        marker.iconView?.layer.shadowRadius = 1.0
        marker.iconView?.layer.shadowOpacity = 0.5


        let size = image.bounds.size
        let rect = CGRect(x: size.width/2 - size.width/8, y: size.height*0.75 - 2, width: size.width/4, height: 4)
        marker.iconView?.layer.shadowPath = UIBezierPath(ovalIn: rect).cgPath

        marker.appearAnimation = .pop
        marker.position = CLLocationCoordinate2D(latitude: 11.0317303, longitude: 77.0165797)

        return marker
    }


    func playSound() {
        if let path = Bundle.main.path(forResource: "beep", ofType: "mp3") {
            print(path)
            let url = URL(fileURLWithPath:path)
            if let player = try? AVAudioPlayer(contentsOf: url) {
                self.tripSoundPlayer = player
                self.tripSoundPlayer?.numberOfLoops = -1
                self.tripSoundPlayer?.prepareToPlay()
                self.tripSoundPlayer?.play()
            }

        }
    }

    func stopSound() {
        self.tripSoundPlayer?.stop()
        self.tripSoundPlayer = nil
    }
}

extension HomeVC:AppLocationManagerDelegate
{
    func appLocationManager(didUpdateLocations locations: [CLLocation]) {
        self.currentLocUpdatedTime = Date()
        location = locations.last!
        var diff = Calendar.current.dateComponents([.second], from: self.previousLocUpdateTime, to: self.currentLocUpdatedTime).second ?? 1
        if !mapview.projection.contains(location.coordinate)
        {
            diff = 1
        }
        diff = min(diff, 2)
        CATransaction.begin()
        CATransaction.setValue(diff, forKey: kCATransactionAnimationDuration)
        mapview.animate(toLocation: location.coordinate)
        mapview.animate(toViewingAngle: 45)
        CATransaction.commit()
        self.previousLocUpdateTime = Date()


//        if(self.offlineDriverView.isHidden == false)
//        {
            if(self.declinedView.isHidden == false) {
                self.view.bringSubviewToFront(declinedView)
            } else {
                self.view.bringSubviewToFront(offlineDriverView)
            }

//            self.view.bringSubview(toFront: offlineDriverView)
//        }
        //      Creates a marker in the center of the map.
        drivermarker.icon = UIImage(named: "pin_driver")
        drivermarker.position = location.coordinate
        //drivermarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        if let rotaion = AppLocationManager.shared.currentHeading?.trueHeading
        {
            drivermarker.rotation = rotaion
        }
        drivermarker.appearAnimation = .pop

        drivermarker.map = mapview
        //        self.allowDeferredLocationUpdates(untilTraveled: 10.0, timeout: 10.0)
        driversCurrentLatitude = location.coordinate.latitude
        driversCurrentLongitude = location.coordinate.longitude

        //        self.getShadowMarker(Degreess).map = mapview



        pickUpLat="\(location.coordinate.latitude)"
        pickUpLong="\(location.coordinate.longitude)"
        
//        let jsonObject: NSMutableDictionary = NSMutableDictionary()
//
//        jsonObject.setValue(driversCurrentLatitude, forKey: "lat")
//        jsonObject.setValue(driversCurrentLongitude, forKey: "lng")
//        jsonObject.setValue(headingVal, forKey: "bearing")
//        jsonObject.setValue(HelperClass.shared.userID, forKey: "id")
//
//        let jsonData: NSData
//
//        //        jsonString : NSString
//
//        do
//        {
//            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
//            jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String as String as NSString
//            print("json string = \(jsonString)")
//        }
//        catch _
//        {
//            print ("JSON Failure")
//        }
//
//        if HelperClass.shared.userID != "" {
//            self.socket.emit("set_location", self.jsonString)
//        }
        
    }
    func appLocationManager(didUpdateHeading newHeading: CLHeading) {

        CATransaction.begin()
        CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
        if !mapview.projection.contains(location.coordinate)
        {
            mapview.animate(toLocation: self.location.coordinate)
        }
        mapview.animate(toBearing: newHeading.trueHeading)
        mapview.animate(toViewingAngle: 45)
        CATransaction.commit()

        drivermarker.rotation = newHeading.trueHeading


//        print("Heading =",newHeading)
//        degrees = newHeading
//        print("Exact Heads =",degrees.value(forKey: "magneticHeading") as! Double)
//        headingVal = degrees.value(forKey: "magneticHeading") as! Double
//
//        let jsonObject: NSMutableDictionary = NSMutableDictionary()
//
//        jsonObject.setValue(driversCurrentLatitude, forKey: "lat")
//        jsonObject.setValue(driversCurrentLongitude, forKey: "lng")
//        jsonObject.setValue(headingVal, forKey: "bearing")
//        jsonObject.setValue(HelperClass.shared.userID, forKey: "id")
//
//        let jsonData: NSData
//
//        //        jsonString : NSString
//
//        do
//        {
//            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
//            jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String as String as NSString
//            print("json string = \(jsonString)")
//        }
//        catch _
//        {
//            print ("JSON Failure")
//        }

    }
}
extension HomeVC:GMSMapViewDelegate
{
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
//        if mapView.camera.zoom <= 10
//        {
//            let imgData = UIImagePNGRepresentation(UIImage(named:"pin_driver")!)
//            Drivermarker.icon = UIImage(data: imgData!, scale: CGFloat(23-mapView.camera.zoom)/2.5)
//        }
//        else
//        {
            drivermarker.icon = UIImage(named:"pin_driver")!
//        }
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//        if mapView.camera.zoom <= 10
//        {
//            let imgData = UIImagePNGRepresentation(UIImage(named:"pin_driver")!)
//            Drivermarker.icon = UIImage(data: imgData!, scale: CGFloat(23-mapView.camera.zoom)/2.5)
//        }
//        else
//        {
            drivermarker.icon = UIImage(named:"pin_driver")!
//        }
    }
//    mapview

}

//    func gettypesdata()
//    {
//        self.socket.on("types") {
//            data, ack in
//            print("Types for you! \(data[0])")
//            let JSON = data[0] as! NSDictionary
//            print(JSON)
//            let theSuccess = (JSON.value(forKey: "success") as! Bool)
//
//            if(theSuccess == true)
//            {
//            }
//        }
//    }Vehicle typesVehicle types


//        do
//        {
//                            // Set the map style by passing the URL of the local file. Make sure style.json is present in your project
//                if let styleURL = Bundle.main.url(forResource: "GMSMapStyleSilver", withExtension: "json")
//                {
//                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
//                }
//                else
//                {
//                    print("Unable to find style.json")
//                }
//
//        }
//        catch
//        {
//            print("The style definition could not be loaded: \(error)")
//        }
//


class OfflineDriverView:UIView
{
    @IBOutlet weak var infoLbl:UILabel!
    @IBOutlet weak var btnChaneAvailablity: UIButton!
    var layoutDic = [String:AnyObject]()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        infoLbl.font = UIFont.appFont(ofSize: infoLbl.font!.pointSize)
        btnChaneAvailablity.titleLabel!.font = UIFont.appFont(ofSize: btnChaneAvailablity.titleLabel!.font!.pointSize)

        infoLbl.textColor = .themeColor
        infoLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["infoLbl"] = infoLbl
        btnChaneAvailablity.translatesAutoresizingMaskIntoConstraints = false
        btnChaneAvailablity.isHidden = true
        layoutDic["BtnChaneAvailablity"] = btnChaneAvailablity
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(10)-[infoLbl]-(10)-|", options: [], metrics: nil, views: layoutDic))
        infoLbl.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -40).isActive = true

        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[BtnChaneAvailablity]|", options: [], metrics: nil, views: layoutDic))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[BtnChaneAvailablity(0)]|", options: [], metrics: nil, views: layoutDic))
    }
}
class RequestDataView:UIView
{
    var layoutDic = [String:AnyObject]()
    @IBOutlet weak var lblTimer:UILabel!
    @IBOutlet weak var lblCustomerName:UILabel!
    @IBOutlet weak var bgViewForAddress:UIView!
    @IBOutlet weak var lblPickUpAddress:UILabel!
    @IBOutlet weak var lblDropAddress:UILabel!
    @IBOutlet weak var btnAcceptRequest:UIButton!
    @IBOutlet weak var btnRejectRequest:UIButton!
    let circleAnimationView = CircleAnimationView()

    var lblEstEarnings = UILabel()
    var lblColon = UILabel()
    var lblEta = UILabel()

    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        lblTimer.font = UIFont.appFont(ofSize: lblTimer.font!.pointSize)
        lblCustomerName.font = UIFont.appFont(ofSize: lblCustomerName.font!.pointSize)
        lblPickUpAddress.font = UIFont.appFont(ofSize: lblPickUpAddress.font!.pointSize)
        lblDropAddress.font = UIFont.appFont(ofSize: lblDropAddress.font!.pointSize)
        btnAcceptRequest.titleLabel!.font = UIFont.appFont(ofSize: btnAcceptRequest.titleLabel!.font!.pointSize)
        btnRejectRequest.titleLabel!.font = UIFont.appFont(ofSize: btnRejectRequest.titleLabel!.font!.pointSize)

        bgViewForAddress.layer.cornerRadius = 5.0
        bgViewForAddress.addShadow()

        circleAnimationView.backgroundColor = .white
        circleAnimationView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["circleAnimationView"] = circleAnimationView
        addSubview(circleAnimationView)
        lblTimer.removeFromSuperview()
        lblTimer.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["LblTimer"] = lblTimer
        circleAnimationView.addSubview(lblTimer)
        lblCustomerName.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["LblCustomerName"] = lblCustomerName
        bgViewForAddress.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BGViewForAddress"] = bgViewForAddress
        lblPickUpAddress.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["LblPickUpAddress"] = lblPickUpAddress
        lblDropAddress.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["LblDropAddress"] = lblDropAddress
        btnAcceptRequest.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnAcceptRequest"] = btnAcceptRequest
        btnRejectRequest.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnRejectRequest"] = btnRejectRequest

        lblEstEarnings.text = "Estimate Earnings"
        lblEstEarnings.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["lblEstEarnings"] = lblEstEarnings
        self.addSubview(lblEstEarnings)

        lblColon.text = ":"
        lblColon.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["lblColon"] = lblColon
        self.addSubview(lblColon)

        lblEta.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["lblEta"] = lblEta
        self.addSubview(lblEta)
        
        circleAnimationView.widthAnchor.constraint(equalToConstant: 175).isActive = true
        circleAnimationView.heightAnchor.constraint(equalToConstant: 175).isActive = true
        circleAnimationView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.addConstraint(NSLayoutConstraint.init(item: circleAnimationView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 0.5, constant: 0))


        lblTimer.widthAnchor.constraint(equalToConstant: 45).isActive = true
        lblTimer.heightAnchor.constraint(equalToConstant: 45).isActive = true
        lblTimer.centerXAnchor.constraint(equalTo: circleAnimationView.centerXAnchor).isActive = true
        lblTimer.centerYAnchor.constraint(equalTo: circleAnimationView.centerYAnchor).isActive = true
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[LblCustomerName]-(20)-|", options: [], metrics: nil, views: layoutDic))
        lblCustomerName.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.addConstraint(NSLayoutConstraint.init(item: lblCustomerName, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))

        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[LblCustomerName]-(10)-[lblEstEarnings(25)]", options: [], metrics: nil, views: layoutDic))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[LblCustomerName]-(10)-[lblColon(25)]", options: [], metrics: nil, views: layoutDic))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[LblCustomerName]-(10)-[lblEta(30)]", options: [], metrics: nil, views: layoutDic))

         self.addConstraint(NSLayoutConstraint.init(item: lblEstEarnings, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 0.5, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: lblColon, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: lblEta, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.5, constant: 0))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[BGViewForAddress]-(20)-|", options: [], metrics: nil, views: layoutDic))
            bgViewForAddress.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(5)-[LblPickUpAddress]-(5)-|", options: [], metrics: nil, views: layoutDic))
            bgViewForAddress.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[LblPickUpAddress(50)]-(1)-[LblDropAddress(40)]|", options: [.alignAllLeading,.alignAllTrailing], metrics: nil, views: layoutDic))
        self.addConstraint(NSLayoutConstraint.init(item: bgViewForAddress, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.5, constant: 0))

        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[BtnAcceptRequest]-(1)-[BtnRejectRequest(==BtnAcceptRequest)]|", options: [HelperClass.appLanguageDirection,.alignAllBottom,.alignAllTop], metrics: nil, views: layoutDic))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[BtnAcceptRequest(40)]|", options: [], metrics: nil, views: layoutDic))
        self.layoutIfNeeded()
        self.setNeedsLayout()
        print(circleAnimationView.frame)
    }
}

    extension HomeVC: MySocketManagerDelegate {
        func driverRequestResponseReceived(_ response: NSDictionary) {
           
            print(response)
            
            let theSuccess = (response.value(forKey: "success") as! Bool)
            if(theSuccess == true)
            {
                guard self.requestTimer == nil else
                {
                    print("Another Trip Request is in progress")
                    return
                }
                self.navigationItem.leftBarButtonItem = nil
                self.navigationItem.rightBarButtonItem = nil
                HelperClass.shared.receivedRequestData = response.value(forKey: "request") as! NSDictionary
                HelperClass.shared.receivedRequestUserData = HelperClass.shared.receivedRequestData.value(forKey: "user") as! NSDictionary
                self.requestDataView.lblCustomerName.text = (HelperClass.shared.receivedRequestUserData.value(forKey: "firstname") as! String)
                HelperClass.shared.customerID = String(describing: (HelperClass.shared.receivedRequestUserData.value(forKey: "id") as! NSNumber))
                HelperClass.shared.receivedRequestID = String(describing: (HelperClass.shared.receivedRequestData.value(forKey: "id") as! NSNumber))
                
                self.requestDataView.lblPickUpAddress.text! = HelperClass.shared.receivedRequestData.value(forKey: "pick_location") as! String
                self.requestDataView.lblDropAddress.text! = HelperClass.shared.receivedRequestData.value(forKey: "drop_location") as! String
                
                if let etaAmount = HelperClass.shared.receivedRequestData.value(forKey: "driver_eta") as? String {
                    self.requestDataView.lblEta.text = etaAmount
                }
                
                self.pref.set(self.requestDataView.lblPickUpAddress.text!, forKey: "PickAddress")
                self.pref.set(self.requestDataView.lblDropAddress.text!, forKey: "DropAddress")
                
                self.requestTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(HomeVC.update), userInfo: nil, repeats: true)
                
                self.requestDataView.isHidden = false
                self.requestDataView.circleAnimationView.animateCircle(60, startFrom: 0)
                self.playSound()
                //                    self.driverStatusSwitch.isEnabled = false
                self.view.bringSubviewToFront(self.requestDataView)
            }
        }
    }
