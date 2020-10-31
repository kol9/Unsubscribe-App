//
//  AppDelegate.swift
//  Unsubscribe App
//
//  Created by Nikolay Yarlychenko on 01.03.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import UIKit
import VK_ios_sdk

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//
//           return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//       }
//
//       func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//       }
//
       
       func application(_ app: UIApplication,
                        open url: URL,
                        options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
           VKSdk.processOpen(url, fromApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?)
           
           return true
       }
       
    
    func applicationWillResignActive(_ application: UIApplication) {
        print(#function)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print(#function)
    }
      
}

