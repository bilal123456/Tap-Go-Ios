    //
//  RegisterVehicleDocumentsVC.swift
//  TapNGo Driver
//
//  Created by Spextrum on 09/10/17.
//  Copyright © 2017 nPlus. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
import SWRevealViewController
//import CoreData
import Localize

    struct UserDetails
    {
        var firstname = ""
        var lastname = ""
        var email = ""
        var phone = ""
        var country = ""
        var countryCode = ""
        var password = ""
        var address = ""
        var profileImage:UIImage!
        var deviceToken:String!
        var loginBy:String!
        var type = ""
        var carNumber = ""
        var carModel = ""
        var carMake = ""
        var carColor = ""
        var loginMethod:String!
        var socialUniqueId:String!
        var adminId = ""
        var driverDocuments = [Document]()
//        var licenseDoc = Document()
//        var insuranceDoc = Document()
//        var rcBookDoc = Document(.rcBook)
    }


class RegisterVehicleDocumentsVC: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource
{
    
    //***** Variables for Data Received from Previous ViewControllers *****
    var activityView: NVActivityIndicatorView!
//    var DFirstName = String()
//    var DLastName = String()
//    var DEmail = String()
//    var DMobile = String()
//    var country:String!
//    var countryCode:String!
//    var DPassword = String()
//    var DProfileImage = UIImage()
//    var VehicleNumber = String()
//    var VehicleModel = String()
//    var VehicleType = String()
//    var areaId:Int!


    var userDetails:UserDetails!
    var callback : ((UserDetails) -> Void)?

    
    // ******* Other General UI Outlets ********
    @IBOutlet weak var uploadDocumentView: UploadDocumentView!
    
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var docImgView: UIImageView!
    
    @IBOutlet weak var LblDocument: UILabel!
    @IBOutlet weak var LblFileFormat: UILabel!

    var btnDocumentAdd = UIButton()
    var tableDocs = UITableView()

    @IBOutlet weak var BtnSubmit: UIButton!

    @IBOutlet weak var pageControl: UIPageControl!
    var layoutDic = [String:AnyObject]()
    var top:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var bottom:NSLayoutAnchor<NSLayoutYAxisAnchor>!

    // ***** Outlets for License Details *****
    @IBOutlet weak var BGLicenseDetailView: UIView!
    @IBOutlet weak var LicenseImageView: UIImageView!
    @IBOutlet weak var BtnImgforLicense: UIButton!
    @IBOutlet weak var TxtTitleforLicense: UITextField!
    @IBOutlet weak var TxtExpiryForLicense: UITextField!
    @IBOutlet weak var BtnOkforLicense: UIButton!
    @IBOutlet weak var BGViewForTxtLicenseTitle: UIView!
    @IBOutlet weak var BGViewForTxtLicenseExpiry: UIView!
    @IBOutlet weak var BtnPickDateforLicense: UIButton!
    
    // ***** Outlets for Insurance Details *****
    @IBOutlet weak var BGInsuranceDetailsView: UIView!
    @IBOutlet weak var InsuranceImageView: UIImageView!
    @IBOutlet weak var BtnImgForInsurance: UIButton!
    @IBOutlet weak var TxtTitleForInsurance: UITextField!
    @IBOutlet weak var TxtExpiryForInsurance: UITextField!
    @IBOutlet weak var BGViewTxtInsuranceTitle: UIView!
    @IBOutlet weak var BGViewForTxtInsuranceExpiry: UIView!
    @IBOutlet weak var BtnOkForInsurance: UIButton!
    @IBOutlet weak var BtnPickDateforInsurance: UIButton!
    
    
    
    // ***** Outlets for RCBook Details *****
    
    @IBOutlet weak var BGRCBookDetailsView: UIView!
    @IBOutlet weak var RCBookImageView: UIImageView!
    @IBOutlet weak var BtnImgForRCBook: UIButton!
    @IBOutlet weak var TxtTitleForRCBook: UITextField!
    @IBOutlet weak var TxtExpiryForRCBook: UITextField!
    @IBOutlet weak var BGViewforTxtRCBookTitle: UIView!
    @IBOutlet weak var BGViewforTxtRCBookExpiry: UIView!
    @IBOutlet weak var BtnOkForRCBook: UIButton!
    @IBOutlet weak var BtnPickdateforRCBook: UIButton!
    

    let AppDelegates = UIApplication.shared.delegate as! AppDelegate
//    let HelperObject = HelperClass()
    let imagePicker = UIImagePickerController()

    
    var DocsTagforMultipart = String()
//    var arrayDocAdd = [UIImage]()

    var docToken = ""
    var docListArray = [AnyObject]()
    var docListDict = [String: AnyObject]()
    var arrayStr=[String]()

     let Pref = UserDefaults.standard

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        imagePicker.delegate = uploadDocumentView
        uploadDocumentView.delegate = self
        //        TxtExpiryForLicense.delegate = self

        setUpViews()
        DocumentTokenGenerate()
        
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

        uploadDocumentView.isHidden = true
        uploadDocumentView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["uploadDocumentView"] = uploadDocumentView
        bgImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["bgImgView"] = bgImgView
        docImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["docImgView"] = docImgView
        docImgView.contentMode = .scaleAspectFit
        LblDocument.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["LblDocument"] = LblDocument
        LblFileFormat.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["LblFileFormat"] = LblFileFormat

        btnDocumentAdd.setImage(UIImage(named: "Add"), for: .normal)
        btnDocumentAdd.addTarget(self, action: #selector(btnDocumentAddPressed), for: .touchUpInside)
        btnDocumentAdd.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["btnDocumentAdd"] = btnDocumentAdd
        self.view.addSubview(btnDocumentAdd)
        tableDocs.isHidden = true
       
        tableDocs.delegate = self
        tableDocs.dataSource = self
        tableDocs.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["tableDocs"] = tableDocs
        self.view.addSubview(tableDocs)
        tableDocs.register(DocumentTableViewCell.self, forCellReuseIdentifier: "DocumentCell")

        BtnSubmit.backgroundColor = .secondaryColor
        BtnSubmit.setTitleColor(.themeColor, for: .normal)
        BtnSubmit.layer.borderColor = UIColor.themeColor.cgColor
        BtnSubmit.layer.borderWidth = 1.0
        BtnSubmit.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnSubmit"] = BtnSubmit


        pageControl.pageIndicatorTintColor = .yellow
        pageControl.currentPageIndicatorTintColor = .themeColor
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["pageControl"] = pageControl
//        if self.userDetails.licenseDoc.validateAll()
//        {
//            self.BtnLicense.setBackgroundImage(UIImage(named: "Right"), for: .normal)
//        }
//        if self.userDetails.insuranceDoc.validateAll()
//        {
//            self.BtnInsurance.setBackgroundImage(UIImage(named: "Right"), for: .normal)
//        }
//        if self.userDetails.rcBookDoc.validateAll()
//        {
//            self.BtnRCBook.setBackgroundImage(UIImage(named: "Right"), for: .normal)
//        }

        bgImgView.topAnchor.constraint(equalTo: self.top, constant: 0).isActive = true
        bgImgView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1/6).isActive = true
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bgImgView(150)]", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bgImgView]|", options: [], metrics: nil, views: layoutDic))
        self.docImgView.widthAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1/7).isActive = true
        self.docImgView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1/7).isActive = true
        self.docImgView.centerXAnchor.constraint(equalTo: bgImgView.centerXAnchor).isActive = true
        self.docImgView.centerYAnchor.constraint(equalTo: bgImgView.bottomAnchor).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[docImgView]-(20)-[LblDocument(30)]-(10)-[LblFileFormat(30)]", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[LblFileFormat]-15-[btnDocumentAdd(50)]-15-[tableDocs]", options: [.alignAllLeading,.alignAllTrailing], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[LblFileFormat]-16-|", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
//        self.LblFileFormat.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//        self.LblFileFormat.widthAnchor.constraint(equalToConstant: 250).isActive = true
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[btnDocumentAdd(50)]-16-|", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[tableDocs]-16-|", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))


        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[tableDocs]-(20)-[pageControl(20)]-(5)-[BtnSubmit(40)]", options: [.alignAllCenterX], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[LblDocument(150)]", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        self.pageControl.widthAnchor.constraint(equalToConstant: 60).isActive = true
        self.BtnSubmit.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[uploadDocumentView]|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[uploadDocumentView]|", options: [], metrics: nil, views: layoutDic))
        BtnSubmit.bottomAnchor.constraint(equalTo: self.bottom, constant: -20).isActive = true

        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()

        BtnSubmit.layer.cornerRadius = BtnSubmit.bounds.height/2

        LblDocument.textAlignment = HelperClass.appTextAlignment
        LblFileFormat.textAlignment = HelperClass.appTextAlignment

        uploadDocumentView.documentImgBtn.addTarget(self, action: #selector(pickImgBtnAction(_ :)), for: .touchUpInside)
        uploadDocumentView.documentHideBtn.addTarget(self, action: #selector(documentHidePressed(_ :)), for: .touchUpInside)

    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.title = "Register".localize().uppercased(with: Locale(identifier: HelperClass.currentAppLanguage))
        customFormat()
    }
    override func viewWillDisappear(_ animated: Bool) {
        if self.isMovingFromParent
        {
            print("Going back")
            callback?(self.userDetails)
        }
        else
        {
            print("Going forward")
        }
    }

    //MARK: TableviewMethods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userDetails.driverDocuments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableDocs.dequeueReusableCell(withIdentifier: "DocumentCell") as? DocumentTableViewCell ?? DocumentTableViewCell()

            cell.lblDocName.text = self.userDetails.driverDocuments[indexPath.row].title
            cell.btnDelDoc.setImage(UIImage(named: "crossDelete"), for: .normal)
        cell.btnDelDoc.addTarget(self, action: #selector(btnDelDocPressed(_ :)), for: .touchUpInside)
        cell.btnDelDoc.tag = indexPath.row

        return cell
    }
    
    @objc func documentHidePressed(_ sender: UIButton) {
        
        self.uploadDocumentView.isHidden = true
        self.btnDocumentAdd.isHidden = false
        self.tableDocs.isHidden = false
        self.tableDocs.reloadData()
    }

    @objc func btnDocumentAddPressed() {
        uploadDocumentView.showUploadDocumentView(Document([ : ]))
        tableDocs.isHidden = true
        self.btnDocumentAdd.isHidden = true
    }


    @objc func btnDelDocPressed(_ sender: UIButton) {
        let button = sender.tag
        self.userDetails.driverDocuments.remove(at: button)
        tableDocs.reloadData()
    }

//    @IBAction func pickImgBtnAction(_ sender: UIButton)
//    {
//        let alert = UIAlertController(title: "Choose Image".localize(), message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Camera".localize(), style: .default, handler: { _ in
//            self.openCamera()
//        }))
//
//        alert.addAction(UIAlertAction(title: "Gallery".localize(), style: .default, handler: { _ in
//            self.openGallary()
//        }))
//
//        alert.addAction(UIAlertAction.init(title: "Cancel".localize(), style: .cancel, handler: nil))
//
//        self.present(alert, animated: true, completion: nil)
//    }

    @objc func pickImgBtnAction(_ sender: UIButton)
    {
        let alert = UIAlertController(title: "Choose Image".localize(), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera".localize(), style: .default, handler: { _ in
            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: "Gallery".localize(), style: .default, handler: { _ in
            self.openGallary()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel".localize(), style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    

    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            self.showAlert("Warning".localize(), message: "You don't have camera".localize())
        }
    }
    
    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }

    func DocumentTokenGenerate() {
        if ConnectionCheck.isConnectedToNetwork()
        {
            let url = HelperClass.BASEURL + HelperClass.documentToken
           // var paramdict = Dictionary<String, Any>()

            Alamofire.request(url, method:.post, parameters: [:], encoding: JSONEncoding.default, headers:HelperClass.Header)
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
                                if let documenttoken = JSON["document_token"] as? String {
                                    self.docToken = documenttoken
                                     print(self.docToken)
                                }

                            }
                        }
                    }
            }
        }
    }


    func MultiPart()
    {
        if ConnectionCheck.isConnectedToNetwork()
        {
            self.showLoadingIndicator()
            print("Connected")
            let url = HelperClass.BASEURL + HelperClass.driverRegister

            var paramDict = Dictionary<String, Any>()

            paramDict["firstname"] = self.userDetails.firstname
            paramDict["lastname"] = self.userDetails.lastname
            paramDict["email"] = self.userDetails.email
            paramDict["phone"] = self.userDetails.phone
            paramDict["country"] = self.userDetails.country
            paramDict["country_code"] = self.userDetails.countryCode
            paramDict["password"] = self.userDetails.password
            paramDict["device_token"] = AppDelegates.DeviceToken == "" ? "Devicetokennil" : AppDelegates.DeviceToken
            paramDict["login_by"] = "ios"
            paramDict["type"] = self.userDetails.type
            paramDict["car_number"] = self.userDetails.carNumber
            paramDict["car_model"] = self.userDetails.carModel
            paramDict["car_make"] = self.userDetails.carMake
            paramDict["car_color"] = self.userDetails.carColor
            paramDict["login_method"] = "manual"
            paramDict["social_unique_id"] = ""
            paramDict["admin_id"] = self.userDetails.adminId
            paramDict["document_token"] = self.docToken
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: self.docListArray, options: .prettyPrinted)
                let string = String(data: jsonData, encoding: String.Encoding.utf8)
                paramDict["document_list"] = string

            } catch {
                print(error.localizedDescription)
            }
//             paramDict["document_list"] = docListArray//arrayStr

            print("URL & Paremeters for SignUp =",paramDict)

            Alamofire.request(url, method: .post, parameters: paramDict, encoding: JSONEncoding.prettyPrinted, headers:HelperClass.Header)
                .responseString(completionHandler: { (responsestring) in
                    print(responsestring)
                })
                            .responseJSON { response in
                                if case .failure(let error) = response.result
                                {
                                    print(error.localizedDescription)
                                }
                                else if case .success = response.result
                                {
                                    print(response.result.value)
                                    self.stopLoadingIndicator()
                                    if let JSON = response.result.value as? [String:AnyObject], let status = JSON["success"] as? Bool, status
                                    {
                                        
                                     
                                            let UserDetails = JSON["driver"] as! [String:AnyObject]

                                            //                        ios - Gopi - vignesh@erdster.co.uk

                                            self.Pref.set(JSON["sos"], forKey: "SOSDetails")  //setObject as! NSArray
                                            self.Pref.set(UserDetails["is_available"], forKey: "IsDriverAvailable")
                                            self.Pref.set(UserDetails["is_active"], forKey: "IsDriverActive")
                                            self.Pref.set(UserDetails["is_approve"], forKey: "IsDriverApprove")
                                            self.Pref.synchronize()
                                            print(UserDetails)
                                            print(UserDetails["firstname"] as! String)
                                            HelperClass.shared.storeUserDetails(UserDetails, currentUser: nil)
                                            self.stopLoadingIndicator()
                                            AppLocationManager.shared.startTracking()
                                            AppSocketManager.shared.establishConnection()
                                            let swRevealViewController = SWRevealViewController()
                                            swRevealViewController.navigationItem.hidesBackButton = true
                                            let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                                            swRevealViewController.frontViewController = UINavigationController(rootViewController: homeVC)
                                            swRevealViewController.rearViewController = self.storyboard?.instantiateViewController(withIdentifier: "LeftSideSliderVC") as! LeftSideSliderVC
                                            swRevealViewController.rightViewController = self.storyboard?.instantiateViewController(withIdentifier: "LeftSideSliderVC") as! LeftSideSliderVC
                                            self.navigationController?.present(swRevealViewController, animated: true, completion: nil)

                                       
                                    }else
                                    {
                                        self.stopLoadingIndicator()
                                        let JSON = response.result.value as! NSDictionary
                                        print("Invalid Response",JSON)
                                        self.showAlert("Alert".localize(), message: JSON.value(forKey: "error_message") as! String)
                                    }
                                    
                            }


                        }


        }
        else
        {
            print("disConnected")
            self.showAlert("No Internet".localize(), message: "Please Check Your Internet Connection".localize())
        }



//        //let headers = ["Accept":"application/json"]
//
//        let urlStr = URL(string: HelperClass.BASEURL + HelperClass.driverRegister)
//        var urlReq = URLRequest(url: urlStr!)
//        urlReq.httpMethod = "POST"
//
//        guard let httpBody = try? JSONSerialization.data(withJSONObject: paramDict, options: []) else {
//            return
//        }
//
//        urlReq.httpBody = httpBody
//
//        urlReq.allHTTPHeaderFields = HelperClass.Header
//
//
//
//        let task = URLSession.shared.dataTask(with: urlReq) { (data, response, error) in
//            if let response = response {
//                print(response)
//            }
//            if let data = data {
//                do {
//                    if let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [String: AnyObject] {
//                            print(json)
//                    }
//
//                }catch {
//                    print(error)
//                }
//            }
//        };task.resume()


    }
    

    @IBAction func SubmitBtn(_ sender: Any)
    {
        if self.userDetails.driverDocuments.contains(where: { $0.validateAll() })

        {

            MultiPart()
        }
        else
        {
            self.showAlert("Alert".localize(), message: "Please Enter Atleast One Document Details".localize())
        }
    }
    
//    
//    @IBAction func NavigateBackBtn(_ sender: Any)
//    {
//        self.performSegue(withIdentifier: "RegisterVehicleDocsVCToRegisterVehicleVC", sender: self)
//    }
    
    
    
    func customFormat()
    {

    }
    
 
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if(textField == self.TxtExpiryForLicense)
        {
            
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
extension RegisterVehicleDocumentsVC
{
    
}
extension RegisterVehicleDocumentsVC:UploadDocumentViewDelegate
{
    func okBtnTapped(_ document:Document)
    {
        DocsTagforMultipart = "TWO"
        if(document.title.trimmingCharacters(in: .whitespaces) == "")
        {
            self.showAlert("Alert".localize(), message: "Please Enter the Title for your Document".localize())

            return
        }
        else if(document.dateStr.trimmingCharacters(in: .whitespaces) == "")
        {
             self.showAlert("Alert".localize(), message: "Please Enter the Expiry Date of your Document".localize())


            return
        }
        else if !document.imageUploaded
        {
             self.showAlert("Alert".localize(), message: "Please Upload Image of your Document".localize())


            return
        }
        else
        {
            DocumentImageUploadApi(document: document)

        }
    }

    func DocumentImageUploadApi(document:Document) {

        if ConnectionCheck.isConnectedToNetwork()
        {
            self.showLoadingIndicator()
            print("Connected")
            let url = try! URLRequest(url: HelperClass.BASEURL + HelperClass.documentImageUpload, method: .post, headers: HelperClass.Header)
            //let url = HelperClass.BASEURL + HelperClass.documentImageUpload
            var paramdict = Dictionary<String, Any>()

            paramdict["document_token"] = self.docToken
            paramdict["document_name"] = document.title
          //  paramdict["document"] = ""

            print("URL & Paremeters for SignUp =",url,paramdict)


            Alamofire.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(document.image.pngData()!, withName: "document", fileName: "picture1.png", mimeType: "image/png")

                                for (key, value) in paramdict
                                {
                                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                                }
            }, with: url, encodingCompletion: {
                encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON
                        { response in
                            self.stopLoadingIndicator()
                           print(response.result.value)
                            self.docListDict = (response.result.value as! [String: Any]) as [String : AnyObject]
                            self.docListDict["documentExpiry"] = document.dateStr as AnyObject

//                            do {
//                                let jsonData = try JSONSerialization.data(withJSONObject: self.docListDict, options: .prettyPrinted)
//                                let string = String(data: jsonData, encoding: String.Encoding.utf8)
//
////                                let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
//                                self.docListArray.append(string as AnyObject)
////                                if let dictFromJSON = decoded as? [String:String] {
////                                    print(dictFromJSON)
////                                self.docListArray.append(string as AnyObject )
////                                }
//                            } catch {
//                                print(error.localizedDescription)
//                            }

                            self.docListArray.append(self.docListDict as [String : AnyObject] as AnyObject)
                            print(self.docListArray)
                            let theSuccess = ((response.result.value as! [String: Any])["success"] as! Bool)

                            if (theSuccess == true)
                            {
                                self.uploadDocumentView.endEditing(true)
                                self.uploadDocumentView.isHidden = true
                                self.userDetails.driverDocuments.append(document)
                                self.btnDocumentAdd.isHidden = false
                                self.tableDocs.isHidden = false
                                self.tableDocs.reloadData()
                            }
                            else if(theSuccess == false)
                            {
                                let JSON = response.result.value as! NSDictionary
                                print("Invalid Response",JSON)
                                self.showAlert("Alert".localize(), message: JSON.value(forKey: "error_message") as! String)
                            }

                    }
                case .failure(let encodingError):
                    // hide progressbas here
                    print("ERROR RESPONSE: \(encodingError)")
                }
            })

        }
        else {
            print("no internet")
        }

    }

}

//MARK:- UploadDocumentView
protocol UploadDocumentViewDelegate
{
    func okBtnTapped(_ document:Document)
}
class UploadDocumentView:UIView,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate
{
// @IBOutlet weak var datePicker:UIDatePicker!
//    @IBOutlet weak var containerView:UIView!
//    @IBOutlet weak var documentImgBtn:UIButton!
//    @IBOutlet weak var documentTitleTxtField:UITextField!
//    @IBOutlet weak var documentDateTxtField:RJKPickerTextField!
//    @IBOutlet weak var okBtn:UIButton!

    var containerView = UIView()
    var documentHideBtn = UIButton()
    var documentImgBtn = UIButton()
    var documentTitleTxtField = UITextField()
    var documentDateTxtField = RJKPickerTextField()
    var okBtn = UIButton()

    

    var layoutDic = [String:AnyObject]()
    var currentDoc:Document!
    var delegate:UploadDocumentViewDelegate!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
//        okBtn.layer.cornerRadius = 5.0
        documentImgBtn.layer.cornerRadius = 5.0
        documentImgBtn.imageView?.contentMode = .scaleAspectFit
        containerView.layer.cornerRadius = 5.0
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = TimeZone(abbreviation:"UTC")!
        var components = DateComponents()
        components.calendar = calendar as Calendar
        components.month = -1
        let minDate = calendar.date(byAdding: components, to: Date())
        
        let calendar2 = Calendar.current
        var maxDateComponent = calendar2.dateComponents([.day,.month,.year], from: Date())
        maxDateComponent.day = 0
        maxDateComponent.month = 03 + 1
        maxDateComponent.year = 2218
        let maxDate = calendar.date(from: maxDateComponent)
        
        
        documentDateTxtField.configureDatePicker(minDate,maxDate:maxDate, dateFormat: "yyyy-MM-dd")


        self.addSubview(documentHideBtn)
        self.addSubview(containerView)
        
        self.containerView.addSubview(documentImgBtn)
        self.containerView.addSubview(documentTitleTxtField)
        self.containerView.addSubview(documentDateTxtField)
        self.containerView.addSubview(okBtn)

       // documentImgBtn.addTarget(self, action: #selector(pickImgBtnAction(_ :)), for: .touchUpInside)


        containerView.backgroundColor = UIColor(red: 255/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        containerView.addShadow()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["containerView"] = containerView
        
        documentHideBtn.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["documentHideBtn"] = documentHideBtn
        
        documentImgBtn.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["documentImgBtn"] = documentImgBtn

        documentTitleTxtField.placeholder = "Title".localize()
        documentTitleTxtField.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["documentTitleTxtField"] = documentTitleTxtField
        documentTitleTxtField.addBorder(edges: .bottom)
        documentTitleTxtField.delegate = self

        documentDateTxtField.placeholder = "(yyyy-mm-dd) Expiry Date".localize()
        documentDateTxtField.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["documentDateTxtField"] = documentDateTxtField
        documentDateTxtField.addBorder(edges: .bottom)
        documentDateTxtField.delegate = self

        okBtn.setTitle("OK".localize(), for: .normal)
        okBtn.backgroundColor = .secondaryColor
        okBtn.setTitleColor(.themeColor, for: .normal)
        okBtn.layer.borderColor = UIColor.themeColor.cgColor
        okBtn.layer.borderWidth = 1.0
        okBtn.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["okBtn"] = okBtn
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[documentHideBtn]|", options: [], metrics: nil, views: layoutDic))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[documentHideBtn]|", options: [], metrics: nil, views: layoutDic))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(30)-[containerView]-(30)-|", options: [], metrics: nil, views: layoutDic))
        containerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
       
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(16)-[documentImgBtn(120)]-(10)-[documentTitleTxtField]", options: [], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[documentTitleTxtField(30)]-(10)-[documentDateTxtField(30)]", options: [.alignAllLeading,.alignAllTrailing], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[documentDateTxtField]-(16)-|", options: [], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[documentImgBtn(240)]", options: [], metrics: nil, views: layoutDic))
            documentImgBtn.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[documentDateTxtField]-(10)-[okBtn(30)]-(16)-|", options: [.alignAllCenterX], metrics: nil, views: layoutDic))
        okBtn.widthAnchor.constraint(equalToConstant: 80).isActive = true
        self.layoutIfNeeded()
        self.setNeedsLayout()
        okBtn.layer.cornerRadius = okBtn.bounds.height/2.0
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "", options: [], metrics: nil, views: layoutDic))
        okBtn.addTarget(self, action: #selector(okBtnAction(_:)), for: .touchUpInside)

        documentTitleTxtField.textAlignment = HelperClass.appTextAlignment
        documentDateTxtField.textAlignment = HelperClass.appTextAlignment
    }
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        let hitView = super.hitTest(point, with: event)
//        if hitView == self
//        {
//            self.isHidden = true
//            return nil
//        }
//        else
//        {
//
//            return hitView
//        }
//    }
    func showUploadDocumentView(_ document:Document?)
    {
        currentDoc = document
        self.isHidden = false
        if let document = document
        {
            if let image = document.image
            {
                documentImgBtn.setImage(image, for: .normal)
            }
            else
            {
                documentImgBtn.setImage(UIImage(named:"Document_PlaceHolder"), for: .normal)
            }
            documentTitleTxtField.text = document.title
            documentDateTxtField.text = document.dateStr


        }
    }


    @objc func okBtnAction(_ sender:UIButton)
    {
        currentDoc.title = documentTitleTxtField.text!
        currentDoc.date = documentDateTxtField.datePicker.date
        currentDoc.dateStr = documentDateTxtField.text!
//        currentDoc.image =
        delegate.okBtnTapped(currentDoc)
    }
    //MARK:- UIImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        

        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        {
            currentDoc.image = image
            documentImgBtn.setImage(image, for: .normal)
            currentDoc.imageUploaded = true
        }
        else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            currentDoc.image = image
            documentImgBtn.setImage(image, for: .normal)
            currentDoc.imageUploaded = true
        }
        else
        {
            currentDoc.imageUploaded = false
        }
        picker.dismiss(animated: true, completion: nil)
    }
    //UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {        
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return  textField != documentDateTxtField
    }
}
struct Document:Equatable
{

//    lhs.docType == rhs.docType &&
    static func ==(lhs: Document, rhs: Document) -> Bool {
        return lhs.title == rhs.title && lhs.date == rhs.date && lhs.dateStr == rhs.dateStr && lhs.image == rhs.image
    }
    func validateAll()->Bool
    {
        return title.trimmingCharacters(in: .whitespaces).count > 0 && date != nil && dateStr.trimmingCharacters(in: .whitespaces).count > 0 && image != nil && imageUploaded
    }
//    var docType:DocumentType!
    var documentExpired: Bool?
    var id: String?
    var title:String = ""
    var date:Date!
    var dateStr:String = ""
    var image:UIImage!
    var imageUploaded:Bool!

    init(_ dict: [String: AnyObject]) {
        if let docURl = dict["document"] as? String {
            if  let imgUrl = URL(string: docURl) {
                self.imageUploaded = true
                if let imgData = try? Data(contentsOf: imgUrl) {
                    self.image = UIImage(data: imgData)
                }

            }

        }

        if let docName = dict["document_name"] as? String {
            self.title = docName
        }
        if let docDate = dict["document_ex_date"] as? String ?? dict["documentExpiry"] as? String {
            self.dateStr = docDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            self.date = dateFormatter.date(from: docDate)
        }
        if let docExpire = dict["document_expired"] as? Bool{
            self.documentExpired = docExpire

        }
        if let id = dict["id"] as? Int {
            self.id = String(id)

        }


        }

}




