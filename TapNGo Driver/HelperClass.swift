//
//  HelperClass.swift
//  TapNGo Driver
//
//  Created by Spextrum on 07/10/17.
//  Copyright © 2017 nPlus. All rights reserved.
//

import UIKit
import Foundation
import NVActivityIndicatorView
import Alamofire
import Localize
import IQKeyboardManagerSwift
import CoreData
import Kingfisher

protocol LogoutDelegate {
    func logedOut()
}

class HelperClass: NSObject
{
    static let shared = HelperClass()
    var delegate:LogoutDelegate?

    private override init() {
        super.init()
    }
    var currentTripDetail:TripDetail!

    var activityView: NVActivityIndicatorView!
    // Application Base URL

    static let BASEURL = "http://35.176.117.118/tapngo/public/v1/"
    static let socketUrl = URL(string: "http://35.176.117.118:3001")!

//    static let BASEURL = "http://192.168.1.18/tapngo/public/v1/"
//    static let socketUrl = URL(string: "http://192.168.1.18:3002")!

    // Other URL Suffixes
    static let Header = ["Accept":"application/json"]
    
    static let LoginURL                      = "driver/login"
    static let RegisterForOTPURL             = "driver/new_register"
    static let ChangeDriverAvailablityURL    = "driver/toogle/status"
    static let ResendOTPURL                  = "driver/resendotp"
    static let CheckOTPURL                   = "driver/checkotp"
    static let RegisterURL                   = "driver/register_update"
    static let driverRegister                = "driver/signup"
    static let RespondToRequestURL           = "driver/response"
    static let DriverArrivedToPlaceURL       = "driver/arrived"
    static let CancelTripURL                 = "driver/trip/cancel"
    static let StartTheTripURL               = "driver/trip/start"
    static let EndTheTripURL                 = "driver/requestBill"
    static let GiveRatingURL                 = "driver/review"
    static let DriverUpdateProfileURL        = "driver/profile"
    static let getAreaList                   = "driver/admin/list"
    static let GetVehicleTypeURL             = "application/types"
    static let DriverHistoryURL              = "driver/history"
    static let ForgetPasswordURL             = "driver/forgotpassword"
    static let OnTripUpdateDriverLocationURL = "request/location"
    static let CreateInstantJobURL           = "driver/createrequest"
    static let LogoutURL                     = "driver/logout"
    static let TokenGeneraterURL             = "user/temptoken"
    static let DriverComplaintsListURL       = "compliants/list"
    static let savecomplaint                 = "compliants/driver"
    static let gethistorydata                = "driver/historyList"
    static let gethistorydetails             = "driver/historySingle"
    static let documentToken                 = "document/tokenGenerate"
    static let documentImageUpload           = "document/imageUpload"
    static let getrequestinprogress          = "driver/requestInprogress"
    static let cancelReasonList              = "cancellation/list"
    static let DocumentList                  = "driver/document/list"
    static let DocumentListUpdate            = "driver/document/list_update"
    static let DocumentListDelete            = "driver/document/list_delete"
    static let privacyPolicy                 = "privacy_policy"
   
    // ***** Reusable Functions *****
    var userName = String()
    var userLastName = String()
    var userID  = String()
    var userToken = String()
    var isUserApproved = String()
    var isUserActive  = String()
    var isUserAvailable = String()
    var userPhone = String()
    var userProfilePicture = String()
    var userProfileImg:ImageResource?
    var userEmail = String()
    var carModel = String()
    var carNumber = String()
    var carTypeName = String()
    
    var receivedRequestData = NSDictionary()
    var receivedRequestUserData = NSDictionary()
    var invoiceDataDict = [String:AnyObject]()
    var completedTripDataDict = [String:AnyObject]()
    var customerID  = String()
    var receivedRequestID  = String()
    
    //Global property for language direction alignment
    static let appTilteFontName = "Laksaman"
    static let appTilteBoldFontName = "Laksaman"
    static let appFontName = "Padauk-Regular"
    static let appBoldFontName = "Padauk-Bold"

    var appName:String? {
        if let name =  Bundle.main.infoDictionary?["CFBundleName"] as? String {
            return name
        }
        return nil
    }


    static var appLanguageDirection:NSLayoutConstraint.FormatOptions {
        get { return currentAppLanguage == "ar" ? .directionRightToLeft : .directionLeftToRight }
    }
    static var appTextAlignment:NSTextAlignment {
        get { return currentAppLanguage == "ar" ? .right : .left }
    }
    static var appSemanticContentAttribute:UISemanticContentAttribute
    {
        get { return currentAppLanguage == "ar" ? .forceRightToLeft : .forceLeftToRight }
    }
    static var currentAppLanguage:String {
        get {
            return UserDefaults.standard.string(forKey: "currentLanguage") ?? "en"
        }
        set {
            Localize.shared.update(language: newValue)
            Localize.update(language: newValue)
            UserDefaults.standard.set(newValue, forKey: "currentLanguage")
            UserDefaults.standard.synchronize()
            IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Done".localize()
        }
    }
    //MARK:- CORE DATA - USER DETAILS
    func fetchUsersDetails()
    {
        let fetchRequest: NSFetchRequest<Login_UserData> = Login_UserData.fetchRequest()
        do
        {
            let users = try self.persistentContainer.viewContext.fetch(fetchRequest)

            if let user = users.first
            {
                user.entity.attributesByName.keys.forEach { print($0) }
                if let userName = user.value(forKey: "loginuser_firstname") as? String
                {
                    self.userName = userName
                }
                if let userLastName = user.value(forKey: "loginuser_lastname") as? String
                {
                    self.userLastName = userLastName
                }
                if let userID = user.value(forKey: "loginuser_ID") as? String
                {
                    self.userID = userID
                }
                if let userToken = user.value(forKey: "loginuser_token") as? String
                {
                    self.userToken = userToken
                }
                if let isUserActive = user.value(forKey: "loginuser_is_active") as? String
                {
                    self.isUserActive = isUserActive
                }
                if let isUserApproved = user.value(forKey: "loginuser_is_approve") as? String
                {
                    self.isUserApproved = isUserApproved
                }
                if let isUserAvailable = user.value(forKey: "loginuser_is_available") as? String
                {
                    self.isUserAvailable  = isUserAvailable
                }
                if let userPhone = user.value(forKey: "loginuser_phone") as? String
                {
                    self.userPhone  = userPhone
                }
                if let userProfilePicture = user.value(forKey: "loginuser_profilepicture") as? String
                {
                    self.userProfilePicture  = userProfilePicture
                    if let url = URL(string:self.userProfilePicture)
                    {
                        self.userProfileImg = ImageResource(downloadURL: url)
                    }
                }
                if let userEmail = user.value(forKey: "loginuser_email") as? String
                {
                    self.userEmail  = userEmail
                }
                if let carModel = user.value(forKey: "carModel") as? String
                {
                    self.carModel = carModel
                }
                if let carNumber = user.value(forKey: "carNumber") as? String
                {
                    self.carNumber  = carNumber
                }
                if let carTypeName = user.value(forKey: "carTypeName") as? String
                {
                    self.carTypeName  = carTypeName
                }
            }
            else
            {
                print("No users found or More than one user details found. Something went wrong")
            }
        }
        catch
        {
            print("Error with request: \(error)")
        }
    }
    func storeUserDetails(_ userDetails: [String:AnyObject], currentUser:Login_UserData!)
    {
        var user:Login_UserData!
        if currentUser == nil//Insert in core data
        {
            user = Login_UserData(context: self.persistentContainer.viewContext)
        }
        else// update in core data
        {
            user = currentUser
        }
        if let userName = userDetails["firstname"] as? String
        {
            user.loginuser_firstname = userName
        }
        if let userId = userDetails["id"] as? Int
        {
            user.loginuser_ID = String(userId)
        }
        if let userToken = userDetails["token"] as? String
        {
            user.loginuser_token = userToken
        }
        if let isUserApproved = userDetails["is_approve"] as? Int
        {
            user.loginuser_is_approve = String(isUserApproved)
        }
        if let isUserActive = userDetails["is_active"] as? Int
        {
            user.loginuser_is_active = String(isUserActive)
        }
        if let isUserAvailable = userDetails["is_available"] as? Int
        {
            user.loginuser_is_available = String(isUserAvailable)
        }
        if let userLastName = userDetails["lastname"] as? String
        {
            user.loginuser_lastname = userLastName
        }
        if let userEmail = userDetails["email"] as? String
        {
            user.loginuser_email = userEmail
        }
        if let userPhone = userDetails["phone"] as? String
        {
            user.loginuser_phone = userPhone
        }
        if let userProfilePicture = userDetails["profile_pic"] as? String
        {
            user.loginuser_profilepicture = userProfilePicture
        }
        if let carModel = userDetails["car_model"] as? String
        {
            user.carModel = carModel
        }
        if let carNumber = userDetails["car_number"] as? String
        {
            user.carNumber = carNumber
        }
        if let carTypeName = userDetails["type_name"] as? String
        {
            user.carTypeName = carTypeName
        }

        do
        {
            try context.save()
            print("saved!")
            self.fetchUsersDetails()
        }
        catch let error as NSError
        {
            print("Could not save \(error), \(error.userInfo)")
        }
        catch
        {

        }
    }
    func updateUserDetails(_ userDetails:[String:AnyObject])
    {
        let fetchRequest: NSFetchRequest<Login_UserData> = Login_UserData.fetchRequest()
        do
        {
            let users = try self.persistentContainer.viewContext.fetch(fetchRequest)
            if let user = users.first
            {
                self.storeUserDetails(userDetails, currentUser: user)
            }
            else
            {
                print("No users found or something went wrong")
            }
        }
        catch let error
        {
            print("ERROR DELETING : \(error)")
        }
    }
    func deleteUserDetails()
    {
        do {
            let fetchRequest: NSFetchRequest<Login_UserData> = Login_UserData.fetchRequest()
            do
            {
                let objects  = try context.fetch(fetchRequest)
                _ = objects.map{ context.delete($0) }
                try context.save()
                self.userName = String()
                self.userLastName = String()
                self.userID  = String()
                self.userToken = String()
                self.isUserApproved = String()
                self.isUserActive  = String()
                self.isUserAvailable = String()
                self.userPhone = String()
                self.userProfilePicture = String()
                self.userEmail = String()
                delegate?.logedOut()
                print("Deleted!")
            }
            catch let error
            {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    func saveTripDetails(_ Request_Local_Details: [String:AnyObject], currentTrip:Request_AcceptedData!)
    {

        var trip:Request_AcceptedData!
        if currentTrip == nil//Insert in core data
        {
            trip = Request_AcceptedData(context: self.persistentContainer.viewContext)
        }
        else// update in core data
        {
            trip = currentTrip
        }

        if let Accepted_Req_ID = Request_Local_Details["id"] as? Int
        {
            trip.accepted_request_id = String(Accepted_Req_ID)
        }
        if let Req_isDriverArrived = Request_Local_Details["is_driver_arrived"] as? Int
        {
            trip.request_is_driver_arrived = String(Req_isDriverArrived)
        }
        if let Req_isTripStarted = Request_Local_Details["is_trip_start"] as? Int
        {
            trip.request_is_trip_started = String(Req_isTripStarted)
        }
        if let Req_isTripCompleted = Request_Local_Details["is_completed"] as? Int
        {
            trip.request_is_trip_completed = String(Req_isTripCompleted)
        }

        if let customerDetails = Request_Local_Details["user"] as? [String:AnyObject]
        {
            if let email = customerDetails["email"] as? String
            {
                trip.request_customer_email = email
            }
            if let id = customerDetails["id"] as? Int
            {
                trip.request_customer_id = String(id)
            }
            if let review = customerDetails["review"] as? String
            {
                trip.request_customer_review = review
            }
            if let profilePic = customerDetails["profile_pic"] as? String
            {
                trip.request_customer_profilepicture = profilePic
            }
            if let phoneNumber = customerDetails["phone_number"] as? String
            {
                trip.request_customer_phonenumber = phoneNumber
            }
            if let firstname = customerDetails["firstname"] as? String
            {
                trip.request_customer_firstname = firstname
            }
            if let lastname = customerDetails["lastname"] as? String
            {
                trip.request_customer_lastname = lastname
            }
        }
        if let billDetails = Request_Local_Details["bill"] as? [String:AnyObject]
        {
            if let timePrice = billDetails["time_price"] as? String
            {
                trip.bill_timecost = timePrice
            }
            if let basePrice = billDetails["base_price"] as? String
            {
                trip.bill_baseprice = basePrice
            }
            if let promoAmount = billDetails["promo_amount"] as? String
            {
                trip.bill_promobonus = promoAmount
            }
            if let serviceFee = billDetails["service_fee"] as? String
            {
                trip.bill_servicefee = serviceFee
            }
            if let serviceTax = billDetails["service_tax"] as? String
            {
                trip.bill_servicetax = serviceTax
            }
            if let total = billDetails["total"] as? String
            {
                trip.bill_totalamount = total
            }
            if let waitingPrice = billDetails["waiting_price"] as? String
            {
                trip.bill_waitingcost = waitingPrice
            }
            if let baseDistance = billDetails["base_distance"] as? String
            {
                trip.bill_basedistance = baseDistance
            }
            if let distancePrice = billDetails["distance_price"] as? String
            {
                trip.bill_distancecost = distancePrice
            }
            if let driverAmount = billDetails["driver_amount"] as? String
            {
                trip.bill_driverpayment = driverAmount
            }
            if let referralAmount = billDetails["referral_amount"] as? String
            {
                trip.bill_referralbonus = referralAmount
            }
            if let referralAmount = billDetails["referral_amount"] as? String
            {
                trip.bill_referralbonus = referralAmount
            }
            if let walletAmount = billDetails["wallet_amount"] as? String
            {
                trip.bill_wallet_amount = walletAmount
            }
            if let pricePerTime = billDetails["price_per_time"] as? String
            {
                trip.bill_price_per_time = pricePerTime
            }
            if let pricePerDistance = billDetails["price_per_distance"] as? String
            {
                trip.bill_price_per_distance = pricePerDistance
            }
            if let serviceTaxPercentage = billDetails["service_tax_percentage"] as? String
            {
                trip.bill_servicetax_percent = serviceTaxPercentage
            }
            if let currency = billDetails["currency"] as? String
            {
                trip.bill_currency = currency
            }
        }
//        print("My New ID",Accepted_Req_IDString)

//        let TripTotalDistance = Request_Local_Details["distance"] as! String
//        print("My New ID",TripTotalDistance)
//
//        let TripTotalTime = String(describing: (Request_Local_Details["time"] as! NSNumber))
//        print("My New ID",TripTotalTime)


        //save the object
        do
        {
            try self.persistentContainer.viewContext.save()
            print("saved!")
            self.fetchTripDetails()
        }
        catch let error as NSError
        {
            print("Could not save \(error), \(error.userInfo)")
        }
        catch
        {

        }
    }
    func updateTripDetails(_ Request_Local_Details: [String:AnyObject])
    {

        let fetchRequest: NSFetchRequest<Request_AcceptedData> = Request_AcceptedData.fetchRequest()
        do
        {
            let trips = try self.persistentContainer.viewContext.fetch(fetchRequest)
            if let trip = trips.first
            {
                self.saveTripDetails(Request_Local_Details, currentTrip:trip)
//                storeUserDetails(userDetails, currentUser: user)
            }
            else
            {
                print("No users found or something went wrong")
            }
        }
        catch let error
        {
            print("ERROR DELETING : \(error)")
        }
    }

    func fetchTripDetails()
    {
        let fetchRequest: NSFetchRequest<Request_AcceptedData> = Request_AcceptedData.fetchRequest()
        do
        {
            let trips = try self.persistentContainer.viewContext.fetch(fetchRequest)
            if let trip = trips.first
            {
                self.currentTripDetail = TripDetail(trip)
            }
            else
            {
                print("No trips available or something went wrong")
            }
        }
        catch
        {
            print("Error with request: \(error)")
        }
    }
    func deleteTripDetails()
    {
        do {
            let fetchRequest: NSFetchRequest<Request_AcceptedData> = Request_AcceptedData.fetchRequest()
            do
            {
                let objects  = try context.fetch(fetchRequest)
                _ = objects.map{context.delete($0)}
                try context.save()
                self.currentTripDetail = nil
                print("Deleted!")
            }
            catch let error
            {
                print("ERROR DELETING : \(error)")
            }
        }
    }
// MARK: - Core Data Saving support
    var context:NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TapNGo_Driver")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
// MARK: - Core Data Saving support
extension HelperClass
{
    func saveContext ()
    {
        if context.hasChanges
        {
            do
            {
                try context.save()
            }
            catch
            {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
struct TripDetail
{
    var acceptedRequestId:String!
    var billBaseDistance:String!
    var billBasePrice:String!
    var billCurrency:String!
    var billDistanceCost:String!
    var billDriverPayment:String!
    var billPricePerDistance:String!
    var billPricePerTime:String!
    var billPromoBonus:String!
    var billReferralBonus:String!
    var billServiceFee:String!
    var billServiceRax:String!
    var billServiceTaxPercent:String!
    var billTimeCost:String!
    var billTotalAmount:String!
    var billWaitingCost:String!
    var billWalletAmount:String!
    var requestCustomerEmail:String!
    var requestCustomerFirstName:String!
    var requestCustomerId:String!
    var requestCustomerLastName:String!
    var requestCustomerPhoneNumber:String!
    var requestCustomerProfilePicture:String!
    var requestCustomerReview:String!
    var requestDropLocation:String!
    var requestIsCustomerRated:String!
    var requestIsDriverArrived:String!
    var requestIsTripAccepted:String!
    var requestIsTripCancelled:String!
    var requestIsTripCompleted:String!
    var requestIsTripStarted:String!
    var requestPickupLocation:String!
    var requestTripPaymentType:String!
    var tripDistance:String!
    var tripTime:String!




    init(_ trip:Request_AcceptedData) {
        trip.entity.attributesByName.forEach {
            print($0.key)
            print(trip.value(forKey: $0.key) as? String)
        }
        if let acceptedRequestId = trip.value(forKey: "accepted_request_id") as? String
        {
            self.acceptedRequestId = acceptedRequestId
        }
        if let billBaseDistance = trip.value(forKey: "bill_basedistance") as? String
        {
            self.billBaseDistance = billBaseDistance
        }
        if let billBasePrice = trip.value(forKey: "bill_baseprice") as? String
        {
            self.billBasePrice = billBasePrice
        }
        if let billCurrency = trip.value(forKey: "bill_currency") as? String
        {
            self.billCurrency = billCurrency
        }
        if let billDistanceCost = trip.value(forKey: "bill_distancecost") as? String
        {
            self.billDistanceCost = billDistanceCost
        }
        if let billDriverPayment = trip.value(forKey: "bill_driverpayment") as? String
        {
            self.billDriverPayment = billDriverPayment
        }
        if let billPricePerDistance = trip.value(forKey: "bill_price_per_distance") as? String
        {
            self.billPricePerDistance = billPricePerDistance
        }
        if let billPricePerTime = trip.value(forKey: "bill_price_per_time") as? String
        {
            self.billPricePerTime = billPricePerTime
        }
        if let billPromoBonus = trip.value(forKey: "bill_promobonus") as? String
        {
            self.billPromoBonus = billPromoBonus
        }
        if let billReferralBonus = trip.value(forKey: "bill_referralbonus") as? String
        {
            self.billReferralBonus = billReferralBonus
        }
        if let billServiceFee = trip.value(forKey: "bill_servicefee") as? String
        {
            self.billServiceFee = billServiceFee
        }
        if let billServiceRax = trip.value(forKey: "bill_servicetax") as? String
        {
            self.billServiceRax = billServiceRax
        }
        if let billServiceTaxPercent = trip.value(forKey: "bill_servicetax_percent") as? String
        {
            self.billServiceTaxPercent = billServiceTaxPercent
        }
        if let billTimeCost = trip.value(forKey: "bill_timecost") as? String
        {
            self.billTimeCost = billTimeCost
        }
        if let billTotalAmount = trip.value(forKey: "bill_totalamount") as? String
        {
            self.billTotalAmount = billTotalAmount
        }
        if let billWaitingCost = trip.value(forKey: "bill_waitingcost") as? String
        {
            self.billWaitingCost = billWaitingCost
        }
        if let billWalletAmount = trip.value(forKey: "bill_wallet_amount") as? String
        {
            self.billWalletAmount = billWalletAmount
        }
        if let requestCustomerEmail = trip.value(forKey: "request_customer_email") as? String
        {
            self.requestCustomerEmail = requestCustomerEmail
        }
        if let requestCustomerFirstName = trip.value(forKey: "request_customer_firstname") as? String
        {
            self.requestCustomerFirstName = requestCustomerFirstName
        }
        if let requestCustomerId = trip.value(forKey: "request_customer_id") as? String
        {
            self.requestCustomerId = requestCustomerId
        }
        if let requestCustomerLastName = trip.value(forKey: "request_customer_lastname") as? String
        {
            self.requestCustomerLastName = requestCustomerLastName
        }
        if let requestCustomerPhoneNumber = trip.value(forKey: "request_customer_phonenumber") as? String
        {
            self.requestCustomerPhoneNumber = requestCustomerPhoneNumber
        }
        if let requestCustomerProfilePicture = trip.value(forKey: "request_customer_profilepicture") as? String
        {
            self.requestCustomerProfilePicture = requestCustomerProfilePicture
        }
        if let requestCustomerReview = trip.value(forKey: "request_customer_review") as? String
        {
            self.requestCustomerReview = requestCustomerReview
        }
        if let requestDropLocation = trip.value(forKey: "request_drop_location") as? String
        {
            self.requestDropLocation = requestDropLocation
        }
        if let requestIsCustomerRated = trip.value(forKey: "request_is_customer_rated") as? String
        {
            self.requestIsCustomerRated = requestIsCustomerRated
        }
        if let requestIsDriverArrived = trip.value(forKey: "request_is_driver_arrived") as? String
        {
            self.requestIsDriverArrived = requestIsDriverArrived
        }
        if let requestIsTripAccepted = trip.value(forKey: "request_is_trip_accepted") as? String
        {
            self.requestIsTripAccepted = requestIsTripAccepted
        }
        if let requestIsTripCancelled = trip.value(forKey: "request_is_trip_cancelled") as? String
        {
            self.requestIsTripCancelled = requestIsTripCancelled
        }
        if let requestIsTripCompleted = trip.value(forKey: "request_is_trip_completed") as? String
        {
            self.requestIsTripCompleted = requestIsTripCompleted
        }
        if let requestIsTripStarted = trip.value(forKey: "request_is_trip_started") as? String
        {
            self.requestIsTripStarted = requestIsTripStarted
        }
        if let requestPickupLocation = trip.value(forKey: "request_pickup_location") as? String
        {
            self.requestPickupLocation = requestPickupLocation
        }
        if let requestTripPaymentType = trip.value(forKey: "request_trip_paymenttype") as? String
        {
            self.requestTripPaymentType = requestTripPaymentType
        }
        if let tripDistance = trip.value(forKey: "trip_distance") as? String
        {
            self.tripDistance = tripDistance
        }
        if let tripTime = trip.value(forKey: "trip_time") as? String
        {
            self.tripTime = tripTime
        }
    }
}
