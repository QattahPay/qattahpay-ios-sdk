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
        
        self.customWebView = CustomWebView(qattahResponse: self.qattahResponse, qattahPaymentCallback: self.qattahPaymentCallback!, qattahWebView: self)
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                self.customWebView
            }
        }.navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action : {
               goBack()
            }) {
                Image(systemName: "arrow.left")
            })
    }
    
    func goBack() {
        self.mode.wrappedValue.dismiss()
        self.qattahPaymentCallback?.onCancel()
        self.customWebView?.disconnect()
    }
}

@available(iOS 13.0, *)
public struct CustomWebView: UIViewRepresentable {

    let manager = SocketManager(socketURL: URL(string: "https://testing-callback.qattahpay.sa")!, config: [.log(false), .compress])
    
    @State private var remainingMin = 1
    @State private var remainingSec = 0
    
    public typealias UIViewType = WKWebView
    let webView: WKWebView
    
    var socket: SocketIOClient? = nil

    public init(qattahResponse: QattahResponse?, qattahPaymentCallback: PaymentCallback, qattahWebView: QattahWebView) {

        let requiredUrl = qattahResponse?.links?.redirect_to
        webView = WKWebView(frame: .zero)
        
        if (requiredUrl != nil) {
            webView.load(URLRequest(url: URL(string: requiredUrl!)!))
            startSocketListener(qattahResponse: qattahResponse!, qattahPaymentCallback: qattahPaymentCallback)
            checkExpiration(qattahResponse: qattahResponse!, qattahPaymentCallback: qattahPaymentCallback, qattahWebView: qattahWebView)
        } else {
            qattahWebView.goBack()
        }
    }

    private func checkExpiration(qattahResponse: QattahResponse!, qattahPaymentCallback: PaymentCallback, qattahWebView: QattahWebView) {
        
        // check the order status
        if (qattahResponse?.data?.order.activityStatus == "STARTED" // if the order is started
            && qattahResponse?.data?.order.remainingTime?.min == 0 // and no remaining mintues
            && qattahResponse?.data?.order.remainingTime?.sec == 0) { // and no remaining seconds
            
            // return that the order is expired
            qattahPaymentCallback.onError(errorMessage: "Qattah Pay order is expired")
            qattahWebView.goBack()
            
        } else {
            
            // start the order life-timer
            startExpirationTimer(qattahResponse: qattahResponse, qattahPaymentCallback: qattahPaymentCallback, qattahWebView: qattahWebView)
            
        }
    }
    
    private func startExpirationTimer(qattahResponse: QattahResponse, qattahPaymentCallback: PaymentCallback, qattahWebView: QattahWebView) {
        _ = Timer.scheduledTimer(withTimeInterval: TimeInterval(((remainingMin * 60) + remainingSec)), repeats: false) {[self] _ in
            
            // call the server to check the order status
            ApiService().checkOrderStatus(orderId: qattahResponse.data?.order.id, onComplete: { minitues, seconds in
                
                // on success - update remaining time
                self.remainingMin = minitues
                self.remainingSec = seconds
                
                // check if order is expired
                self.checkExpiration(qattahResponse: qattahResponse, qattahPaymentCallback: qattahPaymentCallback, qattahWebView: qattahWebView)
                
            }, onError: {errorMessage in
                
                // on failed - return that the order is expired
                qattahPaymentCallback.onError(errorMessage: errorMessage + ": Qattah Pay order is expired")
                
            })
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
            
        case "AUTHORIZED":
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
