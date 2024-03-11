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
        
        // Add gesture recognizer for pan down gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(CustomWebViewDelegate.handlePanGesture(_:)))
        webView.addGestureRecognizer(panGesture)
        
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

class CustomWebViewDelegate: NSObject {
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        guard recognizer.state == .ended else { return }

        let translation = recognizer.translation(in: recognizer.view)
        let isDraggingDown = translation.y > 0

        if isDraggingDown {
          // Show confirmation alert
          let alert = UIAlertController(title: "Dismiss View", message: "Are you sure you want to dismiss the web view?", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: { _ in
            // User confirms dismissal, remove gesture recognizer and allow dismissal
            recognizer.view?.removeGestureRecognizer(recognizer)
          }))
          alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
          UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
        }
    }
}
