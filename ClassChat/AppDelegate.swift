//
//  AppDelegate.swift
//  ClassChat
//
//  Created by Stephen Link on 8/4/18.
//  Copyright © 2018 Stephen Link. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var authHandle : AuthStateDidChangeListenerHandle?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        // Override point for customization after application launch.
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
        self.authHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            weak var navController = self.window?.rootViewController as? UINavigationController
            
            if let userUnwrapped = user {
                
                print("gotta be somewhere*************************")
                
                weak var dash = navController?.viewControllers[0] as? DashboardController
                if dash == nil {
                    print("dash is nil")
                } else {
                    print("dash is defined")
                }
                dash?.user = userUnwrapped
                dash?.authenticateUser()
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let firstVC = storyboard.instantiateViewController(withIdentifier: "Auth")
                
                //navController.setNavigationBarHidden(true, animated: true)
                navController?.pushViewController(firstVC, animated: true)
                //self.window?.rootViewController = firstVC
                print("we here ********************************")
            }
        }
        
        print("applicationDidBecomeActive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

