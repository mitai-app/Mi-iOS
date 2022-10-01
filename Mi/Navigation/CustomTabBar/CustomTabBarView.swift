//
//  CustomTabBarView.swift
//  Mi
//
//  Created by Vonley on 9/29/22.
//

import SwiftUI

struct CustomTabBarView: View {
    let tabs: [TabBarItem]
    @Binding var selection: TabBarItem
    @Namespace private var namespace
    @State var localSelection: TabBarItem
    var background: Color = .white
    
    var body: some View {
        tabBarVersion1
            .onChange(of: selection, perform: { value in  withAnimation(.easeInOut) {
                    localSelection = value
                }
            })
    }
}

struct CustomTabBarView_Previews: PreviewProvider {
    static let tabs: [TabBarItem] = [
        .home, .package, .settings
    ]
    static var previews: some View {
        VStack {
            Spacer()
            CustomTabBarView(tabs: tabs, selection: .constant(tabs.first!), localSelection: tabs.first!, background: Color.white)
        }
    }
}

extension CustomTabBarView {
    
    private func tabView(tab: TabBarItem) -> some View {
        VStack {
            Image(systemName: tab.iconName)
                .font(.subheadline)
            Text(tab.title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
            
        }.foregroundColor(localSelection == tab ? tab.color : Color.gray)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(localSelection == tab ? tab.color.opacity(0.2) : Color.clear )
            .cornerRadius(10)
    }
    
    private func tabView2(tab: TabBarItem) -> some View {
        VStack {
            Image(systemName: tab.iconName)
                .font(.subheadline)
            Text(tab.title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
            
        }.foregroundColor(localSelection == tab ? tab.color : Color.gray)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(ZStack {
                
                if localSelection == tab {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(tab.color.opacity(0.2))
                        .matchedGeometryEffect(id: "background_rectable", in: namespace)
                } else {
                    
                }
                
            })
    }
    
    private func switchToTab(tab: TabBarItem) {
        selection = tab
    }
    
    
   
}


extension CustomTabBarView {
    
    
    private var tabBarVersion1: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                tabView(tab: tab)
                    .onTapGesture {
                    switchToTab(tab: tab)
                }
            }
        }.padding()
            .background(background.ignoresSafeArea(edges: .bottom))
    }
    
    
    private var tabBarVersion2: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                tabView2(tab: tab)
                    .onTapGesture {
                    switchToTab(tab: tab)
                }
            }
        }.padding()
            .background(background.ignoresSafeArea(edges: .bottom))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
    }
    
}