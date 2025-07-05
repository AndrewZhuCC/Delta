//
//  RomM.swift
//  Delta
//
//  Created by 朱安智 on 2025/7/5.
//  Copyright © 2025 Riley Testut. All rights reserved.
//

import Foundation
import SwiftUI

import DeltaFeatures

struct RomMOptions
{
    @Option(name: "Manage Host", detailView: { _ in HostView() })
    var manageHost: String = ""
}

private extension HostView
{
    class ViewModel: ObservableObject
    {
        @Published
        var username: String
        
        @Published
        var password: String = ""
        
        @Published
        var host: String = ""
        
        init()
        {
            self.username = Keychain.shared.romMUsername ?? ""
            self.password = Keychain.shared.romMPassword ?? ""
            self.host = Keychain.shared.romMHost ?? ""
        }
        
        func signIn() {
            
        }
    }
}

struct HostView: View {
    @StateObject
    private var viewModel = ViewModel()
    
    var body: some View {
        guard #available(iOS 15, *) else { return AnyView(Text("RomM requires iOS 15 or later.")) }
        
        return AnyView(List {
            Section("Host") {
                TextField("Host", text: $viewModel.host)
                    .textContentType(.URL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            Section("Username") {
                TextField("Username", text: $viewModel.username)
                    .textContentType(.username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            Section("Password") {
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            Button("Sign In") {
                viewModel.signIn()
            }
        })
    }
}
