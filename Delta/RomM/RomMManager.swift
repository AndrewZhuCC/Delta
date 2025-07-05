//
//  RomMManager.swift
//  Delta
//
//  Created by 朱安智 on 2025/7/5.
//  Copyright © 2025 Riley Testut. All rights reserved.
//

import Foundation

enum RomMAPI {
    case me
    
    var endpoint: String {
        switch self {
        case .me:
            return "/api/users/me"
        }
    }
    
    var url: URL? {
        guard let baseURL = URL(string: ExperimentalFeatures.shared.romM.serverHost) else {
            return nil
        }
        return baseURL.appendingPathComponent(self.endpoint)
    }
}

private extension URLSession {
    static func session(with username: String?, password: String?) -> URLSession {
        let configuration = URLSessionConfiguration.default
        if let username = username, let password = password {
            let credentials = "\(username):\(password)"
            if let credentialData = credentials.data(using: .utf8) {
                let authToken = credentialData.base64EncodedString()
                let headers = ["Authorization": "Basic \(authToken)"]
                configuration.httpAdditionalHeaders = headers
            }
        }
        return URLSession(configuration: configuration)
    }
}

final class RomMManager {
    static let shared = RomMManager()
    
    private var session: URLSession
    
    private init()
    {
        self.session = URLSession.session(with: Keychain.shared.romMUsername, password: Keychain.shared.romMUsername)
    }
    
    private func resetSession() {
        self.session.invalidateAndCancel()
        self.session = URLSession.session(with: Keychain.shared.romMUsername, password: Keychain.shared.romMUsername)
    }
    
    @discardableResult
    public func tryAuth(with username: String, password: String) async -> Bool {
        let session = URLSession.session(with: username, password: password)
        guard let meUrl = RomMAPI.me.url else {
            return false
        }
        
        var request = URLRequest(url: meUrl)
        do {
            let (data, response) = try await session.data(for: request)
            print("RomM Auth Response: \(response)")
            Keychain.shared.romMUsername = username
            Keychain.shared.romMPassword = password
            return true
        } catch {
            print("Failed to authenticate with RomM: \(error.localizedDescription)")
            return false
        }
    }
}
