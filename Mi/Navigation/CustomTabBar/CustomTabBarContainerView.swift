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
        .home, .favorites, .profile
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
        ZStack(alignment: .bottom) {
            content.ignoresSafeArea()
            CustomTabBarView(tabs: tabs, selection: $selection, localSelection: selection, background: background)
        }.onPreferenceChange(TabBarItemsPreferenceKey.self) { value in
            self.tabs = value
        }
    }
    
}

struct CustomTabBarContainerView_Previews: PreviewProvider {
    static let tabs: [TabBarItem] = [
        .home, .favorites, .profile
    ]
    static var previews: some View {
        CustomTabBarContainerView(selection: .constant(tabs.first!)) {
            
        }
    }
}
