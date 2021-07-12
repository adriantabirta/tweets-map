//
//  ViewController.swift
//  tweets-map
//
//  Created by Tabirta Adrian on 08.07.2021.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit
import RxMKMapView
import Foundation

class TweetMapView: UIViewController {
    
    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var map: MKMapView!
    
    private lazy var viewModel = TweetMapViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.transform(input: .init(query: input.rx.text,
                                                      didSelectAnnotationView: map.rx.didSelectAnnotationView))
        
        
        output.geoTweets.drive(map.rx.annotations).disposed(by: disposeBag)
        output.presentTweetDetail
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] tweet in
                let vc = TweetDetailView(with: .init(viewModel: .init(tweet: tweet)))
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)

        map.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        map.rx.regionWillChangeAnimated.do(onNext: { [weak self] _ in
            self?.input.resignFirstResponder()
        })
        .subscribe()
        .disposed(by: disposeBag)
    }
}

extension TweetMapView: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        view.setSelected(false, animated: false)
    }
}
