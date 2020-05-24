//
//  HistoryVC.swift
//  TapNGo Driver
//
//  Created by Spextrum on 10/11/17.
//  Copyright © 2017 nPlus. All rights reserved.
//

import UIKit
//import CoreData
import Alamofire
import NVActivityIndicatorView
import Localize
import Kingfisher

class HistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource

{


    struct HistroyDetail {

        var requestId:String!
        var id:Int!
        var userId:Int!
        var pickLatitude:Double!
        var pickLongitude:Double!
        var dropLatitude:Double!
        var dropLongitude:Double!
        var pickLocation:String!
        var dropLocation:String!
        var tripStartTime:String!
        var isCompleted:Bool!
        var isCancelled:Bool!
        var driverId:Int!
        var carModel:String!
        var carNumber:String!
        var driverType:Int!
        var userProfilePicUrlStr:String!
        var typeIconUrlStr:String!
        var typeName:String!
        var total:Double!
        var currency:String!

        init(_ dict:[String:AnyObject]) {

            if let requestId = dict["request_id"] as? String {
                self.requestId = requestId
            }
            if let id = dict["id"] as? Int {
                self.id = id
            }
            if let userId = dict["user_id"] as? Int {
                self.userId = userId
            }
            if let pickLatitude = dict["pick_latitude"] as? Double {
                self.pickLatitude = pickLatitude
            }
            if let pickLongitude = dict["pick_longitude"] as? Double {
                self.pickLongitude = pickLongitude
            }
            if let dropLatitude = dict["drop_latitude"] as? Double {
                self.dropLatitude = dropLatitude
            }
            if let dropLongitude = dict["drop_longitude"] as? Double {
                self.dropLongitude = dropLongitude
            }
            if let pickLocation = dict["pick_location"] as? String {
                self.pickLocation = pickLocation
            }
            if let dropLocation = dict["drop_location"] as? String {
                self.dropLocation = dropLocation
            }
            if let tripStartTime = dict["trip_start_time"] as? String {
                self.tripStartTime = tripStartTime
            }
            if let isCompleted = dict["is_completed"] as? Bool {
                self.isCompleted = isCompleted
            }
            if let isCancelled = dict["is_cancelled"] as? Bool {
                self.isCancelled = isCancelled
            }
            if let driverId = dict["driver_id"] as? Int {
                self.driverId = driverId
            }
            if let carModel = dict["car_model"] as? String {
                self.carModel = carModel
            }
            if let carNumber = dict["car_number"] as? String {
                self.carNumber = carNumber
            }
            if let driverType = dict["driver_type"] as? Int {
                self.driverType = driverType
            }
            if let userProfilePicUrlStr = dict["user_profile_pic"] as? String {
                self.userProfilePicUrlStr = userProfilePicUrlStr
            }
            if let typeIconUrlStr = dict["type_icon"] as? String {
                self.typeIconUrlStr = typeIconUrlStr
            }
            if let typeName = dict["type_name"] as? String {
                self.typeName = typeName
            }
            if let total = dict["total"] as? Double {
                self.total = total
            }
            if let currency = dict["currency"] as? String {
                self.currency = currency
            }
        }

    }



    var layoutDic = [String:AnyObject]()
    var top:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var bottom:NSLayoutAnchor<NSLayoutYAxisAnchor>!

    var userTokenstr:String=""
    var successMessage = String()
    var pageNumber = Int()

    var histroyDetailsList:[HistroyDetail] = []


    let appdel=UIApplication.shared.delegate as!AppDelegate

    @IBOutlet weak var historytbv: UITableView!

    @IBOutlet weak var noitemsfoundiv: UIImageView!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        pageNumber = 1
        self.gethistorydetails()
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
        historytbv.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["historytbv"] = historytbv
        noitemsfoundiv.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["noitemsfoundiv"] = noitemsfoundiv

        historytbv.topAnchor.constraint(equalTo: self.top, constant: 0).isActive = true
        historytbv.bottomAnchor.constraint(equalTo: self.bottom).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[historytbv]", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[historytbv]|", options: [], metrics: nil, views: layoutDic))
        noitemsfoundiv.widthAnchor.constraint(equalToConstant: 180).isActive = true
        noitemsfoundiv.heightAnchor.constraint(equalToConstant: 110).isActive = true
        noitemsfoundiv.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        noitemsfoundiv.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }

//    func getContext () -> NSManagedObjectContext
//    {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        return appDelegate.persistentContainer.viewContext
//    }

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

    override func viewWillAppear(_ animated: Bool)
    {
        SetLocalization()
        customFormat()
    }

    func SetLocalization()
    {
        self.title = "History".localize().uppercased(with: Locale(identifier: HelperClass.currentAppLanguage))
    }

    func customFormat()
    {
        self.navigationItem.backBtnString = ""
    }
    //--------------------------------------
    // MARK: - Getting history details
    //--------------------------------------

    func gethistorydetails()
    {
        if ConnectionCheck.isConnectedToNetwork()
        {
            print("Connected")
            // NVActivityIndicatorPresenter.sharedInstance.startAnimating(HelperClass.shared.activityData,nil)
            var paramDict = Dictionary<String, Any>()
            paramDict["id"] = HelperClass.shared.userID
            paramDict["token"] = HelperClass.shared.userToken
            paramDict["page"] = pageNumber
            let url = HelperClass.BASEURL + HelperClass.gethistorydata
            print(url)
            print(paramDict)
            Alamofire.request(url, method:.post, parameters: paramDict, headers: ["Accept":"application/json"])
                .responseJSON { response in
                    print(response.response as Any) // URL response
                    print(response.result.value as AnyObject)   // result of response serialization
                    //  to get JSON return value
                    //                    if let result = response.result.value
                    //                    {

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
                                if let successMessage = JSON["success_message"] as? String {
                                    self.successMessage = successMessage
                                }

                                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                                print(JSON)
                                if let historyarray = JSON["history"] as? [[String:AnyObject]] {
                                    self.histroyDetailsList.append(contentsOf: historyarray.map({ HistroyDetail($0) }))
                                    if self.histroyDetailsList.isEmpty {
                                        self.historytbv.isHidden=true
                                        self.noitemsfoundiv.isHidden=false
                                    } else {
                                        self.historytbv.isHidden=false
                                        self.noitemsfoundiv.isHidden=true
                                        self.historytbv.reloadData()
                                    }
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
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }
        }
        else
        {
            print("disConnected")
            self.showAlert("txt_NoInternet_title".localize(), message: "txt_NoInternet".localize())
        }
    }

    //------------------------------------------
    // MARK: - NVActivityIndicatorview
    //------------------------------------------

//    func showLoadingIndicator()
//    {
//        if activityView == nil
//        {
//            activityView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100.0, height: 100.0), type: NVActivityIndicatorType.ballClipRotate, color: UIColor.black, padding: 0.0)
//            // add subview
//            view.addSubview(activityView)
//            // autoresizing mask
//            activityView.translatesAutoresizingMaskIntoConstraints = false
//            // constraints
//            view.addConstraint(NSLayoutConstraint(item: activityView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
//            view.addConstraint(NSLayoutConstraint(item: activityView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
//
//        }
//        activityView.startAnimating()
//    }
//
//    func stopLoadingIndicator()
//    {
//        activityView.stopAnimating()
//    }

   
    //--------------------------------------
    // MARK: - Table view Delegates
    //--------------------------------------

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.histroyDetailsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historycell", for: indexPath) as? historyTableViewCell 

        cell?.vehicletypelbl.text = self.histroyDetailsList[indexPath.row].typeName
        cell?.tripreqidlbl.text = self.histroyDetailsList[indexPath.row].requestId

         cell?.tripcancelledimageIv.layer.masksToBounds = true
        cell?.tripcancelledimageIv.layer.cornerRadius = 20

        if self.histroyDetailsList[indexPath.row].isCancelled
        {
             cell?.tripcostlbl.isHidden=true
             cell?.tripcancelledimageIv.isHidden=false
        }
        else
        {
             cell?.tripcostlbl.isHidden=false
             cell?.tripcancelledimageIv.isHidden=true
        }
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy hh:mm a"
        let date: Date? = dateFormatterGet.date(from: self.histroyDetailsList[indexPath.row].tripStartTime!)
        print(dateFormatter.string(from: date!))

        if let time = self.histroyDetailsList[indexPath.row].tripStartTime {
              cell?.triptimelbl.text = time
        }

        //cell.triptimelbl.text = self.tripstarttimearray[indexPath.row] as? String //dateFormatter.string(from: date!)
         cell?.fromaddrlbl.text=self.histroyDetailsList[indexPath.row].pickLocation
         cell?.toaddrlbl.text=self.histroyDetailsList[indexPath.row].dropLocation

        let totalstr = self.histroyDetailsList[indexPath.row].currency! + " " + String(format:"%.2f",self.histroyDetailsList[indexPath.row].total!)
        //            self.totaltripcostarray[indexPath.row] as? String
         cell?.tripcostlbl.text=totalstr

        //        cell.driverimageIv.image = UIImage(named: "Profile_placeholder")  //set placeholder image first.
        if let urlStr = histroyDetailsList[indexPath.row].userProfilePicUrlStr, let url = URL(string:urlStr)
        {
            let driverResource = ImageResource(downloadURL: url)
             cell?.driverimageIv.kf.setImage(with: driverResource)
        } else {
             cell?.driverimageIv.tintColor = UIColor.themeColor
            let defaultImg = UIImage(named:"profile")?.withRenderingMode(.alwaysTemplate)
             cell?.driverimageIv.image = defaultImg
        }
        if let urlStr = histroyDetailsList[indexPath.row].typeIconUrlStr, let url = URL(string:urlStr)
        {
            let vehicleResource = ImageResource(downloadURL: url)
             cell?.vehicleimageIv.kf.setImage(with: vehicleResource)
        }
         cell?.driverimageIv.layer.masksToBounds = true
        cell?.driverimageIv.layer.cornerRadius = 5
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        if self.successMessage == "driver_history_not_found"
        {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
        else
        {
            if(indexPath.row == histroyDetailsList.count-1)
            {
                pageNumber += 1
                self.gethistorydetails()
            }
        }

        //        UIView.beginAnimations("rotation", context: nil)
        //        UIView.setAnimationDuration(0.8)
        //        cell.layer.transform = CATransform3DIdentity
        //        cell.alpha = 1
        //        cell.layer.shadowOffset = CGSize(width: CGFloat(0), height: CGFloat(0))
        //            UIView.commitAnimations()
        return (cell)!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if self.histroyDetailsList[indexPath.row].isCancelled
        {
            if let historycancelleddetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "historycancelleddetailsVC") as? HistoryCancelledDetailsVC {
                historycancelleddetailsVC.historyrequestid = String(self.histroyDetailsList[indexPath.row].id)
                self.navigationController?.pushViewController(historycancelleddetailsVC, animated: true)
            }
        }
        else
        {
            if let historycomdetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "historycomdetailsViewController") as? HistoryComDetailsViewController {
                historycomdetailsViewController.historyrequestid = String(self.histroyDetailsList[indexPath.row].id)
                self.navigationController?.pushViewController(historycomdetailsViewController, animated: true)
            }
        }
    }
}

//extension UIImageView
//{
//    func downloadImageFrom(link:String, contentMode: UIViewContentMode)
//    {
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
