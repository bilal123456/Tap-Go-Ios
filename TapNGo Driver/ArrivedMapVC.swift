//
//  ArrivedMapVC.swift
//  TapNGo Driver
//
//  Created by Spextrum on 08/02/18.
//  Copyright © 2018 nPlus. All rights reserved.
//

import UIKit
import SWRevealViewController
import GoogleMaps
import GooglePlaces
import CoreLocation
//import CoreData
import Alamofire
import NVActivityIndicatorView
import SocketIO
import Localize
import Kingfisher


class ArrivedMapVC: UIViewController,CLLocationManagerDelegate
{
    
    var lbl = UITextView()
    
    
    var layoutDic = [String:AnyObject]()
    var top:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var bottom:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    //***** Variables for Data Received from Previous ViewControllers *****
    var CustomerDetailsDict = NSDictionary()
    var ReceivedRequestDetailsDict = NSDictionary()
    
//    var LDBCustomerFName = String()
//    var LDBCustomerLName = String()
//    var LDBCustomerID = String()
//    var LDBCustomerPhone = String()
//    var LDBCustomerPicture = String()
//    var LDBCustomerEmail = String()
//    var LDBCustomerReview = String()

    var ActivityIndicator = NVActivityIndicatorView?.self
    static let activityData = ActivityData()

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var BGViewForCancelCallBtns: UIView!
    @IBOutlet weak var BGViewForDistanceAndData: UIView!
    @IBOutlet weak var BGViewForTripActionBtns: UIView!
    
    @IBOutlet weak var cancelTripBtn: UIButton!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var arrivedBtn: UIButton!
    @IBOutlet weak var startTripBtn: UIButton!
    @IBOutlet weak var endTripBtn: UIButton!

    var viewAdditionalCharge = UIView()
    var lblAdditionalCharge = UILabel()
    var txtAdditionalCharge = UITextField()
    var lblNotMandotory = UILabel()
    var btnAdditionalCharge = UIButton()
    var btnSkipAdditionalCharge = UIButton()

    var additionalCharge = String()

    
    @IBOutlet weak var distanceTextLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var paymentTextLbl: UILabel!
    @IBOutlet weak var paymentTypeLbl: UILabel!
    @IBOutlet weak var navigationLbl: UILabel!
    @IBOutlet weak var BGViewForCustomer: UIView!
    @IBOutlet weak var CustomerImgView: UIImageView!
    @IBOutlet weak var customerNameLbl: UILabel!

    var btnNavigation = UIButton(type: .custom)

    var viewPickDropAddress = UIView()
    var pickImg = UIImageView()
    var dropImg = UIImageView()
    var lblPickAddress = UILabel()
    var lblDropAddress = UILabel()



    let languagePopUpView = PopUpTableView()
    
    let Pref = UserDefaults.standard
    
    let AppDelegates = UIApplication.shared.delegate as! AppDelegate
//    let HelperObject = HelperClass()
    var locationManager = CLLocationManager()
    let Drivermarker = GMSMarker()
    var degrees = CLHeading()
    var HeadingVal = Double()
    var DriversCurrentLatitude = Double()
    var DriversCurrentLongitude = Double()
    
//    var TripRequestID = String()
//    var tripIsDriverArrived = String()
//    var tripIsStarted = String()
//    var tripIsCompleted = String()

    let socket = SocketIOClient(socketURL: HelperClass.socketUrl)
    var JsonStringToServer = NSString()
    
    var Is_TripStarted = String()
    var ReceivedDistance = String()
//    var ProfilePicURL = String()


    var PickLat = String()
    var PickLong = String()
    var DropLat = String()
    var DropLong = String()

    var currentLoc = CLLocationCoordinate2D()
    var userPicLocLat = Double()
    var userPicLocLong = Double()
    var userDropLocLat = Double()
    var userDropLocLong = Double()

    var pickLocation = String()
    var dropLocation = String()

    var pref = UserDefaults.standard
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        AppLocationManager.shared.delegate = self
        print(HelperClass.shared.currentTripDetail)
        checkRequestinprogress()

        if #available(iOS 11.0, *) {
            self.languagePopUpView.langListTblView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }

        cancelTripBtn.titleLabel!.font = UIFont.appFont(ofSize: cancelTripBtn.titleLabel!.font!.pointSize)
        callBtn.titleLabel!.font = UIFont.appFont(ofSize: callBtn.titleLabel!.font!.pointSize)
        arrivedBtn.titleLabel!.font = UIFont.appFont(ofSize: arrivedBtn.titleLabel!.font!.pointSize)
        startTripBtn.titleLabel!.font = UIFont.appFont(ofSize: startTripBtn.titleLabel!.font!.pointSize)
        endTripBtn.titleLabel!.font = UIFont.appFont(ofSize: endTripBtn.titleLabel!.font!.pointSize)
        distanceTextLbl.font = UIFont.appFont(ofSize: distanceTextLbl.font!.pointSize)
        distanceLbl.font = UIFont.appFont(ofSize: distanceLbl.font!.pointSize)
        paymentTextLbl.font = UIFont.appFont(ofSize: paymentTextLbl.font!.pointSize)
        paymentTypeLbl.font = UIFont.appFont(ofSize: paymentTypeLbl.font!.pointSize)
        navigationLbl.font = UIFont.appFont(ofSize: navigationLbl.font!.pointSize)
        customerNameLbl.font = UIFont.appFont(ofSize: customerNameLbl.font!.pointSize)

//        AppDelegates.getUsers()

//        getTripRequestDetails()
//        getCurrentLocation()
        print("Data Received from Previous ViewController",self.CustomerDetailsDict,self.ReceivedRequestDetailsDict)
        Is_TripStarted = "NO"
        self.arrivedBtn.isHidden = false
        self.startTripBtn.isHidden = true
        self.endTripBtn.isHidden = true
        
        guard let tripDetails = HelperClass.shared.currentTripDetail else {
            return
        }
        
        if  tripDetails.requestIsDriverArrived == "1" &&
            tripDetails.requestIsTripStarted == "0"  {
            print("Driver started state")
            self.arrivedBtn.isHidden = true
            self.startTripBtn.isHidden = false
            self.endTripBtn.isHidden = true
            
            cancelTripBtn.isHidden = false
            callBtn.isHidden = false
            
        }
        else if tripDetails.requestIsDriverArrived == "1" &&
            tripDetails.requestIsTripStarted == "1"  {
            self.arrivedBtn.isHidden = true
            self.startTripBtn.isHidden = true
            self.endTripBtn.isHidden = false
            cancelTripBtn.isEnabled = false
            cancelTripBtn.isHidden = false
            callBtn.isHidden = false
        }
        

//        do {
//            // Set the map style by passing the URL of the local file.
//            if let styleURL = Bundle.main.url(forResource: "mapStyle", withExtension: "json") {
//                self.mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
//            } else {
//                print("Unable to find mapStyle.json")
//            }
//        } catch {
//            print("One or more of the map styles failed to load. \(error)")
//        }

//        if(self.Pref.value(forKey: "IsDriverArrived") as! String == "ArrivedYes")
//        {
//            self.arrivedBtn.isHidden = true
//            self.startTripBtn.isHidden = false
//
//            self.endTripBtn.isHidden = true
//        }
//        else if(self.Pref.value(forKey: "IsTripStarted") as! String == "TripStartedYes")
//        {
//            self.cancelTripBtn.isEnabled = false
//            self.cancelTripBtn.isUserInteractionEnabled = false
//            self.arrivedBtn.isHidden = true
//            self.startTripBtn.isHidden = true
//            self.endTripBtn.isHidden = false
//        }
//        else
//        {
//            Is_TripStarted = "NO"
//            self.arrivedBtn.isHidden = false
//            self.startTripBtn.isHidden = true
//            self.endTripBtn.isHidden = true
//        }
        
        
//        ProfilePicURL = self.LDBCustomerPicture
        self.customerNameLbl.text = HelperClass.shared.currentTripDetail.requestCustomerFirstName + " " + HelperClass.shared.currentTripDetail.requestCustomerLastName
        self.LoadProfilePicture()

        setUpViews()
        viewAdditionalCharge.isHidden = true

//        if let userPicLocLa = HelperClass.shared.receivedRequestData.value(forKey: "pick_latitude")as? Double {
//            userPicLocLat = userPicLocLa
//        }
//
//        if let userPicLocLon = HelperClass.shared.receivedRequestData.value(forKey: "pick_longitude")as? Double {
//            userPicLocLong = userPicLocLon
//        }

       
        let userPicLoc = CLLocationCoordinate2D(latitude: self.userPicLocLat, longitude: self.userPicLocLong)

        let markerPic = GMSMarker()
        markerPic.position = userPicLoc
        markerPic.icon = UIImage(named: "DropMarker")
        markerPic.map = self.mapView

        let markerDrop = GMSMarker()
        markerDrop.position = self.currentLoc
        markerDrop.icon = UIImage(named: "PickupMarker")
        markerDrop.map = self.mapView


        self.getPolylineRoute(from: self.currentLoc, to: userPicLoc)
    }
    
    func checkRequestinprogress()
    {
        if ConnectionCheck.isConnectedToNetwork()
        {
            // NVActivityIndicatorPresenter.sharedInstance.startAnimating(HelperClass.shared.activityPulseData)
            print("Connected")
            let url = HelperClass.BASEURL + HelperClass.getrequestinprogress
            var paramdict = Dictionary<String, Any>()
            
            paramdict["id"] = HelperClass.shared.userID
            paramdict["token"] = HelperClass.shared.userToken
            
            print("URL & Parameters for Checking current Request API =",url,paramdict)
            
            Alamofire.request(url, method:.post, parameters: paramdict, encoding: JSONEncoding.default, headers:HelperClass.Header)
                .responseJSON
                { response in
                   print(response.result.value)
                    if let result = response.result.value as? [String: AnyObject] {
                        if let status = result["success"] as? Bool, status {
                            if let request = result["request"] as? [String: AnyObject] {
                                if let piclat = request["pick_latitude"] as? Double, let piclong = request["pick_longitude"] as? Double {
                                    self.userPicLocLat = piclat
                                    self.userPicLocLong = piclong
                                }
                                if let droplat = request["drop_latitude"] as? Double, let droplong = request["drop_longitude"] as? Double {
                                    self.userDropLocLat = droplat
                                    self.userDropLocLong = droplong
                                }
                                if let picklocation = request["pick_location"] as? String, let droplocation = request["drop_location"] as? String {
                                    self.pickLocation = picklocation
                                    self.dropLocation = droplocation
                                }
                            }
                        } else {
                            print("error")
                        }
                    }
            }
        }
        else
        {
            print("disConnected")
            self.stopLoadingIndicator()
            self.showAlert("No Internet".localize(), message: "Please Check Your Internet Connection".localize())
        }
    }
    
    
    func setUpViews()
    {
        if #available(iOS 11.0, *) {
            self.top = self.view.safeAreaLayoutGuide.topAnchor
            self.bottom = self.view.safeAreaLayoutGuide.bottomAnchor
        } else {
            self.top = self.topLayoutGuide.bottomAnchor
            self.bottom = self.bottomLayoutGuide.topAnchor
        }
        mapView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BGMapView"] = mapView
        BGViewForCancelCallBtns.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BGViewForCancelCallBtns"] = BGViewForCancelCallBtns
        BGViewForDistanceAndData.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BGViewForDistanceAndData"] = BGViewForDistanceAndData
        BGViewForTripActionBtns.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BGViewForTripActionBtns"] = BGViewForTripActionBtns
        cancelTripBtn.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnCancelTrip"] = cancelTripBtn
        callBtn.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnCall"] = callBtn
        arrivedBtn.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnArrived"] = arrivedBtn
        startTripBtn.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnStartTrip"] = startTripBtn
        endTripBtn.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnEndTrip"] = endTripBtn
        distanceTextLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["LblDistanceText"] = distanceTextLbl
        distanceLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["LblDistance"] = distanceLbl
        paymentTextLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["LblPaymentText"] = paymentTextLbl
        paymentTypeLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["LblPaymentType"] = paymentTypeLbl
        navigationLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["LblNavigation"] = navigationLbl
        BGViewForCustomer.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BGViewForCustomer"] = BGViewForCustomer
        BGViewForCustomer.addShadow()
        CustomerImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["CustomerImgView"] = CustomerImgView
        customerNameLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["LblCustomerName"] = customerNameLbl

        BGViewForDistanceAndData.addSubview(btnNavigation)
        btnNavigation.setImage(UIImage(named: "navi"), for: .normal)
        btnNavigation.addTarget(self, action: #selector(openGoogleMap(_:)), for: .touchUpInside)
        btnNavigation.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["btnNavigation"] = btnNavigation


        viewPickDropAddress.backgroundColor = UIColor.white
        viewPickDropAddress.addShadow()
        viewPickDropAddress.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["viewPickDropAddress"] = viewPickDropAddress
        self.view.addSubview(viewPickDropAddress)

        if let pickLocation = HelperClass.shared.receivedRequestData.value(forKey: "pick_location")as? String {
            lblPickAddress.text = pickLocation
        }
        lblPickAddress.textColor = UIColor.black
        lblPickAddress.font = UIFont.appFont(ofSize: 12)
        self.lblPickAddress.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["lblPickAddress"] = lblPickAddress
        self.viewPickDropAddress.addSubview(lblPickAddress)

        if let dropLocation = HelperClass.shared.receivedRequestData.value(forKey: "drop_location")as? String {
            lblDropAddress.text = dropLocation
        }
        lblDropAddress.textColor = UIColor.black
        lblDropAddress.font = UIFont.appFont(ofSize: 12)
        lblDropAddress.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["lblDropAddress"] = lblDropAddress
        self.viewPickDropAddress.addSubview(lblDropAddress)

        pickImg.image = UIImage(named: "Ellipse")
        pickImg.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["pickImg"] = pickImg
        self.viewPickDropAddress.addSubview(pickImg)

        dropImg.image = UIImage(named: "Ellipsered")
        dropImg.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["dropImg"] = dropImg
        self.viewPickDropAddress.addSubview(dropImg)

        viewAdditionalCharge.backgroundColor = UIColor.white
        viewAdditionalCharge.addShadow()
        viewAdditionalCharge.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["viewAdditionalCharge"] = viewAdditionalCharge
        self.view.addSubview(viewAdditionalCharge)

        lblAdditionalCharge.text = "Additional Charges"
        lblAdditionalCharge.textColor = UIColor.black
        lblAdditionalCharge.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["lblAdditionalCharge"] = lblAdditionalCharge
        self.viewAdditionalCharge.addSubview(lblAdditionalCharge)

        txtAdditionalCharge.placeholder = "Enter amount"
        txtAdditionalCharge.keyboardType = .numberPad
        txtAdditionalCharge.addBorder(edges: .bottom)
        txtAdditionalCharge.addBorder(edges: .left)
        txtAdditionalCharge.addBorder(edges: .right)
        txtAdditionalCharge.addBorder(edges: .top)
        txtAdditionalCharge.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["txtAdditionalCharge"] = txtAdditionalCharge
        self.viewAdditionalCharge.addSubview(txtAdditionalCharge)

        lblNotMandotory.text = "charges not mandotory,if not skip it"
        lblNotMandotory.textColor = UIColor.gray
        lblNotMandotory.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["lblNotMandotory"] = lblNotMandotory
        self.viewAdditionalCharge.addSubview(lblNotMandotory)

        btnAdditionalCharge.setTitle("Apply", for: .normal)
        btnAdditionalCharge.setTitleColor(UIColor.white, for: .normal)
        btnAdditionalCharge.backgroundColor = UIColor.themeColor
        btnAdditionalCharge.addTarget(self, action: #selector(btnAdditionalChargePressed(_ :)), for: .touchUpInside)
        btnAdditionalCharge.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["btnAdditionalCharge"] = btnAdditionalCharge
        self.viewAdditionalCharge.addSubview(btnAdditionalCharge)

        btnSkipAdditionalCharge.setTitle("Skip", for: .normal)
        btnSkipAdditionalCharge.setTitleColor(UIColor.white, for: .normal)
        btnSkipAdditionalCharge.backgroundColor = UIColor.themeColor
        btnSkipAdditionalCharge.addTarget(self, action: #selector(btnSkipAdditionalChargePressed(_ :)), for: .touchUpInside)
        btnSkipAdditionalCharge.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["btnSkipAdditionalCharge"] = btnSkipAdditionalCharge
        self.viewAdditionalCharge.addSubview(btnSkipAdditionalCharge)


        languagePopUpView.translatesAutoresizingMaskIntoConstraints = false
        languagePopUpView.delegate = self
        layoutDic["languagePopUpView"] = languagePopUpView
        languagePopUpView.removeFromSuperview()
        self.navigationController?.view.addSubview(languagePopUpView)
        self.navigationController?.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[languagePopUpView]|", options: [], metrics: nil, views: layoutDic))
        self.navigationController?.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[languagePopUpView]|", options: [], metrics: nil, views: layoutDic))

        mapView.topAnchor.constraint(equalTo: self.top, constant: 0).isActive = true
        mapView.bottomAnchor.constraint(equalTo: self.bottom, constant: 0).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[BGMapView]|", options: [], metrics: nil, views: layoutDic))

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(8)-[BGViewForCustomer]-(8)-|", options: [], metrics: nil, views: layoutDic))
        BGViewForCustomer.topAnchor.constraint(equalTo: self.top, constant: 12).isActive = true
        BGViewForCustomer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(10)-[CustomerImgView(80)]-(10)-|", options: [], metrics: nil, views: layoutDic))
        BGViewForCustomer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(20)-[LblCustomerName(30)]", options: [], metrics: nil, views: layoutDic))
        BGViewForCustomer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(10)-[CustomerImgView(80)]-(10)-[LblCustomerName]-(10)-|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[BGViewForCustomer]-4-[viewPickDropAddress(60)]-(>=20)-[BGViewForCancelCallBtns(45)]-(5)-[BGViewForDistanceAndData(75)]-(5)-[BGViewForTripActionBtns(45)]", options: [.alignAllLeading,.alignAllTrailing], metrics: nil, views: layoutDic))
        BGViewForTripActionBtns.bottomAnchor.constraint(equalTo: self.bottom, constant: -8).isActive = true
        BGViewForCancelCallBtns.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(2)-[BtnCancelTrip]-(2)-[BtnCall(==BtnCancelTrip)]-(2)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        BGViewForCancelCallBtns.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(2)-[BtnCancelTrip]-(2)-|", options: [], metrics: nil, views: layoutDic))


        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(8)-[viewPickDropAddress]-(8)-|", options: [], metrics: nil, views: layoutDic))
      //  self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[BGViewForCustomer]-4-[viewPickDropAddress(60)]", options: [], metrics: nil, views: layoutDic))

        self.viewPickDropAddress.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(4)-[pickImg(10)]-(5)-[lblPickAddress]|", options: [], metrics: nil, views: layoutDic))
         self.viewPickDropAddress.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(4)-[dropImg(10)]-(5)-[lblDropAddress]|", options: [], metrics: nil, views: layoutDic))

        self.viewPickDropAddress.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[lblPickAddress(25)]-5-[lblDropAddress(25)]", options: [], metrics: nil, views: layoutDic))
       // self.viewPickDropAddress.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[pickImg(10)]-12-[dropImg(10)]", options: [], metrics: nil, views: layoutDic))

        self.viewPickDropAddress.addConstraint(NSLayoutConstraint(item: pickImg, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: lblPickAddress, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0))
        self.viewPickDropAddress.addConstraint(NSLayoutConstraint(item: dropImg, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: lblDropAddress, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0))




        BGViewForTripActionBtns.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(5)-[BtnArrived]-(5)-|", options: [], metrics: nil, views: layoutDic))
        BGViewForTripActionBtns.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(5)-[BtnArrived]-(5)-|", options: [], metrics: nil, views: layoutDic))
        BGViewForTripActionBtns.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(5)-[BtnStartTrip]-(5)-|", options: [], metrics: nil, views: layoutDic))
        BGViewForTripActionBtns.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(5)-[BtnStartTrip]-(5)-|", options: [], metrics: nil, views: layoutDic))
        BGViewForTripActionBtns.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(5)-[BtnEndTrip]-(5)-|", options: [], metrics: nil, views: layoutDic))
        BGViewForTripActionBtns.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(5)-[BtnEndTrip]-(5)-|", options: [], metrics: nil, views: layoutDic))

//Additional charrge view
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[viewAdditionalCharge]|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[viewAdditionalCharge(185)]|", options: [], metrics: nil, views: layoutDic))

        self.viewAdditionalCharge.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[lblAdditionalCharge]-8-|", options: [], metrics: nil, views: layoutDic))
        self.viewAdditionalCharge.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[txtAdditionalCharge]-8-|", options: [], metrics: nil, views: layoutDic))
        self.viewAdditionalCharge.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[lblNotMandotory]-8-|", options: [], metrics: nil, views: layoutDic))
        self.viewAdditionalCharge.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[lblAdditionalCharge(40)]-8-[txtAdditionalCharge(40)]-5-[lblNotMandotory(30)]", options: [], metrics: nil, views: layoutDic))
        self.viewAdditionalCharge.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[btnAdditionalCharge(40)]-8-|", options: [], metrics: nil, views: layoutDic))
        self.viewAdditionalCharge.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[btnSkipAdditionalCharge(40)]-8-|", options: [], metrics: nil, views: layoutDic))
        self.viewAdditionalCharge.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[btnAdditionalCharge]-4-[btnSkipAdditionalCharge(==btnAdditionalCharge)]-8-|", options: [], metrics: nil, views: layoutDic))


        BGViewForDistanceAndData.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(5)-[LblDistanceText(==LblNavigation)]-(5)-[LblPaymentText(==LblNavigation)]-(5)-[LblNavigation]-(5)-|", options: [], metrics: nil, views: layoutDic))
        BGViewForDistanceAndData.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(5)-[LblDistanceText(30)]-(5)-[LblDistance]-(5)-|", options: [.alignAllLeading,.alignAllTrailing], metrics: nil, views: layoutDic))
        BGViewForDistanceAndData.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(5)-[LblPaymentText(30)]-(5)-[LblPaymentType]-(5)-|", options: [.alignAllLeading,.alignAllTrailing], metrics: nil, views: layoutDic))
        BGViewForDistanceAndData.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(5)-[LblNavigation(30)]-(5)-[btnNavigation(30)]-(5)-|", options: [], metrics: nil, views: layoutDic))
        BGViewForDistanceAndData.addConstraint(NSLayoutConstraint(item: btnNavigation, attribute: .centerX, relatedBy: .equal, toItem: navigationLbl, attribute: .centerX, multiplier: 1, constant: 0))
        BGViewForDistanceAndData.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[btnNavigation(30)]", options: [], metrics: nil, views: layoutDic))


    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        AppSocketManager.shared.currentEmitType = .tripLocation
        AppSocketManager.shared.socketDelegate = self
//        updateStatus()
//        addHandlers()
//        self.socket.connect()
        //self.title = "App Name".localize().uppercased(with: Locale(identifier: HelperClass.currentAppLanguage))
//        if let title = HelperClass.shared.appName {
//            self.title = title
//        }
        self.title = "TapNgo Driver"
        customFormat()
//        if let pickLocation = HelperClass.shared.receivedRequestData.value(forKey: "pick_location")as? String {
//            lblPickAddress.text = pickLocation
//        }
//        if let dropLocation = HelperClass.shared.receivedRequestData.value(forKey: "drop_location")as? String {
//            lblDropAddress.text = dropLocation
//        }

        lblPickAddress.text = pref.object(forKey: "PickAddress") as? String
        lblDropAddress.text = pref.object(forKey: "DropAddress") as? String

        NotificationCenter.default.addObserver(self, selector: #selector(methodOfReceivedNotification(notification:)), name: Notification.Name("TripCancelledNotification"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name:Notification.Name("TripCancelledNotification"), object: nil)
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
            self.showToast("Trip Canceled".localize())
            HelperClass.shared.deleteTripDetails()
            self.removeHandlers()
            self.navigationController?.popViewController(animated: true)
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @objc func openGoogleMap(_ sender:UIButton) {

        if let dropArea = HelperClass.shared.receivedRequestData.value(forKey: "drop_location")as? String {
            self.dropLocation = dropArea
        }
        if let pickArea = HelperClass.shared.receivedRequestData.value(forKey: "pick_location")as? String {
            self.pickLocation = pickArea
        }

        let url = URL(string:"comgooglemaps://")!
        if UIApplication.shared.canOpenURL(url) {
            if self.arrivedBtn.isHidden {
                if let myLocation = AppLocationManager.shared.locationManager.location?.coordinate {
                    if let url = URL(string:"comgooglemaps://?saddr\(myLocation.latitude),\(myLocation.longitude)=&daddr=\(self.userDropLocLat),\(self.userDropLocLong)&directionsmode=driving") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            } else {
                if let myLocation = AppLocationManager.shared.locationManager.location?.coordinate {
                    if let url = URL(string:"comgooglemaps://?saddr\(myLocation.latitude),\(myLocation.longitude)=&daddr=\(self.userPicLocLat),\(self.userPicLocLong)&directionsmode=driving") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
        }
        else {
            if self.arrivedBtn.isHidden {
                if let myLocation = AppLocationManager.shared.locationManager.location?.coordinate  {
                    if let url = URL(string:"https://www.google.co.in/maps/dir/?saddr\(myLocation.latitude),\(myLocation.longitude)=&daddr=\(self.userDropLocLat),\(self.userDropLocLong)&directionsmode=driving") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            } else {
                if let myLocation = AppLocationManager.shared.locationManager.location?.coordinate {
                    if let url = URL(string:"https://www.google.co.in/maps/dir/?saddr\(myLocation.latitude),\(myLocation.longitude)=&daddr=\(self.userPicLocLat),\(self.userPicLocLong)&directionsmode=driving") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
        }

    }
    
    func getaddress(_ location:CLLocation,completion:@escaping (String)->Void)
    {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { placemarks, error in
            guard let addressDict = placemarks?[0].addressDictionary else {
                return
            }
            addressDict.forEach { print($0) }
            if let formattedAddress = addressDict["FormattedAddressLines"] as? [String]
            {
                print(formattedAddress.joined(separator: ", "))
                let address = formattedAddress.joined(separator: ", ")
                completion(address)
            }
        })
    }
    
//    func getCurrentLocation()
//    {
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.startUpdatingLocation()
//        locationManager.startUpdatingHeading()
//    }

//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
//    {
//        let userLocation = locations.last
//        _ = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
//
//        self.currentLoc = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
//
//        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude,
//                                              longitude: userLocation!.coordinate.longitude, zoom: 15.0)
//
//        mapView.camera=camera
//        mapView.isMyLocationEnabled = true
//
//        mapView.settings.myLocationButton = true
//
//        mapView.backgroundColor = UIColor.white
//        mapView.settings.compassButton = true;
//        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 10)
//
//        //      Creates a marker in the center of the map.
//        Drivermarker.position = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
//        Drivermarker.icon = UIImage(named: "pin_driver")
//        let Degreess = HeadingVal
//        Drivermarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
//        Drivermarker.rotation = Degreess
//        Drivermarker.map = mapView
//        locationManager.stopUpdatingLocation()
//        //        self.allowDeferredLocationUpdates(untilTraveled: 10.0, timeout: 10.0)
//        DriversCurrentLatitude = userLocation!.coordinate.latitude
//        DriversCurrentLongitude = userLocation!.coordinate.longitude
//        self.socket.emit("trip_location", self.JsonStringToServer)
//    }
    
//    func locationManager(_ manager: CLLocationManager,
//                         didUpdateHeading newHeading: CLHeading)
//    {
//
//        print("Heading =",newHeading)
//        degrees = newHeading
//        print("Exact Heads =",degrees.value(forKey: "magneticHeading") as! Double)
//        HeadingVal = degrees.value(forKey: "magneticHeading") as! Double
//
//        let jsonObject: NSMutableDictionary = NSMutableDictionary()
//
//        jsonObject.setValue(DriversCurrentLatitude, forKey: "lat")
//        jsonObject.setValue(DriversCurrentLongitude, forKey: "lng")
//        jsonObject.setValue(HeadingVal, forKey: "bearing")
//        jsonObject.setValue(HelperClass.shared.userID, forKey: "id")
//        jsonObject.setValue(HelperClass.shared.currentTripDetail.acceptedRequestId, forKey: "request_id")
//        jsonObject.setValue(HelperClass.shared.currentTripDetail.requestCustomerId, forKey: "user_id")
//        if(self.Is_TripStarted == "NO")
//        {
//            jsonObject.setValue("0", forKey: "trip_start")
//        }
//        else if(self.Is_TripStarted == "YES")
//        {
//            jsonObject.setValue("1", forKey: "trip_start")
//        }
//
//        let jsonData: NSData
//
//        do
//        {
//            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
//            JsonStringToServer = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String as String as NSString
//            print("json string = \(JsonStringToServer)")
//
//        }
//        catch _
//        {
//
//            print ("JSON Failure")
//        }
//
//    }
    
    func updateStatus() {

        lbl = UITextView(frame: CGRect(x: UIScreen.main.bounds.width/4, y: 20, width: UIScreen.main.bounds.width/2, height: 120))
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
            self.lbl.isHidden = false
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

    func addHandlers()
    {
        socket.nsp = "/driver/home"
        self.socket.on("connect") {data, ack in
            print("socket connected")
           // self.showToast("Socket Connected")
            
            self.socket.emit("start_connect", HelperClass.shared.userID)
            self.socket.emit("trip_location", self.JsonStringToServer)
            
            self.socket.on("trip_status_driver")
            {
                data, ack in
                print("Received Distance Update from Socket! \(data[0])")
                let JSON = data[0] as! NSDictionary
                print("Received Distance Update",JSON)
                self.lbl.text = "\(JSON)"
                let theSuccess = (JSON.value(forKey: "success") as! Bool)
                if(theSuccess == true)
                {
                    if let recievedDistance =  JSON.value(forKey: "distance") as? Double {
                        self.ReceivedDistance = String(format: "%.2f", recievedDistance)
                    }
                   // self.ReceivedDistance = String(format: "%.2f", JSON.value(forKey: "distance") as! Double)
                    self.distanceLbl.text! = self.ReceivedDistance
//                    self.HelperObject.ReceivedRequestData = JSON.value(forKey: "request") as! NSDictionary
                }
            }
            self.socket.on("cancelled_request")
            {
                data, ack in
                print("Received Distance Update from Socket! \(data[0])")

            }
            self.socket.on("request_handler"){
                data, ack in
                print("Cancelled by driver \(data[0])")
                let JSON = data[0] as! NSDictionary
                print(JSON)
                let reqid=JSON.value(forKey: "is_cancelled") as! NSInteger
                if(reqid==1) {

                    self.navigationController?.popToRootViewController(animated: true)

                }
            }
        }
      
    }
    func removeHandlers()
    {
        locationManager.delegate = nil
        socket.nsp = "/driver/home"
        self.socket.off("connect")
        self.socket.off("trip_status_driver")
        //AppLocationManager.shared.delegate = nil
        AppSocketManager.shared.socketDelegate = nil
        AppSocketManager.shared.currentEmitType = .none
    }


    @IBAction func CancelTripBtn(_ sender: Any)
    {
       // self.APIToCancelTheTrip()

        if self.languagePopUpView.optionsList == nil {
            self.getCancelReasonList()
        } else {
            self.languagePopUpView.isHidden = false
        }
    }
    
    
    @IBAction func CallBtn(_ sender: Any)
    {
        self.MakeAphoneCall(phoneNum: HelperClass.shared.currentTripDetail.requestCustomerPhoneNumber)
    }
    
    
    @IBAction func ArrivedToPickupBtn(_ sender: Any)
    {
        print("Arrived Btn Clicked")
        self.arrivedBtn.isHidden = true
        self.startTripBtn.isHidden = false
        self.endTripBtn.isHidden = true
        DriverArrivedToPickUpLocationAPI()
    }
    
    
    @IBAction func StartTripBtn(_ sender: Any)
    {
        print("Start Trip Btn Clicked")
        Is_TripStarted = "YES"
        self.cancelTripBtn.isEnabled = false
        self.cancelTripBtn.isUserInteractionEnabled = false
        self.arrivedBtn.isHidden = true
        self.startTripBtn.isHidden = true
        self.endTripBtn.isHidden = false
        StartTheTripAPI()
    }

    @objc func btnAdditionalChargePressed(_ sender: UIButton){

        if(txtAdditionalCharge.text == "") {
            self.additionalCharge = "0"
        } else {
            self.additionalCharge = txtAdditionalCharge.text!
        }

        viewAdditionalCharge.isHidden = true

    }

    @objc func btnSkipAdditionalChargePressed(_ sender: UIButton){


        self.additionalCharge = "0"

        viewAdditionalCharge.isHidden = true

    }


    
    
    @IBAction func EndTripBtn(_ sender: UIButton)
    {

        if(self.additionalCharge == "") {
            viewAdditionalCharge.isHidden = false
        } else {
            print("End Trip Btn Clicked")
            EndTheTripAPI()
        }

//        sender.tag += 1
//        //if sender.tag > 1 { sender.tag = 0 }
//        switch sender.tag {
//        case 1:
//            viewAdditionalCharge.isHidden = false
//
//        case 2:
//
//            print("End Trip Btn Clicked")
//            EndTheTripAPI()
//
//        default:
//            break
//        }


    }
    
    
    func customFormat()
    {
//        self.navigationItem.hidesBackButton = true
        self.CustomerImgView.layer.cornerRadius = self.CustomerImgView.frame.height/2
        self.CustomerImgView.clipsToBounds = true
        
    }
    
    func MakeAphoneCall(phoneNum: String)
    {
        if let url = URL(string: "tel://\(phoneNum)")
        {
            if #available(iOS 10, *)
            {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            else
            {
                UIApplication.shared.openURL(url as URL)
            }
        }
    }


    func APIToCancelTheTrip(_ reasonId:Int)
    {
        if ConnectionCheck.isConnectedToNetwork()
        {
            self.showLoadingIndicator()
            print("Connected")
            let url = HelperClass.BASEURL + HelperClass.CancelTripURL
            var paramdict = Dictionary<String, Any>()
            
            paramdict["id"] = HelperClass.shared.userID
            paramdict["token"] = HelperClass.shared.userToken
            paramdict["request_id"] = HelperClass.shared.currentTripDetail.acceptedRequestId
                //HelperObject.ReceivedRequestData.value(forKey: "id");
            paramdict["reason"] = reasonId  //"Already in Trip";
            
            print("URL & Parameters for Cancel Trip API =",url,paramdict)
            
            Alamofire.request(url, method:.post, parameters: paramdict, encoding: JSONEncoding.default, headers:HelperClass.Header)
                .responseJSON
                { response in
                    print(response.result.value)
                    if case .failure(let error) = response.result
                    {
                        print(error.localizedDescription)
                    }
                    else if case .success = response.result
                    {
                        if let JSON = response.result.value as? [String:AnyObject], let status = JSON["success"] as? Bool
                        {
                            if status
                            {
                                self.showToast("Trip Cancelled".localize())
                                HelperClass.shared.deleteTripDetails()
                                self.removeHandlers()
                                self.navigationController?.popViewController(animated: true)
                            }
                            else
                            {
                                if let errcode = JSON["error_code"] as? String, errcode == "808" {
                                    
                                    self.showToast(JSON["error_message"] as! String)
                                    HelperClass.shared.deleteTripDetails()
                                    self.removeHandlers()
                                    self.navigationController?.popViewController(animated: true)
                                } else {
                                    print(JSON["error_message"] as! String)
                                    self.showAlert("Alert".localize(), message: JSON["error_message"] as! String)
                                }
                                
                            }
                        }
                    }
                    self.stopLoadingIndicator()
            }
            
        }
        else
        {
            print("disConnected")
            
            self.showAlert("No Internet".localize(), message: "Please Check Your Internet Connection".localize())
        }
        
    }

    func getCancelReasonList() {
        if ConnectionCheck.isConnectedToNetwork()
        {

            let url = HelperClass.BASEURL + HelperClass.cancelReasonList

            print("URL for cancelReasonList  = ",url)
            let paramdict = ["id":HelperClass.shared.userID,
                             "token":HelperClass.shared.userToken,
                             "user_type":"2"]
            print("param for cancelReasonList  = ",paramdict)

            Alamofire.request(url, method:.post, parameters: paramdict, encoding: JSONEncoding.default, headers:HelperClass.Header)
                .responseJSON
                { response in

                    if case .failure(let error) = response.result
                    {
                        print(error.localizedDescription)
                    }
                    else if case .success = response.result
                    {
                        print(response.result.value as Any)
                        if let JSON = response.result.value as? [String:AnyObject], let status = JSON["success"] as? Bool
                        {
                            if status
                            {
                                if let reasons = JSON["reason"] as? [[String:AnyObject]] {
                                    self.languagePopUpView.optionsList = reasons.map({
                                        let feeName = $0["cancellation_fee_name"] as? String
                                        let identifier = $0["id"] as? Int
                                        return (text: feeName!,identifier:String(identifier!))
                                    })

                                    self.languagePopUpView.tableTitle = "Cancel Trip".localize().uppercased(with: Locale(identifier: HelperClass.currentAppLanguage))
                                    if self.languagePopUpView.optionsList!.isEmpty {
                                        self.showToast("text_reason_na".localize())
                                    } else {
                                        self.languagePopUpView.isHidden = false
                                    }
                                }
                            }
                            else
                            {
                                if let errcodestr = JSON["error_code"] as? String, errcodestr == "606" {
                                    HelperClass.shared.deleteUserDetails()
                                } else {
                                    if let errorMessage = JSON["error_message"] as? String {
                                        print(errorMessage)
                                        self.showAlert("text_Alert".localize(), message: errorMessage)
                                    }
                                }
                            }
                        }
                    }
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }
        }
        else
        {
            print("disConnected")
            self.showAlert("txt_NoInternet_title".localize(), message: "txt_NoInternet".localize())
        }
    }
    
    func DriverArrivedToPickUpLocationAPI()
    {
        if ConnectionCheck.isConnectedToNetwork()
        {
            self.showLoadingIndicator()
            print("Connected")
            let url = HelperClass.BASEURL + HelperClass.DriverArrivedToPlaceURL
            var paramdict = Dictionary<String, Any>()
            
            paramdict["id"] = HelperClass.shared.userID
            paramdict["token"] = HelperClass.shared.userToken
            paramdict["request_id"] = HelperClass.shared.currentTripDetail.acceptedRequestId
            
            print("URL & Parameters for Driver Arrived API =",url,paramdict)
            
            Alamofire.request(url, method:.post, parameters: paramdict, encoding: JSONEncoding.default, headers:HelperClass.Header)
                .responseJSON
                { response in

                    if case .failure(let error) = response.result
                    {
                        print(error.localizedDescription)
                    }
                    else if case .success = response.result
                    {
                        print(response.result.value)
                        if let JSON = response.result.value as? [String:AnyObject], let status = JSON["success"] as? Bool
                        {
                            if status
                            {
                                self.showToast("Driver Arrived".localize())
                                self.Pref.set("ArrivedYes", forKey: "IsDriverArrived")
                                self.Pref.synchronize()
                                HelperClass.shared.updateTripDetails(["is_driver_arrived" : 1 as AnyObject])
                               // APIHelper.shared.updateTripDetails(["is_driver_arrived" : 1 as AnyObject])

//                                if let userPicLocLa = HelperClass.shared.receivedRequestData.value(forKey: "pick_latitude")as? Double {
//                                    self.userPicLocLat = userPicLocLa
//                                }
//                                if let userPicLocLon = HelperClass.shared.receivedRequestData.value(forKey: "pick_longitude")as? Double {
//                                    self.userPicLocLong = userPicLocLon
//                                }
//
                                guard let myLocation = AppLocationManager.shared.locationManager.location?.coordinate else{
                                    return
                                }
                                
                                let userPicLoc = CLLocationCoordinate2D(latitude: myLocation.latitude, longitude: myLocation.longitude)

//                                if let userDropLocLa = HelperClass.shared.receivedRequestData.value(forKey: "drop_latitude")as? Double {
//                                    self.userDropLocLat = userDropLocLa
//                                }
//                                if let userDropLocLon = HelperClass.shared.receivedRequestData.value(forKey: "drop_longitude")as? Double {
//                                    self.userDropLocLong = userDropLocLon
//                                }
//
                                let userDropLoc = CLLocationCoordinate2D(latitude: self.userDropLocLat, longitude: self.userDropLocLong)


                                let markerPic = GMSMarker()
                                markerPic.position = userPicLoc
                                markerPic.icon = UIImage(named: "PickupMarker")
                                markerPic.map = self.mapView

                                let markerDrop = GMSMarker()
                                markerDrop.position = userDropLoc
                                markerDrop.icon = UIImage(named: "DropMarker")
                                markerDrop.map = self.mapView


                                self.getPolylineRoute(from: userPicLoc, to: userDropLoc)

                            }
                            else
                            {
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
            
            self.showAlert("No Internet".localize(), message: "Please Check Your Internet Connection".localize())
        }

    }
    
    func StartTheTripAPI()
    {
        if ConnectionCheck.isConnectedToNetwork()
        {
            
            guard let myLocation = AppLocationManager.shared.locationManager.location?.coordinate else{
                return
            }

            self.showLoadingIndicator()
            print("Connected")
            let url = HelperClass.BASEURL + HelperClass.StartTheTripURL
            var paramdict = Dictionary<String, Any>()
            
            paramdict["id"] = HelperClass.shared.userID
            paramdict["token"] = HelperClass.shared.userToken
            paramdict["request_id"] = HelperClass.shared.currentTripDetail.acceptedRequestId
            paramdict["platitude"] = myLocation.latitude//HelperClass.shared.receivedRequestData.value(forKey: "pick_latitude")as? Double
            paramdict["plongitude"] = myLocation.longitude//self.userPicLocLong//HelperClass.shared.receivedRequestData.value(forKey: "pick_longitude")as? Double
            paramdict["plocation"] = self.pickLocation//HelperClass.shared.receivedRequestData.value(forKey: "pick_location")as? String
            
            let coord = CLLocation(latitude: myLocation.latitude, longitude: myLocation.longitude)
            
            self.getaddress(coord) { address in
            //    paramdict["plocation"] = address
            }
            print(HelperClass.shared.currentTripDetail.requestPickupLocation)
            
            print("URL & Parameters for Start Trip API =",url,paramdict)
            
            Alamofire.request(url, method:.post, parameters: paramdict, encoding: JSONEncoding.default, headers:HelperClass.Header)
                .responseJSON
                { response in

                    if case .failure(let error) = response.result
                    {
                        print(error.localizedDescription)
                    }
                    else if case .success = response.result
                    {
                        print(response.result.value as Any)
                        if let JSON = response.result.value as? [String:AnyObject], let status = JSON["success"] as? Bool
                        {
                            if status
                            {
                                self.showToast("Trip Started".localize())
                                self.cancelTripBtn.isEnabled = false
                                HelperClass.shared.updateTripDetails(["is_trip_start":1 as AnyObject])

//                                if let userPicLocLa = HelperClass.shared.receivedRequestData.value(forKey: "pick_latitude")as? Double {
//                                    self.userPicLocLat = userPicLocLa
//                                }
//                                if let userPicLocLon = HelperClass.shared.receivedRequestData.value(forKey: "pick_longitude")as? Double {
//                                    self.userPicLocLong = userPicLocLon
//                                }
                               

                                let userPicLoc = CLLocationCoordinate2D(latitude: myLocation.latitude, longitude: myLocation.longitude)

//                                if let userDropLocLa = HelperClass.shared.receivedRequestData.value(forKey: "drop_latitude")as? Double {
//                                    self.userDropLocLat = userDropLocLa
//                                }
//                                if let userDropLocLon = HelperClass.shared.receivedRequestData.value(forKey: "drop_longitude")as? Double {
//                                    self.userDropLocLong = userDropLocLon
//                                }
//
                                let userDropLoc = CLLocationCoordinate2D(latitude: self.userDropLocLat, longitude: self.userDropLocLong)


                                let markerPic = GMSMarker()
                                markerPic.position = userPicLoc
                                markerPic.icon = UIImage(named: "PickupMarker")
                                markerPic.map = self.mapView

                                let markerDrop = GMSMarker()
                                markerDrop.position = userDropLoc
                                markerDrop.icon = UIImage(named: "DropMarker")
                                markerDrop.map = self.mapView


                                self.getPolylineRoute(from: userPicLoc, to: userDropLoc)
                            }
                            else
                            {
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
            
            self.showAlert("No Internet".localize(), message: "Please Check Your Internet Connection".localize())
        }

    }

    func EndTheTripAPI()
    {
        if ConnectionCheck.isConnectedToNetwork()
        {
            self.showLoadingIndicator()
            print("Connected")
            let url = HelperClass.BASEURL + HelperClass.EndTheTripURL
            var paramdict = Dictionary<String, Any>()
            
            paramdict["id"] = HelperClass.shared.userID
            paramdict["token"] = HelperClass.shared.userToken
            paramdict["request_id"] = HelperClass.shared.currentTripDetail.acceptedRequestId
            paramdict["distance"] = "0"
            paramdict["before_waiting_time"] = "0"
            paramdict["after_waiting_time"] = "0"
            paramdict["extra_amount"] = self.additionalCharge
            paramdict["dlatitude"] = self.userDropLocLat//HelperClass.shared.receivedRequestData.value(forKey: "drop_latitude")as? Double
            paramdict["dlongitude"] = self.userDropLocLong//HelperClass.shared.receivedRequestData.value(forKey: "drop_longitude")as? Double
           // paramdict["dlocation"] = HelperClass.shared.receivedRequestData.value(forKey: "drop_location")as? String
            
            let coord = CLLocation(latitude: self.userDropLocLat, longitude: self.userDropLocLong)
            
            self.getaddress(coord) { address in
                 paramdict["dlocation"] = address
            }
            
            print("URL & Parameters for End Trip API =",url,paramdict)
            
            Alamofire.request(url, method:.post, parameters: paramdict, encoding: JSONEncoding.default, headers:HelperClass.Header)
                .responseJSON
                { response in

                    if case .failure(let error) = response.result
                    {
                        print(error.localizedDescription)
                    }
                    else if case .success = response.result
                    {
                        if let JSON = response.result.value as? [String:AnyObject], let status = JSON["success"] as? Bool
                        {
                            if status
                            {
                                //Trip Details are needed for feedback VC. Dont delete trip details here
//                                HelperClass.shared.deleteTripDetails()
                                HelperClass.shared.completedTripDataDict = JSON["request"] as! [String:AnyObject]
                                HelperClass.shared.invoiceDataDict = HelperClass.shared.completedTripDataDict["bill"] as! [String:AnyObject]
                                self.showToast("Trip Completed".localize())
                                var newTripDetails = JSON["request"] as! [String:AnyObject]
                                newTripDetails["is_driver_arrived"] = "1" as AnyObject
                                newTripDetails["is_trip_start"] = "1" as AnyObject
                                newTripDetails["is_completed"] = "1" as AnyObject
                                HelperClass.shared.updateTripDetails(newTripDetails)
                                self.arrivedMapVCToTripInvoiceVC()
//                                self.StoreCompletedTripBillDetails(Request_Local_Details: JSON["request"] as! [String:AnyObject])
                            }
                            else
                            {
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
            self.showAlert("No Internet".localize(), message: "Please Check Your Internet Connection".localize())
        }

    }
    
    func ReviewAndRatetheCustomerAPI()
    {
        if ConnectionCheck.isConnectedToNetwork()
        {
            self.showLoadingIndicator()
            print("Connected")
            let url = HelperClass.BASEURL + HelperClass.GiveRatingURL
            var paramdict = Dictionary<String, Any>()
            
            paramdict["id"] = HelperClass.shared.userID
            paramdict["token"] = HelperClass.shared.userToken
            paramdict["request_id"] = HelperClass.shared.currentTripDetail.acceptedRequestId
            paramdict["comment"] = "Testing In Progress"
            paramdict["rating"] = "5"
            
            print("URL & Parameters for Review & Rating API =",url,paramdict)
            
            Alamofire.request(url, method:.post, parameters: paramdict, encoding: JSONEncoding.default, headers:HelperClass.Header)
                .responseJSON
                { response in

                    if case .failure(let error) = response.result
                    {
                        print(error.localizedDescription)
                    }
                    else if case .success = response.result
                    {
                        if let JSON = response.result.value as? [String:AnyObject], let status = JSON["success"] as? Bool
                        {
                            if status
                            {
                                self.showToast("Review & Rating Completed".localize())
                                self.arrivedMapVCToTripInvoiceVC()
                            }
                            else
                            {
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
            self.showAlert("No Internet".localize(), message: "Please Check Your Internet Connection".localize())
        }

    }
    
    func LoadProfilePicture()
    {
//        if(ProfilePicURL.count>0)
//        {
//            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
//            indicator.center = self.CustomerImgView.center
//            view.addSubview(indicator)
//            indicator.startAnimating()
//
//            let profilePictureURL = URL(string: ProfilePicURL)!
//            let session = URLSession(configuration: .default)
//            let downloadPicTask = session.dataTask(with: profilePictureURL) { (data, response, error) in
//                // The download has finished.
//                if let e = error
//                {
//                    print("Error downloading cat picture: \(e)")
//                }
//                else
//                {
//                    // No errors found.
//                    // It would be weird if we didn't have a response, so check for that too.
//                    if let res = response as? HTTPURLResponse
//                    {
//                        print("Downloaded cat picture with response code \(res.statusCode)")
//                        if let imageData = data
//                        {
//                            DispatchQueue.main.sync
//                                {
//                                    indicator.stopAnimating()
//                                    let image = UIImage(data: imageData)
//                                    self.CustomerImgView.image=image
//                            }
//                        }
//                        else
//                        {
//                            indicator.stopAnimating()
//                            self..showToast("Couldn't get image: Image is nil".localize())
//
//                        }
//                    }
//                    else
//                    {
//                        indicator.stopAnimating()
//                        self..showToast("Couldn't get response code for some reason".localize())
//                    }
//                }
//            }
//            downloadPicTask.resume()
//        }

        if let strngPrfile = HelperClass.shared.currentTripDetail.requestCustomerProfilePicture ,let url = URL(string: strngPrfile)
        {
            let resource = ImageResource(downloadURL: url)
            self.CustomerImgView.kf.indicatorType = .activity
            self.CustomerImgView.kf.setImage(with: resource)
        }
        else
        {
            self.CustomerImgView.image=UIImage(named: "sidemenuprofile")
        }
    }
    
//    func getContext () -> NSManagedObjectContext
//    {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        return appDelegate.persistentContainer.viewContext
//    }
    
    func StoreCompletedTripBillDetails(Request_Local_Details: [String:AnyObject])
    {
        let context = HelperClass.shared.persistentContainer.viewContext
        print("Request Local Dictionary is: ",Request_Local_Details)
        
        var LBCustomerDict = [String:AnyObject]()
        LBCustomerDict = Request_Local_Details["user"] as! [String:AnyObject]
        

        var LBInvoiceDict = [String:AnyObject]()
        LBInvoiceDict = Request_Local_Details["bill"] as! [String:AnyObject]
        
        let Accepted_Req_IDString = String(describing: (Request_Local_Details["id"] as! NSNumber))
        print("My New ID",Accepted_Req_IDString)
        
        let TripTotalDistance = Request_Local_Details["distance"] as! String
        print("My New ID",TripTotalDistance)
        
        let TripTotalTime = String(describing: (Request_Local_Details["time"] as! NSNumber))
        print("My New ID",TripTotalTime)
        

        let Request_LocalDB_Data = Request_AcceptedData(context:HelperClass.shared.persistentContainer.viewContext)
        Request_LocalDB_Data.accepted_request_id = Accepted_Req_IDString
        Request_LocalDB_Data.request_is_driver_arrived = "1"
        Request_LocalDB_Data.request_is_trip_started = "1"
        Request_LocalDB_Data.request_is_trip_completed = "1"
        Request_LocalDB_Data.request_customer_email = LBCustomerDict["email"] as? String
        Request_LocalDB_Data.request_customer_id = String(describing: (LBCustomerDict["id"] as! NSNumber))
        Request_LocalDB_Data.request_customer_review = LBCustomerDict["review"] as? String
        Request_LocalDB_Data.request_customer_profilepicture = LBCustomerDict["profile_pic"] as? String
        Request_LocalDB_Data.request_customer_phonenumber = LBCustomerDict["phone_number"] as? String
        Request_LocalDB_Data.request_customer_firstname = LBCustomerDict["firstname"] as? String
        Request_LocalDB_Data.request_customer_lastname = LBCustomerDict["lastname"] as? String
        
        Request_LocalDB_Data.bill_timecost = LBInvoiceDict["time_price"] as? String
        Request_LocalDB_Data.bill_baseprice = LBInvoiceDict["base_price"] as? String
        Request_LocalDB_Data.bill_promobonus = LBInvoiceDict["promo_amount"] as? String
        Request_LocalDB_Data.bill_servicefee = LBInvoiceDict["service_fee"] as? String
        Request_LocalDB_Data.bill_servicetax = LBInvoiceDict["service_tax"] as? String
        Request_LocalDB_Data.bill_totalamount = LBInvoiceDict["total"] as? String
        Request_LocalDB_Data.bill_waitingcost = LBInvoiceDict["waiting_price"] as? String
        Request_LocalDB_Data.bill_basedistance = LBInvoiceDict["base_distance"] as? String
        Request_LocalDB_Data.bill_distancecost = LBInvoiceDict["distance_price"] as? String
        Request_LocalDB_Data.bill_driverpayment = LBInvoiceDict["driver_amount"] as? String
        Request_LocalDB_Data.bill_referralbonus = LBInvoiceDict["referral_amount"] as? String
        Request_LocalDB_Data.bill_wallet_amount = LBInvoiceDict["wallet_amount"] as? String
        Request_LocalDB_Data.bill_price_per_time = LBInvoiceDict["price_per_time"] as? String
        Request_LocalDB_Data.bill_price_per_distance = LBInvoiceDict["price_per_distance"] as? String
        Request_LocalDB_Data.bill_servicetax_percent = LBInvoiceDict["service_tax_percentage"] as? String
        Request_LocalDB_Data.bill_currency = LBInvoiceDict["currency"] as? String
        
        
        
        //save the object
        do
        {
            try context.save()
            print("saved!")
            self.arrivedMapVCToTripInvoiceVC()
//            self.performSegue(withIdentifier: "ArrivedMapVCToTripInvoiceVC", sender: self)

        }
        catch let error as NSError
        {
            print("Could not save \(error), \(error.userInfo)")
        }
        catch
        {
            
        }
        
    }

    
//    func getTripRequestDetails()
//    {
//        //create a fetch request, telling it about the entity
//        let fetchRequest: NSFetchRequest<Request_AcceptedData> = Request_AcceptedData.fetchRequest()
//
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
//
//                print("\(String(describing: trip.value(forKey: "accepted_request_id")))")
////                TripRequestID = trip.value(forKey: "accepted_request_id") as! String
////                tripIsDriverArrived = trip.value(forKey: "request_is_driver_arrived") as! String
////                tripIsStarted = trip.value(forKey: "request_is_trip_started") as! String
////                tripIsCompleted = trip.value(forKey: "request_is_trip_completed") as! String
//
////                LDBCustomerFName = trip.value(forKey: "request_customer_firstname")as! String
////                LDBCustomerLName = trip.value(forKey: "request_customer_lastname")as! String
////                LDBCustomerID =  trip.value(forKey: "request_customer_id")as! String
////                LDBCustomerEmail =  trip.value(forKey: "request_customer_email")as! String
////                LDBCustomerPhone =  trip.value(forKey: "request_customer_phonenumber")as! String
////                LDBCustomerPicture =  trip.value(forKey: "request_customer_profilepicture")as! String
////                LDBCustomerReview =  trip.value(forKey: "request_customer_review") as? String ?? ""
//
//                print("User ID =",TripRequestID)
//            }
//        }
//        catch
//        {
//            print("Error with request: \(error)")
//        }
//
//    }


    // Pass your source and destination coordinates in this method.

    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D)
    {
        //let config = URLSessionConfiguration.default
        //        let session = URLSession(configuration: config)
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=AIzaSyCkNVoPSgCiH2WYZBv64DEctInk1BbXCmI")!
        print(url)
        let urlReq = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlReq) { (data, response, error) in

            if let myData = data

            {
                do

                {
                    guard let jsondata = try JSONSerialization.jsonObject(with: (myData as? Data)!, options: .mutableLeaves) as? [String: AnyObject] else {
                        return
                    }

                    print("json data is----->",jsondata)

                    if let preRoutes = jsondata["routes"] as? [[String:AnyObject]] ,let routes = preRoutes.first as? [String:AnyObject] ,

                        let routeOverviewPolyline = routes["overview_polyline"] as? [String:AnyObject],
                        let polyString = routeOverviewPolyline["points"] as? String {
                        print(polyString)
                        DispatchQueue.main.async {
                            let path = GMSPath(fromEncodedPath: polyString)
                            let polyline = GMSPolyline(path: path)
                            polyline.strokeWidth = 5.0
                            polyline.strokeColor = UIColor.themeColor
                            polyline.map = self.mapView
                        }
                    }

                }
                catch
                {
                    print("error")
                }

            }

        };task.resume()

    }

//    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D)
//    {
//
//        let config = URLSessionConfiguration.default
//        let session = URLSession(configuration: config)
//
//        let url = URL(string: "http://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving")!
//
//        let task = session.dataTask(with: url, completionHandler:
//        {
//            (data, response, error) in
//            if error != nil
//            {
//                print(error!.localizedDescription)
//            }
//            else
//            {
//                do
//                {
//                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
//
//                        let routes = json["routes"] as? [Any]
//                        let overview_polyline = routes?[0] as?[String:Any]
//                        let polyString = overview_polyline?["points"] as?String
//
//                        //Call this method to draw path on map
//                        self.showPath(polyStr: polyString!)
//                    }
//
//                }catch{
//                    print("error in JSONSerialization")
//                }
//            }
//        })
//        task.resume()
//    }

    func showPath(polyStr :String)
    {
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.map = mapView // Your map view
    }
    
    func showLoadingIndicator()
    {
        NVActivityIndicatorView.DEFAULT_TYPE = .ballClipRotatePulse
        NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE = CGSize(width: 180, height: 180)
        NVActivityIndicatorView.DEFAULT_COLOR = UIColor.lightGray
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ArrivedMapVC.activityData)
    }
    
    func stopLoadingIndicator()
    {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }

 
    func arrivedMapVCToTripInvoiceVC()
    {
        self.removeHandlers()
        let tripInvoiceVC = self.storyboard?.instantiateViewController(withIdentifier: "TripInvoiceVC") as! TripInvoiceVC
        tripInvoiceVC.CompletedTripDetailsDict = HelperClass.shared.completedTripDataDict
        tripInvoiceVC.InvoiceDetailsDict = HelperClass.shared.invoiceDataDict
        tripInvoiceVC.CustomersDetailsDict = self.CustomerDetailsDict
        tripInvoiceVC.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(tripInvoiceVC, animated: true)
    }

}

extension ArrivedMapVC:PopUpTableViewDelegate
{
    func popUpTableView(_ popUpTableView: PopUpTableView, didSelectOption option: Option, atIndex index: Int) {
        self.APIToCancelTheTrip(Int(option.identifier)!)
    }
}
extension ArrivedMapVC: AppLocationManagerDelegate {
    func appLocationManager(didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        _ = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        
        self.currentLoc = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        
        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude,
                                              longitude: userLocation!.coordinate.longitude, zoom: 15.0)
        
        mapView.camera=camera
        mapView.isMyLocationEnabled = true
        
        mapView.settings.myLocationButton = true
        
        mapView.backgroundColor = UIColor.white
        mapView.settings.compassButton = true;
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 10)
        
        //      Creates a marker in the center of the map.
        Drivermarker.position = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        Drivermarker.icon = UIImage(named: "pin_driver")
        let Degreess = HeadingVal
        Drivermarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        Drivermarker.rotation = Degreess
        Drivermarker.map = mapView
        //AppLocationManager.shared.stopTracking()
        //locationManager.stopUpdatingLocation()
        
        DriversCurrentLatitude = userLocation!.coordinate.latitude
        DriversCurrentLongitude = userLocation!.coordinate.longitude
//        print("trip location = \(JsonStringToServer)")
//        self.socket.emit("trip_location", self.JsonStringToServer)
    }
    
    func appLocationManager(didUpdateHeading newHeading: CLHeading) {
        print("Heading =",newHeading)
        degrees = newHeading
        print("Exact Heads =",degrees.value(forKey: "magneticHeading") as! Double)
        HeadingVal = degrees.value(forKey: "magneticHeading") as! Double
        
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        
        jsonObject.setValue(DriversCurrentLatitude, forKey: "lat")
        jsonObject.setValue(DriversCurrentLongitude, forKey: "lng")
        jsonObject.setValue(HeadingVal, forKey: "bearing")
        jsonObject.setValue(HelperClass.shared.userID, forKey: "id")
        jsonObject.setValue(HelperClass.shared.currentTripDetail.acceptedRequestId, forKey: "request_id")
        jsonObject.setValue(HelperClass.shared.currentTripDetail.requestCustomerId, forKey: "user_id")
        jsonObject.setValue("0", forKey: "is_share")
        if(self.Is_TripStarted == "NO")
        {
            jsonObject.setValue("0", forKey: "trip_start")
        }
        else if(self.Is_TripStarted == "YES")
        {
            jsonObject.setValue("1", forKey: "trip_start")
        }
        
        let jsonData: NSData
        
        do
        {
            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
            JsonStringToServer = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String as String as NSString
            //print("json string = \(JsonStringToServer)")
            
        }
        catch _
        {
            
            print ("JSON Failure")
        }
       // self.socket.emit("trip_location", self.JsonStringToServer)
    }
}
extension ArrivedMapVC: MySocketManagerDelegate {
    func tripStatusDriverResponseReceived(_ response: [String : AnyObject]) {
       
        print("Received Distance Update",response)
        let theSuccess = response["success"] as? Bool//(JSON.value(forKey: "success") as! Bool)
        if(theSuccess == true)
        {
            if let recievedDistance = response["distance"] as? Double {// JSON.value(forKey: "distance")
                self.ReceivedDistance = String(format: "%.2f", recievedDistance)
            }
            
            self.distanceLbl.text! = self.ReceivedDistance
            
        }
    }
    
//    func cancelledRequestResponseReceived(_ response: [String : AnyObject]) {
//        <#code#>
//    }
    
    func requestHandlerResponseReceived(_ response: [String : AnyObject]) {
       
        print(response)
        let reqid=response["is_cancelled"] as? Int//JSON.value(forKey: "is_cancelled") as! NSInteger
        if(reqid==1) {
            
            self.navigationController?.popToRootViewController(animated: true)
            
        }
    }
}
