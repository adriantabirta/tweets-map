//
//  NetworkServiceProvider.swift
//  tweets-map
//
//  Created by Tabirta Adrian on 08.07.2021.
//

import Foundation
import RxCocoa
import RxSwift

class NetworkServiceProvider<N: NetworkService>: NSObject, URLSessionDataDelegate {
    
    private var urlSession: URLSession?
    
    private var decoder: JSONDecoder?
    
    fileprivate(set) var currentTask: URLSessionDataTask?
    
    private lazy var onStreamNewData = PublishSubject<Data>()
    
    init(urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default),
         decoder: JSONDecoder = JSONDecoder(), formatter: DateFormatter = DateFormatter()) {
        super.init()
        self.urlSession = URLSession(configuration: urlSession.configuration, delegate: self, delegateQueue: OperationQueue())
        
        formatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ss.SSS'Z'"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        self.decoder = decoder
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(dataTask.state != .canceling ? .allow : .cancel)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if dataTask.state != .canceling {
            onStreamNewData.onNext(data)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {        
        guard let unwrapped = error else { return }
        onStreamNewData.onError(unwrapped)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let host = task.originalRequest?.url?.host
        if let serverTrust = challenge.protectionSpace.serverTrust, challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust && challenge.protectionSpace.host == host {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }
    }
}

extension NetworkServiceProvider {
    
    func request<D: Decodable>(endpoint: N) -> Observable<Result<D, Error>> {
        return Observable.create { [unowned self] (observer) -> Disposable in
            
            #if DEBUG
            print("NetworkServiceProvider: \n \(endpoint.description)")
            #endif
            
            self.urlSession!.dataTask(with: endpoint.urlRequest) {(data, response: URLResponse?, error) in
                if let error = error {
                    observer.onNext(.failure(error))
                } else if let data = data, let response = response, let httpResponse = response as? HTTPURLResponse {
                    
                    #if DEBUG
                    print("NetworkServiceProvider: Response \n \(httpResponse.statusCode) \(httpResponse.url?.description ?? "")")
                    print("NetworkServiceProvider: Response Body \n \(String(data: data, encoding: .utf8) ?? "")")
                    
                    #endif
                    
                    
                    switch httpResponse.statusCode {
                    case 200..<300:
                        do {
                            let object = try self.decoder!.decode(D.self, from: data)
                            observer.onNext(.success(object))
                        } catch {
                            observer.onNext(.failure(AppError.unableToDecode))
                        }
                        
                    default:
                        observer.onNext(.failure(ApiError.unknown))
                    }
                } else {
                    observer.onNext(.failure(ApiError.unknown))
                }
            }.resume()
            return Disposables.create()
        }
    }
    
    func requestStream<D: Decodable>(endpoint: N) -> Observable<D> {
        currentTask = urlSession!.dataTask(with: endpoint.urlRequest)
        currentTask?.resume()
        return onStreamNewData
            .asObserver()
            .filter{ $0.count > 0 }
            .compactMap{ String(data: $0, encoding: .utf8)  }
            .do(onNext: { data in
                print("before decode: \(data)\n\n")
            })
            .compactMap{ String(describing: "[" + $0.replacingOccurrences(of: "\r\n", with: ",") + "]").data(using: .utf8) }
            .compactMap { try? self.decoder!.decode(D.self, from: $0) }
    }
}
