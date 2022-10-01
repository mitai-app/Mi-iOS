//
//  CustomNavBarView.swift
//  Mi
//
//  Created by Vonley on 9/29/22.
//

import SwiftUI

struct CustomNavBarView: View {
    @Environment(\.presentationMode) var presentationMode
    let showBackButton: Bool
    let title: String
    let subtitle: String?
    let background: Color = Color("quinary")
    
    var body: some View {
        HStack {
            if showBackButton {
                backButton
            }
            Spacer()
            titleSection
            Spacer()
            if showBackButton {
                backButton.opacity(0)
            }
        }
        .padding()
        .accentColor(.white)
        .foregroundColor(.white)
        .font(.headline)
        .background(background.ignoresSafeArea(edges: .top))
    }
}

struct CustomNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CustomNavBarView(showBackButton: true, title: "Title here", subtitle: "")
            Spacer()
        }
    }
}


extension CustomNavBarView {
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label:  {
            Image(systemName: "chevron.left")
        })
    }
    
    private var titleSection: some View {
        VStack (spacing: 4) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            if let subtitle = self.subtitle {
                if(!subtitle.isEmpty) {
                    Text(subtitle)
                }
            }
        }
    }
    
}
