//
//  RawMetarView.swift
//  METARFetcher
//
//  Created by Benjamin Montgomery on 3/6/20.
//  Copyright © 2020 Benjamin Montgomery. All rights reserved.
//

import SwiftUI
import AvWeather


struct RawMetarView: View {

    /// METAR data for this station.
    @State var metar: Metar

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(metar.stationId)")
                .padding(4)
                .font(.headline)
                .foregroundColor(Color.white)
                .background(Color.gray)

            Text("\(metar.rawText)")
                .padding(6)

            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.offWhite)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                .shadow(color: Color.white.opacity(0.7), radius: 10, x: -10, y: -10)
        )
    }

}

struct RawMetarView_Previews: PreviewProvider {

    static var previews: some View {
        PreviewWrapper()
    }

    struct PreviewWrapper: View {
        var metar1: Metar {
            var metar = Metar()
            metar.rawText = "KFME 261348Z AUTO 25005KT 10SM CLR 01/01 A2994 RMK AO1"
            metar.stationId = "KFME"
            metar.observationTime = Date().addingTimeInterval(-63 * 60)
            metar.latitude = 39.08
            metar.longitude = -76.77
            metar.temp = 1.0
            metar.dewpoint = 1.0
            metar.windDirection = 250
            metar.windSpeed = 5
            metar.windGust = 0
            metar.visibility = 10.0
            metar.altimeter = 29.940945
            metar.flightCategory = .vfr
            metar.metarType = .metar
            metar.stationElevation = 46.0

            //var skyCondition = Metar.SkyCondition(skyCover: .clr, base: 0)
            //metar.skyCondition = [skyCondition]

            return metar
        }

        var metar2: Metar {
            var metar = Metar()
            metar.rawText = "KBOS 261348Z AUTO 25005KT 1/4SM OVC080 01/01 A3042 RMK AO1"
            metar.stationId = "KBOS"
            metar.observationTime = Date().addingTimeInterval(-20 * 60)
            metar.latitude = 39.08
            metar.longitude = -76.77
            metar.temp = 1.0
            metar.dewpoint = 1.0
            metar.windDirection = 100
            metar.windSpeed = 15
            metar.windGust = 20
            metar.visibility = 0.25
            metar.altimeter = 30.4233456
            metar.flightCategory = .ifr
            metar.metarType = .metar
            metar.stationElevation = 150.0

            //var skyCondition = Metar.SkyCondition(skyCover: .ovc, base: 800)
            //metar.skyCondition = [skyCondition]

            return metar
        }

        var body: some View {
            Group {
                RawMetarView(metar: metar1)

                RawMetarView(metar: metar2)
            }
            .previewLayout(.fixed(width: 414, height: 150))
        }
    }
}
