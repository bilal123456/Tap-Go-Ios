//
//  FeedbackVC.swift
//  TapNGo Driver
//
//  Created by Spextrum on 12/02/18.
//  Copyright © 2018 nPlus. All rights reserved.
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
import Kingfisher
import UserNotifications

class FeedbackVC: UIViewController
{

    var layoutDic = [String:AnyObject]()
    var top:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var bottom:NSLayoutAnchor<NSLayoutYAxisAnchor>!

    var ActivityIndicator = NVActivityIndicatorView?.self
    static let activityData = ActivityData()
    
    let pref = UserDefaults.standard
    
    let AppDelegates = UIApplication.shared.delegate as! AppDelegate
//    let HelperObject = HelperClass()

    @IBOutlet weak var LblFeedback: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var BGViewforRating: UIView!
    @IBOutlet weak var ProfileImgView: UIImageView!
    @IBOutlet weak var LblCustomerName: UILabel!
    @IBOutlet weak var commentsTxtView: UITextView!
    
    @IBOutlet weak var BtnStar1: UIButton!
    @IBOutlet weak var BtnStar2: UIButton!
    @IBOutlet weak var BtnStar3: UIButton!
    @IBOutlet weak var BtnStar4: UIButton!
    @IBOutlet weak var BtnStar5: UIButton!
    
    
    var CompletedRequestID = String()
    var CustomerData = NSDictionary()
    var ProfilePicURL = String()
    var NetRatingToCustomer = "0"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        LblFeedback.font = UIFont.appFont(ofSize: LblFeedback.font!.pointSize)
        sendBtn.titleLabel?.font = UIFont.appFont(ofSize: sendBtn.titleLabel!.font!.pointSize)
        LblCustomerName.font = UIFont.appFont(ofSize: LblCustomerName.font!.pointSize)

        //FIXME:-fix //TripRequestID
//        self.CompletedRequestID = self.Pref.value(forKey: "TripID") as! String
        if self.CustomerData.count > 0
        {
            if let propicurl = self.CustomerData.value(forKey: "profile_pic") as? String {
            ProfilePicURL = propicurl
            self.LblCustomerName.text! = "\(self.CustomerData.value(forKey: "firstname") as! String) \(self.CustomerData.value(forKey: "lastname") as! String)"
            self.LoadProfilePicture()
            }
        }
        else
        {
            if let trip = HelperClass.shared.currentTripDetail,let profilepiccurl = trip.requestCustomerProfilePicture
            {
                ProfilePicURL = profilepiccurl
//                    (String(describing: trip.value(forKey: "request_customer_profilepicture")!))//self.CustomerData.value(forKey: "profile_pic") as! String
                self.LblCustomerName.text = trip.requestCustomerFirstName + " " + trip.requestCustomerLastName
                self.LoadProfilePicture()
            }
        }
        // Do any additional setup after loading the view.
        setUpViews()
    }
    func setUpViews()
    {
        commentsTxtView.layer.cornerRadius = 4.0
        commentsTxtView.layer.borderColor = UIColor.gray.cgColor
        commentsTxtView.layer.borderWidth = 1.0


        if #available(iOS 11.0, *) {
            self.top = self.view.safeAreaLayoutGuide.topAnchor
            self.bottom = self.view.safeAreaLayoutGuide.bottomAnchor
        } else {
            self.top = self.topLayoutGuide.bottomAnchor
            self.bottom = self.bottomLayoutGuide.topAnchor
        }
        LblFeedback.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["LblFeedback"] = LblFeedback
        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnSend"] = sendBtn
        BGViewforRating.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BGViewforRating"] = BGViewforRating
        ProfileImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["ProfileImgView"] = ProfileImgView
        LblCustomerName.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["LblCustomerName"] = LblCustomerName
        commentsTxtView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["CommentsTxtView"] = commentsTxtView
        BtnStar1.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnStar1"] = BtnStar1
        BtnStar2.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnStar2"] = BtnStar2
        BtnStar3.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnStar3"] = BtnStar3
        BtnStar4.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnStar4"] = BtnStar4
        BtnStar5.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnStar5"] = BtnStar5

        LblFeedback.topAnchor.constraint(equalTo: self.top, constant: 20).isActive = true
        sendBtn.bottomAnchor.constraint(equalTo: self.bottom, constant: -20).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[LblFeedback(150)]", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[LblFeedback(35)]-(25)-[BGViewforRating(320)]-(>=20)-[BtnSend(40)]", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[BGViewforRating]-(16)-|", options: [], metrics: nil, views: layoutDic))
        BGViewforRating.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(15)-[ProfileImgView(75)]-(15)-[LblCustomerName(30)]-(15)-[BtnStar3(30)]-(20)-[CommentsTxtView]-(20)-|", options: [], metrics: nil, views: layoutDic))
        ProfileImgView.widthAnchor.constraint(equalToConstant: 75).isActive = true
        ProfileImgView.centerXAnchor.constraint(equalTo: BGViewforRating.centerXAnchor).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[LblCustomerName]-(20)-|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[BtnStar1(30)][BtnStar2(30)][BtnStar3(30)][BtnStar4(30)][BtnStar5(30)]", options: [.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(25)-[CommentsTxtView]-(25)-|", options: [], metrics: nil, views: layoutDic))
        sendBtn.widthAnchor.constraint(equalToConstant: 150).isActive = true
        sendBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        BtnStar3.centerXAnchor.constraint(equalTo: BGViewforRating.centerXAnchor).isActive = true
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        //self.title = "App Name".localize().uppercased(with: Locale(identifier: HelperClass.currentAppLanguage))
//        if let title = HelperClass.shared.appName {
//            self.title = title
//        }
        self.title = "TapNgo Driver"
        customFormat()
    }
    
    
    func customFormat()
    {
//        self.navigationItem.hidesBackButton = true
        self.ProfileImgView.layer.cornerRadius = self.ProfileImgView.frame.height/2
        self.ProfileImgView.clipsToBounds = true
        self.sendBtn.layer.cornerRadius = 17
    }


    
    @IBAction func SendBtn(_ sender: Any)
    {
        if(self.NetRatingToCustomer == "0")
        {
            self.showToast("Please Rate The Passenger".localize())
            return
        }
        else if(self.commentsTxtView.text == "")
        {
            self.showToast("Please Give Your Comments or Feedback".localize())
            return
        }
        else
        {
            self.ReviewAndRatetheCustomerAPI()
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
            paramdict["request_id"] = self.CompletedRequestID
            paramdict["comment"] = self.commentsTxtView.text!
            paramdict["rating"] = self.NetRatingToCustomer
            
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
                                HelperClass.shared.deleteTripDetails()
//                                self.DeleteCancelledTripDetails()
                                self.navigationController?.popToRootViewController(animated: true)
                                UIApplication.shared.applicationIconBadgeNumber = 0
                                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
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
//            indicator.center = self.ProfileImgView.center
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
//                                    self.ProfileImgView.image=image
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
        if let url = URL(string: ProfilePicURL)
        {
            let resource = ImageResource(downloadURL: url)
            self.ProfileImgView.kf.indicatorType = .activity
            self.ProfileImgView.kf.setImage(with: resource)
        }
        else
        {
            self.ProfileImgView.image=UIImage(named: "Profile_placeHolder")
        }
    }

    
    @IBAction func Star1(_ sender: Any)
    {
        NetRatingToCustomer = "1"
        BtnStar1.setImage(UIImage(named: "FilledStar"), for: UIControl.State.normal)
        BtnStar2.setImage(UIImage(named: "EmptyStar"), for: UIControl.State.normal)
        BtnStar3.setImage(UIImage(named: "EmptyStar"), for: UIControl.State.normal)
        BtnStar4.setImage(UIImage(named: "EmptyStar"), for: UIControl.State.normal)
        BtnStar5.setImage(UIImage(named: "EmptyStar"), for: UIControl.State.normal)
    }
    
    @IBAction func Star2(_ sender: Any)
    {
        NetRatingToCustomer = "2"
        BtnStar1.setImage(UIImage(named: "FilledStar"), for: UIControl.State.normal)
        BtnStar2.setImage(UIImage(named: "FilledStar"), for: UIControl.State.normal)
        BtnStar3.setImage(UIImage(named: "EmptyStar"), for: UIControl.State.normal)
        BtnStar4.setImage(UIImage(named: "EmptyStar"), for: UIControl.State.normal)
        BtnStar5.setImage(UIImage(named: "EmptyStar"), for: UIControl.State.normal)
    }
    
    @IBAction func Star3(_ sender: Any)
    {
        NetRatingToCustomer = "3"
        BtnStar1.setImage(UIImage(named: "FilledStar"), for: UIControl.State.normal)
        BtnStar2.setImage(UIImage(named: "FilledStar"), for: UIControl.State.normal)
        BtnStar3.setImage(UIImage(named: "FilledStar"), for: UIControl.State.normal)
        BtnStar4.setImage(UIImage(named: "EmptyStar"), for: UIControl.State.normal)
        BtnStar5.setImage(UIImage(named: "EmptyStar"), for: UIControl.State.normal)
    }
    
    @IBAction func Star4(_ sender: Any)
    {
        NetRatingToCustomer = "4"
        BtnStar1.setImage(UIImage(named: "FilledStar"), for: UIControl.State.normal)
        BtnStar2.setImage(UIImage(named: "FilledStar"), for: UIControl.State.normal)
        BtnStar3.setImage(UIImage(named: "FilledStar"), for: UIControl.State.normal)
        BtnStar4.setImage(UIImage(named: "FilledStar"), for: UIControl.State.normal)
        BtnStar5.setImage(UIImage(named: "EmptyStar"), for: UIControl.State.normal)
    }
    
    @IBAction func Star5(_ sender: Any)
    {
        NetRatingToCustomer = "5"
        BtnStar1.setImage(UIImage(named: "FilledStar"), for: UIControl.State.normal)
        BtnStar2.setImage(UIImage(named: "FilledStar"), for: UIControl.State.normal)
        BtnStar3.setImage(UIImage(named: "FilledStar"), for: UIControl.State.normal)
        BtnStar4.setImage(UIImage(named: "FilledStar"), for: UIControl.State.normal)
        BtnStar5.setImage(UIImage(named: "FilledStar"), for: UIControl.State.normal)
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
    
//    func getContext () -> NSManagedObjectContext
//    {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        return appDelegate.persistentContainer.viewContext
//    }
//    func getTripRequestDetails()->NSManagedObject!
//    {
//        let fetchRequest: NSFetchRequest<Request_AcceptedData> = Request_AcceptedData.fetchRequest()
//        do
//        {
//            let Array_TripDetails = try HelperClass.shared.persistentContainer.viewContext.fetch(fetchRequest)
//            return Array_TripDetails.first
//        }
//        catch
//        {
//            print("Error with request: \(error)")
//        }
//        return nil
//    }

//    func DeleteCancelledTripDetails ()
//    {
//
//        do {
//            let context = HelperClass.shared.persistentContainer.viewContext
//            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Request_AcceptedData")
//            do
//            {
//                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
//                _ = objects.map{$0.map{context.delete($0)}}
//                try context.save()
//                print("Deleted!")
//
//            }
//            catch let error
//            {
//                print("ERROR DELETING : \(error)")
//            }
//        }
//    }


}
