<p align="center">
    <img src="https://random-bucket.fra1.cdn.digitaloceanspaces.com/images/logo_en.svg"
        height="230">
        
</p>

# Qattah Pay iOS SDK Library

Qattah Pay iOS SDK Library is a payment integration library that allows merchants to accept payments in their iOS applications.

## Getting Started

To include the Qattah Pay iOS SDK Library in your iOS application, follow these steps:

1. Open your Xcode project, navigate the File tab within the macOS bar, and click on “Add Packages”.

<p align="center">
    <img src="https://random-bucket.fra1.cdn.digitaloceanspaces.com/images/Screenshot%202023-05-15%20at%207.47.09%20PM.png"
        height="400">
        
</p>

2. In the Add New Package window you can search for a package via the URL to the Github page (https://github.com/QattahPay/qattahpay-ios-sdk/).

<p align="center">
    <img src="https://random-bucket.fra1.cdn.digitaloceanspaces.com/images/Screenshot%202023-05-15%20at%209.07.34%20PM.png"
        height="400">
        
</p>

## Usage

To use the QattahPay iOS SDK Library, you need to import the qattahpay_ios_sdk to your project by:

```swift
import qattahpay_ios_sdk

```

And then create a new QattahPaySDK object where you want as in the below example:
Note: you have to put your API key in the initiation phase.

```swift
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentViewModel(qattahPay: QattahPaySDK(apiKey: "<YOUR_API_HERE>")))
        }
    }
```

To make a payment request, you need to create a PaymentRequest object and call the startPayment() method:

```swift
// create a new payment request
let paymentRequest = PaymentRequestBuilder().setAmount(120).setCurrency(Currency.SAR).setOrderId("ORDER_ID").setDescription("ORDER_DESCRIPTION").setCustomerEmail("customer@email.com").setCustomerMobileNumber("0501234567").isSandbox(true).build()

 // start a new payment session
 qattahPay.startPaymentSession(paymentRequest: paymentRequest, onSuccess: { qattahResponse in
    //handle creation success
    
}, onFail: { errorMessage in
    //handle creation failure
    
})
```

After starting a new payment session with Qattah Pay, you will get a new `qattahResponse` object in the `onSuccess` callback of the `startPaymentSession` function, by this object you can navigate to the `QattahWebView` which is built using SwiftUI as following:

```swift
NavigationLink(destination: QattahWebView(qattahResponse: viewModel.qattahResponse, qattahPaymentCallback: self.qattahPaymentCallback as PaymentCallback), isActive: $viewModel.navigatToQattahWebView) {
    EmptyView()
}
````

And you can handle all callbacks by creating a new class that implements the protocol `PaymentCallback` for the Qattah Pay Callback Service by following the below steps:

```swift
import Foundation
import qattahpay_ios_sdk

class QattahPaymentCallback: PaymentCallback {
    
    func onStarted(paymentId: String) {
        print(paymentId)
    }
    
    func onSuccess(paymentId: String) {
        print(paymentId)
    }
    
    func onError(errorMessage: String) {
        print(errorMessage)
    }
    
    func onCancel() {
        print("onCancel")
    }
}
```

## License

This library is licensed under the MIT License.
