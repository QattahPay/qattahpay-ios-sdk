//
//  QattahPaySDK.swift
//  qattahpay-ios-sdk
//
//  Created by khlafawi on 14/04/2023.
//

import Foundation
import SwiftUI
import WebKit

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public final class QattahPaySDK: ObservableObject {
    
    fileprivate var apiKey: String = ""
    fileprivate var qattahResponse: QattahResponse?
    
    public static var shared = QattahPaySDK()
    
    public init() {}
    
    public init(apiKey: String) {
        QattahPaySDK.shared = self
        self.apiKey = apiKey
    }
    
    @available(iOS 13.0, *)
    public func startPaymentSession(paymentRequest: PaymentRequest, onSuccess: @escaping (_: QattahResponse) -> Void, onFail: @escaping (_ errorMessage: String) -> Void) {
        
        if (apiKey == "" || apiKey == "<YOUR_API_KEY>") {
            onFail("API KEY is required")
            return
        }
        
        if (paymentRequest.amount == nil) {
            onFail("Amount is required")
            return
        }
        
        if (paymentRequest.amount == 0) {
            onFail("Amount is zero")
            return
        }
        
        let qattahRequest = paymentRequest.mapToQattahRequest()
        
        Api.shared.createNewOrder(payload: qattahRequest, apiKey: self.apiKey, env: self.getEnvironment(paymentRequest: paymentRequest), completed: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let qattahResponse):
                    self.qattahResponse = qattahResponse
                    onSuccess(qattahResponse)
                case .failure(let error):
                    let errorMessage = error.localizedDescription
                    print(errorMessage)
                    onFail(errorMessage)
                }
            }
        })
    }
    
    func getEnvironment(paymentRequest: PaymentRequest) -> Env {
        if (paymentRequest.isSandbox ?? false) {
            return .staging
        }
        
        if (paymentRequest.isTesting ?? false) {
            return .testing
        }
        
        return .prod
    }
}

@available(iOS 14.0, *)
public struct QattahWebView: View {
    @StateObject var viewModel = QattahWebViewModel()
    
    @Environment(\.presentationMode) private var presentationMode
    
    private var qattahPaymentCallback: PaymentCallback? = nil
    private var qattahResponse: QattahResponse? = nil
    @State private var showAlert = false
    
    public init(qattahResponse: QattahResponse?, qattahPaymentCallback: PaymentCallback) {
        self.qattahResponse = qattahResponse
        self.qattahPaymentCallback = qattahPaymentCallback
    }
    
    private func onResult(result: QattahResult) {
        switch result {
        case .authorized:
            qattahPaymentCallback?.onSuccess(paymentId: (viewModel.response?.data?.order.id)!)
            
        case .rejected:
            qattahPaymentCallback?.onError(errorMessage: "Qattah Pay order is rejected")
        
        case .close:
            qattahPaymentCallback?.onError(errorMessage: "Qattah Pay order is closed")
            
        case .expired:
                qattahPaymentCallback?.onError(errorMessage: "Qattah Pay order is expired")
        }
    }
    
    public var body: some View {
        HStack {
            if (viewModel.response != nil) {
                CustomWebView(
                    viewModel: self.viewModel
                )
            } else {
                ActivityIndicator(style: .medium)
            }
        }
        .valueChanged(value: viewModel.result, onChange: { val in
            guard let v = val else {
                return
            }
            self.onResult(result: v)
        })
        .onAppear() {
            if let s = QattahPaySDK.shared.qattahResponse {
                viewModel.response = s
            }
        }
        .onDisappear() {
              // No longer needed as dismissal is handled within the sheet
        }
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Close Qattah Pay"), message: Text("Are you sure you want to close Qattah Pay? This might cancel your ongoing payment."), primaryButton: .destructive(Text("Close"), action: {
                // Dismiss the view after confirmation
                presentationMode.wrappedValue.dismiss()
            }), secondaryButton: .default(Text("Cancel")))
        })
        .background(
              GeometryReader { _ in
                EmptyView()
                  .onDisappear {
                    // User tried to dismiss by tapping outside the sheet area
                    showAlert = true
                  }
              }
            )
    }
}
