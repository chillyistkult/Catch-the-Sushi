import SpriteKit
import UIKit
import CoreGraphics
import AVFoundation

//Wird ausgelöst wenn Geld -600 Yen oder Zeit abgelaufen ist
protocol GameDelegate {
    func lostAll()
}

//Structure für die Physic Grids
struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let PhysicsSushi: UInt32 = 0b1
    static let PhysicsChopsticks: UInt32 = 0b10
}

class GameScene: SKScene, SKPhysicsContactDelegate, GameDelegate {
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)

    var gameDelegate: GameDelegate? // Delegate für Spielende
    
    let streakBar = SKSpriteNode() //Streak-Meter
    
    var duration: TimeInterval = 4.0 //Fallzeiten
    
    var streakPoints = 0 //Punkte

    var streak = 0 //Anzahl gefangener Sushis
    
    var maxStreak = 0 //höchster erreichter Streak
    
    var gamesPlayed = 0 //gespielte Spiele
    
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 48))
    
    var money = 0 //Yens
    
    var sushiDropped = 0 //fallen gelassene Sushi's
    
    var bonus = 0 //Bonusgeld
    
    let chopsticks = SKSpriteNode(imageNamed: "Chopsticks")
    
    let mountain = SKSpriteNode(imageNamed: "Mountain")
    
    let streakMeter = SKSpriteNode(imageNamed: "StreakMeter")
    
    var moneyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 48))
    
    var gameEnded = UILabel(frame: CGRect(x: 0, y: 0, width: 700, height: 70))
    
    let replayGame = UIButton(type: .custom)
    
    //Bentobox Mockup
    var bentoBoxViews = [UIImageView]()
    var bentoBox = [UIImage]()
    
    var streakIcons = [SKSpriteNode]()
    let twoX = SKSpriteNode(imageNamed: "2x colored")
    let fourX = SKSpriteNode(imageNamed: "4x colored")
    let eightX = SKSpriteNode(imageNamed: "8x colored")
    let sixteenX = SKSpriteNode(imageNamed: "16x colored")
    
    let play = UIImage(named: "Play") as UIImage?
    
    var sushi_Timer = Timer()
    var gameOver_Timer = Timer()
    var cloud_Timer = Timer()
    var speed_Timer = Timer()
    
    var sushiArray = [SKSpriteNode]()
    

    
    //MARK: Game Delegate Methods
    @objc func lostAll() {
        gameOver()
    }
    
    // Läd wenn Szene startet
    override func didMove(to view: SKView) {
        
        gameDelegate = self
        
        // Neues Spiel
        replayGame.frame = CGRect(x: 90, y: 320, width: 200, height: 200)
        replayGame.setBackgroundImage(play, for: UIControlState())
        replayGame.addTarget(self, action: #selector(GameScene.buttonAction(_:)), for: UIControlEvents.touchUpInside)
        
        // Punkteanzeige
        moneyLabel.center = CGPoint(x: 310, y: 40)
        moneyLabel.textAlignment = NSTextAlignment.center
        moneyLabel.text = String(self.money)
        moneyLabel.font = UIFont(name:"Menlo-Bold", size: 40.0)
        self.view?.addSubview(moneyLabel)
        
        //Physics
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        //Collision Properties
        chopsticks.physicsBody = SKPhysicsBody(rectangleOf: chopsticks.size, center: chopsticks.position)
        chopsticks.physicsBody?.isDynamic = true
        chopsticks.physicsBody?.categoryBitMask = PhysicsCategory.PhysicsChopsticks
        chopsticks.physicsBody?.contactTestBitMask = PhysicsCategory.PhysicsSushi
        chopsticks.physicsBody?.collisionBitMask = PhysicsCategory.None
        chopsticks.physicsBody?.usesPreciseCollisionDetection = true
        
        // Sushi spawnen jede halbe Sekunde
        speed_Timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameScene.speedUp), userInfo: nil, repeats: true)
        
        sushi_Timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(GameScene.pickSushi), userInfo: nil, repeats: true)

        
        //Wolken spawnen jede Sekunde
        cloud_Timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.clouds), userInfo: nil, repeats: true)

        // Skalierungen
        chopsticks.xScale = 0.30
        chopsticks.yScale = 0.30
        
        twoX.xScale = 0.5
        twoX.yScale = 0.5
        
        fourX.xScale = 0.5
        fourX.yScale = 0.5
        
        eightX.xScale = 0.5
        eightX.yScale = 0.5
        
        sixteenX.xScale = 0.5
        sixteenX.yScale = 0.5
        
        streakIcons.append(twoX)
        streakIcons.append(fourX)
        streakIcons.append(eightX)
        streakIcons.append(sixteenX)
        
        mountain.xScale = 0.5
        mountain.yScale = 0.5
        
        streakMeter.xScale = 0.6
        streakMeter.yScale = 0.6
        
        //Objekte werden im View positioniert
        chopsticks.position = CGPoint(x: 512, y: 10)
        
        mountain.position = CGPoint(x: 512, y: 150)
        mountain.zPosition = -1
        
        streakBar.position = CGPoint(x:327, y: 392)
        
        streakMeter.position = CGPoint(x: 325, y: 390)
        
        twoX.position = CGPoint(x: 325, y: 665)
        fourX.position = CGPoint(x: 325, y: 665)
        eightX.position = CGPoint(x: 325, y: 665)
        sixteenX.position = CGPoint(x: 325, y: 665)

        //Sprites
        self.addChild(mountain)
        self.addChild(chopsticks)
        self.addChild(streakMeter)
        self.addChild(streakBar)
        
        updateStreakMeter(streakBar, withStreak: streakPoints)
        
        //Game-Over timer ist auf 120 Sekunden gesetzt
        gameOver_Timer = Timer.scheduledTimer(timeInterval: 120.0, target: self, selector: #selector(GameScene.lostAll), userInfo: nil, repeats: false)
    }
    
    //Chopstick Slider
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        chopsticks.position = touch.location(in: self)
        let chopsticksPos = chopsticks.position.x
        chopsticks.position = CGPoint(x: chopsticksPos, y: 10)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch! = touches.first!
        chopsticks.position = touch.location(in: self)
        let chopsticksPos = chopsticks.position.x
        chopsticks.position = CGPoint(x: chopsticksPos, y: 10)
    }
    
    // Zufällige Fallzeit für die Sushi
    @objc func speedUp() -> TimeInterval {
        duration = TimeInterval(arc4random_uniform(4)+1)
        if duration > 1 {
            duration -= 1
        }
        return duration
    }
    
    //Sushi berührt Chopsticks
    func sushiCollidedWithChopsticks(_ sushi:SKSpriteNode) {
        streak += 1
        sushi.removeFromParent() //Sushi wird von der Szene entfernt
        updateBentoBox(UIImage(named: sushi.name!)!) //Bentobox wird geupdatet
        self.moneyLabel.text = String(money)
        
        //Streakmeter
        if (streakPoints >= 0 && streakPoints < 25) {
            streakPoints += 1
            self.updateStreakMeter(self.streakBar, withStreak: self.streakPoints)
            calcStreak(streakPoints)
        }
        
        if (streakPoints == 20 && streak==20) {
            calcStreak(streakPoints)
            powerUp()
        }
        
        if(streakPoints > 20) {
            calcStreak(streakPoints)
        }
        
    }
    
    func calcStreak(_ sPoints: Int) {
        
        //Bonusgeld wird abhängig der Streakpoints berechnet
        if sPoints < 5 {
            return
        }
        
        if sPoints >= 5 && sPoints < 10 {
            bonus = 100
            removeChildren(in: streakIcons)
            addChild(twoX)
        }
        
        if sPoints >= 10 && sPoints < 15 {
            bonus = 200
            removeChildren(in: streakIcons)
            addChild(fourX)
        }
        
        if sPoints >= 15 && sPoints < 20 {
            bonus = 400
            removeChildren(in: streakIcons)
            addChild(eightX)
        }
        
        if sPoints >= 20 {
            removeChildren(in: streakIcons)
            addChild(sixteenX)
            bonus = 800
        }
    
    }
    
    //Power-ups
    func powerUp() {
        
        let type = arc4random_uniform(3)+1
        
        switch(type) {
            case 1:
                //Große Chopsticks
                bigChopsticks()
                return
                
            case 2:
                //Slowmotion
                speed_Timer.invalidate()
                slowMo()
                return
                
            default:
                print("No power-up activated")
                return
        }
    }
    
    //Die größe der Chopsticks wird für 5 Sekunden erhöht
    func bigChopsticks() {
        print("Big chopsticks activated!")
        let scale : CGFloat = 0.5
        let time : TimeInterval = 0.5
        let scaleAction = SKAction.scale(to: scale, duration: time)
        chopsticks.run(scaleAction)

        _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(GameScene.smallchopsticks), userInfo: nil, repeats: false)
    }
    
    //Nach 5 Sekunden werden die Chopsticks resettet
    @objc func smallchopsticks() {
        let scale : CGFloat = 0.3
        let time : TimeInterval = 0.5
        let scaleAction = SKAction.scale(to: scale, duration: time)
        chopsticks.run(scaleAction)
    }
    
    //Slowmotion für 8 Sekunden    
    func slowMo() {
        print("Slow motion powerup activated!")

        duration = TimeInterval(4.0)
        _ = Timer.scheduledTimer(timeInterval: 8, target: self, selector: #selector(GameScene.reSpeed), userInfo: nil, repeats: false)
    }
    
    //Fallgeschwindigkeit wird nach Slowmo wieder hergestellt
    @objc func reSpeed() {
        //self.label.removeFromSuperview()
        speed_Timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameScene.speedUp), userInfo: nil, repeats: true)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        //Zentrale Kollisionsabfrage
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        //Wenn sushi mit den Chopsticks in Kontakt gekommen...
        if ((firstBody.categoryBitMask & PhysicsCategory.PhysicsSushi != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.PhysicsChopsticks != 0)) {
                sushiCollidedWithChopsticks(firstBody.node as! SKSpriteNode)
        }
    }
    
    @objc func pickSushi() {
    
        //Sushi wird zufällig am oberen Bildschirmrand positioniert
        let randomSushiPosition = Int(arc4random_uniform(400)+300)
        
        let sushi: SKSpriteNode! = SKSpriteNode(imageNamed: "sushi1")
        sushi.xScale = 0.4
        sushi.yScale = 0.4
        sushi.position = CGPoint(x : randomSushiPosition, y : 768)
        self.addChild(sushi)
        
        //Code nötig für Kollisionsabfrage
        sushi.physicsBody = SKPhysicsBody(circleOfRadius: sushi.size.height/3)
        sushi.physicsBody?.isDynamic = true
        sushi.physicsBody?.categoryBitMask = PhysicsCategory.PhysicsSushi
        sushi.physicsBody?.contactTestBitMask = PhysicsCategory.PhysicsChopsticks
        sushi.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        //Eines von drei Sushitypen
        let randomSushi = Int(arc4random_uniform(3)+1)
        
        switch(randomSushi) {
            //Animiert die Sushi's
            case 1 : let sushi_animate = SKAction.animate(with: [
                        SKTexture(imageNamed: "sushi1"),
                        SKTexture(imageNamed: "sushi1")
                        ], timePerFrame: 0.25)
            sushi.name = "sushi1"
            sushiArray.append(sushi)
            let run = SKAction.repeatForever(sushi_animate)
            sushi.run(run, completion: { sushi.removeFromParent() })
            fallSushi(sushi, rSushi : randomSushiPosition)

            case 2 : let sushi_animate = SKAction.animate(with: [
                SKTexture(imageNamed: "sushi2"),
                SKTexture(imageNamed: "sushi2")
                ], timePerFrame: 0.25)
            sushi.name = "sushi2"
            sushiArray.append(sushi)
            let run = SKAction.repeatForever(sushi_animate)
            sushi.run(run, completion: { sushi.removeFromParent() })
            fallSushi(sushi, rSushi : randomSushiPosition)
            
            case 3 : let sushi_animate = SKAction.animate(with: [
                SKTexture(imageNamed: "sushi3"),
                SKTexture(imageNamed: "sushi3")
                ], timePerFrame: 0.25)
            sushi.name = "sushi3"
            sushiArray.append(sushi)
            let run = SKAction.repeatForever(sushi_animate)
            sushi.run(run, completion: { sushi.removeFromParent() })
            fallSushi(sushi, rSushi : randomSushiPosition)
    
            default: print("Sushi not found")
            
        }
    }
    
    //Spielende
    func gameOver() {
        gamesPlayed=1
        gameEnded.center = CGPoint(x: 190, y: 260)
        gameEnded.textAlignment = NSTextAlignment.center
        gameEnded.text = "GAME OVER"
        gameEnded.font = UIFont(name:"Menlo-Bold", size: 40.0)
        self.view?.addSubview(gameEnded)
        sushi_Timer.invalidate()
        self.removeChildren(in: sushiArray)
        gameOver_Timer.invalidate()
        self.view!.addSubview(replayGame)
    }
    
    @objc func buttonAction(_ sender:UIButton!)
    {
        self.removeAllChildren()

        moneyLabel.removeFromSuperview()
        gameEnded.removeFromSuperview()
        replayGame.removeFromSuperview()
        restoreOrignalState()
        drawBentoBox(bentoBox)

        // This is the code that resets the scene
        let skView = self.view! as SKView
        skView.ignoresSiblingOrder = true
        let scene = GameScene(fileNamed: "GameScene")
        scene?.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
    
    func restoreOrignalState(){
        bentoBox.removeAll(keepingCapacity: false)
        money = 0
        sushiDropped = 0
        streakPoints = 0
    }
    
    func fallSushi(_ node : SKSpriteNode, rSushi : Int) {

        let fallDown = SKAction.move(to: CGPoint(x: rSushi, y: -20), duration: duration)

        node.run(fallDown, completion: {
            self.removeChildren(in: self.streakIcons)
            self.sushiDropped += 1
            self.streakPoints = 0
            self.bonus = 0
            self.money -= 300;
            self.calcMaxStreak()
            self.moneyLabel.text = String(self.money)
            node.removeFromParent()
            self.updateStreakMeter(self.streakBar, withStreak: self.streakPoints)
            if self.money < 600 {
                self.gameDelegate?.lostAll()
            }
        })
        
        
    }
    
    func calcMaxStreak() {
        if(streak>maxStreak) {
            maxStreak = streak
        }
        streak = 0
        return
    }
    
    //Bentobox wird aktualisiert
    func updateBentoBox(_ catchedSushi: UIImage) {
        var found = false
        if(bentoBox.isEmpty) {
            bentoBox.append(catchedSushi)
        } else {
            for sushi in bentoBox {
                if(catchedSushi.isEqual(sushi)) {
                    found = true
                }
            }
            if (!found) {
                bentoBox.append(catchedSushi)
            }
        }
        
        //Wenn Bentobox voll, dann +1100 Yen und Bonus wenn vorhanden
        if(bentoBox.count == 3) {
            money += 1100 + bonus
            bentoBox.removeAll(keepingCapacity: false)
        }
        drawBentoBox(bentoBox)
    }
    
    //Bentobox Mockup wird gezeichnet
    func drawBentoBox(_ bentoBox: [UIImage]) {
        let size : CGFloat = 50
        var x : CGFloat = 10
        let y : CGFloat = 10
        if(bentoBox.isEmpty) {
            for view in bentoBoxViews {
                view.removeFromSuperview()
            }
        }
        else {
            for image in bentoBox {
                let bentoBoxView = UIImageView()
                bentoBoxView.frame = CGRect(x: x, y: y, width: size, height: size)
                bentoBoxView.image = image;
                bentoBoxViews.append(bentoBoxView)
                self.view?.addSubview(bentoBoxView);
                x += 50
            }
        }
    }
    
    //Streakmeter am linken Bildschirmrand wird geupdatet
    func updateStreakMeter(_ node: SKSpriteNode, withStreak sP: Int) {
        
        let barSize = CGSize(width: 21, height: 474)
        
        let fillColor = UIColor(red: 245.0/255, green: 166.0/255, blue: 35.0/255, alpha:1)

        UIGraphicsBeginImageContextWithOptions(barSize, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        
        fillColor.setFill()
        
        let barHeight = (barSize.height) * CGFloat(sP) / CGFloat(25)
        let barRect = CGRect(x: 0, y: 5, width: barSize.width, height: barHeight)
        
        context?.fill(barRect)
        
        let spriteImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        node.texture = SKTexture(image: spriteImage!)
        node.size = barSize

    }
    
    //Animiert die Wolken
    @objc func clouds() {
        
        let randomCloudPosition = Int(arc4random_uniform(470)+200)
        let cloudPick =  Int(arc4random_uniform(5)+1) //pick random cloud

        let cloud: SKSpriteNode! = SKSpriteNode(imageNamed: "cloud\(cloudPick)")
        
        cloud.xScale = 0.5
        cloud.yScale = 0.5
        
        let direction = Int(arc4random_uniform(2)+1)
        
        switch(direction){
            //L->R Movement
            case 1: cloud.position = CGPoint(x: -40, y: randomCloudPosition)
            //R->L Movement
            case 2: cloud.position = CGPoint(x: 800, y: randomCloudPosition)
            
            default: cloud.position = CGPoint(x: -40, y: randomCloudPosition)
        }
        
        self.addChild(cloud)
        
        let moveAcrossLR = SKAction.move(to: CGPoint(x: 800, y: randomCloudPosition), duration:7.0) // Left to right transition
        
        let moveAcrossRL = SKAction.move(to: CGPoint(x: -40, y: randomCloudPosition), duration:7.0) // right to left transition
        
        //Richtung der Animation
        switch(cloudPick) {
            case 1:
            if(direction == 1) {
                cloud.run(moveAcrossLR, completion: { cloud.removeFromParent() })
                
            }
            else {
                cloud.run(moveAcrossRL, completion: { cloud.removeFromParent() })
            }
            
            case 2:
            if(direction == 1) {
                cloud.run(moveAcrossLR, completion: { cloud.removeFromParent() })
            }
            else {
                cloud.run(moveAcrossRL, completion: { cloud.removeFromParent() })
            }
            
            case 3:
            if(direction == 1) {
                cloud.run(moveAcrossLR, completion: { cloud.removeFromParent() })
            }
            else {
                cloud.run(moveAcrossRL, completion: { cloud.removeFromParent() })
            }
            
            case 4:
            if(direction == 1) {
                cloud.run(moveAcrossLR, completion: { cloud.removeFromParent() })
            }
            else {
                cloud.run(moveAcrossRL, completion: { cloud.removeFromParent() })
            }
            
            case 5:
            if(direction == 1) {
                cloud.run(moveAcrossLR, completion: { cloud.removeFromParent() })
            }
            else {
                cloud.run(moveAcrossRL, completion: { cloud.removeFromParent() })
            }

            default: print("Cloud not found")
        }

    }
    
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}
