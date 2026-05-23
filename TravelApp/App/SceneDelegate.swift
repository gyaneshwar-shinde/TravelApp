//
//  SceneDelegate.swift
//  TravelApp
//
//  Created by Laptop X on 23/05/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        let window = UIWindow(windowScene: windowScene)

        // Root View Controller
        window.rootViewController = MainTabBarController()

        self.window = window
        window.makeKeyAndVisible()
    }
}
