//
//  GiftWonDialog.swift
//  CacadoresOfertas
//
//  Created by Ricardo Koch on 5/6/15.
//  Copyright (c) 2015 Ricardo Koch. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class GiftWonDialog: UIView, SmartPopupViewProtocol {

    @IBOutlet weak var dialogTitleLabel: UILabel!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var baseImageView: UIImageView!
    //description
    @IBOutlet weak var titleLabel: UILabel!
    //setname, store
    @IBOutlet weak var subtitleLabel: UILabel!
    //category, slot name
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var equipButton: UIButton!
    
    var popupId: String = ""
    var title: String?
    var pTitle: String?
    var pSubtitle: String?
    var pDetails: String?
    
    /*
    MANDATORY PROTOCOL METHODS
    */
    
    class func createFromXib() -> SmartPopupViewProtocol! {
        
        let array = Bundle.main.loadNibNamed("GiftWonDialog", owner: self, options: nil)
        
        if array?.count > 0 {
            if let dialog = array![0] as? SmartPopupViewProtocol {
                return dialog
            }
        }
        return nil
    }
    
    func setArgs(_ args: [Any]!) {
        
        if args != nil && args.count > 0 {
            if let arg = args[0] as? String {
                //set variables...
                self.title = arg
            }
            if let arg = args[1] as? String {
                self.pTitle = arg
            }
            if let arg = args[2] as? String {
                //set variables...
                self.pSubtitle = arg
            }
            if let arg = args[3] as? String {
                //set variables...
                self.pDetails = arg
            }
        }
    }
    
    func willShow(withId identifier: String!) {
        
        self.popupId = identifier
    }
    
    func config() {
        //configure ui elements
        
        if self.title != nil {
            self.dialogTitleLabel.text = self.title
        }
        
        if self.pTitle != nil {
            self.titleLabel.text = self.pTitle
        }
        
        if self.pSubtitle != nil {
            self.subtitleLabel.text = self.pSubtitle
        }
        
        if self.pDetails != nil {
            self.detailLabel.text = self.pDetails
        }
        
        var buttonImage = UIImage(named:"BlueButton");
        buttonImage = buttonImage?.stretchableImage(withLeftCapWidth: 10, topCapHeight: 0)
        self.closeButton.setBackgroundImage(buttonImage, for: UIControlState())
        
        var buttonImage2 = UIImage(named:"BlueButtonP");
        buttonImage2 = buttonImage2?.stretchableImage(withLeftCapWidth: 10, topCapHeight: 0)
        self.closeButton.setBackgroundImage(buttonImage2, for: UIControlState.highlighted)
        self.closeButton.backgroundColor = UIColor.clear
        
        buttonImage = UIImage(named:"GrayButton");
        buttonImage = buttonImage?.stretchableImage(withLeftCapWidth: 10, topCapHeight: 0)
        self.equipButton.setBackgroundImage(buttonImage, for: UIControlState())
        
        buttonImage2 = UIImage(named:"GrayButtonP");
        buttonImage2 = buttonImage2?.stretchableImage(withLeftCapWidth: 10, topCapHeight: 0)
        self.equipButton.setBackgroundImage(buttonImage2, for: UIControlState.highlighted)
        self.equipButton.backgroundColor = UIColor.clear
        
    }
    
    /*
     END OF MANDATORY PROTOCOL METHODS
     */
    
    @IBAction func closeClicked(_ sender: AnyObject) {
        
        SmartPopup.instance().dismiss(self.popupId)
    }
    
    @IBAction func goToClicked(_ sender: AnyObject) {
        
        SmartPopup.instance().dismiss(self.popupId)
    }
    
    
    
    

}
