//
//  GeoMath.swift
//  Where2Look
//
//  Created by Bill Weatherwax on 3/30/26.
//


import Foundation
import CoreLocation

enum GeoMath {
    static func distanceMiles(
        fromLatitude: Double,
        fromLongitude: Double,
        toLatitude: Double,
        toLongitude: Double
    ) -> Double {
        let from = CLLocation(latitude: fromLatitude, longitude: fromLongitude)
        let to = CLLocation(latitude: toLatitude, longitude: toLongitude)
        return from.distance(from: to) / 1609.344
    }

    static func bearingDegrees(
        fromLatitude: Double,
        fromLongitude: Double,
        toLatitude: Double,
        toLongitude: Double
    ) -> Double {
        let lat1 = fromLatitude * .pi / 180
        let lon1 = fromLongitude * .pi / 180
        let lat2 = toLatitude * .pi / 180
        let lon2 = toLongitude * .pi / 180

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x) * 180 / .pi
        return bearing >= 0 ? bearing : bearing + 360
    }

    static func headingDifferenceDegrees(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b).truncatingRemainder(dividingBy: 360)
        return min(diff, 360 - diff)
    }

    static func isWithinHeadingTolerance(
        headingDegrees: Double,
        targetBearingDegrees: Double,
        toleranceDegrees: Double
    ) -> Bool {
        headingDifferenceDegrees(headingDegrees, targetBearingDegrees) <= toleranceDegrees
    }
}