//
//  ViewController.swift
//  SmartPopup
//
//  Created by Ricardo Koch on 02/22/2016.
//  Copyright (c) 2016 Ricardo Koch. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     SAMPLE CODE
     */
    
    @IBAction func simpleDialogAction(sender: AnyObject) {
        
        
        SmartPopup.instance().showWithTitle("Welcome", message: "Welcome to Smart Popups!", buttons:
            [
                SmartPopupButton(text: "OK", andBlock: {
                    (instance:String!) -> Void in
                })
            ]
        )
        
    }
    
    @IBAction func chainedDialogAction(sender: AnyObject) {
        
        
        SmartPopup.instance().showWithType(SmartPopupTypeImage, image: UIImage(named: "questionIcon"), title: "Question", message: "Do you want to save your avatar?\nThe view will auto resize based on the size of the text.\nLarge blocks are welcome, but the user will not read it :)", buttons:
            [
                SmartPopupButton(text: "Yes", andBlock: {
                    (instance:String!) -> Void in
                    
                    self.chainedDialogAction(sender)
                }),
                SmartPopupButton(text: "No", andBlock: {
                    (instance:String!) -> Void in
                    
                    
                })
            ]
        )
        
    }
    
    @IBAction func loadingDialogAction(sender: AnyObject) {
        
        SmartPopup.instance().showWithType(SmartPopupTypeLoading, image: nil, title: "Please Waiting", message: "Doing nothing in the background...", buttons:
            [
                SmartPopupButton(text: "Cancel", andBlock: {
                    (instance:String!) -> Void in
                }),
                SmartPopupButton(text: "Fine...", andBlock: {
                    (instance:String!) -> Void in
                })
            ]
        )
    }
    
    @IBAction func customViewAction(sender: AnyObject) {
        
        SmartPopup.instance().showfromXib(GiftWonDialog.self, withArgs: nil)
    }

    @IBAction func buttonsDialogAction(sender: AnyObject) {
        
        SmartPopup.instance().showWithType(SmartPopupTypeImage, image: UIImage(named: "toys"), title: "You Won!", message: "Select your action", buttons:
            [
                SmartPopupButton(text: "Use It", andBlock: {
                    (instance:String!) -> Void in
                }),
                SmartPopupButton(text: "Store in Garage", andBlock: {
                    (instance:String!) -> Void in
                }),
                SmartPopupButton(text: "Throw Away", andBlock: {
                    (instance:String!) -> Void in
                })
            ]
        )
    }
    
    @IBAction func dialogWithImageAction(sender: AnyObject) {
        
        SmartPopup.instance().showWithType(SmartPopupTypeImage, image: UIImage(named: "toys"), title: "Welcome", message: "Welcome to Smart Popups!", buttons:
            [
                SmartPopupButton(text: "OK", andBlock: {
                    (instance:String!) -> Void in
                })
            ]
        )
    }
    
    @IBAction func dialogImageViewAction(sender: AnyObject) {
        
        let iv = UIImageView(image: UIImage(named: "toy"))
        
        SmartPopup.instance().showWithImageView(iv, title: "Welcome", message: "You can load your custom image views with lazy loading here.", buttons:
            [
                SmartPopupButton(text: "Close", andBlock: {
                    (instance:String!) -> Void in
                })
            ]
        )
        
    }
    
    @IBAction func customDialog2Action(sender: AnyObject) {
        
        //You can pass variables to customize the behavior of your custom dialog
        //With custom dialogs you can create your own UX and take advantage of the SmartPopup API.
        
        let args = [ "You Won Brains!", "You can pass variables to customize the behavior of your custom dialog", "Custom Parameters", "Cool API"]
        
        SmartPopup.instance().showfromXib(GiftWonDialog.self, withArgs: args)
    }
    
    
    
}

