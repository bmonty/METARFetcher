//
//  StationOverview.swift
//  METARFetcher
//
//  Created by Benjamin Montgomery on 1/26/20.
//  Copyright © 2020 Benjamin Montgomery. All rights reserved.
//

import SwiftUI
import AvWeather


/// View to display METAR information for a station.
struct StationOverview: View {

    /// METAR data for this station.
    @State var metar: Metar

    /// Relative time between now and when the METAR was published (i.e. "30 min. ago").
    @State private var relativeTime: String = ""

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    /// Timer used to update the relative time display.
    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            
            VStack {
                FlightConditionIndicator(condition: metar.flightCategory)

                //WindIndicator(windDirection: metar.windDirection, windSpeed: metar.windSpeed, windGust: metar.windGust)
            }

            VStack(alignment: .leading) {
                HStack {
                    Text("\(metar.stationId)")
                        .padding(4)
                        .font(.headline)
                        .foregroundColor(Color.white)
//                        .background(LinearGradient(Color.darkStart, Color.darkEnd))
                        .background(Color.gray)

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("\(metar.observationTime, formatter: Self.dateFormatter)")
                            .font(.footnote)

                        Text("\(relativeTime)")
                            .font(.caption)
                            .italic()
                            .onReceive(timer) { _ in
                                self.relativeTime = self.getRelativeTime(for: self.metar.observationTime)
                        }
                    }
                }

                HStack {
                    Text("Wind: ").bold() + Text("\(metar.windDirection)° @ \(metar.windSpeed)\(metar.windGust > 0 ? "kt, gust \(metar.windGust)kt" : "kt")")
                }

                HStack {
                    Text("sky condition here").bold().italic()
                }

                HStack {
                    if metar.visibility > 1 {
                        Text("Visibility: ").bold() + Text("\(metar.visibility, specifier: "%.0f") SM")
                    } else {
                        Text("Visibility: ").bold() + Text("\(getRationalVisibility(metar.visibility)) SM")
                    }
                }

                HStack {
                    Text("Temp: ").bold() + Text("\(metar.temp, specifier: "%.0f")°C")

                    Spacer()

                    Text("Dew Point: ").bold() + Text("\(metar.dewpoint, specifier: "%.0f")°C")

                    Spacer()

                    Text("Alt: ").bold() + Text("\(metar.altimeter, specifier: "%.2f")")
                }
            }

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
        .onAppear {
            self.relativeTime = self.getRelativeTime(for: self.metar.observationTime)
        }
    }

    private func getRelativeTime(for metarTime: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short

        return formatter.localizedString(for: metarTime, relativeTo: Date())
    }

    private func getRationalVisibility(_ value: Double) -> String {
        let rationalValue = rationalApproximationOf(x0: value)
        return "\(rationalValue.num)/\(rationalValue.den)"
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
                StationOverview(metar: metar1)
                    //.environment(\.colorScheme, .light)

                StationOverview(metar: metar2)
                    //.environment(\.colorScheme, .light)
            }
            .previewLayout(.fixed(width: 414, height: 150))
        }
    }
}
#endif
