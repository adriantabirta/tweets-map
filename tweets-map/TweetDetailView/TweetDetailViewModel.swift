//
//  TweetDetailViewModel.swift
//  tweets-map
//
//  Created by Tabirta Adrian on 08.07.2021.
//

import RxCocoa
import RxSwift

class TweetDetailViewModel: NSObject {

    struct Input {}
    
    struct Output {
        let id: Driver<String>
        let text: Driver<String>
        let location: Driver<String>
    }
    
    private var tweet: GeoTweet
    private lazy var bag = DisposeBag()
    
    init(tweet: GeoTweet) {
        self.tweet = tweet
    }
}

extension TweetDetailViewModel {
    
    func transform(input: Input) -> Output {
        
        return Output(id: Driver.just("Id: \(tweet.id.description)"),
                      text: Driver.just("Title: \(tweet.title ?? "")" ),
                      location:  Driver.just("Coordinates \(tweet.coordinate.latitude.description),\(tweet.coordinate.longitude.description)"))
    }
}

