//
//  ManageDocumentsViewController.swift
//  TapNGo Driver
//
//  Created by Mohammed Arshad on 15/11/18.
//  Copyright © 2018 nPlus. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire

class ManageDocumentsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {


//    struct DocumentLists {
//        var docURL: String?
//        var docName: String?
//        var docDate: String?
//        var id: String?
//        var docExpire: Bool?
//
//        init(_ dict: [String:AnyObject]) {
//            self.docURL = dict["docURL"] as? String
//            self.docName = dict["document_name"] as? String
//            self.docDate = dict["document_ex_date"] as? String
//            self.docExpire = dict["document_expired"] as? Bool
//
//            if let id = dict["id"] as? Int {
//                self.id = String(id)
//
//            }
//        }
//    }

    var lblFileformat = UILabel()
    var btnDocumentAdd = UIButton()
    var tblDocList = UITableView()
    var uploadDocumentView = UploadDocumentView()

    var layoutDict = [String: AnyObject]()
    var top:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var bottom:NSLayoutAnchor<NSLayoutYAxisAnchor>!

    var documentTypes = [Document]()

    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Manage Documents"
        setupViews()
        DocumentListAPI()

        imagePicker.delegate = uploadDocumentView
        uploadDocumentView.delegate = self

    }
    

    func setupViews() {

        self.view.backgroundColor = UIColor.white

        if #available(iOS 11.0, *) {
            self.top = self.view.safeAreaLayoutGuide.topAnchor
            self.bottom = self.view.safeAreaLayoutGuide.bottomAnchor
        } else {
            self.top = self.topLayoutGuide.bottomAnchor
            self.bottom = self.bottomLayoutGuide.topAnchor
        }



        lblFileformat.text = "It is recomended to attach the Documents as JPEG,JPG or PNG Format."
        lblFileformat.numberOfLines = 0
        lblFileformat.lineBreakMode = .byWordWrapping
        lblFileformat.textAlignment = .center
        lblFileformat.textColor = UIColor.gray
        lblFileformat.translatesAutoresizingMaskIntoConstraints = false
        layoutDict["lblFileformat"] = lblFileformat
        self.view.addSubview(lblFileformat)

        btnDocumentAdd.setTitle("Add", for: .normal)
        btnDocumentAdd.setTitleColor(UIColor.white, for: .normal)
        btnDocumentAdd.backgroundColor = UIColor.themeColor
        btnDocumentAdd.addTarget(self, action: #selector(btnDocumentAddPressed(_ :)), for: .touchUpInside)
        btnDocumentAdd.translatesAutoresizingMaskIntoConstraints = false
        layoutDict["btnDocumentAdd"] = btnDocumentAdd
        self.view.addSubview(btnDocumentAdd)

        tblDocList.delegate = self
        tblDocList.dataSource = self
        tblDocList.separatorStyle = .none
        tblDocList.register(ManageDocumentTableViewCell.self, forCellReuseIdentifier: "ManageDocumentCell")
        tblDocList.translatesAutoresizingMaskIntoConstraints = false
        layoutDict["tblDocList"] = tblDocList
        self.view.addSubview(tblDocList)

        uploadDocumentView.isHidden = true
        uploadDocumentView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        uploadDocumentView.translatesAutoresizingMaskIntoConstraints = false
        layoutDict["uploadDocumentView"] = uploadDocumentView
        self.view.addSubview(uploadDocumentView)

        uploadDocumentView.documentImgBtn.addTarget(self, action: #selector(pickImgBtnAction(_ :)), for: .touchUpInside)

        lblFileformat.topAnchor.constraint(equalTo: self.top, constant: 35).isActive = true

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lblFileformat(90)]-[btnDocumentAdd(40)]-[tblDocList]-60-|", options: [], metrics: nil, views: layoutDict))

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[lblFileformat]-16-|", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDict))

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[btnDocumentAdd(90)]-16-|", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDict))

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[tblDocList]-16-|", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDict))

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[uploadDocumentView]|", options: [], metrics: nil, views: layoutDict))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[uploadDocumentView]|", options: [], metrics: nil, views: layoutDict))


    }


    @objc func btnDocumentAddPressed(_ sender: UIButton) {
        uploadDocumentView.showUploadDocumentView(Document([:]))


    }

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



    func DocumentListAPI()
    {
        if ConnectionCheck.isConnectedToNetwork()
        {
            self.showLoadingIndicator()
            print("Connected")
            let url = HelperClass.BASEURL + HelperClass.DocumentList
            var paramdict = Dictionary<String, Any>()

            paramdict["id"] = HelperClass.shared.userID
            paramdict["token"] = HelperClass.shared.userToken
           
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
                        print(response.result.value as Any)
                        if let JSON = response.result.value as? [String:AnyObject], let status = JSON["success"] as? Bool
                        {
                            if status
                            {
                                if let documentaArray = JSON["documents"] as? [[String: AnyObject]] {

                                    self.documentTypes = documentaArray.map({Document($0) })
                                    print(self.documentTypes)
                                    self.tblDocList.reloadData()
                                }

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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.documentTypes.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "ManageDocumentCell"

        let cell = tblDocList.dequeueReusableCell(withIdentifier: identifier) as? ManageDocumentTableViewCell ?? ManageDocumentTableViewCell()

        cell.selectionStyle = .none

        cell.lblDocName.text = self.documentTypes[indexPath.row].title

        if self.documentTypes[indexPath.row].documentExpired! {
            cell.lblDocFile.text = "File Expired"
        } else {
            cell.lblDocFile.text = "File "
        }

        cell.btnDelete.addTarget(self, action: #selector(btnDeletePressed(_ :)), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        uploadDocumentView.showUploadDocumentView(documentTypes[indexPath.row])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    @objc func btnDeletePressed(_ sender: UIButton) {


        //let index = sender.tag
        guard let cell = sender.superview?.superview as? ManageDocumentTableViewCell else {
            return // or fatalError() or whatever
        }

        let indexPath = tblDocList.indexPath(for: cell)

        let docId = self.documentTypes[(indexPath?.row)!].id


        let alert = UIAlertController(title: "", message: "Are you sure.You want to delete", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default) { (action) in
           // self.DocumentListDeleteAPI(document: <#Document#>)
            if ConnectionCheck.isConnectedToNetwork()
            {
                self.showLoadingIndicator()
                print("Connected")
                let url = HelperClass.BASEURL + HelperClass.DocumentListDelete
                var paramdict = Dictionary<String, Any>()

                paramdict["id"] = HelperClass.shared.userID
                paramdict["token"] = HelperClass.shared.userToken
                paramdict["document_id"] = docId

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
                            print(response.result.value as Any)
                            if let JSON = response.result.value as? [String:AnyObject], let status = JSON["success"] as? Bool
                            {
                                if status
                                {
                                    self.DocumentListAPI()
                                    self.tblDocList.reloadData()

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
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true)

    }

    func DocumentListDeleteAPI(document:Document)
    {
        if ConnectionCheck.isConnectedToNetwork()
        {
            self.showLoadingIndicator()
            print("Connected")
            let url = HelperClass.BASEURL + HelperClass.DocumentListDelete
            var paramdict = Dictionary<String, Any>()

            paramdict["id"] = HelperClass.shared.userID
            paramdict["token"] = HelperClass.shared.userToken
            paramdict["document_id"] = document.id

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
                        print(response.result.value as Any)
                        if let JSON = response.result.value as? [String:AnyObject], let status = JSON["success"] as? Bool
                        {
                            if status
                            {
                                self.DocumentListAPI()
                                self.tblDocList.reloadData()

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
  

}

extension ManageDocumentsViewController:UploadDocumentViewDelegate
{
    func okBtnTapped(_ document:Document)
    {

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
            let url = try! URLRequest(url: HelperClass.BASEURL + HelperClass.DocumentListUpdate, method: .post, headers: HelperClass.Header)
            //let url = HelperClass.BASEURL + HelperClass.documentImageUpload
            var paramdict = Dictionary<String, Any>()

            paramdict["id"] = HelperClass.shared.userID
            paramdict["token"] = HelperClass.shared.userToken
            paramdict["document_name"] = document.title
            paramdict["document_ex_date"] = document.dateStr
            if let documentId = document.id {
                paramdict["document_id"] = documentId
            } else {
                paramdict["document_id"] = "0"
            }




            print("URL & Paremeters for SignUp =",url,paramdict)


            Alamofire.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(document.image.pngData()!, withName: "document", fileName: "picture1.png", mimeType: "image/png")

                for (key, value) in paramdict
                {
                    print(key)
                    print(value)
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
//                            self.docListDict = (response.result.value as! [String: Any]) as [String : AnyObject]
//                            self.docListDict["documentExpiry"] = document.dateStr as AnyObject

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
//
//                            self.docListArray.append(self.docListDict as [String : AnyObject] as AnyObject)
//                            print(self.docListArray)
                            let theSuccess = ((response.result.value as! [String: Any])["success"] as! Bool)
//
                            if (theSuccess == true)
                            {
                                self.uploadDocumentView.endEditing(true)
                                self.uploadDocumentView.isHidden = true
                                self.DocumentListAPI()
                                self.tblDocList.reloadData()
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
