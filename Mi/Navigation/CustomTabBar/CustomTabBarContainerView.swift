//
//  CustomTabBarContainer.swift
//  Mi
//
//  Created by Vonley on 9/29/22.
//

import SwiftUI

struct CustomTabBarContainerView<Content:View> : View {
    
    @Binding var selection: TabBarItem
    @State private var tabs: [TabBarItem] = [
        .home, .package, .settings
    ]
    let content: Content
    var background: Color
    
    init(selection: Binding<TabBarItem>, @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.background = Color.white
        self.content = content()
    }
    
    init(selection: Binding<TabBarItem>, background: Color, @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.background = background
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                content.ignoresSafeArea()
            }.onPreferenceChange(TabBarItemsPreferenceKey.self) { value in
                self.tabs = value
            }
            CustomTabBarView(tabs: tabs, selection: $selection, localSelection: selection, background: background)
        }
    }
    
}

struct CustomTabBarContainerView_Previews: PreviewProvider {
    static let tabs: [TabBarItem] = [
        .home, .package, .settings
    ]
    static var previews: some View {
        CustomTabBarContainerView(selection: .constant(tabs.first!), background: Color("quinary")) {
            
        }
    }
}
