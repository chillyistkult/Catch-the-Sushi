import UIKit
import SpriteKit

extension SKNode {
    class func unarchive(from file : String) -> SKNode? {
        if let url = Bundle.main.url(forResource: file, withExtension: "sks") {
            do {
                let sceneData = try Data(contentsOf: url)
                let archiver = NSKeyedUnarchiver(forReadingWith: sceneData)
                
                archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
                let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! GameScene
                archiver.finishDecoding()
                return scene
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.pauseGameScene), name: NSNotification.Name(rawValue: "Pause Game"), object: nil)
        if let scene = GameScene.unarchive(from: "GameScene") as? GameScene {

            let skView = self.view as! SKView
            skView.ignoresSiblingOrder = false
            scene.scaleMode = .aspectFill
            skView.presentScene(scene)
        }
    }
    
    func pauseGameScene() {
        if (GameScene.unarchive(from: "GameScene") as? GameScene) != nil {
            let skView = self.view as! SKView

            if skView.scene != nil {
                skView.isPaused = skView.scene!.isPaused
            }
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override var shouldAutorotate : Bool {
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
