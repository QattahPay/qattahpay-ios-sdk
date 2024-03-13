//
//  Api.swift
//  qattahpay-ios-sdk
//
//  Created by khlafawi on 09/03/2024.
//

import Foundation

@available(iOS 13.0, *)
final class Api {
    
    static let shared = Api()
    
    private init() {}
    
    func createNewOrder(payload: QattahRequest, apiKey: String, env: Env, completed: @escaping (Result<QattahResponse, ApiError>) -> Void) {
        var jsonBody: String = ""
        do {
            let jsonData = try JSONEncoder().encode(payload)
            jsonBody = String(data: jsonData, encoding: .utf8)!
        } catch {
            completed(.failure(.invalidData))
            return
        }
        
        let createOrderUrl = self.getNewOrderUrl(env: env)
        
        guard let url = URL(string: createOrderUrl) else {
            completed(.failure(.invalidUrl))
            return
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let _ = error {
                completed(.failure(.unableToComplete))
                return
            }
            
//            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
//                completed(.failure(.invalidResponse))
//                return
//            }
            
            guard let data = data else {
                completed(.failure(.noResponse))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(QattahResponse.self, from: data)
                completed(.success(decodedResponse))
            } catch {
                completed(.failure(.unableToDecode))
            }
        }
        
        task.resume()
    }
    
    func cancelCurrentOrder(qattahOrderId: String, apiKey: String, env: Env, completed: @escaping (Result<QattahResponse, ApiError>) -> Void) {
        
        let cancelOrderUrl = self.getCancelOrderUrl(env: env, orderId: qattahOrderId)
        
        guard let url = URL(string: cancelOrderUrl) else {
            completed(.failure(.invalidUrl))
            return
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let _ = error {
                completed(.failure(.unableToComplete))
                return
            }
            
            guard let data = data else {
                completed(.failure(.noResponse))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(QattahResponse.self, from: data)
                completed(.success(decodedResponse))
            } catch {
                completed(.failure(.unableToDecode))
            }
        }
        
        task.resume()
    }
    
    private func getNewOrderUrl(env: Env) -> String {
        let createOrderUrlProd = "https://api.qattahpay.sa/api/v1/merchant-integration/orders"
        let createOrderUrlStage = "https://staging-api.qattahpay.sa/api/v1/merchant-integration/orders"
        let createOrderUrlTest = "https://testing-api.qattahpay.sa/api/v1/merchant-integration/orders"
        
        switch (env) {
        case .prod:
            return createOrderUrlProd
        case .staging:
            return createOrderUrlStage
        case .testing:
            return createOrderUrlTest
        }
    }
    
    private func getCancelOrderUrl(env: Env, orderId: String) -> String {
        let createOrderUrlProd = "https://api.qattahpay.sa/api/v1/qattah/orders/\(orderId)/cancel"
        let createOrderUrlStage = "https://staging-api.qattahpay.sa/api/v1/qattah/orders/\(orderId)/cancel"
        let createOrderUrlTest = "https://testing-api.qattahpay.sa/api/v1/qattah/orders/\(orderId)/cancel"
        
        switch (env) {
        case .prod:
            return createOrderUrlProd
        case .staging:
            return createOrderUrlStage
        case .testing:
            return createOrderUrlTest
        }
    }
}
