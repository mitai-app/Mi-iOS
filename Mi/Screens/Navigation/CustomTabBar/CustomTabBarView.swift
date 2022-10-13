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
    @State var background: Color
    
    var body: some View {
        tabBarVersion1
            .onChange(of: selection, perform: { value in
                if localSelection != .ftp {
                    Task(priority: .background) {
                        if(!FTP.isConnected) {
                            await SyncServiceImpl.shared.connectFtp()
                        } else if (FTP.isConnected && FTP.shared.dir.count == 0) {
                            switch (value) {
                            case .ftp:
                                await FTP.shared.getCurrentDir()
                            break
                            default:
                                break
                            }
                        }
                    }
                }
                withAnimation(.easeInOut) {
                    localSelection = value
                }
                
            })
    }
}

struct CustomTabBarView_Previews: PreviewProvider {
    static let tabs: [TabBarItem] = [
        .home, .consoles, .package, .ftp, .settings
    ]
    static var previews: some View {
        VStack {
            Spacer()
            CustomTabBarView(tabs: tabs, selection: .constant(tabs.first!), localSelection: tabs.first!, background: Color("tabcolor"))
        }
        VStack {
            Spacer()
            CustomTabBarView(tabs: tabs, selection: .constant(tabs.first!), localSelection: tabs.first!, background: Color("tabcolor")).colorScheme(.dark)
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
            
        }.foregroundColor(
            (
                localSelection == tab ?
                Color("tabtextcolor") :
                Color("tabforecolor")
            )
        ).padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            (
                localSelection == tab ?
                Color("tabforecolor") :
                Color("tabtextcolor")
            )
            .opacity(0.8)
        ).cornerRadius(10)
    }
    
    private func tabView2(tab: TabBarItem) -> some View {
        VStack {
            Image(systemName: tab.iconName)
                .font(.subheadline)
            Text(tab.title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
            
        }.foregroundColor(localSelection == tab ? Color("tabtextcolor") : Color("tabforecolor"))
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(ZStack {
                
                if localSelection == tab {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            (localSelection == tab ? Color("tabforecolor") : Color("tabcolor")).opacity(0.2))
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
            .background(Color("tabcolor").ignoresSafeArea(edges: .bottom))
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
