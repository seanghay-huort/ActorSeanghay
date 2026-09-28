//
//  SceneDelegate.swift
//  ActorSeanghay
//
//  Created by Seanghay HUORT (IT) on 9/25/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let listVC = TaskListViewController(style: .insetGrouped)
        window.rootViewController = UINavigationController(rootViewController: listVC)
        self.window = window
        window.makeKeyAndVisible()
    }
}

