//
//  CustomNavBarView.swift
//  Mi
//
//  Created by Vonley on 9/29/22.
//

import SwiftUI

struct CustomNavBarView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL
    let showBackButton: Bool
    let title: String
    let subtitle: String?
    let background: Color = Color("navcolor")

    var body: some View {
        ZStack {
            // Title stays centered regardless of the leading/trailing icons.
            titleSection
                .frame(maxWidth: .infinity)
            HStack {
                if showBackButton {
                    backButton
                }
                Spacer()
                repoButton
            }
        }
        .padding()
        .accentColor(Color("navcolorFore"))
        .foregroundColor(Color("navcolorFore"))
        .frame(maxWidth: .infinity)
        .font(.headline)
        .background(background.ignoresSafeArea(edges: .top))
    }
}

struct CustomNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CustomNavBarView(showBackButton: false, title: "The Title here", subtitle: "")
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

    /// Opens the project's source repository in the browser.
    private var repoButton: some View {
        Button(action: {
            if let url = URL(string: Constants.REPO_URL) {
                openURL(url)
            }
        }, label: {
            Image(systemName: "chevron.left.forwardslash.chevron.right")
        })
        .accessibilityLabel("Open project on GitHub")
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
