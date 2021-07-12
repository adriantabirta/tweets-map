//
//  Injectable.swift
//  tweets-map
//
//  Created by Tabirta Adrian on 08.07.2021.
//

import Foundation

public protocol Injectable {
    
    associatedtype Dependency = Void
    func inject(_ dependency: Dependency)
}

public extension Injectable where Dependency == Void {
    func inject(_ dependency: Dependency) {
        
    }
}
