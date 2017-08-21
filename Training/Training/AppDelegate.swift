//
//  AppDelegate.swift
//  Training
//
//  Created by Valbal on 8/21/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import UIKit
import MBProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var HUD : MBProgressHUD?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.setUpRootViewController()
        self.initHUDNotif()
        
        return true
    
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func initHUDNotif(){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.showHUD),
            name: NSNotification.Name.ShowHUD,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.hideHUD),
            name: NSNotification.Name.HideHUD,
            object: nil)
        
    }
    
    
    func setUpRootViewController(){
        
        let storyboard = UIStoryboard.init(name: "MainSB", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MainVC")
        
        let navController : UINavigationController = UINavigationController.init(rootViewController: viewController)
        self.window?.rootViewController = navController;
        navController.setNavigationBarHidden(true, animated: false)
        
        self.window?.makeKeyAndVisible()
        
        self.HUD = nil;
        
    }
    
    
    func resetAllViews(modalVC:UIViewController?){
        // Create new Intro
        self.setUpRootViewController()
        
    }
    
    func showHUD(notification:NSNotification?){
        
        if(self.HUD == nil){
            
            guard let window = self.window else{
                return
            }
            
            self.HUD = MBProgressHUD.init(frame:window.frame)
            window.addSubview(self.HUD!)
            
        }
        
        if(HUD?.alpha == 0){
            HUD?.label.text = "Loading..."
            HUD?.show(animated: true)
        }
        
    }
    
    func hideHUD(notification:NSNotification?){
        HUD?.hide(animated: true)
    }
    

}

