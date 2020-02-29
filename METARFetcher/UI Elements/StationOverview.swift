//
//  StationOverview.swift
//  METARFetcher
//
//  Created by Benjamin Montgomery on 1/26/20.
//  Copyright © 2020 Benjamin Montgomery. All rights reserved.
//

import SwiftUI
import AvWeather

struct StationOverview: View {

    @State var metar: Metar
    @State private var relativeTime: String = ""

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    // timer used to update the relative time ("34 mins ago") display
    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            VStack {
                FlightConditionIndicator(condition: metar.flightCategory)

                WindIndicator(windDirection: metar.windDirection, windSpeed: metar.windSpeed, windGust: metar.windGust)
            }

            VStack(alignment: .leading) {
                HStack {
                    Text("\(metar.stationId)")
                        .font(.headline)

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("\(metar.observationTime, formatter: Self.dateFormatter)")
                            .font(.footnote)

                        Text("\(relativeTime)")
                            .font(.caption)
                            .onReceive(timer) { _ in
                                self.relativeTime = self.getRelativeTime(for: self.metar.observationTime)
                            }
                    }
                }

                HStack {
                    Text("Wind: \(metar.windDirection) @ \(metar.windSpeed)\(metar.windGust > 0 ? ", gust \(metar.windGust)" : "")")

                    Spacer()

                    Text("Vis: \(metar.visibility, specifier: "%.0f") SM")
                }

                HStack {
                    Text("Temp: \(metar.temp, specifier: "%.0f")°C")

                    Spacer()

                    Text("DP: \(metar.dewpoint, specifier: "%.0f")°C")

                    Spacer()

                    Text("Alt: \(metar.altimeter, specifier: "%.2f")")
                }
            }

            Spacer()
        }
        .padding(5)
        .onAppear {
            self.relativeTime = self.getRelativeTime(for: self.metar.observationTime)
        }
    }

    private func getRelativeTime(for metarTime: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short

        return formatter.localizedString(for: metarTime, relativeTo: Date())
    }

}

#if DEBUG
struct StationOverview_Previews: PreviewProvider {

    static var previews: some View {
        PreviewWrapper()
    }

    struct PreviewWrapper: View {
        var metar1: Metar {
            var metar = Metar()
            metar.rawText = "KFME 261348Z AUTO 25005KT 10SM OVC080 01/01 A2994 RMK AO1"
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
            return metar
        }

        var metar2: Metar {
            var metar = Metar()
            metar.rawText = "KFME 261348Z AUTO 25005KT 10SM OVC080 01/01 A2994 RMK AO1"
            metar.stationId = "KBOS"
            metar.observationTime = Date().addingTimeInterval(-20 * 60)
            metar.latitude = 39.08
            metar.longitude = -76.77
            metar.temp = 1.0
            metar.dewpoint = 1.0
            metar.windDirection = 100
            metar.windSpeed = 15
            metar.windGust = 20
            metar.visibility = 10.0
            metar.altimeter = 29.940945
            metar.flightCategory = .ifr
            metar.metarType = .metar
            metar.stationElevation = 150.0
            return metar
        }

        var body: some View {
            Group {
                StationOverview(metar: metar1)
                    .environment(\.colorScheme, .light)

                StationOverview(metar: metar2)
                    .environment(\.colorScheme, .light)
            }
            .previewLayout(.fixed(width: 400, height: 90))
        }
    }
}
#endif
