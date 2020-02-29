//
//  FlightConditionIndicator.swift
//  METARFetcher
//
//  Created by Benjamin Montgomery on 1/26/20.
//  Copyright © 2020 Benjamin Montgomery. All rights reserved.
//

import SwiftUI
import AvWeather

struct FlightConditionIndicator: View {

    @State var condition: Metar.FlightCategory
    private var fillColor: Color {
        switch condition {
        case .vfr:
            return Color.green
        case .mvfr:
            return Color.blue
        case .ifr:
            return Color.red
        case .lifr:
            return Color.purple
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .scale(1.1)
                .fill(fillColor)

            Circle()
                .scale(0.9)
                .fill(RadialGradient(
                    gradient: Gradient(colors: [fillColor, .white]),
                    center: .center,
                    startRadius: CGFloat(integerLiteral: 10),
                    endRadius: CGFloat(integerLiteral: 17)))

            Text(condition.rawValue)
                .font(Font.system(size: 10, design: .monospaced))
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
        .previewLayout(.sizeThatFits)
    }
}
#endif
