//
//  LeftSideSliderVC.swift
//  TapNGo Driver
//
//  Created by Spextrum on 07/10/17.
//  Copyright © 2017 nPlus. All rights reserved.
//

import UIKit
import SWRevealViewController
//import CoreData
import Alamofire
import NVActivityIndicatorView
import Localize
import Kingfisher

class LeftSideSliderVC: UIViewController,UITableViewDelegate,UITableViewDataSource
{

    enum MenuType
    {
        case profile
        case home
        case history
        case settings
        case documents
        case complaints
        case sos
        case share
        case logout

        var title:String {
            switch self {
                case .profile:
                    return "Profile".localize()
                case .home:
                    return "Home".localize()
                case .history:
                    return "History".localize()
                case .settings:
                    return "Settings".localize()
                case .documents:
                    return "Documents".localize()
                case .complaints:
                    return "Complaints".localize()
                case .sos:
                    return "SOS".localize()
                case .share:
                    return "Share".localize()
                case .logout:
                    return "Logout".localize()
            }
        }
        var icon:UIImage {
            switch self {
                case .profile:
                    return UIImage(named:"sidemenuprofile")!
                case .home:
                    return UIImage(named:"sidemenuhome")!
                case .history:
                    return UIImage(named:"sidemenuhistory")!
                case .settings:
                    return UIImage(named:"sidemenusettings")!
                case .documents:
                    return UIImage(named:"sidemenucomplaints")!
                case .complaints:
                    return UIImage(named:"sidemenucomplaints")!
                case .sos:
                    return UIImage(named:"sidemenusos")!
                case .share:
                    return UIImage(named:"sidemenushare")!
                case .logout:
                    return UIImage(named:"sidemenulogout")!
            }
        }
    }
    var layoutDic = [String:AnyObject]()
    var top:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var bottom:NSLayoutAnchor<NSLayoutYAxisAnchor>!

    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var bgViewForUserDetails: UIView!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userEmailLbl: UILabel!
    
    var window: UIWindow?
    let AppDelegates = UIApplication.shared.delegate as! AppDelegate
//    let HelperObject = HelperClass()
    var activityView: NVActivityIndicatorView!
    var profilePicURL = String()
    
//    var UserName = String()
//    var User_ID  = String()
//    var User_token = String()

    var menuItemsArr:[MenuType] = [.profile,.home,.history,.settings,.documents,.complaints,.sos,.share,.logout]

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.profilePicURL = HelperClass.shared.userProfilePicture
        self.loadProfilePicture()

        if #available(iOS 11.0, *) {
            self.menuTableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.userImgView.layer.cornerRadius = self.userImgView.frame.height/2
        self.userImgView.clipsToBounds = true
        
//        getUsers()

        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.allowsMultipleSelection = false
        menuTableView.tableFooterView = UIView()

        userNameLbl.font = UIFont.appFont(ofSize: userNameLbl.font!.pointSize)
        userEmailLbl.font = UIFont.appFont(ofSize: userEmailLbl.font!.pointSize)
        print("Left Slider")
        // Do any additional setup after loading the view.
        setUpViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.userNameLbl.text! = HelperClass.shared.userName + " " + HelperClass.shared.userLastName
        self.userEmailLbl.text! = HelperClass.shared.userEmail
        if self.profilePicURL != HelperClass.shared.userProfilePicture
        {
            self.profilePicURL = HelperClass.shared.userProfilePicture
            self.loadProfilePicture()
        }
    }
    func setUpViews()
    {
        bgViewForUserDetails.backgroundColor = UIColor.themeColor
        self.view.backgroundColor = UIColor.themeColor
        userNameLbl.adjustsFontSizeToFitWidth = true
        userNameLbl.minimumScaleFactor = 0.1
        userEmailLbl.adjustsFontSizeToFitWidth = true
        userEmailLbl.minimumScaleFactor = 0.1

        if #available(iOS 11.0, *) {
            self.top = self.view.safeAreaLayoutGuide.topAnchor
            self.bottom = self.view.safeAreaLayoutGuide.bottomAnchor
        } else {
            self.top = self.topLayoutGuide.bottomAnchor
            self.bottom = self.bottomLayoutGuide.topAnchor
        }
        menuTableView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["MenuTableView"] = menuTableView
        bgViewForUserDetails.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BGViewForUserDetails"] = bgViewForUserDetails
        userImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["UserImgView"] = userImgView
        userNameLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["UseNameLbl"] = userNameLbl
        userNameLbl.textAlignment = HelperClass.appTextAlignment
        userEmailLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["UserEmailLbl"] = userEmailLbl
        userEmailLbl.textAlignment = HelperClass.appTextAlignment

        bgViewForUserDetails.topAnchor.constraint(equalTo: self.top).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[BGViewForUserDetails(190)][MenuTableView]|", options: [.alignAllLeading,.alignAllTrailing], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[BGViewForUserDetails]|", options: [], metrics: nil, views: layoutDic))
        bgViewForUserDetails.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[UserImgView(70)]", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        bgViewForUserDetails.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[UseNameLbl]", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        bgViewForUserDetails.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[UserEmailLbl]", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        userNameLbl.widthAnchor.constraint(equalToConstant: self.revealViewController().rearViewRevealWidth-40).isActive = true
        userEmailLbl.widthAnchor.constraint(equalToConstant: self.revealViewController().rearViewRevealWidth-40).isActive = true
        bgViewForUserDetails.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(30)-[UserImgView(70)]-(10)-[UseNameLbl(30)]-(10)-[UserEmailLbl(30)]-(10)-|", options: [], metrics: nil, views: layoutDic))
    }

    // ***** Tableview Methods *****
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return menuItemsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as! MenuTableViewCell
        cell.selectionStyle = .none
        cell.gradientLine.backgroundColor = .themeColor
        cell.MenuItemLabel.text! = menuItemsArr[indexPath.row].title
        cell.MenuImageView.image = menuItemsArr[indexPath.row].icon
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)

        if HelperClass.appLanguageDirection == .directionLeftToRight
        {
            self.revealViewController().revealToggle(animated: true)
        }
        else
        {
            self.revealViewController().rightRevealToggle(animated: true)
        }

        if menuItemsArr[indexPath.row] == .profile
        {
            let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            (self.revealViewController().frontViewController as? UINavigationController)?.pushViewController(profileVC, animated: false)
        }
        else if menuItemsArr[indexPath.row] == .home
        {
        }
        else if menuItemsArr[indexPath.row] == .history
        {
            let historyVC = self.storyboard?.instantiateViewController(withIdentifier: "HistoryVC") as! HistoryVC
            (self.revealViewController().frontViewController as? UINavigationController)?.pushViewController(historyVC, animated: false)
        }
        else if menuItemsArr[indexPath.row] == .settings
        {
            let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
            (self.revealViewController().frontViewController as? UINavigationController)?.pushViewController(settingsVC, animated: false)
        }
        else if menuItemsArr[indexPath.row] == .documents
        {
            let documentVC = ManageDocumentsViewController()
            (self.revealViewController().frontViewController as? UINavigationController)?.pushViewController(documentVC, animated: false)
        }
        else if menuItemsArr[indexPath.row] == .complaints
        {
            let complaintsVC = self.storyboard?.instantiateViewController(withIdentifier: "ComplaintsVC") as! ComplaintsVC
            (self.revealViewController().frontViewController as? UINavigationController)?.pushViewController(complaintsVC, animated: false)
        }
        else if menuItemsArr[indexPath.row] == .sos
        {
            let sosVC = self.storyboard?.instantiateViewController(withIdentifier: "SOSVC") as! SOSVC
            (self.revealViewController().frontViewController as? UINavigationController)?.pushViewController(sosVC, animated: false)
        }
        else if menuItemsArr[indexPath.row] == .share
        {
            let activityViewController = UIActivityViewController(activityItems: [URL(string:"https://itunes.apple.com")!], applicationActivities: nil)
            present(activityViewController, animated: true, completion: {})
        }
        else if menuItemsArr[indexPath.row] == .logout
        {
            let logoutAlert = UIAlertController(title: "Alert !".localize(), message: "Are you Sure, want to Logout ?".localize(), preferredStyle: .alert)
            logoutAlert.addAction(UIAlertAction(title: "Ok".localize(), style: .default, handler: { action in
                self.showLoadingIndicator()
                self.Logout()
            }))
            logoutAlert.addAction(UIAlertAction(title: "Cancel".localize(), style: .cancel, handler: nil))
            present(logoutAlert, animated: true, completion: nil)
        }
    }
    
    func Logout()
    {
        if ConnectionCheck.isConnectedToNetwork()
        {
            print("Connected")
            let url = HelperClass.BASEURL + HelperClass.LogoutURL
            var paramdict = Dictionary<String, Any>()
            paramdict["token"] = HelperClass.shared.userToken
            paramdict["id"] = HelperClass.shared.userID
            print("URL & Parameters for Logout API =",url,paramdict)
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
                                HelperClass.shared.deleteUserDetails()
                                self.stopLoadingIndicator()
                            }
                            else
                            {
                                print(JSON["error_message"] as! String)
                                let errcodestr=(JSON["error_code"] as! String)
                                if(errcodestr=="609" || errcodestr=="606")
                                {
                                    HelperClass.shared.deleteUserDetails()
                                }
                                self.stopLoadingIndicator()

                                if JSON["error_message"] as! String == "Token Expired"
                                {
                                    HelperClass.shared.deleteUserDetails()
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
//                UserName = (String(describing: user.value(forKey: "loginuser_firstname")!))
//                User_ID = (String(describing: user.value(forKey: "loginuser_ID")!))
//                User_token = (String(describing: user.value(forKey: "loginuser_token")!))
//                self.ProfilePicURL = user.value(forKey: "loginuser_profilepicture") as! String
//                print("User ID =",User_ID)
//                self.loadProfilePicture()
//            }
//        }
//        catch
//        {
//            print("Error with request: \(error)")
//        }
//    }

    
//    func DeleteUser()
//    {
//
//        do {
//            let context = HelperClass.shared.persistentContainer.viewContext
//            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Login_UserData")
//            do
//            {
//                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
//                _ = objects.map{$0.map{context.delete($0)}}
//                try context.save()
//                print("Deleted!")
//                self.window = UIWindow(frame: UIScreen.main.bounds)
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
//                let loginBaseVC = storyboard.instantiateViewController(withIdentifier: "LoginBaseVC") as! LoginBaseVC
//                self.window?.rootViewController = UINavigationController(rootViewController: loginBaseVC)
//                self.window?.makeKeyAndVisible()
//                //                  self.appDelegate.checkLogin()
//            }
//            catch let error
//            {
//                print("ERROR DELETING : \(error)")
//            }
//        }
//    }

    func loadProfilePicture()
    {
        if let resource = HelperClass.shared.userProfileImg
        {
            self.userImgView.kf.indicatorType = .activity
            self.userImgView.kf.setImage(with: resource)
        }
        else if let url = URL(string: HelperClass.shared.userProfilePicture)
        {
            let resource = ImageResource(downloadURL: url)            
            self.userImgView.kf.indicatorType = .activity
            self.userImgView.kf.setImage(with: resource)
        }
        else
        {
            self.userImgView.tintColor = UIColor.themeColor
            self.userImgView.image = UIImage(named: "profile.png")//?.withRenderingMode(.alwaysTemplate)
        }
    }

    //    # pragma mark - NVActivityIndicatorView
    
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
