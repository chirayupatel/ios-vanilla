//
//  AppDelegate.swift
//  Vanilla
//
//  Created by Alex on 7/11/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import FlybitsKernelSDK
import FlybitsContextSDK
import FlybitsPushSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var projectID: String!
    var flybitsManager: FlybitsManager?
    let scopes: [FlybitsScope] = [
        KernelScope(),
        ContextScope(timeToUploadContext: 5, timeUnit: Utilities.TimeUnit.seconds),
        PushScope()]
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if !checkForRequiredFlybitsProjectID() {
            return false
        }
        
        FlybitsManager.enableLogging()
        
        UINavigationBar.appearance().tintColor = UIColor(red: 41/255, green: 190/255, blue: 238/255, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 51/255, green: 62/255, blue: 72/255, alpha: 1)]
        
        var shouldPerformAdditionalDelegateHandling = true
        
        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification {
            application.cancelLocalNotification(notification)
            shouldPerformAdditionalDelegateHandling = false
        } else if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: Any] {
            print(notification)
        }
        
        return shouldPerformAdditionalDelegateHandling
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
    
    // MARK: - Required Project ID
    
    func checkForRequiredFlybitsProjectID() -> Bool {
        
        guard let url = Bundle.main.url(forResource: "FlybitsProjectID", withExtension: "plist") else {
            print("Missing FlybitsProjectID.plist file")
            return false
        }
        guard let dictionary = NSDictionary(contentsOf: url), let projectID = dictionary["ProjectID"] as? String else {
            print("Failed reading from ProjectID key in FlybitsProjectID.plist file")
            return false
        }
        self.projectID = projectID
        return true
    }

    // MARK: - APNS Notifications
    
    struct FlybitsNotification {
        static let identifier = "com.flybits.lite_notification_identifier"
        static let title      = "com.flybits.lite_notification_title"
        static let body       = "com.flybits.lite_notification_body"
    }
    
    var pushDeviceToken: Data?
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        application.cancelLocalNotification(notification)
        
        let title = notification.userInfo?[FlybitsNotification.title] as? String
        let body = notification.userInfo?[FlybitsNotification.body] as? String
        
        // If it's a link, add a view button so it may be opened with a supported app.
        if var body = body,
            let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue),
            let match = detector.firstMatch(in: body, options: .reportCompletion, range: NSMakeRange(0, body.characters.count)),
            let matchedURL = match.url, application.canOpenURL(matchedURL) {
            
            let matchedRange = match.range
            let urlRange: Range = body.startIndex..<body.index(body.startIndex, offsetBy: matchedRange.length)
            body.removeSubrange(urlRange)
            
            let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Dismiss", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "View", style: .default) { _ in
                application.openURL(matchedURL)
            })
            application.delegate?.window??.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            
            let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            application.delegate?.window??.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("APNS device token: \(deviceTokenString)")
        
        if deviceToken.count > 0 {
            self.pushDeviceToken = deviceToken
            PushManager.shared.configuration.apnsToken = pushDeviceToken
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNS registration failed: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> ()) {
        print("Did receive remote notification")
        
        if let aps = userInfo["aps"] as? [String: Any], let alert = aps["alert"] as? [String: Any] {
            if UIApplication.shared.applicationState == .active {
                
                let title: String? = alert["title"] as? String
                let body: String? = alert["body"] as? String
                let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction.init(title: "Dismiss", style: .default, handler: nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                
                completionHandler(UIBackgroundFetchResult.newData)
            }
        }
    }
}

