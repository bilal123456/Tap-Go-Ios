//
//  RegisterVehicleDetailsVC.swift
//  TapNGo Driver
//
//  Created by Spextrum on 09/10/17.
//  Copyright © 2017 nPlus. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
import Localize
import Kingfisher

class RegisterVehicleDetailsVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, UITextFieldDelegate
{
    struct VehicleType:Codable
    {
        var name:String?
        var id:String?
        var imgUrlStr:String?
        init(_ dict:[String:AnyObject]) {
            self.name = dict["name"] as? String
            self.imgUrlStr = dict["icon"] as? String
            if let id = dict["id"] as? Int
            {
                self.id = String(id)
            }
        }
    }
    
    var layoutDic = [String:AnyObject]()
    var top:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var bottom:NSLayoutAnchor<NSLayoutYAxisAnchor>!

    //***** Variables for Data Received from Previous ViewController *****
    var userDetails:UserDetails!
    var callback : ((UserDetails) -> Void)?
    
//    var FirstName = String()
//    var LastName = String()
//    var Email = String()
//    var Mobile = String()
//    var country:String!
//    var countryCode:String!
//    var Password = String()
//    var ProfileImage = UIImage()
//    var areaId:Int!

    var selectedVehicleType = String()
    var isVehicleSelected = String()
    
    var activityView: NVActivityIndicatorView!

    
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var carImgView: UIImageView!
    
    @IBOutlet weak var vehicleInfoLbl: UILabel!
    
    @IBOutlet weak var leftDisclosureBtn: UIButton!
    @IBOutlet weak var rightDisclosureBtn: UIButton!
    @IBOutlet weak var vehicleTypesCollectionView: UICollectionView!
    @IBOutlet weak var vehicleNumberTxtField: UITextField!
    @IBOutlet weak var vehicleModelTxtField: UITextField!
    var txtCarMake = UITextField()
    var txtCarColor = UITextField()
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextBtn: UIButton!
    
    
    
    
    let AppDelegates = UIApplication.shared.delegate as! AppDelegate
//    let HelperObject = HelperClass()

    var vehicleTypes = [VehicleType]()
    var selectedCell: Int! = 0


//    var VehicleNameArray = NSArray()
//    var VehicleImageArray = NSArray()



    override func viewDidLoad()
    {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.vehicleTypesCollectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        print(self.userDetails)
        GetVehicleTypes()
        isVehicleSelected = "NO"
//        VehicleNameArray = ["Home","Logout"]
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

        nextBtn.backgroundColor = .themeColor

        
        bgImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["bgImgView"] = bgImgView
        carImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["carImgView"] = carImgView
        carImgView.contentMode = .scaleAspectFit
        vehicleInfoLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["LblVehicleInfo"] = vehicleInfoLbl
        leftDisclosureBtn.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnLeftDisclosure"] = leftDisclosureBtn
        rightDisclosureBtn.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnRightDisclosure"] = rightDisclosureBtn

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 200, height: 110)
        vehicleTypesCollectionView.collectionViewLayout = layout
        vehicleTypesCollectionView.allowsMultipleSelection = false
        vehicleTypesCollectionView.showsHorizontalScrollIndicator = false
        vehicleTypesCollectionView.showsVerticalScrollIndicator = false
        vehicleTypesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom:0, right: 0)
        vehicleTypesCollectionView.isPagingEnabled = true

        vehicleTypesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["CollectionViewVehicle"] = vehicleTypesCollectionView

        vehicleNumberTxtField.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["TxtVehicleNumber"] = vehicleNumberTxtField
        vehicleNumberTxtField.addBorder(edges: .bottom)
        vehicleModelTxtField.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["TxtVehicleModel"] = vehicleModelTxtField
        vehicleModelTxtField.addBorder(edges: .bottom)

        txtCarMake.placeholder = "Car Make"
        txtCarMake.font = UIFont.appFont(ofSize: txtCarColor.font!.pointSize)
        txtCarMake.textAlignment = .center
        txtCarMake.addBorder(edges: .bottom)
        txtCarMake.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["txtCarMake"] = txtCarMake
        self.view.addSubview(txtCarMake)

        txtCarColor.placeholder = "Car Color"
        txtCarColor.font = UIFont.appFont(ofSize: txtCarColor.font!.pointSize)
        txtCarColor.textAlignment = .center
        txtCarColor.addBorder(edges: .bottom)
        txtCarColor.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["txtCarColor"] = txtCarColor
        self.view.addSubview(txtCarColor)

        pageControl.pageIndicatorTintColor = .yellow
        pageControl.currentPageIndicatorTintColor = .themeColor
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["pageControl"] = pageControl

        nextBtn.backgroundColor = .secondaryColor
        nextBtn.setTitleColor(.themeColor, for: .normal)
        nextBtn.layer.borderColor = UIColor.themeColor.cgColor
        nextBtn.layer.borderWidth = 1.0
        nextBtn.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnNext"] = nextBtn
        
        bgImgView.topAnchor.constraint(equalTo: self.top, constant: 0).isActive = true
        bgImgView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1/6).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bgImgView]|", options: [], metrics: nil, views: layoutDic))
        self.carImgView.widthAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1/7).isActive = true
        self.carImgView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1/7).isActive = true
        self.carImgView.centerXAnchor.constraint(equalTo: bgImgView.centerXAnchor).isActive = true
        self.carImgView.centerYAnchor.constraint(equalTo: bgImgView.bottomAnchor).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[carImgView]-(20)-[LblVehicleInfo(25)]-(25)-[CollectionViewVehicle(110)]-(20)-[TxtVehicleNumber(30)]", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=10)-[BtnLeftDisclosure(30)]-(20)-[CollectionViewVehicle(200)]-(20)-[BtnRightDisclosure(30)]-(>=10)-|", options: [.alignAllCenterY], metrics: nil, views: layoutDic))
        self.vehicleTypesCollectionView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.leftDisclosureBtn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        self.rightDisclosureBtn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[TxtVehicleNumber]-4-[txtCarMake(30)]-(>=20)-[pageControl(20)]-(5)-[BtnNext(40)]-(20)-|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[TxtVehicleNumber]-4-[txtCarColor(30)]", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[LblVehicleInfo(150)]", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[TxtVehicleNumber]-(8)-[TxtVehicleModel(==TxtVehicleNumber)]-(16)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[txtCarMake]-(8)-[txtCarColor(==txtCarMake)]-(16)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))

        self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.pageControl.widthAnchor.constraint(equalToConstant: 60).isActive = true
        self.nextBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.nextBtn.widthAnchor.constraint(equalToConstant: 120).isActive = true
        nextBtn.bottomAnchor.constraint(equalTo: self.bottom, constant: -20).isActive = true
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
        nextBtn.layer.cornerRadius = nextBtn.bounds.height/2

        vehicleInfoLbl.textAlignment = HelperClass.appTextAlignment

        self.vehicleModelTxtField.text = self.userDetails.carModel
        self.vehicleNumberTxtField.text = self.userDetails.carNumber
        self.txtCarMake.text = self.userDetails.carMake
        self.txtCarColor.text = self.userDetails.carColor
        self.selectedVehicleType = self.userDetails.type

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

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // ***** CollectionView Delegate Methods *****
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.vehicleTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VehicleCollectionViewCell", for: indexPath as IndexPath) as! VehicleCollectionViewCell
        
        cell.vehicleName.text = self.vehicleTypes[indexPath.item].name
        
        if let imgUrlStr = self.vehicleTypes[indexPath.item].imgUrlStr, let vehicleTypeImageUrl = URL(string:imgUrlStr)
        {
            let resource = ImageResource(downloadURL: vehicleTypeImageUrl)
            cell.vehicleImgView.kf.setImage(with: resource)
        }        
        if self.vehicleTypes[indexPath.row].id == selectedVehicleType
        {
            cell.vehicleSelectImgView.isHidden=false
        }
        else
        {
            cell.vehicleSelectImgView.isHidden=true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if let id = self.vehicleTypes[indexPath.item].id
        {
            selectedVehicleType = id
        }
        self.userDetails.type = self.selectedVehicleType
//        // handle tap events
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VehicleCollectionViewCell", for: indexPath as IndexPath) as! VehicleCollectionViewCell
//        print("You selected cell #\(indexPath.item)!")
//        cell.backgroundColor = UIColor.cyan
//        isVehicleSelected = "YES"
//
//        let z : Int = Int(((indexPath.item) as NSNumber))
//        SelectedVehicleType = String(z)
//        print("Selected Vehicle ID =",SelectedVehicleType)
//
//        self.vehicledummyarray[indexPath.row]="1"
//        self.VehicleselectArray=self.vehicledummyarray
//        vehicledummyarray=NSMutableArray()
//        for ss in self.VehicleNameArray
//        {
//            self.vehicledummyarray.add("0")
//        }
        self.vehicleTypesCollectionView.reloadData()
    }

    @IBAction func LeftDisclosureBtn(_ sender: Any)
    {
        if let currentCell = self.vehicleTypesCollectionView.indexPathsForVisibleItems.sorted().first, currentCell.item != 0
        {
            self.vehicleTypesCollectionView.scrollToItem(at:IndexPath(item: currentCell.item-1, section: 0), at: .left, animated: false)
        }
    }
    
    
    @IBAction func RightDisclosureBtn(_ sender: Any)
    {
        if let currentCell = self.vehicleTypesCollectionView.indexPathsForVisibleItems.sorted().first, currentCell.item+1 != self.vehicleTypesCollectionView.numberOfItems(inSection: 0)
        {
            self.vehicleTypesCollectionView.scrollToItem(at:IndexPath(item: currentCell.item+1, section: 0), at: .right, animated: false)
        }
    }
        
    @IBAction func nextBtnAction(_ sender: Any)
    {
        if(selectedVehicleType.isEmpty)
        {
            self.showAlert("Alert".localize(), message: "Please Choose Your Vehicle Type".localize())
            return
        }
        else if(vehicleNumberTxtField.text!.trimmingCharacters(in: .whitespaces).isEmpty)
        {
            self.showAlert("Alert".localize(), message: "Please Enter Your Vehicle Number".localize())
            return
        }
        else if(vehicleModelTxtField.text!.trimmingCharacters(in: .whitespaces).isEmpty)
        {
            self.showAlert("Alert".localize(), message: "Please Enter Your Vehicle Model".localize())
            return
        }
        else if(txtCarMake.text!.trimmingCharacters(in: .whitespaces).isEmpty)
        {
            self.showAlert("Alert".localize(), message: "car make field should not be empty".localize())
            return
        }
        else if(txtCarColor.text!.trimmingCharacters(in: .whitespaces).isEmpty)
        {
            self.showAlert("Alert".localize(), message: "Please Enter Your car color".localize())
            return
        }
        else
        {
            
            let registerVehicleDocumentsVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterVehicleDocumentsVC") as! RegisterVehicleDocumentsVC
            self.userDetails.carModel = self.vehicleModelTxtField.text!
            self.userDetails.carNumber = self.vehicleNumberTxtField.text!
            self.userDetails.carMake = self.txtCarMake.text!
            self.userDetails.carColor = self.txtCarColor.text!
            self.userDetails.type = self.selectedVehicleType
            registerVehicleDocumentsVC.userDetails = userDetails
            registerVehicleDocumentsVC.callback = { [unowned self] userDetails in
                self.userDetails = userDetails
                print(userDetails)
            }
            self.navigationController?.pushViewController(registerVehicleDocumentsVC, animated: true)

        }
    }

    func customFormat()
    {
        self.navigationItem.backBtnString = ""
//        nextBtn.layer.cornerRadius = 10
    }
    
    
    func GetVehicleTypes()
    {
        if ConnectionCheck.isConnectedToNetwork()
        {
            print("Connected")
            
            self.showLoadingIndicator()
            let params:[String:Any] = ["admin_id":self.userDetails.adminId]
            let url = HelperClass.BASEURL+HelperClass.GetVehicleTypeURL
            print(url)
            Alamofire.request(url, method:.post, parameters: params, encoding: JSONEncoding.default, headers: HelperClass.Header)
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
                                self.vehicleTypes = (JSON["types"] as! [[String:AnyObject]]).map({ VehicleType($0) })
                                print("Vehicle types =",self.vehicleTypes)
                            }
                            else
                            {
                                print(JSON["error_message"] as! String)
                            }
                        }
                        self.vehicleTypesCollectionView.reloadData()
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

    


    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        if(textField==self.vehicleModelTxtField)
        {
            let maxLength = 15
            let currentString: NSString = self.vehicleModelTxtField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        else if( textField==self.vehicleNumberTxtField)
        {
            let maxLength = 15
            let currentString: NSString = self.vehicleNumberTxtField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.vehicleModelTxtField {
            self.userDetails.carModel = self.vehicleModelTxtField.text!
        }
        else if textField == self.vehicleNumberTxtField {
            self.userDetails.carNumber = self.vehicleNumberTxtField.text!
        }
        else if textField == self.txtCarMake {
            self.userDetails.carMake = self.txtCarMake.text!
        }
        else if textField == self.txtCarColor {
            self.userDetails.carColor = self.txtCarColor.text!
        }
    }

    

}


