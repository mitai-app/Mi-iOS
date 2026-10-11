//
//  CustomNavBarContainerView.swift
//  Mi
//
//  Created by Vonley on 9/29/22.
//

import SwiftUI

struct CustomNavBarContainerView<Content: View>: View {
    
    let content: Content
    
    @State private var showBackButton: Bool = false
    @State private var title: String = "Mi"
    @State private var subtitle: String? = nil
    
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavBarView(showBackButton: showBackButton, title: title, subtitle: subtitle)
            content.frame(maxWidth: .infinity, maxHeight: .infinity)
        }.onPreferenceChange(CustomNavBarTitlePreferenceKey.self, perform: { value in
            DispatchQueue.main.async {
                // Fall back to the app name when a screen doesn't set its own title.
                self.title = value.isEmpty ? "Mi" : value
            }
        }).onPreferenceChange(CustomNavBarSubtitlePreferenceKey.self, perform: { value in
            DispatchQueue.main.async {
            self.subtitle = value
            }
        }).onPreferenceChange(CustomNavBarBackButtonHiddenPreferenceKey.self, perform: { value in
            DispatchQueue.main.async {
                // `value` is "back button hidden"; show the button when not hidden.
                self.showBackButton = !value
            }
        })
    }
}

protocol onNavigationCallback: Equatable {
    func onClick()
}

struct CustomNavBarContainerView_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavBarContainerView() {
            ZStack {
                Color.green.ignoresSafeArea()
                Text("Hello world").foregroundColor(.white)
                    .customNavigationTitle("Hello")
            }
        }
    }
}
