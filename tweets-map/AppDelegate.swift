//
//  AppDelegate.swift
//  tweets-map
//
//  Created by Tabirta Adrian on 08.07.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let navigationController = storyboard.instantiateViewController(withIdentifier: "MainNavBarController") as! UINavigationController
        let vc = storyboard.instantiateViewController(identifier: "DecoderViewController") as! UIViewController
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
        
        return true
    }
}
