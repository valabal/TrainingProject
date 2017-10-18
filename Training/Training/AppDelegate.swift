//
//  AppDelegate.swift
//  Training
//
//  Created by Valbal on 8/21/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import UIKit
import MBProgressHUD
import INTULocationManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    var HUD : MBProgressHUD?
    var locationRequestID : INTULocationRequestID?
    var sceneCoordinator : SceneCoordinator? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.setUpRootViewController()
        self.initHUDNotif()
        self.startLocationUpdateSubscription()
        
        return true
    
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.cancelLocationRequest()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
         self.startLocationUpdateSubscription()
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
        
        sceneCoordinator = SceneCoordinator(window: window!)
        
        if(UserManager.accessToken() == nil){
            let viewModel = LoginVM(coordinator: sceneCoordinator!)
            let firstScene = Scene.login(viewModel)
            sceneCoordinator!.transition(to: firstScene, type: .root)
        }
        else{
            let viewModel = MainVM(coordinator: sceneCoordinator!)
            let firstScene = Scene.mainVC(viewModel)
            sceneCoordinator!.transition(to: firstScene, type: .root)
        }
        
        self.HUD = nil;
        
    }
    
    
    func resetAllViews(){
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
        
        if(self.HUD?.alpha == 0){
            self.HUD?.label.text = "Loading..."
            self.HUD?.show(animated: true)
        }
        
    }
    
    func hideHUD(notification:NSNotification?){
        HUD?.hide(animated: true)
    }
    

}

// MARK: Location Manager
extension AppDelegate {

    func getLocationErrorDescription(status : INTULocationStatus) -> String?{
       
        if (status == .servicesNotDetermined){
           return "Error: User has not responded to the permissions alert."
        }
        if (status == .servicesDenied){
            AlertHelper.showAlert(title: "Location Not Found", message: "Location Not Found Please Turn On Your Location Settings")
            return "Error: User has denied this app permissions to access device location.";
        }
        if (status == .servicesRestricted){
            AlertHelper.showAlert(title: "Location Not Found", message: "Location Not Found Please Turn On Your Location Settings")
            return "Error: User is restricted from using location services by a usage policy.";
        }
        if (status == .servicesDisabled){
            AlertHelper.showAlert(title: "Location Not Found", message: "Location Not Found Please Turn On Your Location Settings")
            return "Error: Location services are turned off for all apps on this device.";
        }
         return "An unknown error occurred.\n(Are you using iOS Simulator with location set to 'None'?)";
    
    }
    
    func startLocationUpdateSubscription(){
    
        guard let locReq = self.locationRequestID, locReq != NSNotFound else{
         
            let locMgr = INTULocationManager.sharedInstance()
            
            self.locationRequestID = locMgr.subscribeToLocationUpdates({(currentLocation:CLLocation?, achievedAccuracy : INTULocationAccuracy, status : INTULocationStatus) in
                
                if let currentLocation = currentLocation,status == INTULocationStatus.success{
                    let result = ["lat":NSNumber(value: currentLocation.coordinate.latitude),"lng":NSNumber(value: currentLocation.coordinate.longitude)]
                    UserManager.saveCurrentCoordinate(dic: result as NSDictionary?)
                }
                else{
                    let error = self.getLocationErrorDescription(status: status)
                    print ("ERROR LOCATION \n \(error)")
                }
                
               }
            )
           return
        }
    }
    
    func cancelLocationRequest(){
        if let locationReq = self.locationRequestID, locationReq != NSNotFound {
        INTULocationManager.sharedInstance().cancelLocationRequest(locationReq)
        self.locationRequestID = NSNotFound
        }
    }
    

}


