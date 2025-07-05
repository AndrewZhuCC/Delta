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
    
    @Option()
    var serverHost: String = ""
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
            self.host = ExperimentalFeatures.shared.romM.serverHost
        }
        
        func signIn() async {
            ExperimentalFeatures.shared.romM.serverHost = self.host
            await RomMManager.shared.tryAuth(with: self.username, password: self.password)
        }
    }
}

struct PasswordField: View {
    @Binding var text: String
    @State private var isSecure: Bool = true

    var body: some View {
        HStack {
            if isSecure {
                SecureField("Password", text: $text)
            } else {
                TextField("Password", text: $text)
            }
            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
    }
}

struct HostView: View {
    @StateObject
    private var viewModel = ViewModel()
    @State private var isSigningIn = false
    
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
                PasswordField(text: $viewModel.password)
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            ZStack {
                Button("Save") {
                    isSigningIn = true
                    Task {
                        await viewModel.signIn()
                        isSigningIn = false
                    }
                }
                if isSigningIn {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.blue)
                }
            }
        })
    }
}
