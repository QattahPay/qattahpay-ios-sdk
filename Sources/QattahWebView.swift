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
    @ObservedObject var qattahResponse: QattahResponse
    var qattahPaymentCallback: PaymentCallback? = nil
    var customWebView: CustomWebView? = nil
    
    public init(qattahResponse: QattahResponse?, qattahPaymentCallback: PaymentCallback) {
        self.qattahResponse = qattahResponse ?? QattahResponse()
        self.qattahPaymentCallback = qattahPaymentCallback
        
        self.customWebView = CustomWebView(qattahResponse: self.qattahResponse, qattahPaymentCallback: self.qattahPaymentCallback!)
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                self.customWebView
            }
        }.navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action : {
                self.mode.wrappedValue.dismiss()
                self.qattahPaymentCallback?.onCancel()
                self.customWebView?.disconnect()
            }) {
                Image(systemName: "arrow.left")
            })
    }
    
}

@available(iOS 13.0, *)
public struct CustomWebView: UIViewRepresentable {

    let manager = SocketManager(socketURL: URL(string: "https://testing-callback.qattahpay.sa")!, config: [.log(false), .compress])
    
    public typealias UIViewType = WKWebView
    let webView: WKWebView
    
    var socket: SocketIOClient? = nil

    public init(qattahResponse: QattahResponse?, qattahPaymentCallback: PaymentCallback) {

        let requiredUrl = qattahResponse?.links?.redirect_to
        webView = WKWebView(frame: .zero)
        
        if (requiredUrl != nil) {
            webView.load(URLRequest(url: URL(string: requiredUrl!)!))
            startSocketListener(qattahResponse: qattahResponse!, qattahPaymentCallback: qattahPaymentCallback)
        } else {
            //TODO: navigate back
        }
    }

    private mutating func startSocketListener(qattahResponse: QattahResponse, qattahPaymentCallback: PaymentCallback) {
        
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
            qattahPaymentCallback.onError(errorMessage: "Qattah Pay socket connection lost, please check internet connection.")
        }
        
        self.socket?.on(clientEvent: .error) { data, ack in
            print("CONECTION_ERROR")
            qattahPaymentCallback.onError(errorMessage: "Qattah Pay socket connection lost, please check internet connection.")
        }
        
        self.socket?.connect()
        
    }
    
    private func connectionHandling(qattahResponse: QattahResponse, qattahPaymentCallback: PaymentCallback, data: [Any]) {
        qattahPaymentCallback.onStarted(paymentId: (qattahResponse.data?.order.id)!)
        print("CONNECTED" + ((data[0] as AnyObject) as! String))
        socket?.emit("join-room", (qattahResponse.data?.order.id)!)
    }
    
    private func updatePayment(qattahResponse: QattahResponse, qattahPaymentCallback: PaymentCallback, data: [Any]) {
        print("update-payment")
        
        let arr = data as? [[String: Any]]
        let paymentStatus = arr![0]["paymentStatus"] as? String
        print(paymentStatus!)
        self.onNewMessage(newMessage: paymentStatus!, qattahResponse: qattahResponse, qattahPaymentCallback: qattahPaymentCallback)
    }
    
    func disconnect() {
        self.socket?.disconnect()
    }
    
    private func onNewMessage(newMessage: String, qattahResponse: QattahResponse, qattahPaymentCallback: PaymentCallback) {
        switch newMessage {
            
        case "PAID":
            qattahPaymentCallback.onSuccess(paymentId: (qattahResponse.data?.order.id)!)
           
        case "REFUNDED":
                qattahPaymentCallback.onError(errorMessage: "Qattah Pay order is expired")
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
