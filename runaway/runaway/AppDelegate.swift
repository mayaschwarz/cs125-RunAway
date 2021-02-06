//
//  AppDelegate.swift
//  runaway
//
//  Created by Kay Lab on 1/30/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import UIKit
import Parse




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let parseConfig = ParseClientConfiguration {
                $0.applicationId = "2mWkdg6LnYfgxqm4PQkDLiG7WWeEGq21T3uvOHjo"
                $0.clientKey = "Tk5ogEvZAC7EXlAtnXk9Yn41Qo7UUxJ3gul6f0Aa"
                $0.server = "https://parseapi.back4app.com"
        }
        Parse.initialize(with: parseConfig)
        
        saveInstallationObject()
        
        return true
    }
    
    func saveInstallationObject(){
            if let installation = PFInstallation.current(){
                installation.saveInBackground {
                    (success: Bool, error: Error?) in
                    if (success) {
                        print("You have successfully connected your app to Back4App!")
                    } else {
                        if let myError = error{
                            print(myError.localizedDescription)
                        }else{
                            print("Unknown error")
                        }
                    }
                }
            }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.#imageLiteral(resourceName: "simulator_screenshot_DCA45749-D416-4359-9939-6C8469F6D4EB.png")
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
   
    


}

