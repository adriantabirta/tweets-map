//
//  TestVC.swift
//  tweets-map
//
//  Created by Tabirta Adrian on 28.07.2021.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture
import Network

public enum Message {
    case data(Data)
    case string(String)
}

struct TouchEvent: Encodable {
    let width: CGFloat
    let height: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension OutputStream {
  func write(data: Data) -> Int {
    return data.withUnsafeBytes { write($0, maxLength: data.count) }
  }
}
extension InputStream {
  func read(data: inout Data) -> Int {
    var temp = data
    return temp.withUnsafeMutableBytes { read($0, maxLength: data.count) }
  }
}

class ImageVC: UIViewController {
    
    @IBOutlet weak var dataImageView: UIImageView!
    private let provider = NetworkServiceProvider<TweetService>()
    private let disposeBag = DisposeBag()
    
    
    let webSocketTask = URLSession(configuration: .default).webSocketTask(with: URL(string: "ws://192.168.100.28:8080/echo")!)
    
    
    func receive() {
        webSocketTask.receive { [self] result in
            switch result {
            case .failure(let error):
                print("Failed to receive message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received text message: \(text)")
                case .data(let data):
                    
//                    print("Received binary message: \(data)")

                    DispatchQueue.main.async {
                        dataImageView.image = UIImage(data: data)
                        
                    }
                    print("Received binary message: \(data)")
                @unknown default:
                    fatalError()
                }
            }
            
            self.receive()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webSocketTask.resume()
        
        
        dataImageView.rx.panGesture()
            .when(.changed)
            .map{ $0.location(in: self.view) }
            .throttle(RxTimeInterval.milliseconds(100), latest: true, scheduler: MainScheduler.instance)
//            .map{ $0.translation }
            .map{ TouchEvent(width: UIScreen.main.bounds.size.width * 2, height: UIScreen.main.bounds.size.height * 2, x: $0.x, y: $0.y) }
            .compactMap{ try? JSONEncoder().encode($0) }
            .map{ URLSessionWebSocketTask.Message.data($0) }
            .do(onNext: { json in
                self.webSocketTask.send(json) { error in
                    if let error = error {
                        print("WebSocket sending error: \(error)")
                    }
                }
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        receive()

    
        
        //        let message = URLSessionWebSocketTask.Message.string("image")
        
        
        
        //        let message = URLSessionWebSocketTask.Message.string("{  }")
        //        webSocketTask.send(message) { error in
        //            if let error = error {
        //                print("WebSocket sending error: \(error)")
        //            }
        //        }
        
        
        
        //        while true {
        //            webSocketTask.receive { result in
        //                switch result {
        //                case .failure(let error):
        //                    print("Failed to receive message: \(error)")
        //                case .success(let message):
        //                    switch message {
        //                    case .string(let text):
        //                        print("Received text message: \(text)")
        //                    case .data(let data):
        //                        print("Received binary message: \(data)")
        //                    @unknown default:
        //                        fatalError()
        //                    }
        //                }
        //            }
        //        }
        //(with: "ws://0.0.0.0:8080/echo")
        
        
        //        conn.stateUpdateHandler = stateDidChange(to:)
        //        setupReceive()
        //        conn.start(queue: DispatchQueue.global(qos: .background))
        //
        
        //        let conn = NetworkConnection(nwConnection: NWConnection(host: "192.168.100.28", port: 8080, using: .tcp))
        //        conn.delegate = self
        //        conn.start(queue: DispatchQueue.global())
        
        
        
        //        let stream = URLSession(configuration: URLSessionConfiguration.default).streamTask(withHostName: "192.168.100.28", port: 8080)
        //
        //
        //        stream.readData(ofMinLength: 1, maxLength: 23039, timeout: 5) { (data, success, error) in
        //
        //            print(String(data: data!, encoding: .utf8))
        ////            print(data?.count)
        ////            let image = UIImage(data: data!)
        ////            print(error?.localizedDescription)
        //        }
        //
        //        stream.resume()
        
        //            .dataTask(with: URLRequest(url: URL(string: "http://192.168.100.28:8080")!)) { (data, response, error) in
        //
        //                print(data?.count)
        ////                print(String(data: data!, encoding: .utf8))
        //            }.resume()
        
        
        
        //         Observable.just(TweetService.streamTweets)
        //         .flatMapLatest{ [unowned self] endpoint -> Observable<(Data, Int)> in
        //         return self.provider.requestStreamImage(endpoint: endpoint)
        //         }
        //         .do(onNext: { [unowned self] data in
        ////            if let imageData = Data(base64Encoded:  data.0) {
        ////                let image = UIImage(data:  imageData)
        ////                print(String(data: data.0, encoding: .utf8))
        ////
        ////            }
        ////
        ////            print(String(data: data.0, encoding: .utf8))
        //
        //         })
        //            .filter{ $0.1 == self.imageInfo.count }
        //            .compactMap{ _ in UIImage(data: self.imageInfo) }
        //            .observe(on: MainScheduler.instance)
        //            .bind(to: dataImageView.rx.image)
        //         .subscribe()
        //         .disposed(by: disposeBag)
        
        
        
    }
}

//extension ImageVC: NetworkConnectionDelegate {
//
//    func connectionOpened(connection: NetworkConnection) {
//        print("conn open")
//    }
//
//    func connectionClosed(connection: NetworkConnection) {
//        print("conn closed")
//    }
//
//    func connectionError(connection: NetworkConnection, error: Error) {
//        print("conn error \(error.localizedDescription)")
//    }
//
//    func connectionReceivedData(connection: NetworkConnection, data: Data) {
//        print("received data on conn \(connection.id): \(String(data: data, encoding: .utf8))")
//    }
//}
