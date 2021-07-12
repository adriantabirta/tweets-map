//
//  ViewModelType.swift
//  tweets-map
//
//  Created by Tabirta Adrian on 08.07.2021.
//

import UIKit

protocol ViewModelType {
  associatedtype Input
  associatedtype Output
  
  func transform(input: Input) -> Output
}
