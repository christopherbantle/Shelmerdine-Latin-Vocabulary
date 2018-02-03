//
//  AppDelegate.swift
//  Shelmerdine Latin Vocabulary
//
//  Created by Christopher Bantle on 2018-01-31.
//  Copyright © 2018 Christopher Bantle. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var databaseManager: DatabaseManager {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.databaseManager!
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var databaseManager: DatabaseManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let bundle = Bundle.main
        let pathToDatabase = bundle.url(forResource: "latin_vocabulary", withExtension: ".sqlite3")
        self.databaseManager = DatabaseManager(pathToDatabase: pathToDatabase!.absoluteString)
        return true
    }
}

