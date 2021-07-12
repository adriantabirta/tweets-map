//
//  UIViewController.swift
//  tweets-map
//
//  Created by Tabirta Adrian on 08.07.2021.
//

import UIKit

public extension StoryboardInstantiatable where Self: UIViewController {
    init(with dependency:Dependency) {
        let storyboard = (Self.self as StoryboardType.Type).storyboard
        switch Self.instantiateSource {
        case .initial:
            self = storyboard.instantiateInitialViewController() as! Self
        case .identifier(let identifier):
            self = storyboard.instantiateViewController(withIdentifier: identifier) as! Self
        }
        if self is ViewLoadBeforeInject {
            _ = self.view
        }
        self.inject(dependency)
    }
}
