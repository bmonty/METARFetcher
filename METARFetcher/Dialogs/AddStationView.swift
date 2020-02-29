//
//  AddStationView.swift
//  METARFetcher
//
//  Created by Benjamin Montgomery on 2/2/20.
//  Copyright © 2020 Benjamin Montgomery. All rights reserved.
//

import SwiftUI

struct AddStationView: View {
    @Binding var stationId: String

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Text("Enter a new ICAO ID")
            TextField("Station ID", text: $stationId)

            HStack {
                Button("Add") {

                }

                Spacer()

                Button("Cancel") {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

#if DEBUG
struct AddStationView_Previews: PreviewProvider {
    static var previews: some View {
        AddStationView(stationId: .constant(""))
    }
}
#endif
