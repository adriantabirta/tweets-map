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
    
    private lazy var onStreamNewData1 = PublishSubject<(Data, Int)>()
    
    var outputStream: OutputStream? = nil

    
    init(urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default),
         decoder: JSONDecoder = JSONDecoder(), formatter: DateFormatter = DateFormatter()) {
        super.init()
        self.urlSession = URLSession(configuration: urlSession.configuration, delegate: self, delegateQueue: OperationQueue())
        
        formatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ss.SSS'Z'"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        self.decoder = decoder
    }
    
    private func closeStream() {
        if let stream = self.outputStream {
            stream.close()
            self.outputStream = nil
        }
    }
    
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print(response.debugDescription)
        completionHandler(dataTask.state != .canceling ? .allow : .cancel)
    }
    
//    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
//        self.closeStream()
//
//        var inStream: InputStream? = nil
//        var outStream: OutputStream? = nil
//        Stream.getBoundStreams(withBufferSize: 4096, inputStream: &inStream, outputStream: &outStream)
//        self.outputStream = outStream
//
//        completionHandler(inStream)
//    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard dataTask.state != .canceling else { return }
        onStreamNewData1.onNext((data, 100))
//        if let httpResponse = dataTask.response as? HTTPURLResponse {
//            if let length = Int(httpResponse.allHeaderFields["Content-Length"] as! String) {
//                onStreamNewData1.onNext((data, length))
//            }
//        }
        
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
    
    func requestStreamImage(endpoint: N) -> Observable<(Data, Int)> {
        currentTask = urlSession!.dataTask(with: endpoint.urlRequest)
        currentTask?.resume()
        return onStreamNewData1
            .asObserver()
            .filter{ $0.0.count > 0 }
            .do(onNext: { result in
                print("received bytes: \(result.0.count)")
                
            })
    }
}
