//
//  ProfileViewController.swift
//  Catch The Puppies
//
//  Created by Khizer Arshad on 4/30/15.
//  Copyright (c) 2015 S & K Apps. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

let puppiesCaughtKey = "Puppies Caught"
let streakKey = "Maximum Streak"
let catchPKey = "Catch Percentage"
let bestScoreKey = "High Score"
let gamesPlayedKey = "Games Played"
let puppiesDroppedKey = "Puppies Dropped"
let averageScoreKey = "Average"
let totalScoreKey = "Total Score"

// communicates with pList

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let resetStats = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    let profileSelect = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    let settingsSelect = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    
    let changePic = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton

    @IBOutlet weak var highScore: UILabel!
    @IBOutlet weak var catchPercentage: UILabel!
    @IBOutlet weak var puppiesSaved: UILabel!
    @IBOutlet weak var MaxStreak: UILabel!
    @IBOutlet weak var gamesPlayed: UILabel!
    @IBOutlet weak var averageScore: UILabel!
    
    let reset = UIImage(named:"RESET STATS") as UIImage?
    
    let profile = UIImage(named: "profile selected") as UIImage?
    
    let settings = UIImage(named: "settings unselected") as UIImage?
    
    let change = UIImage(named: "FB Pic") as UIImage?
    
    var puppiesCaughtID: AnyObject = 0
    var streakID: AnyObject = 0
    var catchPID: AnyObject = 0
    var bestScoreID: AnyObject = 0
    var gamesPlayedID: AnyObject = 0
    var puppiesDroppedID: AnyObject = 0
    var averageScoreID: AnyObject = 0
    var totalScoreID: AnyObject = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGameData()

        resetStats.frame = CGRectMake(114, 573, 155, 40)
        resetStats.setBackgroundImage(reset, forState: .Normal)
        resetStats.addTarget(self, action: "resetAction:", forControlEvents: UIControlEvents.TouchUpInside)
       
        
        profileSelect.frame = CGRectMake(185,25,115,40)
        profileSelect.setBackgroundImage(profile, forState: .Normal)
        
        settingsSelect.frame = CGRectMake(70,25,115,40)
        settingsSelect.setBackgroundImage(settings, forState: .Normal)
        settingsSelect.addTarget(self, action: "settingsTapped", forControlEvents: UIControlEvents.TouchUpInside)
        
        changePic.frame = CGRectMake(22,93,135,135)
        changePic.setBackgroundImage(change, forState: .Normal)
        changePic.addTarget(self, action: "picChange", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view?.addSubview(resetStats)
        self.view?.addSubview(profileSelect)
        self.view?.addSubview(settingsSelect)
        self.view?.addSubview(changePic)
        settingLabels()
    }
    
    func settingLabels() {
        let a = bestScoreID.stringValue
        let aString = "\(a)"
        highScore.text = aString
        
        let b = averageScoreID.stringValue
        let bString = "\(b)"
        averageScore.text = bString
        
        let c = streakID.stringValue
        let cString = "\(c)"
        MaxStreak.text = cString
        
        let d = catchPID.stringValue
        let dString = "\(d)"
        catchPercentage.text = dString
        
        let e = puppiesCaughtID.stringValue
        let eString = "\(e)"
        puppiesSaved.text = eString
        
        let f = gamesPlayedID.stringValue
        let fString = "\(f)"
        gamesPlayed.text = fString

    }
    
    //load from pList
    func loadGameData() {
        // getting path to PersistedValues.plist
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let path = documentsDirectory.stringByAppendingPathComponent("PersistedValues.plist")
        let fileManager = NSFileManager.defaultManager()
        //check if file exists
        if(!fileManager.fileExistsAtPath(path)) {
            // If it doesn't, copy it from the default file in the Bundle
            if let bundlePath = NSBundle.mainBundle().pathForResource("PersistedValues", ofType: "plist") {
                let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                println("Bundle PersistedValues.plist file is --> \(resultDictionary?.description)")
                fileManager.copyItemAtPath(bundlePath, toPath: path, error: nil)
                println("copy")
            } else {
                println("PersistedValues.plist not found. Please, make sure it is part of the bundle.")
            }
        }
        
        else {
            //println("PersistedValues.plist already exits at path.")
        }
        
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        //println("Loaded PersistedValues.plist file is --> \(resultDictionary?.description)")
        var myDict = NSDictionary(contentsOfFile: path)
        if let dict = myDict {
            //loading values
            puppiesCaughtID = dict.objectForKey(puppiesCaughtKey)!
            averageScoreID = dict.objectForKey(averageScoreKey)!
            streakID = dict.objectForKey(streakKey)!
            bestScoreID = dict.objectForKey(bestScoreKey)!
            catchPID = dict.objectForKey(catchPKey)!
            gamesPlayedID = dict.objectForKey(gamesPlayedKey)!
            puppiesDroppedID = dict.objectForKey(puppiesDroppedKey)!
            totalScoreID = dict.objectForKey(totalScoreKey)!

        } else {
            println("WARNING: Couldn't create dictionary from PersistedValues.plist! Default values will be used!")
        }
    }
    
    //function saves game data to pList and updates profile view
    func saveGameData() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent("PersistedValues.plist")
        var dict: NSMutableDictionary = ["XInitializerItem": "DoNotEverChangeMe"]
        
        //saving values
        
        dict.setObject(puppiesCaughtID, forKey: puppiesCaughtKey)
        dict.setObject(averageScoreID, forKey: averageScoreKey)
        dict.setObject(streakID, forKey: streakKey)
        dict.setObject(bestScoreID, forKey: bestScoreKey)
        dict.setObject(catchPID, forKey: catchPKey)
        dict.setObject(gamesPlayedID, forKey: gamesPlayedKey)
        dict.setObject(puppiesDroppedID, forKey: puppiesDroppedKey)
        dict.setObject(totalScoreID, forKey: totalScoreKey)

        //writing to PersistedValues.plist
        dict.writeToFile(path, atomically: false)
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        println("Saved PersistedValues.plist file is --> \(resultDictionary?.description)")
    }
    
    //reset stats function
    func resetAction(sender: UIButton!){
        let alert = UIAlertController(title: "Reset All Statistics?", message: "Note: You cannot undo this action", preferredStyle: UIAlertControllerStyle.Alert)
        
        let yes = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (yesSelected) -> Void in
            self.puppiesCaughtID = 0
            self.averageScoreID = 0
            self.catchPID = 0
            self.gamesPlayedID = 0
            self.streakID = 0
            self.puppiesDroppedID = 0
            self.totalScoreID = 0
            self.bestScoreID = 0
            self.saveGameData()
            self.settingLabels()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive) { (noSelected) -> Void in
            println("Cancelled")
        }
        
        alert.addAction(yes)
        alert.addAction(cancel)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // if settings tapped go to SettingsView
    func settingsTapped() {
      let settingsVC = self.storyboard!.instantiateViewControllerWithIdentifier("settings") as! UIViewController

        presentViewController(settingsVC, animated: false) { () -> Void in
            return
        }
    }
    
    //adding custom pic to game, doesn't work
    func picChange() {
        let imageController = UIImagePickerController()
        imageController.editing = false
        imageController.delegate = self
        
        let alert = UIAlertController(title: "Choose Photo", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let libButton = UIAlertAction(title: "Select Photo From Library", style: UIAlertActionStyle.Default) { (alert) -> Void in
            imageController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imageController, animated: true, completion: nil)
        }
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            let cameraButton = UIAlertAction(title: "Take a Picture", style: UIAlertActionStyle.Default) { (alert) -> Void in
                println("Take Photo")
                imageController.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(imageController, animated: true, completion: nil)
                
            }
            alert.addAction(cameraButton)
        } else {
            println("Camera not available")
            
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
            println("Cancel Pressed")
        }
        
        alert.addAction(libButton)
        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}



