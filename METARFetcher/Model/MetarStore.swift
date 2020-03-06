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

/// Stores METAR data and metadata.
struct MetarStoreData: Codable {
    var stationList: [String]
    var stationData: [String : StationData]
}

/// Stores station IDs with a `UUID` so they can be uniquely identified in SwiftUI elements.
struct StationData: Codable {
    enum StationLoadingState: Int, Codable {
        case loading, loaded, failed
    }

    /// The station ID.
    let stationId: String
    /// Loading state for this station's data.
    var loadingState: StationLoadingState = .loading
    /// `Date` for the time `.metars` was last updated.
    var lastUpdated: Date
    /// All METAR data for this station
    var metarData: [Metar]
}

/// Model for the app.  Stores and updates all METAR data.
final class MetarStore: ObservableObject {

    /// Struct to store all METAR information.
    @Published var metarStoreData: MetarStoreData = MetarStoreData(stationList: [], stationData: [:])
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
            let stationData = StationData(stationId: station, lastUpdated: date, metarData: data[index])

            metarStoreData.stationList.append(station)
            metarStoreData.stationData.updateValue(stationData, forKey: station)
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
        stationIds.forEach { station in
            self.getStationData(for: station)
        }
    }

    /// Update user's station ID list in User Data.
    private func updateUserData() {
        // update user defaults with the new list of station IDs
        UserDefaults.standard.set(metarStoreData.stationList, forKey: UserDefaultResourceNames.stationIds.rawValue)
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
    ///     - index: optional location for inserting the station ID in the `stationList` array
    private func storeMetar(for stationId: String, withData metars: [Metar], at index: Int? = nil) {
        let stationData = StationData(stationId: stationId, lastUpdated: Date(), metarData: metars)

        // switch to main thread, because this will trigger a UI update
        DispatchQueue.main.async {
            if !self.metarStoreData.stationList.contains(stationId) {
                if index != nil {
                    self.metarStoreData.stationList.insert(stationId, at: index!)
                } else {
                    self.metarStoreData.stationList.append(stationId)
                }
            }

            self.metarStoreData.stationData.updateValue(stationData, forKey: stationId)
            self.metarStoreData.stationData[stationId]!.loadingState = .loaded
        }
    }

    /// Used as a callback for a timer to periodically update station METAR data.
    private func fireUpdateMetars() {
        // a station gets an update if it's lastUpdated is more than 30 mins old
        let updateDate = Date().addingTimeInterval(-30.0 * 60.0)

        metarStoreData.stationList.forEach { station in
            guard let lastUpdated = metarStoreData.stationData[station]?.lastUpdated else {
                fatalError("\(station) is in the stationList but not in stationData.")
            }

            if lastUpdated < updateDate {
                self.getStationData(for: station)
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
        if let stationData = metarStoreData.stationData[station] {
            return stationData.metarData.first
        }

        // requested a station ID that's not the data store
        return nil
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
