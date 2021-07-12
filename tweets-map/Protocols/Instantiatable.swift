//
//  Instantiatable.swift
//  tweets-map
//
//  Created by Tabirta Adrian on 08.07.2021.
//

import Foundation

/// `init(with:)` make user interface object with Nib/Storyboard and some parameter(s) using `Injectable` protocol.
public protocol Instantiatable: Injectable {
    init(with dependency:Dependency)
}

public extension Instantiatable {
    static func instantiate(with dependency: Dependency) -> Self {
        return Self(with: dependency)
    }
}

public extension Instantiatable where Dependency == Void {
    static func instantiate() -> Self {
        return Self(with: ())
    }
}
