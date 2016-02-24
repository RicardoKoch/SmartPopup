# SmartPopup

[![CI Status](http://img.shields.io/travis/Ricardo Koch/SmartPopup.svg?style=flat)](https://travis-ci.org/Ricardo Koch/SmartPopup)
[![Version](https://img.shields.io/cocoapods/v/SmartPopup.svg?style=flat)](http://cocoapods.org/pods/SmartPopup)
[![License](https://img.shields.io/cocoapods/l/SmartPopup.svg?style=flat)](http://cocoapods.org/pods/SmartPopup)
[![Platform](https://img.shields.io/cocoapods/p/SmartPopup.svg?style=flat)](http://cocoapods.org/pods/SmartPopup)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SmartPopup is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SmartPopup"
```

## Author

Ricardo Koch, ricardo@ricardokoch.com

## License

SmartPopup is available under the MIT license. See the LICENSE file for more info.

## Description

Cocoapods component for easy creating and management of UI dialogs for iOS

## How to Use

Just access SmartPopup singleton from anywhere to show amazing animated popups. 

```ruby
SmartPopup.instance().showWithTitle("Welcome", message: "Welcome to Smart Popups!", buttons: nil)
```

If you want to define buttons for your model.

```ruby
var btn1 = SmartPopupButton(text: "Close Me", andBlock: {
    (instance:String!) -> Void in
    //Button click callback (instance: id of the popup)
})
```

Or you can simply create them inline with the popup.

```ruby
SmartPopup.instance().showWithType(SmartPopupTypeImage, image: UIImage(named: "questionIcon"), title: "Question", message: "Do you want to save?", buttons:
    [
        SmartPopupButton(text: "Yes", andBlock: {
            (instance:String!) -> Void in 
        }),
        SmartPopupButton(text: "No", andBlock: {
            (instance:String!) -> Void in
        })
    ]
)
```

You have five types of popups to play with: plain, with image, with image view, with activity indicator and a custom popup with xib.

## Custom Models

Custom modals can have any interface you want. They can be completly customazied because they are build using the IB and a View class. The SmartPopup will just manage the presentation of thoses popups for you.
To create a custom SmartPopup user interface you must create a Xib file and design anything you want. Then create a View class and implement the following protocol:

```ruby
SmartPopupViewProtocol
```

This protocol must be implemented so the SmartPopup component understand your view as a custom popup.
Those are the methods that must be implemented:

```ruby
//Method used to instantiate the view and sent as parameter to the SmartPopup singleton
class func createFromXib() -> SmartPopupViewProtocol! {

    let array = NSBundle.mainBundle().loadNibNamed("XibNameHere", owner: self, options: nil)

    if array?.count > 0 {
        if let dialog = array![0] as? SmartPopupViewProtocol {
            return dialog
        }
    }
    return nil
}

//Called to pass arguments to customize the behavior of the class and UI
func setArgs(args: [AnyObject]!) {

    if args != nil && args.count > 0 {
        if let arg = args[0] as? String {
            //set variables...
            self.title = arg
        }
    }
}

//Used when the popup is going to be shown.
func willShowWithId(identifier: String!) {
    self.popupId = identifier
}

//Used when the UI components are going to be presented in the screen. This is when you should configure views, create or customize.
func config() {
    //configure ui elements
}
```

