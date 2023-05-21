import XCTest
@testable import qattahpay_ios_sdk

final class qattahpay_ios_sdkTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        //XCTAssertEqual(qattahpay_ios_sdk().text, "Hello, World!")
        
        let qattahPaySdk = QattahPaySDK(apiKey: "")
        let paymentRequest = PaymentRequestBuilder()
            .setAmount(amount)
            .setCurrency(currency)
            .setOrderId(orderId)
            .setDescription(description)
            .setCustomerEmail(userEmail)
            .setCustomerMobileNumber(userPhoneNumber)
            .isSandbox(isSandbox)
            .build()
        
        qattahPay.startPaymentSession(paymentRequest: paymentRequest, onSuccess: { qattahResponse in
            
            startSocketListener(qattahResponse: qattahResponse, qattahPaymentCallback: QattahPaymentCallback())
            
        }, onFail: { errorMessage in
            print("onFail: " + errorMessage)
        })
    }
    
    private func startSocketListener(qattahResponse: QattahResponse, qattahPaymentCallback: PaymentCallback) {
        
        let manager = SocketManager(socketURL: URL(string: "https://testing-callback.qattahpay.sa/")!, config: [.log(true), .compress])
        let socket = manager.defaultSocket

        socket.on(clientEvent: .connect) { data, ack in
            print("CONNECTED" + ((data[0] as AnyObject) as! String))
        }
        
        socket.on(clientEvent: .connect) { data, ack in
            qattahPaymentCallback.onStarted(paymentId: (qattahResponse.data?.order.id)!)
            print("CONNECTED" + ((data[0] as AnyObject) as! String))
            socket.emit("join-room", (qattahResponse.data?.order.id)!)
        }
        
        socket.on("update-payment") { data, ack in
            print("update-payment" + ((data[0] as AnyObject) as! String))
            
            let arr = data as? [[String: Any]]
            let paymentStatus = arr![0]["paymentStatus"] as? String
            print(paymentStatus!)
            onNewMessage(newMessage: paymentStatus!, qattahResponse: qattahResponse, qattahPaymentCallback: qattahPaymentCallback)
        }
        
        socket.on(clientEvent: .disconnect) { data, ack in
            print("DISCONNECTED" + ((data[0] as AnyObject) as! String))
            qattahPaymentCallback.onError(errorMessage: "Qattah Pay socket connection lost, please check internet connection.")
        }
        
        socket.on(clientEvent: .error) { data, ack in
            print("CONECTION_ERROR" + ((data[0] as AnyObject) as! String))
            qattahPaymentCallback.onError(errorMessage: "Qattah Pay socket connection lost, please check internet connection.")
        }
        
        socket.connect()
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
}

final class QattahPaymentCallback: PaymentCallback {
    func onStarted(paymentId: String) {
        print("onStarted: " + paymentId)
    }
    
    func onSuccess(paymentId: String) {
        print("onSuccess: " + paymentId)
    }
    
    func onError(errorMessage: String) {
        print("onError: " + errorMessage)
    }
    
    func onCancel() {
        print("onCancel")
    }
}
