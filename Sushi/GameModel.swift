//
//  GameModel.swift
//  Catch The Puppies
//
//  Created by Saaduddin on 4/10/15.
//  Copyright (c) 2015 S & K Apps. All rights reserved.
//


// USELESS FILE not implemented in game

import Foundation
import UIKit

/*

 scoreUpdate() -> 2x 4x 8x 16x
- powerUp ()
    -> bigNet ()
    -> slowMo ()
    -> healthBoost ()
- levelUp ()
- healthMeter ()
- streakMeter ()
- updateStats ()
- updateAchievements ()
- speedUp ()
- fallingDogs ()

Persisting Data 

- puppiesCaught
- puppiesDropped
- bestScore
- average
- catchPercentage
- level
- highStreak


class GameModel {
    required init(coder aDecoder: NSCoder) {
        
    }
    
    var caught: Bool = true
    var dropped: Bool = true
    var gameOn: Bool = true
    var streakArray = [Int]()
    var speed = 1.0
    
    // Represents persisted Post Game Statistics on 'Profile' Scene
    
    struct Stats {
        static var numberOfGamesPlayed = 0 // total # of games started
        static var totalPuppiesCaught = 0 // total # of puppies caught in history of game
        static var totalPuppiesDropped = 0 // total # of puppies dropped in history of game
        static var highLevel = 0 // highest level achieved
        static var bestScore = 0 // highest score achieved
        static var highStreak = 0 // highest consecutive puppies caught streak
        static var catchPercentage = totalPuppiesCaught/(totalPuppiesCaught + totalPuppiesDropped) // ratio of puppies caught to puppies faced
        static var average = totalPuppiesCaught/numberOfGamesPlayed
    }
    
    // Represents statistics during Game Play
    
    struct GameStats {
        static var scoreMultiplier = 1 // is used to boost score
        static var score = 0 // score in game
        // static var currentScore = 0
        static var health = 100 // represents the health in game
        static var streak = 0 // represents the streak meter streak
        static var currentStreak = 0 // represents the in game consecutive puppies caught streak
        static var caughtPuppies = 0 // represents puppies caught in game
        static var droppedPuppies = 0 // represents puppies dropped in game
        static var level = 1 // represents level in game
    }
    
    // Score Updating Dynamically During Gameplay
    
    func scoreUpdate() {

        if caught && gameOn {
            GameStats.caughtPuppies++ //keeps track of in game # of puppies caught      
            healthMeter(true) // calls healthMeter function
            streakMeter(true) // calls streakMeter
            scoreUpdate() // calls scoreUpdate
        }
        
        if dropped && gameOn {
            GameStats.droppedPuppies++
            healthMeter(false)
            streakMeter(false)
            scoreUpdate()
        }
        
        if dropped && !gameOn {
            healthMeter(false)
        }
        
        return
    }
    
    //generates PowerUp when scoreMultiplier hits 16
    
    func powerUp() {
        
        var powerUpType = arc4random_uniform(3)+1 //random integer between 1-3
        println(powerUpType)
        
        switch(powerUpType) {
            
        case 1:
            println("Big Net!")
            //bigNet()
            return
        
        case 2:
            println("Slow Mo!")
            //slowMo()
            return
        
        case 3:
            println("Health Boost!")
            //healthBoost()
            return
        
        default:
            println("No PowerUp Generated")
            return
        }
    }
    
    //increases game level when player has played game for 'n' number of seconds
    func levelUp() -> Int {
        
        while GameStats.score < GameStats.score+100 {
            continue
        }
        
        GameStats.level = GameStats.level+1
        speedUp()
    
            return GameStats.level
    }
        
    //speedUp will cause dogs to fall faster
    
    func speedUp() -> Double {
        
        speed += Double(arc4random_uniform(1)+1)
        return speed
    }
    
    // Boosts health by a certain number
    
    func healthBoost() {
        
        GameStats.health += Int(arc4random_uniform(30)+10)
    }
    
    //determines if game is over or not
    
    func healthMeter(didCatch:Bool) {
        
        if didCatch { //if true is passed in, health increases by 1
            GameStats.health = GameStats.health + 1
            
            if GameStats.health > 100 {
                GameStats.health = 100
            }
        }
            
        else { // else health drops by 5
            GameStats.health = GameStats.health - 5
            
            if GameStats.health <= 0 { // if gameOver
                gameOn = false
                updateStats()
                //gameOver_NextView()
            }
        }
    }
    
    //keeps track of streak in game and compares it to best streak at end of game
    
    func streakMeter(caught: Bool) {
        
        while caught { // if true passed in enter while loop, based on streak determine multiplier
            if GameStats.streak < 10 {
                GameStats.score++
                GameStats.streak++
                GameStats.currentStreak++
                
                return
            }
                
            else if GameStats.streak >= 10 && GameStats.streak < 20 {
                GameStats.scoreMultiplier = 2
                GameStats.score += GameStats.scoreMultiplier
                GameStats.streak++
                GameStats.currentStreak++
                
                return
            }
            
            else if GameStats.streak >= 20 && GameStats.streak < 30 {
                GameStats.scoreMultiplier = 4
                GameStats.score += GameStats.scoreMultiplier
                GameStats.streak++
                GameStats.currentStreak++
                
                return
            }
                
            else if GameStats.streak >= 30 && GameStats.streak < 40 {
                GameStats.scoreMultiplier = 8
                GameStats.score += GameStats.scoreMultiplier
                GameStats.streak++
                GameStats.currentStreak++
                
                return
            }
            
            else if GameStats.streak == 40 {
                GameStats.scoreMultiplier = 16
                GameStats.score += GameStats.scoreMultiplier
                powerUp() //changes view!
                GameStats.currentStreak++
                
                return
            }
                
            else {
                GameStats.currentStreak++
                
                return
            }
        }
        
        streakArray.append(GameStats.currentStreak)
        GameStats.currentStreak = 0
        GameStats.streak = 0
        GameStats.scoreMultiplier = 1

        return
    }
    
    // updates all personal statistics at end of game
    
    func updateStats() {
        
        Stats.totalPuppiesCaught = GameStats.caughtPuppies + Stats.totalPuppiesCaught
        
        if GameStats.score > Stats.bestScore {
            Stats.bestScore = GameStats.score
        }
        
        if maxElement(streakArray) > Stats.highStreak {
            Stats.highStreak = maxElement(streakArray)
        }
        
        if GameStats.level > Stats.highLevel {
            Stats.highLevel = GameStats.level
        }
        
        Stats.average = Stats.totalPuppiesCaught/Stats.numberOfGamesPlayed
        
        Stats.catchPercentage = Stats.totalPuppiesCaught/(Stats.totalPuppiesCaught+Stats.totalPuppiesDropped)
        
        updateAchievements()
    }
    
    //updates all personal achievements at end of game
    
    //these will all reveal images in the achievements list
    
    
    
    func updateAchievements() {
        if Stats.totalPuppiesCaught > 100 {
            println("100 Puppies Caught!")
        }
        
        if Stats.totalPuppiesCaught > 250 {
            println("250 Puppies Caught!")
        }
        
        if Stats.totalPuppiesCaught > 500 {
            println("500 Puppies Caught!")
        }

        if Stats.totalPuppiesCaught > 1000 {
            println("1000 Puppies Caught!")
        }
        
        if Stats.totalPuppiesCaught > 5000 {
            println("5000 Puppies Caught!")
        }
       
        if Stats.totalPuppiesCaught > 10000 {
            println("10000 Puppies Caught!")
        }
        
        if Stats.totalPuppiesCaught > 25000 {
            println("25000 Puppies Caught!")
        }
        
        if Stats.totalPuppiesCaught > 50000 {
            println("50000 Puppies Caught!")
        }
        
        if Stats.totalPuppiesCaught > 75000 {
            println("75000 Puppies Caught!")
        }
        
        if Stats.totalPuppiesCaught > 100000 {
            println("100000 Puppies Caught")
        }
        
        
        
        if Stats.highLevel >= 10 && Stats.highLevel < 25 {
            println("Reached Level 10")
        }
        
        if Stats.highLevel >= 25 &&  Stats.highLevel < 50 {
            println("Reached Level 25")
        }
        
        if Stats.highLevel >= 50 &&  Stats.highLevel < 100 {
            println("Reached Level 50")
        }
        if Stats.highLevel >= 100 &&  Stats.highLevel < 150 {
            println("Reached Level 100")
        }
        
        
        
        if Stats.bestScore >= 100 && Stats.bestScore < 500 {
            println("100 Points Achieved!")
        }
        
        if Stats.bestScore >= 500 && Stats.bestScore < 1000 {
            println("500 Points Achieved!")
        }
        
        if Stats.bestScore >= 1000 && Stats.bestScore < 2000 {
            println("1000 Points Achieved!")
            println("Unlocked Long Ears!")
        }
        
        if Stats.bestScore >= 5000 && Stats.bestScore < 10000 {
            println("5000 Points Achieved!")
        }
        
        if Stats.bestScore >= 10000 && Stats.bestScore < 25000 {
            println("10000 Points Achieved!")
            println("Unlocked Bull Terrier!")
        }

        if Stats.bestScore >= 25000 && Stats.bestScore < 50000 {
            println("25000 Points Achieved!")
            println("Unlocked Bassett Hound!")
        }
        
        if Stats.bestScore >= 50000 && Stats.bestScore < 100000 {
            println("50000 Points Achieved!")
            println("Unlocked Greyhound!")
        }
        
        if Stats.bestScore >= 100000 && Stats.bestScore < 250000 {
            println("100000 Points Achieved!")
            println("Unlocked Dingo!")
        }
        
        if Stats.bestScore >= 250000 && Stats.bestScore < 500000 {
            println("250000 Points Achieved!")
        }
        
        if Stats.bestScore >= 500000 && Stats.bestScore < 1000000 {
            println("500000 Points Achieved!")
        }
        
        if Stats.bestScore >= 1000000 {
            println("1 Million Points Achieved!")
        }
        
   
        
        if Stats.numberOfGamesPlayed >= 100 && Stats.numberOfGamesPlayed < 250 {
            println("100 Games Played")
        }
        
        if Stats.numberOfGamesPlayed >= 250 && Stats.numberOfGamesPlayed < 500 {
            println("250 Games Played")
        }
        
        if Stats.numberOfGamesPlayed >= 500 && Stats.numberOfGamesPlayed < 1000 {
            println("500 Games Played")
        }
        
        if Stats.numberOfGamesPlayed >= 1000 && Stats.numberOfGamesPlayed < 2000 {
            println("1000 Games Played")
        }
        
        if Stats.numberOfGamesPlayed >= 2000 && Stats.numberOfGamesPlayed < 3000 {
            println("2000 Games Played")
        }
        
        if Stats.numberOfGamesPlayed >= 5000 && Stats.numberOfGamesPlayed < 10000 {
            println("5000 Games Played")
        }
        
        if Stats.numberOfGamesPlayed >= 10000 {
            println("10000 Games Played")
        }
        
        
        
        if Stats.highStreak >= 10 && Stats.highStreak < 25 {
            println("10 Puppy Streak!")
        }

        if Stats.highStreak >= 25 && Stats.highStreak < 50 {
            println("25 Puppy Streak!")
        }

        if Stats.highStreak >= 50 && Stats.highStreak < 75 {
            println("50 Puppy Streak!")
        }

        if Stats.highStreak >= 75 && Stats.highStreak < 100 {
            println("75 Puppy Streak!")
        }
        
        if Stats.highStreak >= 100 && Stats.highStreak < 200 {
            println("100 Puppy Streak!")
        }

        if Stats.highStreak >= 200 && Stats.highStreak < 300 {
            println("200 Puppy Streak!")
        }
 
        if Stats.highStreak >= 300 && Stats.highStreak < 400 {
            println("300 Puppy Streak!")
        }
        
        if Stats.highStreak >= 400 && Stats.highStreak < 500 {
            println("400 Puppy Streak!")
        }
        
        if Stats.highStreak >= 500 && Stats.highStreak < 600 {
            println("500 Puppy Streak!")
        }
    }


} //end of GameModel
    

*/
    

