//
//  DetailViewController.swift
//  tweets-map
//
//  Created by Tabirta Adrian on 08.07.2021.
//

import UIKit
import RxSwift
import RxCocoa

class TweetDetailView: UIViewController {
    
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var location: UILabel!
    
    private let disposeBag = DisposeBag()
}

extension TweetDetailView: StoryboardInstantiatable {
    
    public struct Dependency {
        let viewModel: TweetDetailViewModel
    }
    
    static var storyboardName: StoryboardName {
        return "Main"
    }
    
    func inject(_ dependency: Dependency) {
        _ = self.view
        dependency.viewModel.transform(input: .init()).id.drive(id.rx.text).disposed(by: disposeBag)
        dependency.viewModel.transform(input: .init()).text.drive(text.rx.text).disposed(by: disposeBag)
        dependency.viewModel.transform(input: .init()).location.drive(location.rx.text).disposed(by: disposeBag)
    }
}
