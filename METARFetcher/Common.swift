//
//  Common.swift
//  METARFetcher
//
//  Created by Benjamin Montgomery on 2/22/20.
//  Copyright © 2020 Benjamin Montgomery. All rights reserved.
//

import Foundation
import SwiftUI

/// Resource names for user defaults.
enum UserDefaultResourceNames: String {
    case stationIds
}

/// Custom colors
extension Color {
    static let offWhite = Color(red: 255 / 255, green: 255 / 255, blue: 248 / 255)
    static let darkStart = Color(red: 50 / 255, green: 60 / 255, blue: 65 / 255)
    static let darkEnd = Color(red: 5 / 255, green: 25 / 255, blue: 30 / 255)
    static let lightStart = Color(red: 60 / 255, green: 160 / 255, blue: 240 / 255)
    static let lightEnd = Color(red: 30 / 255, green: 80 / 255, blue: 120 / 255)
}

/// Helper for making `LinearGradients`
extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    init(_ colors: [Color]) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
