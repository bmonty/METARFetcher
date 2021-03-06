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

extension LinearGradient {
    /// Helper for making `LinearGradient`s.
    ///
    /// Gradient is from `.topLeading` to `.bottomTrailing`.
    ///
    /// - Parameters:
    ///     - colors: variadic argument of `Color` for the gradient
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// Helper for making `LinearGradient`s.
    ///
    /// Gradient is from `.topLeading` to `.bottomTrailing`.
    ///
    /// - Parameters:
    ///     - colors: array of `Color` for the gradient
    init(_ colors: [Color]) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

typealias Rational = (num : Int, den : Int)

func rationalApproximationOf(x0 : Double, withPrecision eps : Double = 1.0E-6) -> Rational {
    var x = x0
    var a = floor(x)
    var (h1, k1, h, k) = (1, 0, Int(a), 1)

    while x - a > eps * Double(k) * Double(k) {
        x = 1.0/(x - a)
        a = floor(x)
        (h1, k1, h, k) = (h, k, h1 + Int(a) * h, k1 + Int(a) * k)
    }
    return (h, k)
}
