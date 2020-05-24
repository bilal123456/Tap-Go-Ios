//
//  RJKCountryPickerView.swift
//  test
//
//  Created by Admin on 30/03/18.
//  Copyright © 2018 com. All rights reserved.
//

import UIKit
import Localize

struct Country:Codable
{
    var name:String!
    var dialCode:String!
    var isoCode:String!
    init(_ dict:[String:String]) {
        self.name = dict["name"]
        self.dialCode =  dict["dial_code"]
        self.isoCode =  dict["code"]
    }
    init(_ name:String,dialCode:String,isoCode:String) {
        self.name = name
        self.dialCode = dialCode
        self.isoCode = isoCode
    }
}

protocol RJKCountryPickerViewDelegate {
    func countrySelected(_ selectedCountry:Country)
}

class RJKCountryPickerView:UIView
{
    let flagImgCache = NSCache<NSString, UIImage>()
    var allCountries = [Country]() {
        didSet {
            countryHeaders = Array(Set(allCountries.map({ String($0.name.first!).uppercased() }))).sorted()
        }
    }
    var filteredCountries = [Country]()
    var countryHeaders = [String]()
    var showFilterResults = false
    let countryListTable = UITableView()
    let countrySearchBar = UISearchBar()
    var bottomSpace:NSLayoutConstraint!
    var delegate:RJKCountryPickerViewDelegate!

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        DispatchQueue.global(qos: .background).async {
            if let filePath = Bundle.main.path(forResource: "CountryCodes", ofType: "json")
            {
                do
                {
                    let data = try Data(contentsOf: URL(fileURLWithPath: filePath), options: .mappedIfSafe)
                    self.allCountries = (try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [[String:String]]).map({ Country($0) })
                    //try JSONDecoder().decode([Country.self], from: data)


                    DispatchQueue.main.async {
                        self.countryListTable.reloadData()
                    }
                }
                catch
                {
                    print("Something went wrong.")
                }
            }
        }

        setup()
        let startPoint = CGPoint(x: 0.0, y: countrySearchBar.frame.maxY)
        let endPoint = CGPoint(x: countrySearchBar.frame.maxX, y: countrySearchBar.frame.maxY)
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor(red: 34.0/255.0, green: 135.0/255.0, blue: 153.0/255.0, alpha: 1.0).cgColor
        shapeLayer.lineWidth = 3.0
        countrySearchBar.layer.addSublayer(shapeLayer)

    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self
        {

            self.hideCountryPickerView()
        }
        return hitView
    }
    func setup()
    {
        countryHeaders = Array(Set(allCountries.map({ String($0.name.first!).uppercased() }))).sorted()

        countryListTable.register(CountryPickerCell.self, forCellReuseIdentifier: "CountryPickerCell")
        countryListTable.rowHeight = UITableView.automaticDimension
        countryListTable.estimatedRowHeight = 40
        countryListTable.delegate = self
        countryListTable.dataSource = self
        countryListTable.tableFooterView = UIView()
        countryListTable.translatesAutoresizingMaskIntoConstraints = false
        countryListTable.backgroundColor = .white
        addSubview(countryListTable)

        let footerView = UIView()
        footerView.backgroundColor = .darkGray
        footerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(footerView)

        let cancelBtn = UIButton()
        cancelBtn.setTitleColor(countryListTable.tintColor, for: .normal)
        cancelBtn.setTitle("Cancel".localize(), for: .normal)
        cancelBtn.addTarget(self, action: #selector(hideCountryPickerView), for: .touchUpInside)
        cancelBtn.sizeToFit()
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(cancelBtn)

        footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cancelBtn]|", options: [], metrics: nil, views: ["cancelBtn":cancelBtn]))
        footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[cancelBtn]-(8)-|", options: [], metrics: nil, views: ["cancelBtn":cancelBtn]))


        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[container]-(20)-|", options: [], metrics: nil, views: ["container":countryListTable]))

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(50)-[container][footerView(40)]", options: [.alignAllLeading,.alignAllTrailing], metrics: nil, views: ["container":countryListTable,"footerView":footerView]))

        bottomSpace = footerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50)
        bottomSpace.isActive = true

        countrySearchBar.barStyle = .blackTranslucent
        countrySearchBar.searchBarStyle = .prominent
        countrySearchBar.isTranslucent = true
        if countrySearchBar.placeholder == nil //searchBar.placeholder?.isEmpty
        {
            countrySearchBar.placeholder = "Search here..."
        }
        countrySearchBar.keyboardAppearance = .dark
        countrySearchBar.delegate = self
        countrySearchBar.tintColor = .white
        countrySearchBar.sizeToFit()
        countryListTable.tableHeaderView = countrySearchBar
        layoutIfNeeded()
        setNeedsLayout()
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { (notification) in
            if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue?.size
            {
                self.bottomSpace.constant = -keyBoardSize.height - 10
                UIView.animate(withDuration: 0.25, animations: {
                    self.layoutIfNeeded()
                })
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { (notification) in
            self.bottomSpace.constant = -50
            UIView.animate(withDuration: 0.25, animations: {
                self.layoutIfNeeded()
            })
        }
    }
    @objc func hideCountryPickerView()
    {
        self.removeFromSuperview()
        self.showFilterResults = false
        self.countrySearchBar.text = ""
        self.countrySearchBar.resignFirstResponder()
        self.countryListTable.reloadData()
        self.isHidden = true
        self.countryListTable.beginUpdates()
        self.countryListTable.setContentOffset( CGPoint(x: 0.0, y: 0.0), animated: false)
        self.countryListTable.endUpdates()
    }
}
extension RJKCountryPickerView:UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return showFilterResults ? 1 : countryHeaders.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return showFilterResults ? nil : countryHeaders[section]
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return showFilterResults ? nil : countryHeaders
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showFilterResults ? filteredCountries.count : allCountries.filter({ $0.name.uppercased().hasPrefix(countryHeaders[section]) }).count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryPickerCell") as! CountryPickerCell

        cell.selectionStyle = .none
        if showFilterResults
        {
            cell.countryNameLbl.text = filteredCountries[indexPath.row].name
            cell.isoCodeLbl.text = filteredCountries[indexPath.row].dialCode
            if let image = self.flagImgCache.object(forKey: filteredCountries[indexPath.row].isoCode! as NSString)
            {
                cell.flagImgView.image = image
            }
            else
            {
                cell.flagImgView.image = UIImage(named:filteredCountries[indexPath.row].isoCode)
                self.flagImgCache.setObject(UIImage(named: filteredCountries[indexPath.row].isoCode)!, forKey: filteredCountries[indexPath.row].isoCode! as NSString)
            }

        }
        else
        {
            let sortedArray = allCountries.filter({ $0.name.uppercased().hasPrefix(countryHeaders[indexPath.section]) }).sorted(by: { $0.name.caseInsensitiveCompare($1.name) == .orderedAscending })

            cell.countryNameLbl.text = sortedArray[indexPath.row].name
            cell.isoCodeLbl.text = sortedArray[indexPath.row].dialCode
            if let image = self.flagImgCache.object(forKey: sortedArray[indexPath.row].isoCode! as NSString)
            {
                cell.flagImgView.image = image
            }
            else
            {
                cell.flagImgView.image = UIImage(named:sortedArray[indexPath.row].isoCode)
                self.flagImgCache.setObject(UIImage(named: sortedArray[indexPath.row].isoCode)!, forKey: sortedArray[indexPath.row].isoCode! as NSString)
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if showFilterResults
        {
            delegate.countrySelected(filteredCountries[indexPath.row])
        }
        else
        {
            let sortedArray = allCountries.filter({ $0.name.uppercased().hasPrefix(countryHeaders[indexPath.section]) }).sorted(by: { $0.name.caseInsensitiveCompare($1.name) == .orderedAscending })
            delegate.countrySelected(sortedArray[indexPath.row])
        }
        self.hideCountryPickerView()
    }
}
extension RJKCountryPickerView: UISearchBarDelegate
{
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        showFilterResults = false
        countryListTable.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        if searchText.count > 0
        {
            showFilterResults = true
            filteredCountries = allCountries.filter({ $0.name.localizedCaseInsensitiveContains(searchText) || $0.dialCode.localizedCaseInsensitiveContains(searchText) })
            countryListTable.reloadData()
        }
        else
        {
            showFilterResults = false
            countryListTable.reloadData()
        }
    }
}




