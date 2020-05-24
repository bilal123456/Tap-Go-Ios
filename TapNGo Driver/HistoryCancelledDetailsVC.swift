//
//  historycancelleddetailsVC.swift
//  TapNGo Driver
//
//  Created by Mohammed Arshad on 20/03/18.
//  Copyright © 2018 nPlus. All rights reserved.
//

import UIKit
import GoogleMaps
//import CoreData
import NVActivityIndicatorView
import Alamofire
import Localize

class HistoryCancelledDetailsVC: UIViewController, GMSMapViewDelegate
{

    var historyrequestid = String()

    var layoutDic = [String:AnyObject]()
    var top:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var bottom:NSLayoutAnchor<NSLayoutYAxisAnchor>!

    @IBOutlet weak var mapview: GMSMapView!

    @IBOutlet var starratingBtn1: UIButton!
    @IBOutlet var starratingBtn2: UIButton!
    @IBOutlet var starratingBtn3: UIButton!
    @IBOutlet var starratingBtn4: UIButton!
    @IBOutlet var starratingBtn5: UIButton!

    @IBOutlet var userprofilepicture: UIImageView!

    @IBOutlet var usernamelbl: UILabel!

    @IBOutlet var tripstatusimageview: UIImageView!
    @IBOutlet weak var separator1: UIView!

    @IBOutlet var pickupaddrlbl: UILabel!
    @IBOutlet var dropupaddrlbl: UILabel!
    @IBOutlet weak var invoiceImgView: UIImageView!
    @IBOutlet weak var separator2: UIView!

    var historydict = [String:AnyObject]()

    var activityView: NVActivityIndicatorView!

    let appdel=UIApplication.shared.delegate as!AppDelegate

    //    let HelperObject = HelperClass()

    //    var userTokenstr:String=""
    //    var userId:String=""

    var marker = GMSMarker()
    var desmarker = GMSMarker()

    override func viewDidLoad()
    {
        super.viewDidLoad()

        usernamelbl.font = UIFont.appFont(ofSize: usernamelbl.font!.pointSize)
        pickupaddrlbl.font = UIFont.appFont(ofSize: pickupaddrlbl.font!.pointSize)
        dropupaddrlbl.font = UIFont.appFont(ofSize: dropupaddrlbl.font!.pointSize)

        self.title = "text_history_details".localize()
        self.gethistorydetails()


        // Set the map style by passing the URL of the local file.
//        if let styleURL = Bundle.main.url(forResource: "mapStyle", withExtension: "json") {
//            self.mapview.mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
//        } else {
//            print("Unable to find mapStyle.json")
//        }

        setUpViews()
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
        mapview.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["mapview"] = mapview
        starratingBtn1.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["starratingBtn1"] = starratingBtn1
        starratingBtn2.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["starratingBtn2"] = starratingBtn2
        starratingBtn3.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["starratingBtn3"] = starratingBtn3
        starratingBtn4.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["starratingBtn4"] = starratingBtn4
        starratingBtn5.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["starratingBtn5"] = starratingBtn5
        userprofilepicture.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["userprofilepicture"] = userprofilepicture
        usernamelbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["usernamelbl"] = usernamelbl
        tripstatusimageview.contentMode = .scaleAspectFit
        tripstatusimageview.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["tripstatusimageview"] = tripstatusimageview
        separator1.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["separator1"] = separator1
        pickupaddrlbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["pickupaddrlbl"] = pickupaddrlbl
        dropupaddrlbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["dropupaddrlbl"] = dropupaddrlbl
        invoiceImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["invoiceImgView"] = invoiceImgView
        separator2.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["separator2"] = separator2

        mapview.topAnchor.constraint(equalTo: self.top).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[mapview(150)]-(20)-[userprofilepicture(50)]-(10)-[separator1(1)]-(15)-[pickupaddrlbl(40)]-(5)-[dropupaddrlbl(10)]-(15)-[separator2(1)]", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[userprofilepicture]-(>=10)-[tripstatusimageview]", options: [.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[mapview]|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[userprofilepicture(50)]-(15)-[usernamelbl]-(15)-[tripstatusimageview(40)]-(30)-|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[userprofilepicture]-(15)-[starratingBtn1(17)]", options: [HelperClass.appLanguageDirection,.alignAllBottom], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[starratingBtn1][starratingBtn2(17)][starratingBtn3(17)][starratingBtn4(17)][starratingBtn5(17)]", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(15)-[invoiceImgView(30)]-(5)-[pickupaddrlbl]-(10)-|", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[invoiceImgView]-(5)-[dropupaddrlbl]-(10)-|", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        invoiceImgView.topAnchor.constraint(equalTo: pickupaddrlbl.centerYAnchor).isActive = true
        invoiceImgView.bottomAnchor.constraint(equalTo: dropupaddrlbl.centerYAnchor).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[separator1]|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[separator2]|", options: [], metrics: nil, views: layoutDic))
    }

//    func getContext () -> NSManagedObjectContext
//    {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        return appDelegate.persistentContainer.viewContext
//    }
//
//    func getUsers ()
//    {
//        let fetchRequest: NSFetchRequest<Login_UserData> = Login_UserData.fetchRequest()
//        do
//        {
//            let array_users = try getContext().fetch(fetchRequest)
//            print ("num of users = \(array_users.count)")
//            for user in array_users as [NSManagedObject]
//            {
//                userId = (String(describing: user.value(forKey: "loginuser_ID")!))
//                userTokenstr = (String(describing: user.value(forKey: "loginuser_token")!))
//            }
//        }
//        catch
//        {
//            print("Error with request: \(error)")
//        }
//    }

    @IBAction func NavigateBackBtn(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }

    //--------------------------------------
    // MARK: - Getting history details
    //--------------------------------------

    func gethistorydetails()
    {
        if ConnectionCheck.isConnectedToNetwork()
        {
            print("Connected")
            self.showLoadingIndicator()
            var ParamDict = Dictionary<String, Any>()
            ParamDict["id"] = Int(HelperClass.shared.userID)
            ParamDict["token"] = HelperClass.shared.userToken
            ParamDict["request_id"]=self.appdel.historyrequestid
            let url = HelperClass.BASEURL + HelperClass.gethistorydetails
            Alamofire.request(url, method:.post, parameters: ParamDict, headers: ["Accept":"application/json"])
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
                                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                                if let request = JSON["request"] as? [String:AnyObject] {
                                    self.historydict = request
                                    print(self.historydict)
                                    self.setupmap()
                                    self.setupdata()
                                }
                            }
                            else
                            {
                                if let errcodestr = JSON["error_code"] as? String, errcodestr == "606" {
                                    HelperClass.shared.deleteUserDetails()
                                } else {
                                    print(JSON["error_message"] as? String)
                                    print("Response Fail")
                                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                                    self.showToast("text_fetch_history".localize())
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
            //            self.alert(message: , title: )
            self.showAlert("Please Check Your Internet Connection".localize(), message: "No Internet".localize())
        }
    }

    //--------------------------------------
    // MARK: - Populating map info
    //--------------------------------------

    func setupmap ()
    {
        if let latdouble=self.historydict["pick_latitude"] as? CLLocationDegrees, let longdouble=self.historydict["pick_longitude"] as? CLLocationDegrees
        {
            let camera = GMSCameraPosition.camera(withLatitude: latdouble, longitude: longdouble , zoom: 14)
            mapview.camera=camera

            marker.position = CLLocationCoordinate2D(latitude: (mapview.camera.target.latitude), longitude: (mapview.camera.target.longitude))
            marker.icon = UIImage(named:"PickupMarker")
            marker.map = mapview
        }


        if let destlatdouble=self.historydict["drop_latitude"] as? CLLocationDegrees, let destlondouble=self.historydict["drop_longitude"] as? CLLocationDegrees
        {
            desmarker.position = CLLocationCoordinate2D(latitude: destlatdouble, longitude: destlondouble)
            desmarker.icon = UIImage(named:"DropMarker")
            desmarker.map = mapview
            let path = GMSMutablePath()
            path.add(CLLocationCoordinate2D(latitude: mapview.camera.target.latitude, longitude: mapview.camera.target.longitude))
            path.add(CLLocationCoordinate2D(latitude: destlatdouble, longitude: destlondouble))

            var bounds = GMSCoordinateBounds()

            for index in 0...path.count()
            {
                bounds = bounds.includingCoordinate(path.coordinate(at: index))
            }
            self.mapview.animate(with: GMSCameraUpdate.fit(bounds))
        }
    }

    //--------------------------------------
    // MARK: - Populating history info
    //--------------------------------------

    func setupdata()
    {
        self.userprofilepicture.layer.masksToBounds=true
        self.userprofilepicture.layer.cornerRadius=self.userprofilepicture.layer.frame.width/2


        //pickup and drop address

        self.pickupaddrlbl.text=historydict["pick_location"] as? String
        self.dropupaddrlbl.text=historydict["drop_location"] as? String
    }

    //--------------------------------------
    // MARK: - NVActivityIndicatorview
    //--------------------------------------

    func showLoadingIndicator()
    {
        if activityView == nil
        {
            activityView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100.0, height: 100.0), type: NVActivityIndicatorType.ballClipRotate, color: UIColor.black, padding: 0.0)
            // add subview
            view.addSubview(activityView)
            // autoresizing mask
            activityView.translatesAutoresizingMaskIntoConstraints = false
            // constraints
            view.addConstraint(NSLayoutConstraint(item: activityView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: activityView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0))
        }
        activityView.startAnimating()
    }

    func stopLoadingIndicator()
    {
        activityView.stopAnimating()
    }


    }

//extension UIImageView {
//    func downloadImageFrom111(link:String, contentMode: UIViewContentMode) {
//        URLSession.shared.dataTask( with: NSURL(string:link)! as URL, completionHandler: {
//            (data, response, error) -> Void in
//            DispatchQueue.main.async()
//                {
//                    self.contentMode =  contentMode
//                    if let data = data { self.image = UIImage(data: data) }
//            }
//        }).resume()
//    }
//}
