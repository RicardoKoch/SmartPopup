//
//  GiftWonDialog.swift
//  CacadoresOfertas
//
//  Created by Ricardo Koch on 5/6/15.
//  Copyright (c) 2015 Ricardo Koch. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var discountLabel: UILabel!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var equipButton: UIButton!
    
    var popupId: String = ""
    weak var avatarItem: AvatarItem?
    weak var dealItem: Deal?
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    class func createFromXib() -> SmartPopupViewProtocol! {
        
        let array = NSBundle.mainBundle().loadNibNamed("GiftWonDialog", owner: self, options: nil)
        
        if array?.count > 0 {
            if let dialog = array![0] as? SmartPopupViewProtocol {
                return dialog
            }
        }
        return nil
    }
    
    func setArgs(args: [AnyObject]!) {
        
        if args.count > 0 {
            if let ai = args[0] as? AvatarItem {
                self.avatarItem = ai
            }
            else if let d = args[0] as? Deal {
                self.dealItem = d
            }
        }
    }
    
    func willShowWithId(identifier: String!) {
        
        self.popupId = identifier
    }
    
    func config() {
        //configure ui elements
        
        self.dialogTitleLabel.text = LS(" You Won")
        
        self.closeButton.setTitle(LS("Close"), forState: .Normal)
        
        if avatarItem != nil {
            self.titleLabel.text = avatarItem?.getItemName()
            self.subtitleLabel.text = avatarItem?.getItemSetName()
            self.detailLabel.text = avatarItem?.getSlotName()
            self.discountLabel.hidden = true
            self.equipButton.setTitle(LS("Equip"), forState: .Normal)
            
            //equip item tutorial after 1 sec
            let time:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(1.0) * NSEC_PER_SEC))
            dispatch_after(time, dispatch_get_main_queue(), {

                TutorialManager.sharedInstance.showTutorial(10, inView: self.equipButton, controllerView: self)
            })
            
            let iv = iconImageView as! PFImageView
            iv.file = avatarItem?.getImage()
            iv.loadInBackground()
            iv.layer.cornerRadius = 40
            iv.clipsToBounds = true
        }
        else if dealItem != nil {
            
            self.baseImageView.hidden = true
            self.equipButton.setTitle(LS("See Deal"), forState: .Normal)
        }
        
        self.closeButton.setTitle(LS("OK"), forState: .Normal)
        
        var buttonImage = UIImage(named:"BlueButton");
        buttonImage = buttonImage?.stretchableImageWithLeftCapWidth(10, topCapHeight: 0)
        self.closeButton.setBackgroundImage(buttonImage, forState: .Normal)
        
        var buttonImage2 = UIImage(named:"BlueButtonP");
        buttonImage2 = buttonImage2?.stretchableImageWithLeftCapWidth(10, topCapHeight: 0)
        self.closeButton.setBackgroundImage(buttonImage2, forState: UIControlState.Highlighted)
        self.closeButton.backgroundColor = UIColor.clearColor()
        
        buttonImage = UIImage(named:"GrayButton");
        buttonImage = buttonImage?.stretchableImageWithLeftCapWidth(10, topCapHeight: 0)
        self.equipButton.setBackgroundImage(buttonImage, forState: UIControlState.Normal)
        
        buttonImage2 = UIImage(named:"GrayButtonP");
        buttonImage2 = buttonImage2?.stretchableImageWithLeftCapWidth(10, topCapHeight: 0)
        self.equipButton.setBackgroundImage(buttonImage2, forState: UIControlState.Highlighted)
        self.equipButton.backgroundColor = UIColor.clearColor()
        
    }
    
    @IBAction func closeClicked(sender: AnyObject) {
        
        SmartPopup.instance().dismiss(self.popupId)
    }
    
    @IBAction func goToClicked(sender: AnyObject) {
        
        SmartPopup.instance().dismiss(self.popupId)
        NSNotificationCenter.defaultCenter()
            .postNotificationName("ShouldEditAvatar", object:self.avatarItem)
    }
    
    
    
    

}
