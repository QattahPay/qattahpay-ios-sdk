//
//  ApiService.swift
//  qattahpay-ios-sdk
//
//  Created by khlafawi on 14/04/2023.
//

import Combine
import Foundation

@available(macOS 10.15, *)
@available(iOS 13.0, *)
public class ApiService: ObservableObject {
    
    private var apiKey = ""
    private var isSandbox = false
    
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    func createNewQattahOrder(apiToken: String, reference: String, callback_url: String, amount: Double, language: Language, theme: Theme, isSandbox: Bool, onComplete: @escaping (_: QattahResponse) -> Void, onError: @escaping (_: String) -> Void) {
        
        self.apiKey = apiToken
        let version = "1.5.6"
        
        let bodyRequest = "{ \"amount\": " + String(format: "%f", amount) + ", \"reference\": \"" + reference + "\", \"callback_url\": \"https://testing-callback.qattahpay.sa\", \"theme\": \"" + theme.description + "\", \"lang\": \"" + language.description + "\", \"platform\": \"iOS\", \"version\": \"" + version + "\"}"
        
        let postData = bodyRequest.data(using: .utf8)

        var sandbox = ""
        if (isSandbox) {
            self.isSandbox = true
            sandbox = "staging-"
        }
        
        var request = URLRequest(url: URL(string: "https://" + sandbox + "api.qattahpay.sa/api/v1/merchant-integration/orders")!,
        timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer " + apiToken, forHTTPHeaderField: "Authorization")

        request.httpMethod = "POST"
        request.httpBody = postData

        URLSession.shared.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {
                        if error != nil || (response as! HTTPURLResponse).statusCode != 200 {
                            onError("Error occured")
                        } else if let data = data {
                            do {
                                let newOrderResponse = try JSONDecoder().decode(QattahResponse.self, from: data)
                                onComplete(newOrderResponse)
                            } catch {
                                print("Unable to Decode Response \(error)")
                                onError("Error occured")
                            }
                        }
                    }
                }
                .resume()
    }
    
    
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    func checkOrderStatus(orderId: String?, onComplete: @escaping (_: Int, _: Int) -> Void, onError: @escaping (_: String) -> Void) {
        
        if (orderId == nil) {
            onError("no order id found")
            return
        }
        
        var sandbox = ""
        if (self.isSandbox) {
            sandbox = "staging-"
        }
        
        var request = URLRequest(url: URL(string: "https://" + sandbox + "api.qattahpay.sa/api/v1/merchant-integration/orders/" + orderId!)!,
        timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer " + self.apiKey, forHTTPHeaderField: "Authorization")

        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {
                        if error != nil || (response as! HTTPURLResponse).statusCode != 200 {
                            onError("Error occured")
                        } else if let data = data {
                            do {
                                let newOrderResponse = try JSONDecoder().decode(QattahResponse.self, from: data)
                               
                                let minitues = newOrderResponse.data?.order.remainingTime?.min
                                let seconds = newOrderResponse.data?.order.remainingTime?.sec
                                
                                onComplete(minitues ?? 0, seconds ?? 0)
                                
                            } catch {
                                print("Unable to Decode Response \(error)")
                                onError("Error occured")
                            }
                        }
                    }
                }
                .resume()
    }
}
