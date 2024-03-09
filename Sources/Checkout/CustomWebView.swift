//
//  CustomWebView.swift
//  qattahpay-ios-sdk
//
//  Created by khlafawi on 09/03/2024.
//

import SwiftUI
import WebKit
import UIKit

@available(iOS 13.0, *)
struct CustomWebView: UIViewRepresentable {
    
    var url: String?
    var viewModel: QattahWebViewModel
    
    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        let contentController = webView.configuration.userContentController
        contentController.add(viewModel, name: "qattahPayMobileSDK")
        
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        
        return webView
    }
    
    func updateUIView(_ webview: WKWebView, context: Context) {
        if let urlValue = url {
            if let requestUrl = URL(string: urlValue) {
                webview.load(URLRequest(url: requestUrl))
            }
        }
    }
}
