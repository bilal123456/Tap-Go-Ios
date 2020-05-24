//
//  DocumentTableViewCell.swift
//  TapNGo Driver
//
//  Created by Mohammed Arshad on 27/09/18.
//  Copyright © 2018 nPlus. All rights reserved.
//

import UIKit

class DocumentTableViewCell: UITableViewCell {


    var layoutDict = [String: AnyObject]()
    let viewContent = UIView()
    let lblDocName = UILabel()
    let btnDelDoc = UIButton()


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupContraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupContraints()
    }

    func setupContraints() {

        self.addSubview(viewContent)
        viewContent.addSubview(lblDocName)
        viewContent.addSubview(btnDelDoc)

        viewContent.translatesAutoresizingMaskIntoConstraints = false
        layoutDict["viewContent"] = viewContent
        lblDocName.translatesAutoresizingMaskIntoConstraints = false
        layoutDict["lblDocName"] = lblDocName
        btnDelDoc.translatesAutoresizingMaskIntoConstraints = false
        layoutDict["btnAddDoc"] = btnDelDoc

       

        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(4)-[viewContent]-(4)-|", options: [], metrics: nil, views: layoutDict))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[viewContent(40)]", options: [], metrics: nil, views: layoutDict))

        viewContent.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(4)-[lblDocName]-30-|", options: [], metrics: nil, views: layoutDict))
        viewContent.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lblDocName(40)]|", options: [], metrics: nil, views: layoutDict))


        viewContent.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[btnAddDoc(30)]|", options: [], metrics: nil, views: layoutDict))
        viewContent.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[btnAddDoc(40)]|", options: [], metrics: nil, views: layoutDict))


    }

}
