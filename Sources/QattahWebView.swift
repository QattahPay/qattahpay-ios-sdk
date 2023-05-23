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
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    let manager = SocketManager(socketURL: URL(string: "https://testing-callback.qattahpay.sa")!, config: [.log(false), .compress])
    
    @State var socket: SocketIOClient? = nil

    public init(qattahResponse: QattahResponse?, qattahPaymentCallback: PaymentCallback) {
        self.qattahResponse = qattahResponse ?? QattahResponse()
        self.qattahPaymentCallback = qattahPaymentCallback
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                CustomWebView(qattahResponse: self.qattahResponse, qattahPaymentCallback: self.qattahPaymentCallback!).onAppear {
                    self.startSocketListener(qattahResponse: self.qattahResponse, qattahPaymentCallback: self.qattahPaymentCallback)
                }
            }
        }.navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action : {
                self.mode.wrappedValue.dismiss()
                self.qattahPaymentCallback?.onCancel()
                self.socket?.disconnect()
            }) {
                Image(systemName: "arrow.left")
            })
    }
    
    private func startSocketListener(qattahResponse: QattahResponse?, qattahPaymentCallback: PaymentCallback?) {
        
        self.socket = manager.defaultSocket
        
        socket?.on(clientEvent: .connect) { data, ack in
            qattahPaymentCallback?.onStarted(paymentId: (qattahResponse?.data?.order.id)!)
            print("CONNECTED" + ((data[0] as AnyObject) as! String))
            socket?.emit("join-room", (qattahResponse?.data?.order.id)!)
        }
        
        socket?.on("update-payment") { data, ack in
            print("update-payment")
            
            let arr = data as? [[String: Any]]
            let paymentStatus = arr![0]["paymentStatus"] as? String
            print(paymentStatus!)
            self.onNewMessage(newMessage: paymentStatus!, qattahResponse: qattahResponse, qattahPaymentCallback: qattahPaymentCallback)
        }
        
        socket?.on(clientEvent: .disconnect) { data, ack in
            print("DISCONNECTED" + ((data[0] as AnyObject) as! String))
            qattahPaymentCallback?.onError(errorMessage: "Qattah Pay socket connection lost, please check internet connection.")
        }
        
        socket?.on(clientEvent: .error) { data, ack in
            print("CONECTION_ERROR" + ((data[0] as AnyObject) as! String))
            qattahPaymentCallback?.onError(errorMessage: "Qattah Pay socket connection lost, please check internet connection.")
        }
        
        socket?.connect()
    }
    
    private func onNewMessage(newMessage: String, qattahResponse: QattahResponse?, qattahPaymentCallback: PaymentCallback?) {
        switch newMessage {
            
        case "PAID":
            qattahPaymentCallback?.onSuccess(paymentId: (qattahResponse?.data?.order.id)!)
           
        case "REFUNDED":
                qattahPaymentCallback?.onError(errorMessage: "Qattah Pay order is expired")
        default:
                return
        }
    }
}

@available(iOS 13.0, *)
public struct CustomWebView: UIViewRepresentable {
    
    public typealias UIViewType = WKWebView
    let webView: WKWebView
    
    public init(qattahResponse: QattahResponse?, qattahPaymentCallback: PaymentCallback) {

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
