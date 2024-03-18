//
//  ActivityIndicator.swift
//  qattahpay-ios-sdk
//
//  Created by khlafawi on 09/03/2024.
//

import SwiftUI

@available(iOS 13.0, *)
struct ActivityIndicator: UIViewRepresentable {
    let style: UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        uiView.startAnimating()
    }
}

@available(iOS 13.0, *)
struct ActivityIndicator_Preview: PreviewProvider {
  static var previews: some View {
    ActivityIndicator(style: .large)
        .previewLayout(.sizeThatFits)
  }
}
