//
//  NetworkConnection.swift
//  tweets-map
//
//  Created by Tabirta Adrian on 30.07.2021.
//


import Foundation
import Network

protocol NetworkConnectionDelegate: AnyObject
{
    func connectionOpened(connection: NetworkConnection)
    func connectionClosed(connection: NetworkConnection)
    func connectionError(connection: NetworkConnection, error: Error)
    func connectionReceivedData(connection: NetworkConnection, data: Data)
}

class NetworkConnection
{
    private static var nextID: Int = 0
    
    weak var delegate: NetworkConnectionDelegate?
    private let nwConnection: NWConnection
    let id: Int
    private var queue: DispatchQueue?
    
    init(nwConnection: NWConnection)
    {
        self.nwConnection = nwConnection
        self.id = NetworkConnection.nextID
        NetworkConnection.nextID += 1
    }
    
    func start(queue: DispatchQueue)
    {
        self.queue = queue
        self.nwConnection.stateUpdateHandler = self.onStateDidChange(to:)
        self.doReceive()
        self.nwConnection.start(queue: queue)
    }

    func send(data: Data)
    {
        let sizePrefix = withUnsafeBytes(of: UInt16(data.count).bigEndian) { Data($0) }
                
        print("Send \(data.count) bytes")
        
        self.nwConnection.batch {
            self.nwConnection.send(content: sizePrefix, completion: .contentProcessed( { error in
                if let error = error {
                    self.delegate?.connectionError(connection: self, error: error)
                    return
                }
            }))
            
            self.nwConnection.send(content: data, completion: .contentProcessed( { error in
                if let error = error {
                    self.delegate?.connectionError(connection: self, error: error)
                    return
                }
            }))
        }
    }

    private func onStateDidChange(to state: NWConnection.State)
    {
        switch state {
            case .setup:
                break
            case .waiting(let error):
                self.delegate?.connectionError(connection: self, error: error)
            case .preparing:
                break
            case .ready:
                self.delegate?.connectionOpened(connection: self)
            case .failed(let error):
                self.delegate?.connectionError(connection: self, error: error)
            case .cancelled:
                break
            default:
                break
        }
    }

    func close()
    {
        self.nwConnection.stateUpdateHandler = nil
        self.nwConnection.cancel()
        delegate?.connectionClosed(connection: self)
    }

    private func doReceive()
    {
        
        self.nwConnection.receive(minimumIncompleteLength: MemoryLayout<UInt16>.size, maximumLength: MemoryLayout<UInt16>.size) { (sizePrefixData, _, isComplete, error) in
            var sizePrefix: UInt16 = 0
            
            // Decode the size prefix
            if let data = sizePrefixData, !data.isEmpty
            {
                sizePrefix = data.withUnsafeBytes
                {
                    $0.bindMemory(to: UInt16.self)[0].bigEndian
                }
            }
            
            if isComplete
            {
                self.close()
            }
            else if let error = error
            {
                self.delegate?.connectionError(connection: self, error: error)
            }
            else
            {
                // If there is nothing to read
                if sizePrefix == 0
                {
                    print("Received size prefix of 0")
                    self.doReceive()
                    return
                }
                
                print("Read \(sizePrefix) bytes")
                
                // At this point we received a valid message and a valid size prefix
                self.nwConnection.receive(minimumIncompleteLength: Int(sizePrefix), maximumLength: Int(sizePrefix)) { (data, _, isComplete, error) in
                    if let data = data, !data.isEmpty
                    {
                        self.delegate?.connectionReceivedData(connection: self, data: data)
                    }
                    if isComplete
                    {
                        self.close()
                    }
                    else if let error = error
                    {
                        self.delegate?.connectionError(connection: self, error: error)
                    }
                    else
                    {
                        self.doReceive()
                    }
                }
            }
        }
    }
}
