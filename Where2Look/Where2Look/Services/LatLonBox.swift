//
//  LatLonBox.swift
//  Where2Look
//
//  Created by Bill Weatherwax on 3/30/26.
//


import Foundation

struct LatLonBox {
    let minLat: Double
    let maxLat: Double
    let minLon: Double
    let maxLon: Double

    init(distanceMiles: Double, centerLat: Double, centerLon: Double) {
        let earthRadiusMiles = 3958.8
        let latDelta = (distanceMiles / earthRadiusMiles) * (180 / Double.pi)
        let lonDelta = latDelta / max(cos(centerLat * .pi / 180), 0.000001)

        minLat = centerLat - latDelta
        maxLat = centerLat + latDelta
        minLon = centerLon - lonDelta
        maxLon = centerLon + lonDelta
    }
}