//
//  AppBarNavView.swift
//  Mi
//
//  Created by Vonley on 9/29/22.
//

import SwiftUI

struct AppBarNavView: View {
    var body: some View {
        CustomNavView {
            ZStack {
                Color.orange.ignoresSafeArea()
                CustomNavLink(
                    destination: Text("Destination")
                        .customNavBarItems(title: "Second", subtitle: "Welcome", backButtonHidden: false)
                    
                    , label: {
                        Text("Navigate")
                    }
                )
            }
            .customNavigationTitle("Custom Title!")
            .customNavigationSubtitle("Welcome to the first page")
            .customNavigationBarBackButtonHidden(true)
        }
    }
}

struct AppBarNavView_Previews: PreviewProvider {
    static var previews: some View {
        AppBarNavView()
    }
}

extension AppBarNavView {
    
    private var defaultNavView: some View {
        NavigationView  {
            ZStack {
                Color.green.ignoresSafeArea()
                NavigationLink(
                    destination: Text("Destination")
                        .navigationTitle("Title 2")
                        .navigationBarBackButtonHidden(false)) {
                        Text("Navigation")
                    }
            }
        }.navigationTitle("New title here")
    }
}
