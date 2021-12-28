//
//  ConnectivityManager.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 09.09.2021.
//

import Alamofire

enum NetworkConnectionStatus: String {
    case online
    case offline
}

protocol NetworkConnectionStatusListener: AnyObject {
    func networkStatusDidChange(status: NetworkConnectionStatus)
}

final class ConnectivityManager: NSObject {
    
    static let shared = ConnectivityManager()
    private let networkReachability = NetworkReachabilityManager()
    
    private(set) var listeners: [NetworkConnectionStatusListener] = []
    
    var isNetworkAvailable: Bool {
        networkReachability?.isReachable ?? false
    }
    
    func configureReachability() {
        networkReachability?.startListening { status in
            switch status {
            case .unknown, .notReachable:
                self.notifyAllListenersWith(status: .offline)   // ❌
            case .reachable(.ethernetOrWiFi), .reachable(.cellular):
                self.notifyAllListenersWith(status: .online)    // ✅
            }
        }
    }
    
    func notifyAllListenersWith(status: NetworkConnectionStatus) {
        listeners.forEach { $0.networkStatusDidChange(status: status) }
    }
    
    func addListener(listener: NetworkConnectionStatusListener) {
        listeners.append(listener)
    }
    
    func removeListener(listener: NetworkConnectionStatusListener) {
        listeners = listeners.filter { $0 !== listener }
    }
    
    func startListening() {
        configureReachability()
    }
    
    func stopListening() {
        networkReachability?.stopListening()
    }
}

