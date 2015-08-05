import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    //var pauseDelegate: PauseDelegate?
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //pauseDelegate = GameScene.self
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        
        GameScene().sushi_Timer.delete(GameScene)
        //NSNotificationCenter.defaultCenter().postNotificationName("Pause Game", object: self)
    }

    func applicationDidEnterBackground(application: UIApplication) {
        
        //GameScene().dog_Timer.delete(GameScene)
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground
    }


}

