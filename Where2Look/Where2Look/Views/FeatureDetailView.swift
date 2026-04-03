//
//  FeatureDetailView.swift
//  Where2Look
//
//  Created by Bill Weatherwax on 3/30/26.
//


//
//  FeatureDetailView.swift
//  Where2Look
//
//  Created by Bill Weatherwax on 3/30/26.
//

import SwiftUI

struct FeatureDetailView: View {
    let feature: GISFeature

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(feature.location)
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 10) {
                detailRow("Type", feature.featureClassDisplayName)
                detailRow("Distance", feature.formattedDistanceLong)
                detailRow("Bearing", feature.formattedBearing)
                detailRow("Elevation", feature.formattedElevation)
                detailRow("Latitude", feature.formattedLatitude)
                detailRow("Longitude", feature.formattedLongitude)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}
