//
//  CustomNavBarPreferenceKey.swift
//  Mi
//
//  Created by Vonley on 9/29/22.
//

import Foundation
import SwiftUI

struct CustomNavBarTitlePreferenceKey: PreferenceKey {
    
    static var defaultValue: String = ""
    
    static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
    
}


struct CustomNavBarSubtitlePreferenceKey: PreferenceKey {
    
    static var defaultValue: String? = ""
    
    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = nextValue()
    }
}



struct CustomNavBarBackButtonHiddenPreferenceKey: PreferenceKey {
    
    static var defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}



struct CustomNavBarIconPreferenceKey: PreferenceKey {
    
    static var defaultValue: String? = ""
    
    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = nextValue()
    }
}


extension View {
        
    func customNavigationIcon(icon: String?) -> some View {
        preference(key: CustomNavBarIconPreferenceKey.self, value: icon)
    }
    
    func customNavigationTitle(_ title: String) -> some View {
        preference(key: CustomNavBarTitlePreferenceKey.self, value: title)
    }
    
    
    func customNavigationSubtitle(_ subtitle: String?) -> some View{
        preference(key: CustomNavBarSubtitlePreferenceKey.self, value: subtitle)
    }
    
    
    func customNavigationBarBackButtonHidden(_ hidden: Bool) -> some View {
        preference(key: CustomNavBarBackButtonHiddenPreferenceKey.self, value: hidden)
    }
    
    func customNavBarItems(title: String = "", subtitle: String? = "", backButtonHidden: Bool = false) -> some View {
        self.customNavigationTitle(title)
            .customNavigationSubtitle(subtitle)
            .customNavigationBarBackButtonHidden(backButtonHidden)
    }
    
}
