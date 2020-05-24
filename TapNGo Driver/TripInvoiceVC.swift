//
//  TripInvoiceVC.swift
//  TapNGo Driver
//
//  Created by Spextrum on 10/02/18.
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

class TripInvoiceVC: UIViewController,UITableViewDelegate,UITableViewDataSource
{

    var layoutDic = [String:AnyObject]()
    var top:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var bottom:NSLayoutAnchor<NSLayoutYAxisAnchor>!

    //***** Variables for Data Received from Previous ViewControllers *****
    var InvoiceDetailsDict = [String:AnyObject]()
    var CompletedTripDetailsDict = [String:AnyObject]()
    var CustomersDetailsDict = NSDictionary()
    
//    var TripRequestID = String()
//    var TripIsDriverArrived = String()
//    var TripIsStarted = String()
//    var TripIsCompleted = String()
//    var LDBCustomerFName = String()
//    var LDBCustomerLName = String()
//    var LDBCustomerID = String()
//    var LDBCustomerPhone = String()
//    var LDBCustomerPicture = String()
//    var LDBCustomerEmail = String()
//    var LDBCustomerReview = String()

    @IBOutlet weak var BGView1ForInvoiceLbl: UIView!
    @IBOutlet weak var LblInvoice: UILabel!
    @IBOutlet weak var BtnConfirm: UIButton!
    @IBOutlet weak var InvoiceTable: UITableView!
    @IBOutlet weak var BGViewForTotal: UIView!
    @IBOutlet weak var ImgDottedLine: UIImageView!
    @IBOutlet weak var ImgSawtooth: UIImageView!
    @IBOutlet weak var LblTotal: UILabel!
    @IBOutlet weak var LblTotalValue: UILabel!
    
    
    let Pref = UserDefaults.standard
    
    let AppDelegates = UIApplication.shared.delegate as! AppDelegate
//    let HelperObject = HelperClass()

    let socket = SocketIOClient(socketURL: HelperClass.socketUrl)
    var JsonStringToServer = NSString()
    
    var invoiceContentArray:Array = [String]()
    var basePriceValue = String()
    var distanceCostValue = String()
    var timeCostValue = String()
    var WaitingCostValue = String()
    var ServiceTaxValue = String()
    var ReferralBonusValue = String()
    var PromoBonusValue = String()
    var PricePerDistanceValue = String()
    var PricePerTimeValue = String()
    var CurrencySymbol = String()
    var TotalCost = String()
    var extraAmount = String()



    override func viewDidLoad()
    {
        super.viewDidLoad()

        LblInvoice.font = UIFont.appBoldTitleFont(ofSize: LblInvoice.font!.pointSize)
        BtnConfirm.titleLabel!.font = UIFont.appBoldTitleFont(ofSize: BtnConfirm.titleLabel!.font!.pointSize)
        LblTotal.font = UIFont.appBoldTitleFont(ofSize: LblTotal.font!.pointSize)
        LblTotalValue.font = UIFont.appBoldTitleFont(ofSize: LblTotalValue.font!.pointSize)

        InvoiceTable.delegate = self
        InvoiceTable.dataSource = self
        InvoiceTable.allowsMultipleSelection = false
        InvoiceTable.tableFooterView = UIView()
        invoiceContentArray = ["Base Price".localize(),"Distance Cost".localize(),"Time Cost".localize(),"Waiting Cost".localize(),"Service Tax".localize(),"Referral Bonus".localize(),"Promo Bonus".localize(),"Additional charge".localize()]

//        self.GetTripInvoiceDetails()
        if InvoiceDetailsDict.isEmpty
        {
            print("Complete trip details which is received from end trip api is not available")
        }
        print(InvoiceDetailsDict)
        if let basePrice = self.InvoiceDetailsDict["base_price"] as? Double
        {
            basePriceValue = String(format: "%.2f", basePrice) // "\(basePrice)"
        }
        if let distancePrice = self.InvoiceDetailsDict["distance_price"] as? Double
        {
            distanceCostValue = String(format: "%.2f", distancePrice)//"\(distancePrice)"
        }
        if let timePrice = self.InvoiceDetailsDict["time_price"] as? Double
        {
            timeCostValue = String(format: "%.2f", timePrice)//"\(timePrice)"
        }
        if let waitingPrice = self.InvoiceDetailsDict["waiting_price"] as? Double
        {
            WaitingCostValue = String(format: "%.2f", waitingPrice)//"\(waitingPrice)"
        }
        if let serviceTax = self.InvoiceDetailsDict["service_tax"] as? Double
        {
            ServiceTaxValue = String(format: "%.2f", serviceTax)//"\(serviceTax)"
        }
        if let referralAmount = self.InvoiceDetailsDict["referral_amount"] as? Double
        {
            ReferralBonusValue = String(format: "%.2f", referralAmount)//"\(referralAmount)"
        }
        if let promoAmount = self.InvoiceDetailsDict["promo_amount"] as? Double
        {
            PromoBonusValue = String(format: "%.2f", promoAmount)//"\(promoAmount)"
        }
        if let pricePerDistance = self.InvoiceDetailsDict["price_per_distance"] as? Double
        {
            PricePerDistanceValue = String(format: "%.2f", pricePerDistance)//"\(pricePerDistance)"
        }
        if let pricePerTime = self.InvoiceDetailsDict["price_per_time"] as? Double
        {
            PricePerTimeValue = String(format: "%.2f", pricePerTime)//"\(pricePerTime)"
        }
        if let currency = self.InvoiceDetailsDict["currency"]
        {
             CurrencySymbol = "\(currency)"
        }
        if let total = self.InvoiceDetailsDict["total"] as? Double
        {
            TotalCost = String(format: "%.2f", total)//"\(total)"
        }
        if let total = self.InvoiceDetailsDict["total"] as? String
        {
            TotalCost = total
        }
        if let extraamount = self.InvoiceDetailsDict["extra_amount"] as? String
        {
            extraAmount = extraamount
        }
        print("\(CurrencySymbol) \(extraAmount)")

        self.LblTotalValue.text! = "\(CurrencySymbol) \(TotalCost)"
//        self.DeleteCancelledTripDetails()
        self.setUpViews()

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
        BGView1ForInvoiceLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BGView1ForInvoiceLbl"] = BGView1ForInvoiceLbl
        LblInvoice.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["LblInvoice"] = LblInvoice
        BtnConfirm.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnConfirm"] = BtnConfirm
        InvoiceTable.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["InvoiceTable"] = InvoiceTable
        BGViewForTotal.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BGViewForTotal"] = BGViewForTotal
        ImgDottedLine.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["ImgDottedLine"] = ImgDottedLine
        ImgSawtooth.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["ImgSawtooth"] = ImgSawtooth
        LblTotal.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["LblTotal"] = LblTotal
        LblTotalValue.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["LblTotalValue"] = LblTotalValue

        BGView1ForInvoiceLbl.topAnchor.constraint(equalTo: self.top).isActive = true
        BtnConfirm.bottomAnchor.constraint(equalTo: self.bottom).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[BGView1ForInvoiceLbl(118)]-(8)-[InvoiceTable(302)][BGViewForTotal(40)]-(>=20)-[BtnConfirm(43)]", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[BGView1ForInvoiceLbl]|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[InvoiceTable]-(16)-|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[BGViewForTotal]-(16)-|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[BtnConfirm]|", options: [], metrics: nil, views: layoutDic))

        BGView1ForInvoiceLbl.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[LblInvoice]-(20)-|", options: [], metrics: nil, views: layoutDic))
        BGView1ForInvoiceLbl.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(35)-[LblInvoice(35)]", options: [], metrics: nil, views: layoutDic))
        ImgSawtooth.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: -12).isActive = true
        ImgSawtooth.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 12).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[BGView1ForInvoiceLbl]-(-27)-[ImgSawtooth(355)]", options: [], metrics: nil, views: layoutDic))
        BGViewForTotal.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(2)-[ImgDottedLine(5)]-(3)-[LblTotal]-(2)-|", options: [], metrics: nil, views: layoutDic))
        BGViewForTotal.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(10)-[LblTotal]-(10)-[LblTotalValue(==LblTotal)]-(10)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))

        BGViewForTotal.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[ImgDottedLine]|", options: [], metrics: nil, views: layoutDic))

        LblTotal.textAlignment = HelperClass.appTextAlignment
        LblTotalValue.textAlignment = HelperClass.appTextAlignment == .left ? .right : .left
        LblInvoice.textAlignment = HelperClass.appTextAlignment
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
       // self.title = "App Name".localize().uppercased(with: Locale(identifier: HelperClass.currentAppLanguage))
//        if let title = HelperClass.shared.appName {
//            self.title = title
//        }
        self.title = "TapNgo Driver"
        customFormat()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func customFormat()
    {
//        self.navigationItem.hidesBackButton = true
        
    }
    
    
    @IBAction func ConfirmBtn(_ sender: Any)
    {
        let feedbackVC = self.storyboard?.instantiateViewController(withIdentifier: "FeedbackVC") as! FeedbackVC
        feedbackVC.CompletedRequestID = HelperClass.shared.currentTripDetail.acceptedRequestId
        feedbackVC.CustomerData = self.CustomersDetailsDict
        feedbackVC.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(feedbackVC, animated: true)
//        self.DeleteCancelledTripDetails()
//        self.performSegue(withIdentifier: "InvoiceVCToFeedbackVC", sender: self)
    }
    
    // ***** Tableview Methods *****
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return invoiceContentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InvoiceTableCell", for: indexPath) as! InvoiceTableCell
        cell.LblInvoiceContent.text! = invoiceContentArray[indexPath.row]
        
        if indexPath.row == 0
        {
            //cell.priceLbl.text = "Base Price"
            cell.LblInvoiceContentPrice.textColor = UIColor.darkGray
            cell.LblInvoiceContentPrice.text! = "\(CurrencySymbol) \(basePriceValue)"
            
        }
        else if indexPath.row == 1
        {
            //cell.priceLbl.text = "Distance Price"
            cell.LblInvoiceContentPrice.textColor = UIColor.darkGray
            cell.LblInvoiceContentPrice.text! = "\(CurrencySymbol) \(distanceCostValue)"
//            cell.pricePerHrLbl.text = "\(pricePerKMStr) \(currencySymbolStr) \("/ Km")"
        }
        else if indexPath.row == 2
        {
            //cell.priceLbl.text = "Time Price"
            cell.LblInvoiceContentPrice.textColor = UIColor.darkGray
            cell.LblInvoiceContentPrice.text! = "\(CurrencySymbol) \(timeCostValue)"
//            cell.pricePerHrLbl.text = "\(pricePerHrStr) \(currencySymbolStr) \("/ Hr")"
        }
        else if indexPath.row == 3
        {
            //cell.priceLbl.text = "Referral Bonus"
            cell.LblInvoiceContentPrice.textColor = UIColor(red: 57/255, green: 213/255, blue: 122/255, alpha: 1)
            cell.LblInvoiceContentPrice.text! = "\(CurrencySymbol) \(WaitingCostValue)"
//            cell.pricePerHrLbl.text = ""
        }
        else if indexPath.row == 4
        {
            //cell.priceLbl.text = "Promo Bonus"
            cell.LblInvoiceContentPrice.textColor = UIColor(red: 57/255, green: 213/255, blue: 122/255, alpha: 1)
            cell.LblInvoiceContentPrice.text! = "\(CurrencySymbol) \(ServiceTaxValue)"
//            cell.pricePerHrLbl.text = ""
        }
        else if indexPath.row == 5
        {
            //cell.priceLbl.text = "Promo Bonus"
            cell.LblInvoiceContentPrice.textColor = UIColor(red: 57/255, green: 213/255, blue: 122/255, alpha: 1)
            cell.LblInvoiceContentPrice.text! = "\(CurrencySymbol) \(ReferralBonusValue)"
            //            cell.pricePerHrLbl.text = ""
        }
        else if indexPath.row == 6
        {
            //cell.priceLbl.text = "Promo Bonus"
            cell.LblInvoiceContentPrice.textColor = UIColor(red: 57/255, green: 213/255, blue: 122/255, alpha: 1)
            cell.LblInvoiceContentPrice.text! = "\(CurrencySymbol) \(PromoBonusValue)"
            //            cell.pricePerHrLbl.text = ""
        }
        else if indexPath.row == 7
        {
            //cell.priceLbl.text = "Promo Bonus"
            cell.LblInvoiceContentPrice.textColor = UIColor(red: 57/255, green: 213/255, blue: 122/255, alpha: 1)
            cell.LblInvoiceContentPrice.text! = "\(CurrencySymbol) \(extraAmount)"
            //            cell.pricePerHrLbl.text = ""
        }

        
        
        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 252
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
//    func getContext () -> NSManagedObjectContext
//    {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        return appDelegate.persistentContainer.viewContext
//    }

//    func GetTripInvoiceDetails()
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
////                print("Hello",trip.value(forKey: "bill_baseprice") as! String?.Type)
////                print("\(String(describing: trip.value(forKey: "accepted_request_id")))")
////                TripRequestID = trip.value(forKey: "accepted_request_id") as! String
//
////                LDBCustomerFName = trip.value(forKey: "request_customer_firstname")as! String
////                LDBCustomerLName = trip.value(forKey: "request_customer_lastname")as! String
////                LDBCustomerID =  trip.value(forKey: "request_customer_id")as! String
////                LDBCustomerEmail =  trip.value(forKey: "request_customer_email")as! String
////                LDBCustomerPhone =  trip.value(forKey: "request_customer_phonenumber")as! String
////                LDBCustomerPicture =  trip.value(forKey: "request_customer_profilepicture")as! String
////                LDBCustomerReview =  trip.value(forKey: "request_customer_review")as! String
//
////                BasePriceValue = trip.value(forKey: "bill_baseprice") as! String?.Type
////                DistanceCostValue = trip.value(forKey: "bill_distancecost") as! String?.Type
////                TimeCostValue = trip.value(forKey: "bill_timecost") as! String?.Type
////                WaitingCostValue = trip.value(forKey: "bill_waitingcost") as! String?.Type
////                ServiceTaxValue = trip.value(forKey: "bill_servicetax") as! String?.Type
////                ReferralBonusValue = trip.value(forKey: "bill_referralbonus") as! String?.Type
////                PromoBonusValue = trip.value(forKey: "bill_promobonus") as! String?.Type
////                PricePerDistanceValue = trip.value(forKey: "bill_price_per_distance") as! String?.Type
////                PricePerTimeValue = trip.value(forKey: "bill_price_per_time") as! String?.Type
////                CurrencySymbol = trip.value(forKey: "bill_currency") as! String?.Type
////                TotalCost = trip.value(forKey: "bill_totalamount") as! String?.Type
//
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
//


    

}
