//
//  MapViewModel.swift
//  tweets-map
//
//  Created by Tabirta Adrian on 08.07.2021.
//

import MapKit
import RxCocoa
import RxSwift

public class TweetMapViewModel: ViewModelType {
    
    struct Input {
        let query: ControlProperty<String?>
        let didSelectAnnotationView: ControlEvent<MKAnnotationView>
    }
    
    struct Output {
        let geoTweets: Driver<[GeoTweet]>
        let presentTweetDetail: Observable<GeoTweet>
    }
    
    private var tweets = BehaviorRelay<[GeoTweet]>(value: [])
    private let provider: NetworkServiceProvider<TweetService>
    private let disposeBag: DisposeBag
    
    init(provider: NetworkServiceProvider<TweetService> = NetworkServiceProvider<TweetService>(),
         disposeBag: DisposeBag = DisposeBag()) {
        self.provider = provider
        self.disposeBag = disposeBag
    }
}

extension TweetMapViewModel {
    
    func transform(input: Input) -> Output {
        
        let filters = input.query
            .orEmpty
            .filter{ !($0.count == 0) }
            .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMap{ [unowned self] _ -> Observable<Result<TwitterResponse<[Rule]>, Error>> in
                return provider.request(endpoint: .findAllRules)
            }
            .map{ try? $0.get().data }
            .share()
        
        
        filters
            .filter{ $0 == nil }  // add first rule when no other rule exist
            .withLatestFrom(input.query.orEmpty)
            .flatMapLatest{ [unowned self] query -> Observable<Result<TwitterResponse<[Rule]>, Error>> in
                return self.provider.request(endpoint: .addRule(query: query))
            }
            .map({ result -> Void in
                switch result {
                case .success(_): break
                case let .failure(error):
                    AppError(error)?.handle()
                }
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        filters
            .filter{ $0 != nil } // have already rules, delete them and add new
            .compactMap{ $0 as! [Rule] }
            .compactMap { $0.map { (rule) -> String in return rule.id } }
            .flatMapLatest{ [unowned self] ids -> Observable<Result<TwitterResponse<EmptyBody>, Error>> in
                return provider.request(endpoint: .removeAllRules(ids: ids))
            }
            .map({ result -> Void in
                switch result {
                case .success(_): break
                case let .failure(error):
                    AppError(error)?.handle()
                }
            })
            .withLatestFrom(input.query.orEmpty)
            .flatMapLatest{ [unowned self] query -> Observable<Result<TwitterResponse<[Rule]>, Error>> in
                return provider.request(endpoint: .addRule(query: query))
            }
            .map({ result -> Void in
                switch result {
                case .success(_): break
                case let .failure(error):
                    AppError(error)?.handle()
                }
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        
        
        // Start streem
        Observable.just(TweetService.streamTweets)
            .flatMapLatest{ [unowned self] endpoint -> Observable<[GeoTweet]> in
                return self.provider.requestStream(endpoint: endpoint)
            }
            .map{ $0.filter { $0.containsCoordinates } } // only tweets with coordinates
            .filter{ !$0.isEmpty }
            .bind(to: tweets)
            .disposed(by: disposeBag)
        
        // Update eery sec tweets and remove old one.
        let timer = Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
        Observable.zip(timer, tweets.asObservable(), resultSelector: { timer, data in return data })
            .map { (tweets) -> [GeoTweet] in
                return tweets.filter { $0.expireAt < Date() }
            }
            .bind(to: tweets)
            .disposed(by: disposeBag)
        
        
        
        let presentTweetDetail = input.didSelectAnnotationView.compactMap{ [unowned self] annotation -> GeoTweet? in
            return self.tweets.value.filter { (tweet) -> Bool in
                return tweet.coordinate.latitude == annotation.annotation?.coordinate.latitude
                    && tweet.coordinate.longitude == annotation.annotation?.coordinate.longitude
            }.first
        }
        
        return Output(geoTweets: tweets.asDriver(onErrorJustReturn: []),
                      presentTweetDetail: presentTweetDetail)
    }
}


extension BehaviorRelay where Element: RangeReplaceableCollection {
    
    func append(_ subElement: [Element.Element]) {
        var newValue = value
        newValue.append(contentsOf: subElement)
        accept(newValue)
    }
}
