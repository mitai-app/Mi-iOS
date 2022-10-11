//
//  CustomNavBarContainerView.swift
//  Mi
//
//  Created by Vonley on 9/29/22.
//

import SwiftUI

struct CustomNavBarContainerView<Content: View>: View {
    
    let content: Content
    
    @State private var showBackButton: Bool = true
    @State private var title: String = "Title"
    @State private var subtitle: String? = "Subtitle"
    
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavBarView(showBackButton: showBackButton, title: title, subtitle: subtitle)
            content.frame(maxWidth: .infinity, maxHeight: .infinity)
        }.onPreferenceChange(CustomNavBarTitlePreferenceKey.self, perform: { value in
            self.title = value
        }).onPreferenceChange(CustomNavBarSubtitlePreferenceKey.self, perform: { value in
            self.subtitle = value
        }).onPreferenceChange(CustomNavBarBackButtonHiddenPreferenceKey.self, perform: { value in
            self.showBackButton = !value
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
