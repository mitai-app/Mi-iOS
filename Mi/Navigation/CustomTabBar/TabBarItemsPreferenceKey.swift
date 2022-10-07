//
//  TabbarItemPreferenceKey.swift
//  Mi
//
//  Created by Vonley on 9/29/22.
//

import Foundation
import SwiftUI


struct TabBarItemsPreferenceKey: PreferenceKey {
    
    static var defaultValue:  [TabBarItem] = []
    
    static func reduce(value: inout [TabBarItem], nextValue: () -> [TabBarItem]) {
        value += nextValue()
    }
    
}


struct TabBarItemSelectedPreferenceKey: PreferenceKey {
    
    static var defaultValue:  TabBarItem = .home
    
    static func reduce(value: inout TabBarItem, nextValue: () -> TabBarItem) {
        value = nextValue()
    }
    
}


struct TabBarItemViewModifier: ViewModifier {
    
    let tab: TabBarItem
    @Binding var selection: TabBarItem
    
    func body(content: Content) -> some View {
        content
            .opacity(selection == tab ? 1.0 : 0.0)
            .preference(key: TabBarItemsPreferenceKey.self, value: [tab])
            .preference(key: TabBarItemSelectedPreferenceKey.self, value: tab)
            
    }
}

extension View {
    
    func tabBarItem(tab: TabBarItem, selection: Binding<TabBarItem>) -> some View {
        self.modifier(TabBarItemViewModifier(tab: tab, selection: selection))
    }
    
}
