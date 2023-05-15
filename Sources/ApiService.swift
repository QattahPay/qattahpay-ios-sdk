//
//  ApiService.swift
//  qattahpay-ios-sdk
//
//  Created by khlafawi on 14/04/2023.
//

import Combine
import Foundation

@available(macOS 10.15, *)
@available(iOS 14, *)
public class ApiService: ObservableObject {
    
    @available(macOS 10.15, *)
    @available(iOS 14, *)
    func createNewQattahOrder(apiToken: String, reference: String, callback_url: String, amount: Double, onComplete: @escaping (_: QattahResponse) -> Void, onError: @escaping (_: String) -> Void) {
        
        let postData = "{\n    \"amount\": 120.0,\n    \"callback_url\": \"https://testing-callback.qattahpay.sa\"\n}".data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://staging-api.qattahpay.sa/api/v1/merchant-integration/orders")!, timeoutInterval: Double.infinity)
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
}
