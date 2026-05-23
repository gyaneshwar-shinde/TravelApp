//
//  HeroNavigationController.swift
//  TravelApp
//
//  Created by Laptop X on 23/05/26.
//


import UIKit
import Hero

final class HeroNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        hero.isEnabled = true
        hero.navigationAnimationType = .auto  // or .fade, .push(direction:), .zoom, etc.
    }
}