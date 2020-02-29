//
//  WindIndicator.swift
//  METARFetcher
//
//  Created by Benjamin Montgomery on 1/27/20.
//  Copyright © 2020 Benjamin Montgomery. All rights reserved.
//

import SwiftUI

struct WindIndicator: View {

    @State var windDirection: Int
    @State var windSpeed: Int
    @State var windGust: Int

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.blue, lineWidth: 4)
                    .overlay(
                        GeometryReader { geometry in
                            Path { path in
                                path.move(to: CGPoint(x: geometry.size.width / 2, y: geometry.size.height))
                                path.addLine(to: CGPoint(x: (geometry.size.width / 2) - 6, y: geometry.size.height - 15.0))
                                path.addLine(to: CGPoint(x: (geometry.size.width / 2) + 6, y: geometry.size.height - 15.0))
                                path.addLine(to: CGPoint(x: geometry.size.width / 2, y: geometry.size.height))
                            }
                            .fill(Color.red)
                        }
                    )
                    .rotationEffect(Angle(degrees: Double(windDirection - 180)))

                if windGust > 0 {
                    VStack {
                        Text("\(windSpeed)")
                            .font(.system(size: 13))
                        Text("G\(windGust)")
                            .font(.system(size: 13))
                    }
                } else {
                    Text("\(windSpeed)")
                        .font(.system(size: 13))
                }
            }
        }
        .frame(width: 35, height: 35)
    }

}

#if DEBUG
struct WindIndicator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WindIndicator(windDirection: 360, windSpeed: 10, windGust: 0)
            WindIndicator(windDirection: 90, windSpeed: 20, windGust: 0)
            WindIndicator(windDirection: 180, windSpeed: 6, windGust: 0)
            WindIndicator(windDirection: 270, windSpeed: 10, windGust: 5)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
