//
// Created by khlafawi on 11/05/2023.
//

import Foundation
import SwiftUI
import WebKit
import SocketIO

@available(iOS 13.0, *)
public struct QattahWebView: View {
    
    @ObservedObject var qattahResponse: QattahResponse
    var qattahPaymentCallback: PaymentCallback? = nil
    private var socket: SocketIOClient?
    
    public init(qattahResponse: QattahResponse?, qattahPaymentCallback: PaymentCallback) {
        self.qattahResponse = qattahResponse ?? QattahResponse()
        self.qattahPaymentCallback = qattahPaymentCallback
        startSocketListener()
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                CustomWebView(qattahResponse: self.qattahResponse)
            }
        }
    }
    
    mutating func startSocketListener() {
        let manager = SocketManager(socketURL: URL(string: "https://testing-callback.qattahpay.sa")!, config: [.log(true), .compress])
        self.socket = manager.defaultSocket

        handleSocketEvents()
        self.socket?.connect()
    }
    
    func stopSocketListener() {
        self.socket?.disconnect()
    }
    
    // MARK: - Private methods
    private func handleSocketEvents() {
       
        self.socket?.on(clientEvent: .connect) { data, ack in
            print("CONNECTED" + ((data[0] as AnyObject) as! String))
            self.qattahPaymentCallback?.onStarted(paymentId: (qattahResponse.data?.id)!)
            self.socket?.emit("join-room", (qattahResponse.data?.id)!)
        }
        
        self.socket?.on("update-payment") { data, ack in
            print("update-payment" + ((data[0] as AnyObject) as! String))
            
            let arr = data as? [[String: Any]]
            let paymentStatus = arr![0]["paymentStatus"] as? String
            print(paymentStatus!)
            onNewMessage(newMessage: paymentStatus!)
            
        }
        
        self.socket?.on(clientEvent: .disconnect) { data, ack in
            print("DISCONNECTED" + ((data[0] as AnyObject) as! String))
            self.qattahPaymentCallback?.onError(errorMessage: "Qattah Pay socket connection lost, please check internet connection.")
        }
        
        self.socket?.on(clientEvent: .error) { data, ack in
            print("CONECTION_ERROR" + ((data[0] as AnyObject) as! String))
            self.qattahPaymentCallback?.onError(errorMessage: "Qattah Pay socket connection lost, please check internet connection.")
        }
    }
    
    private func onNewMessage(newMessage: String) {
        switch newMessage {
            
        case "PAID":
                self.qattahPaymentCallback?.onSuccess(paymentId: (qattahResponse.data?.id)!)
           
        case "REFUNDED":
                self.qattahPaymentCallback?.onError(errorMessage: "Qattah Pay order is expired")
            
        default:
                return
        }
    }
}

@available(iOS 13.0, *)
public struct CustomWebView: UIViewRepresentable {

    public typealias UIViewType = WKWebView
    let webView: WKWebView

    public init(qattahResponse: QattahResponse?) {

        let requiredUrl = qattahResponse?.links?.redirect_to
        webView = WKWebView(frame: .zero)
        
        if (requiredUrl != nil) {
            webView.load(URLRequest(url: URL(string: requiredUrl!)!))
        } else {
            //TODO: navigate back
        }
    }

    public func makeUIView(context: Context) -> WKWebView {
        webView
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}
