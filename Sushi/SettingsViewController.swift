//
//  SettingsViewController.swift
//  Catch The Puppies
//
//  Created by Khizer Arshad on 4/28/15.
//  Copyright (c) 2015 S & K Apps. All rights reserved.
//

import UIKit
import Foundation

class SettingsViewController : UIViewController {
    
    var sound : Bool! = true
    @IBOutlet weak var soundSwitch: UISwitch!
    
    let profileSelect = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    let settingsSelect = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    
    let profile = UIImage(named: "profile unselected") as UIImage?
    
    let settings = UIImage(named: "settings selected") as UIImage?
    
    //sound = soundSwitch.on
    
    override func viewDidLoad(){
        
        profileSelect.frame = CGRectMake(185,25,115,40)
        profileSelect.setBackgroundImage(profile, forState: .Normal)
        profileSelect.addTarget(self, action: "profileTapped", forControlEvents: UIControlEvents.TouchUpInside)
        
        settingsSelect.frame = CGRectMake(70,25,115,40)
        settingsSelect.setBackgroundImage(settings, forState: .Normal)
        
        self.view?.addSubview(profileSelect)
        self.view?.addSubview(settingsSelect)
        
    }
    
    func profileTapped() {
        let profileVC = self.storyboard!.instantiateViewControllerWithIdentifier("profile") as! UIViewController
        
        presentViewController(profileVC, animated: false) { () -> Void in
            return
        }
    }
    
    /*func stateChanged(switchState: Bool) {
        if !switchState.on {
            println("Sound turned on")
            soundSwitch.setOn(true, animated:true)
        } else {
            //MainMenuScene().stopMusic()
            println("sound turned off")
            soundSwitch.setOn(false, animated:true)
        }
    }*/
    
}
