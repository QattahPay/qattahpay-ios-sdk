//
// Created by khlafawi on 11/05/2023.
//

import Foundation
import SwiftUI
import WebKit
import SocketIO

@available(iOS 13.0, *)
public struct QattahWebView: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @ObservedObject private var qattahResponse: QattahResponse
    @State private var qattahPaymentCallback: PaymentCallback? = nil
    @State private var customWebView: CustomWebView? = nil
    @State private var presentationmode: Binding<PresentationMode>? = nil
    
    public init(qattahResponse: QattahResponse?, qattahPaymentCallback: PaymentCallback) {
        self.qattahResponse = qattahResponse ?? QattahResponse()
        self.qattahPaymentCallback = qattahPaymentCallback
        
        self.customWebView = CustomWebView(qattahResponse: self.qattahResponse, qattahPaymentCallback: self.qattahPaymentCallback, qattahWebView: self)
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                self.customWebView.onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    
                    if (self.qattahResponse.data?.order.id == nil || self.qattahPaymentCallback == nil) {
                        return
                    }
                    
                    self.customWebView?.refreshSession(apiKey: self.qattahResponse.apiKey, orderId: self.qattahResponse.data?.order.id ?? "", isSandbox: self.qattahResponse.isSandbox, qattahPaymentCallback: self.qattahPaymentCallback!)

                }
            }
        }.navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action : {
                self.onBackPressed()
            }) {
                Image(systemName: "arrow.left")
            })
    }
    
    func onBackPressed() {
        self.qattahPaymentCallback?.onCancel()
        self.customWebView?.disconnect()
        self.mode.wrappedValue.dismiss()
    }
}

@available(iOS 13.0, *)
public struct CustomWebView: UIViewRepresentable {

    let manager = SocketManager(socketURL: URL(string: "https://testing-callback.qattahpay.sa")!, config: [.log(false), .compress])
    
    @State private var remainingMin = 15
    @State private var remainingSec = 0
    
    public typealias UIViewType = WKWebView
    let webView: WKWebView
    
    var socket: SocketIOClient? = nil

    public init(qattahResponse: QattahResponse?, qattahPaymentCallback: PaymentCallback?, qattahWebView: QattahWebView) {

        let requiredUrl = qattahResponse?.links?.redirect_to
        webView = WKWebView(frame: .zero)
        
        if (requiredUrl != nil) {
            webView.load(URLRequest(url: URL(string: requiredUrl!)!))
            startSocketListener(qattahResponse: qattahResponse!, qattahPaymentCallback: qattahPaymentCallback)
        } else {
            qattahWebView.onBackPressed()
            self.disconnect()
        }
    }
    
    private mutating func startSocketListener(qattahResponse: QattahResponse, qattahPaymentCallback: PaymentCallback?) {
        
        self.socket = manager.defaultSocket
        let selfItem = self
        
        self.socket?.on(clientEvent: .connect) { data, ack in
            selfItem.connectionHandling(qattahResponse: qattahResponse, qattahPaymentCallback: qattahPaymentCallback, data: data)
        }
        
        self.socket?.on("update-payment") { data, ack in
            selfItem.updatePayment(qattahResponse: qattahResponse, qattahPaymentCallback: qattahPaymentCallback, data: data)
        }
        
        self.socket?.on(clientEvent: .disconnect) { data, ack in
            print("DISCONNECTED")
            qattahPaymentCallback?.onError(errorMessage: "Qattah Pay socket disconnected.")
        }
        
        self.socket?.on(clientEvent: .error) { data, ack in
            print("CONECTION_ERROR")
            qattahPaymentCallback?.onError(errorMessage: "Qattah Pay socket connection lost, please check internet connection.")
        }
        
        self.socket?.connect()
        
    }
    
    private func connectionHandling(qattahResponse: QattahResponse, qattahPaymentCallback: PaymentCallback?, data: [Any]) {
        qattahPaymentCallback?.onStarted(paymentId: (qattahResponse.data?.order.id)!)
        print("CONNECTED" + ((data[0] as AnyObject) as! String))
        socket?.emit("join-room", (qattahResponse.data?.order.id)!)
    }
    
    private func updatePayment(qattahResponse: QattahResponse, qattahPaymentCallback: PaymentCallback?, data: [Any]) {
        let arr = data as? [[String: Any]]
        let paymentStatus = arr![0]["paymentStatus"] as? String
        print(paymentStatus!)
        self.onNewMessage(newMessage: paymentStatus!, qattahResponse: qattahResponse, qattahPaymentCallback: qattahPaymentCallback)
    }
    
    func disconnect() {
        self.socket?.disconnect()
    }
    
    func refreshSession(apiKey: String?, orderId: String, isSandbox: Bool?, qattahPaymentCallback: PaymentCallback) {
        
        // call the server to check the order status
        ApiService().checkOrderStatus(apiKey: apiKey, orderId: orderId, isSandbox: isSandbox, onComplete: { newOrderResponse in
            
            print("checkOrderStatus: success")
            
            // on success - handle the flow regarding the payment activity
            onNewMessage(newMessage: newOrderResponse.data?.order.paymentStatus, qattahResponse: newOrderResponse, qattahPaymentCallback: qattahPaymentCallback)
            
        }, onError: {errorMessage in
            
            print("checkOrderStatus: error: " + errorMessage)
            
            // on failed - return that the order is expired
            qattahPaymentCallback.onError(errorMessage: errorMessage + ": Qattah Pay order is expired")
            
        })
    }
    
    private func onNewMessage(newMessage: String?, qattahResponse: QattahResponse, qattahPaymentCallback: PaymentCallback?) {
        switch newMessage {
            
        case "PAID":
            qattahPaymentCallback?.onSuccess(paymentId: (qattahResponse.data?.order.id)!)
            
        case "AUTHORIZED":
            qattahPaymentCallback?.onSuccess(paymentId: (qattahResponse.data?.order.id)!)
           
        case "REFUNDED":
                qattahPaymentCallback?.onError(errorMessage: "Qattah Pay order is expired")
        default:
                return
        }
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        webView
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}
