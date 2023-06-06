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
    
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    func createNewQattahOrder(apiToken: String, reference: String, callback_url: String, amount: Double, language: Language, theme: Theme, isSandbox: Bool, onComplete: @escaping (_: QattahResponse) -> Void, onError: @escaping (_: String) -> Void) {
        
        let bodyRequest = "{\n    \"amount\": " + String(format: "%f", amount) + ",\n    \"reference\": \"" + reference + "\",\n    \"callback_url\": \"https://testing-callback.qattahpay.sa\",\n    \"theme\":\"" + theme.description + "\",\n    \"lang\":\"" + language.description + "\"\n}"
        let postData = bodyRequest.data(using: .utf8)

        var sandbox = ""
        if (isSandbox) {
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
}
