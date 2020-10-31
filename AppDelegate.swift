//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Luk, Alex on 5/2/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let dataController = DataController(modelName: "Virtual Tourist")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        dataController.load()
        
        let travelLocationsMapViewController = window?.rootViewController as! TravelLocationsMapViewController
        travelLocationsMapViewController.dataController = dataController
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        saveViewContext()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveViewContext()
    }

    func saveViewContext() {
        try? dataController.viewContext.save()
    }

}

