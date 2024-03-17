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
    fileprivate var environment: Env = .prod
    fileprivate var languge: Language = .EN
    fileprivate var currentQattahOrderId: String?
    
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
        self.setEnvironment(paymentRequest: paymentRequest)
        self.languge = paymentRequest.language ?? .EN
        
//        if (self.qattahResponse != nil) {
//            let alert = Alert(title: Text("Close Qattah Pay"), message: Text("Are you sure you want to close Qattah Pay? This might cancel your ongoing payment."), primaryButton: .destructive(Text("Close"), action: {
//                // Dismiss the view after confirmation
//                self.presentationMode.wrappedValue.dismiss()
//            }), secondaryButton: .default(Text("Cancel")))
//            
//            self.present(alert)
//            
//        } else {
            Api.shared.createNewOrder(payload: qattahRequest, apiKey: self.apiKey, env: self.environment, completed: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let qattahResponse):
                        self.qattahResponse = qattahResponse
                        self.currentQattahOrderId = qattahResponse.data?.order.id
                        onSuccess(qattahResponse)
                    case .failure(let error):
                        let errorMessage = error.localizedDescription
                        print(errorMessage)
                        onFail(errorMessage)
                    }
                }
            })
//        }
    }
    
    @available(iOS 13.0, *)
    public func cancelPaymentSession(onSuccess: @escaping (_: QattahResponse) -> Void, onFail: @escaping (_ errorMessage: String) -> Void) {
        
        if (self.currentQattahOrderId == nil) {
            onFail("there is no Qattah Order started to cancel")
            return
        }
        
        Api.shared.cancelCurrentOrder(qattahOrderId: self.currentQattahOrderId!, apiKey: self.apiKey, env: self.environment, completed: { result in
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
    
    func setEnvironment(paymentRequest: PaymentRequest) {
        if (paymentRequest.isSandbox ?? false) {
            self.environment = .staging
            return
        }
        
        if (paymentRequest.isTesting ?? false) {
            self.environment = .testing
            return
        }
        
        self.environment = .prod
    }
}

@available(iOS 14.0, *)
public struct QattahWebView: View {
    @StateObject var viewModel = QattahWebViewModel()
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
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
        NavigationView {
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
//            .valueChanged(value: self.presentationMode, onChange: { val in
//                if val.wrappedValue.isDismissed {
//                    // User tried to dismiss the sheet
//                    self.showAlert = true
//                    self.presentationMode.wrappedValue.dismiss() // Prevent actual dismissal
//                }
//            })
            .onAppear() {
                if let s = QattahPaySDK.shared.qattahResponse {
                    viewModel.response = s
                }
            }
//            .onDisappear() {
//                // No longer needed as dismissal is handled within the sheet
//            }
            .alert(isPresented: $showAlert, content: {
                Alert(title: Text(self.getLocalizedStringForKey("alertTitle")), message: Text(self.getLocalizedStringForKey("alertContent")), primaryButton: .destructive(Text(self.getLocalizedStringForKey("alertPrimaryButton")), action: {
                    QattahPaySDK.shared.cancelPaymentSession(onSuccess: {_ in
                        // Dismiss the view after confirmation
                        self.presentationMode.wrappedValue.dismiss()
                    }, onFail: {errorMessage in
                        self.qattahPaymentCallback?.onError(errorMessage: errorMessage)
                        self.presentationMode.wrappedValue.dismiss()
                    })
                }), secondaryButton: .default(Text(self.getLocalizedStringForKey("alertSecondaryButton"))))
            })
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action : {
            self.showAlert = true
        }) {
            Image(systemName: "arrow.left")
        })
    }
}

@available(iOS 14.0, *)
extension QattahWebView {
    func getLocalizedStringForKey(_ key: String) -> String {
        return localizedMessages[QattahPaySDK.shared.languge.rawValue]?[key] ?? ""
    }
}

fileprivate var localizedMessages: [String: [String: String]] = [
    "ar": [
        "alertTitle": "الغاء الطلب",
        "alertContent": "هل أنت متأكد أنك تريد إغلاق الطلب؟ قد يؤدي هذا إلى إلغاء عملية الدفع",
        "alertPrimaryButton": "الغاء الطلب",
        "alertSecondaryButton": "اغلاق"
    ],
    "en": [
        "alertTitle": "Cancel Qattah Order",
        "alertContent": "Are you sure you want to close Qattah Pay? This might cancel your ongoing payment.",
        "alertPrimaryButton": "Close",
        "alertSecondaryButton": "Cancel",
    ]
]

//@available(iOS 13.0, *)
//class PresentationModeManager: ObservableObject {
//  @Environment(\.presentationMode) var presentationMode
//
//  // This method is called whenever the environment changes,
//  // including changes to presentationMode
//  override func willChangeValue(_ key: String) {
//    super.willChangeValue(key)
//    objectWillChange.send() // Notify when presentationMode changes
//  }
//}
