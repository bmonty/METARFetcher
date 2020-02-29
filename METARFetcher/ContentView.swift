//
//  ContentView.swift
//  METARFetcher
//
//  Created by Benjamin Montgomery on 1/21/20.
//  Copyright © 2020 Benjamin Montgomery. All rights reserved.
//

import SwiftUI
import AvWeather

struct ContentView: View {
    /// Model holding all METAR data
    @EnvironmentObject var metarStore: MetarStore

    /// Stores the Station ID string when the user adds a new station
    @State private var newStationId = ""
    /// Track if the Add Station dialog is visible
    @State private var showingAddStation = false

    var body: some View {
        NavigationView {
            List(metarStore.stationIds) { station -> StationOverview in
                let metar = self.metarStore.getCurrentMetar(for: station.stationId)!
                return StationOverview(metar: metar)
            }
            .navigationBarTitle("METAR Watcher")
            .navigationBarItems(trailing:
                Button(action: {
                    self.showingAddStation.toggle()
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingAddStation) {
                AddStationView(stationId: self.$newStationId)
                .onDisappear() {
                    //self.addStation()
                    self.metarStore.objectWillChange.send()
                }
            }
            .onAppear() {
                self.metarStore.objectWillChange.send()
            }
        }
    }

    /// Called by SwiftUI when the user adds a station to the app.
    private func addStation() {
        metarStore.addStation(with: newStationId)
    }

    /// Called by SwiftUI when the user removes a station from the app.
    private func removeStation(at offsets: IndexSet) {
        // TODO: implement removeStation
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        var metar1 = Metar()
        metar1.rawText = "KFME 261348Z AUTO 25005KT 10SM CLR 01/01 A2994 RMK AO1"
        metar1.stationId = "KFME"
        metar1.observationTime = Date().addingTimeInterval(-15 * 60)
        metar1.latitude = 39.09
        metar1.longitude = -76.76
        metar1.temp = 1.0
        metar1.dewpoint = 1.0
        metar1.windDirection = 250
        metar1.windSpeed = 5
        metar1.windGust = 0
        metar1.visibility = 10.0
        metar1.altimeter = 29.940945
        metar1.flightCategory = .vfr
        metar1.metarType = .metar
        metar1.stationElevation = 150.0

        var metar2 = Metar()
        metar2.rawText = "KBWI 261348Z AUTO 10015G20KT 1/4SM OVC080 13/M13 A2994 RMK AO2"
        metar2.stationId = "KBWI"
        metar2.observationTime = Date()
        metar2.latitude = 39.18
        metar2.longitude = -76.67
        metar2.temp = 3.0
        metar2.dewpoint = -13.0
        metar2.windDirection = 100
        metar2.windSpeed = 15
        metar2.windGust = 20
        metar2.visibility = 0.25
        metar2.altimeter = 30.456654
        metar2.flightCategory = .ifr
        metar2.metarType = .speci
        metar2.stationElevation = 143.0

        let metarStore = MetarStore(for: ["KFME", "KBWI"], with: [[metar1], [metar2]])

        return ContentView().environmentObject(metarStore)
    }

}
#endif
