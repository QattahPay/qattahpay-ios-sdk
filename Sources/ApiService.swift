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
    func createNewQattahOrder(apiToken: String, reference: String, callback_url: String, paymentRequest: PaymentRequest, isSandbox: Bool, isTesting: Bool, onComplete: @escaping (_: QattahResponse) -> Void, onError: @escaping (_: String) -> Void) {
        
        let postData = createJSONString(amount: String(format: "%f", paymentRequest.amount ?? 0), reference: reference, callbackURL: callback_url, theme: paymentRequest.theme?.description, lang: paymentRequest.language?.description, currency: paymentRequest.currency?.description, description: paymentRequest.description, emailAddress: paymentRequest.emailAddress, mobileNumber: paymentRequest.mobileNumber).data(using: .utf8)

        var sandbox = ""
        if (isTesting) {
            sandbox = "testing-"
        } else if (isSandbox) {
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
    
    func createJSONString(amount: String?, reference: String?, callbackURL: String?, theme: String?, lang: String?, currency: String?, description: String?, emailAddress: String?, mobileNumber: String?) -> String {
        let version = "1.6.0"
        let jsonString = """
        {
            "amount": \(amount ?? ""),
            "reference": "\(reference ?? "")",
            "callback_url": "\(callbackURL ?? "")",
            "theme": "\(theme ?? "")",
            "lang": "\(lang ?? "")",
            "currency": "\(currency ?? "")",
            "description": "\(description ?? "")",
            "emailAddress": "\(emailAddress ?? "")",
            "mobileNumber": "\(mobileNumber ?? "")",
            "platform": "iOS",
            "version": "\(version)"
        }
        """
        return jsonString
    }
    
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    func checkOrderStatus(apiKey: String?, orderId: String, isSandbox: Bool?, onComplete: @escaping (_: QattahResponse) -> Void, onError: @escaping (_: String) -> Void) {
        
        if (apiKey == nil) {
            print("API KEY is nil")
            return
        }
        
        var sandbox = ""
        if (isSandbox == true) {
            sandbox = "testing-"
        }
        
        var request = URLRequest(url: URL(string: "https://" + sandbox + "api.qattahpay.sa/api/v1/merchant-integration/orders/" + orderId)!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer " + (apiKey ?? ""), forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {
                        if error != nil || (response as! HTTPURLResponse).statusCode != 200 {
                            onError("Error occured:" + (error?.localizedDescription ?? ""))
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
