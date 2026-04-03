//
//  GISFeature.swift
//  Where2Look
//
//  Created by Bill Weatherwax on 3/30/26.
//


import Foundation

struct GISFeature: Identifiable, Hashable {
    var id: String {
        "\(location)-\(latitude)-\(longitude)-\(featureClass)"
    }

    let location: String
    let latitude: Double
    let longitude: Double
    let featureClass: String
    let elevation: Double

    let distanceMiles: Double
    let bearingDegrees: Double
}

extension GISFeature {
    var featureClassDisplayName: String {
        FeatureClassMapper.displayName(for: featureClass)
    }

    var formattedDistance: String {
        String(format: "%.1f mi", distanceMiles)
    }

    var formattedBearing: String {
        String(format: "%.0f°", bearingDegrees)
    }

    var formattedElevation: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let value = formatter.string(from: NSNumber(value: Int(elevation))) ?? "\(Int(elevation))"
        return "\(value) ft"
    }

    var formattedLatitude: String {
        String(format: "%.4f", latitude)
    }

    var formattedLongitude: String {
        String(format: "%.4f", longitude)
    }

    var formattedDistanceLong: String {
        String(format: "%.1f miles", distanceMiles)
    }
}
