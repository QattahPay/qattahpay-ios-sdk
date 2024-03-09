//
//  QattahWebViewModel.swift
//  qattahpay-ios-sdk
//
//  Created by khlafawi on 09/03/2024.
//

import SwiftUI
import WebKit
import UIKit

@available(iOS 13.0, *)
final class QattahWebViewModel: UIViewController, WKScriptMessageHandlerWithReply, ObservableObject, WKScriptMessageHandler, WKUIDelegate {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        guard let msg = message.body as? String else {
            self.result = .close
            return
        }
        
        DispatchQueue.main.async {
            let parsedMessage = msg.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            switch parsedMessage {
            case "success":
                self.result = .authorized
                break
            case "fail":
                self.result = .expired
                break
            default:
                break
            }
        }
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
        // implementation is not required
    }
    
    @Published var pending: Bool = false
    @Published var response: QattahResponse?
    @Published var result: QattahResult?
}
