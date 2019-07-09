//
//  SceneDelegate.swift
//  BabylonDemoApp
//
//  Created by Kyle Alan Hale on 6/27/19.
//  Copyright © 2019 Kyle Alan Hale. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: SceneView())
        window.tintColor = UIColor(named: "tint") ?? window.tintColor
        self.window = window
        window.makeKeyAndVisible()
    }
}
