//
//  MetarData.swift
//  METARFetcher
//
//  Created by Benjamin Montgomery on 2/2/20.
//  Copyright © 2020 Benjamin Montgomery. All rights reserved.
//

import Foundation
import AvWeather


/// Error values for `MetarStore`.
public enum MetarStoreError: Error {
    case stationIdDoesNotExist(message: String)
}

/// Stores station IDs with a `UUID` so they can be uniquely identified in SwiftUI elements.
struct StationList: Identifiable {
    /// A unique ID for this station ID.
    let id = UUID()
    /// The station ID.
    let stationId: String
}

/// Stores METAR data and metadata.
struct MetarStoreData {
    /// Array of `Metar` for the station.  The first element of the array is the most recent METAR.
    var metars: [Metar]
    /// `Date` for the time `.metars` was last updated.
    var lastUpdated: Date
}

/// Model for the app.  Stores and updates all METAR data.
final class MetarStore: ObservableObject {

    /// List of station IDs the model is storing data for.
    @Published var stationIds: [StationList] = []
    /// Dictionary storing actual METAR data for each station.
    private var metarStore: [String: MetarStoreData] = [:]
    /// `Timer` used to trigger a periodic update of the stored METAR data.
    private var timer: Timer = Timer()

    /// Init a `MetarStore` and load METAR data from the stations stored in User Data.
    ///
    /// This version of the initalizer is used by the app at runtime.
    init() {
        loadStationIds()

        // set Timer to update METARs
        self.timer = Timer(timeInterval: 10.0, repeats: true) { _ in
            self.fireUpdateMetars()
        }
        self.timer.tolerance = 5.0
        RunLoop.current.add(self.timer, forMode: .common)
    }

    /// Init a `MetarStore` with example data.
    ///
    /// This version of the initalizer is used for previews and testing.  The order of the station IDs and
    /// the `Metar` arrays should be the same.
    ///
    /// - Parameters:
    ///     - stations: array of `String` with station IDs
    ///     - data: array of `[Metar]`
    ///     - date: the date to use as the last updated time, defaults to the current date and time
    init(for stations: [String], with data: [[Metar]], at date: Date = Date()) {
        for (index, station) in stations.enumerated() {
            let mstore = MetarStoreData(metars: data[index], lastUpdated: date)
            metarStore.updateValue(mstore, forKey: station)

            stationIds.append(StationList(stationId: station))
        }
    }

    /// Populates the model with METAR information from station IDs stored in User Defaults.
    private func loadStationIds() {
        guard let stationIds = UserDefaults.standard.array(forKey: UserDefaultResourceNames.stationIds.rawValue) as? [String] else {
            fatalError("Couldn't load station IDs from User Defaults.")
        }

        if stationIds.isEmpty {
            return
        }

        // load data for each station ID
        stationIds.forEach { [weak self] station in
            guard let self = self else {
                fatalError("Model class doesn't exist.")
            }

            self.getStationData(for: station)
        }
    }

    /// Update user's station ID list in User Data.
    private func updateUserData() {
        // update user defaults with the new list of station IDs
        UserDefaults.standard.set(self.stationIds, forKey: UserDefaultResourceNames.stationIds.rawValue)
    }

    /// Make a web request to get METAR data for the specified station ID.
    ///
    /// - Parameters:
    ///     - stationId: the station ID to get data for
    private func getStationData(for stationId: String) {
        let avWeatherClient = ADDSClient()

        avWeatherClient.send(MetarRequest(forStation: stationId)) { response in
            switch response {
            case .success(let metars):
                self.storeMetar(for: stationId, withData: metars)

            case .failure(let error):
                // request failed
                print(error.localizedDescription)
            }
        }
    }

    /// Stores new/updated METAR data into the model and triggers view update.
    ///
    /// - Parameters:
    ///     - stationId: the station ID to store/update
    ///     - metars: array of `Metar` to store in the model
    ///     - index: optional location for inserting the station ID in the `stationIds` array
    private func storeMetar(for stationId: String, withData metars: [Metar], at index: Int? = nil) {
        // store/update METAR data in the model
        let metar = MetarStoreData(metars: metars,
                                   lastUpdated: Date())
        metarStore.updateValue(metar, forKey: stationId)

        // update stationIds array, if required, and update view
        if !stationIds.contains(where: { $0.stationId == stationId }) {
            // insert the new station ID and trigger a UI update
            let insertIndex = index ?? stationIds.endIndex
            DispatchQueue.main.async {
                self.stationIds.insert(StationList(stationId: stationId), at: insertIndex)
            }
        } else {
            // trigger a UI update even though the stationIds array didn't change
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }

    /// Used as a callback for a timer to periodically update station METAR data.
    private func fireUpdateMetars() {
        // a station gets an update if it's lastUpdated is more than 30 mins old
        let updateDate = Date().addingTimeInterval(-30.0 * 60.0)

        stationIds.forEach { station in
            guard let lastUpdated = self.metarStore[station.stationId]?.lastUpdated else {
                fatalError("There is a stationId that is not in the metarStore.")
            }

            if lastUpdated < updateDate {
                self.getStationData(for: station.stationId)
            }
        }
    }

    /// Gets the most recent METAR data for the specified station.
    ///
    /// - Parameters:
    ///     - station: the station ID to get the latest METAR for
    ///
    /// - Returns: the most recent `Metar` for the station or `nil` if the station doesn't exist
    public func getCurrentMetar(for station: String) -> Metar? {
        if let metarData = metarStore[station] {
            return metarData.metars.first!
        } else {
            return nil
        }
    }

    /// Add a new Station ID for the model to track.
    func addStation(with stationId: String) {
        // make the call to get station data
        getStationData(for: stationId)

        updateUserData()
    }

    /// Remove a station ID from the model.
    func removeStation(at index: IndexPath) {
        // TODO: Implement removeStation
    }

}
