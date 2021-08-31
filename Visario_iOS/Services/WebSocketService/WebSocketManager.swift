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
    
    func connectToWebSocket(with url: String) {
        guard let webSocketURL = URL(string: url) else { return }
        webSocketTask = URLSession.shared.webSocketTask(with: webSocketURL)
        webSocketTask?.resume()
    }
    
    func receiveData(callback: @escaping (Result<AmazonMessageModel, Error>) -> Void) {
        guard let webSocketTask = webSocketTask else { return }
        
        webSocketTask.receive { response in
            switch response {
            case .failure(let error):
                print("Error receiving message!, \(error.localizedDescription)")
            case .success(let message):
                switch message {
                case .string(let text):
                    guard let data = self.validJSONString(from: text).data(using: .utf8) else { return }
                    do {
                        let amazonMessageModel = try JSONDecoder().decode(AmazonMessageModel.self, from: data)
                        callback(.success(amazonMessageModel))
                    } catch {
                        callback(.failure(error))
                    }
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    debugPrint("Unknown message")
                }
            }
        }
    }
    
    private func validJSONString(from text: String) -> String {
        let withoutBackSlashes = text.replacingOccurrences(of: "\\", with: "")
        let withoutLeadingQuoetes = withoutBackSlashes.replacingOccurrences(of: "\"{", with: "{")
        let validJSONString = withoutLeadingQuoetes.replacingOccurrences(of: "}\"", with: "}")
        return validJSONString
    }
    
    private func decode<T: Decodable>(data: Data) -> T? {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }
}
