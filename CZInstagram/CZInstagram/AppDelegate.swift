//
//  AppDelegate.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 9/2/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import UIKit
import CZUtils
import ReactiveListViewKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    enum AppMode {
        case `default`, login, test
        var feedListController: UIViewController {
            switch self {
            case .`default`:
                return FeedListViewController()
            case .login:
                return LoginViewController(nibName:"LoginViewController", bundle: .main)
            case .test:
                return TestViewController(nibName:"TestViewController", bundle: .main)
            default:
                break
            }
        }
    }
    static let appMode: AppMode = .default

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let navigationViewController = UINavigationController()
        navigationViewController.pushViewController(AppDelegate.appMode.feedListController, animated: true)
        window?.rootViewController = navigationViewController
        window?.makeKeyAndVisible()
        return true
    }
}
