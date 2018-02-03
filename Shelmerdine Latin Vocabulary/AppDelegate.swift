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
        return appDelegate.databaseManager
    }
    
    var latestChapterForCumulativeViewScreen: Chapter {
        get {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate.latestChapterForCumulativeViewScreen
        }
        set {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.latestChapterForCumulativeViewScreen = newValue
        }
    }
    
    var chapterForIndividualChapterViewScreen: Chapter {
        get {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate.chapterForIndividualChapterViewScreen
        }
        set {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.chapterForIndividualChapterViewScreen = newValue
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var databaseManager: DatabaseManager = {
        let bundle = Bundle.main
        let pathToDatabase = bundle.url(forResource: "latin_vocabulary", withExtension: ".sqlite3")
        guard let databaseManger = DatabaseManager(pathToDatabase: pathToDatabase!.absoluteString) else {
            fatalError("Could not establish connection to database.")
        }
        return databaseManger
    }()
    
    var latestChapterForCumulativeViewScreen: Chapter = {
        let chapterNum = UserDefaults.standard.integer(forKey: "lastestChapterForCumulativeViewScreen")
        if chapterNum == 0 {
            return .ChapterOne
        } else {
            return Chapter(rawValue: chapterNum)!
        }
    }() {
        didSet {
            UserDefaults.standard.set(self.latestChapterForCumulativeViewScreen.rawValue, forKey: "lastestChapterForCumulativeViewScreen")
        }
    }
    
    var chapterForIndividualChapterViewScreen: Chapter = {
        let chapterNum = UserDefaults.standard.integer(forKey: "chapterForIndividualChapterViewScreen")
        if chapterNum == 0 {
            return .ChapterOne
        } else {
            return Chapter(rawValue: chapterNum)!
        }
        }() {
        didSet {
            UserDefaults.standard.set(self.latestChapterForCumulativeViewScreen.rawValue, forKey: "chapterForIndividualChapterViewScreen")
        }
    }
}

