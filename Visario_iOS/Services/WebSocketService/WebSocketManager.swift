//
//  WSManager.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 30.08.2021.
//

import Foundation

final class WebSocketManager {
    
    public static let shared = WebSocketManager()
    private init() { }
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    func setupWebSocket(with url: String) {
        guard let webSocketURL = URL(string: url) else { return }
        webSocketTask = URLSession.shared.webSocketTask(with: webSocketURL)
        webSocketTask?.resume()
    }
    
    func connectToWebSocket(callback: @escaping (Result<AmazonMessage, Error>) -> Void) {
        guard let webSocketTask = webSocketTask else { return }
        
        webSocketTask.receive { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .failure(let error):
                print("Error receiving message!, \(error.localizedDescription)")
            case .success(let message):
                switch message {
                case .string(let text):
                    guard let data = self.validJSONString(from: text).data(using: .utf8) else { return }
                    do {
                        let amazonMessageModel = try JSONDecoder().decode(AmazonMessage.self, from: data)
                        callback(.success(amazonMessageModel))
                    } catch {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            let jsonStr = json?["Headers"] as? [String:String]
                            let message = jsonStr?["x-amz-chime-event-type"] ?? "No data"
                            print("WebSocket:", message)
                        } catch {
                            callback(.failure(error))
                        }
                        callback(.failure(error))
                    }
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    debugPrint("Unknown message")
                }
                self.connectToWebSocket(callback: callback)
            }
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    func ping() {
      webSocketTask?.sendPing { (error) in
        if let error = error {
          print("Sending PING failed: \(error)")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
          self.ping()
        }
      }
    }
    
    private func validJSONString(from text: String) -> String {
        let uniqueID = UUID().uuidString
        let text0 = text.replacingOccurrences(of: "\\u0026", with: "&")
        let text1 = text0.replacingOccurrences(of: "\\n", with: uniqueID)
        let text2 = text1.replacingOccurrences(of: "\\", with: "")
        let text3 = text2.replacingOccurrences(of: "\"{", with: "{")
        let text4 = text3.replacingOccurrences(of: "}\"", with: "}")
        let text5 = text4.replacingOccurrences(of: uniqueID, with: "\\n")
        return text5
    }
}
