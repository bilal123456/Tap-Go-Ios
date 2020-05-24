//
//  TermsNConditionsVC.swift
//  TapNGo Driver
//
//  Created by Mohammed Arshad on 28/09/18.
//  Copyright © 2018 nPlus. All rights reserved.
//

import UIKit
import Alamofire

class TermsNConditionsVC: UIViewController {

    var webview = UIWebView()

    var dictLayout = [String: AnyObject]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "TapNgo"
        setupConstraints()
        getPrivacyPolicy()

//        let urlStr = URL(string: "http://192.168.1.18/tapngo/public/v1/privacy_policy")
//        let urlReq = URLRequest(url: urlStr!)
//        self.webview.loadRequest(urlReq)

    }
    
    func getPrivacyPolicy() {
        if ConnectionCheck.isConnectedToNetwork()
        {
            let url = HelperClass.BASEURL+HelperClass.privacyPolicy
            Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: HelperClass.Header).responseJSON { (response) in
                
                if case .failure(let error) = response.result
                {
                    print(error.localizedDescription)
                }
                else if case .success = response.result
                {
                    if let JSON = response.result.value as? [String:AnyObject], let status = JSON["success"] as? Bool
                    {
                        print(response.result.value)
                        if status
                        {
                            if let content = JSON["contents"] as? String {
                                self.webview.loadHTMLString(content, baseURL: nil)
                            }
                        }
                        else
                        {
                            print(JSON["error_message"] as! String)
                        }
                    }
                }
                
            }
        }
        else
        {
            self.showAlert("No Internet".localize(), message: "Please Check Your Internet Connection".localize())
        }
    }
    
    
    func setupConstraints() {

        self.view.addSubview(webview)
        webview.translatesAutoresizingMaskIntoConstraints = false
        dictLayout["webview"] = webview

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webview]|", options: [HelperClass.appLanguageDirection], metrics: nil, views: dictLayout))

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-60-[webview]|", options: [HelperClass.appLanguageDirection], metrics: nil, views: dictLayout))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    


}
