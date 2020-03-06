//
//  FlightConditionIndicator.swift
//  METARFetcher
//
//  Created by Benjamin Montgomery on 1/26/20.
//  Copyright © 2020 Benjamin Montgomery. All rights reserved.
//

import SwiftUI
import AvWeather

/// View to display a flight condition indicator in the `StationOverview`.
struct FlightConditionIndicator: View {

    /// The flight category to display (VFR, MVFR, IFR, LIFR).
    @State var condition: Metar.FlightCategory

    /// Provides appropriate colors for each flight condition.
    private var fillColor: [Color] {
        switch condition {
        case .vfr:
            return [
                Color(red: 0 / 255, green: 255 / 255, blue: 0),
                Color(red: 0 / 255, green: 128 / 255, blue: 0 / 255)
            ]
        case .mvfr:
            return [
                Color(red: 240 / 255, green: 128 / 255, blue: 128 / 255),
                Color(red: 178 / 255, green: 34 / 255, blue: 34 / 255)
            ]
        case .ifr:
            return [
                Color(red: 221 / 255, green: 160 / 255, blue: 221 / 255),
                Color(red: 148 / 255, green: 0 / 255, blue: 211 / 255)
            ]
        case .lifr:
            return [
                Color(red: 30 / 255, green: 144 / 255, blue: 255 / 255),
                Color(red: 0 / 255, green: 0 / 255, blue: 255 / 255)
            ]
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(fillColor))
                .overlay(
                    Circle()
                        .stroke(Color.gray, lineWidth: 4)
                        .blur(radius: 4)
                        .offset(x: 2, y: 2)
                        .mask(
                            Circle()
                                .fill(LinearGradient(Color.black, Color.clear))
                        )
                )
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 8)
                        .blur(radius: 4)
                        .offset(x: -2, y: -2)
                        .mask(
                            Circle()
                                .fill(LinearGradient(Color.clear, Color.black))
                        )
                )

            Text(condition.rawValue)
                .font(Font.system(size: 10, design: .monospaced))
                .foregroundColor(Color.black)
                .allowsTightening(true)
        }
        .frame(width: 35, height: 35)
    }
}

#if DEBUG
struct FlightConditionIndicator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FlightConditionIndicator(condition: .vfr)

            FlightConditionIndicator(condition: .mvfr)

            FlightConditionIndicator(condition: .ifr)

            FlightConditionIndicator(condition: .lifr)
        }
        .previewLayout(.fixed(width: 80, height: 80))
    }
}
#endif
