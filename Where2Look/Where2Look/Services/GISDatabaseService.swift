//
//  GISDatabaseService.swift
//  Where2Look
//
//  Created by Bill Weatherwax on 3/30/26.
//


import Foundation
import SQLite3
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

final class GISDatabaseService {
    static let shared = GISDatabaseService()

    private init() {}

    enum DatabaseError: LocalizedError {
        case fileNotFound
        case openFailed(String)
        case prepareFailed(String)

        var errorDescription: String? {
            switch self {
            case .fileNotFound:
                return "waxnav.db was not found in the app bundle."
            case .openFailed(let message):
                return "Could not open database: \(message)"
            case .prepareFailed(let message):
                return "Could not prepare SQL statement: \(message)"
            }
        }
    }

    private func openDatabase() throws -> OpaquePointer? {
        guard let path = Bundle.main.path(forResource: "waxnav", ofType: "db") else {
            throw DatabaseError.fileNotFound
        }

        var db: OpaquePointer?
        if sqlite3_open_v2(path, &db, SQLITE_OPEN_READONLY, nil) != SQLITE_OK {
            defer { sqlite3_close(db) }
            throw DatabaseError.openFailed(String(cString: sqlite3_errmsg(db)))
        }

        return db
    }

    func nearbyFeatures(request: SearchRequest) throws -> [GISFeature] {
        let box = LatLonBox(
            distanceMiles: request.distanceLimitMiles,
            centerLat: request.currentLatitude,
            centerLon: request.currentLongitude
        )

        let db = try openDatabase()
        defer { sqlite3_close(db) }

        let sql = """
        SELECT location, latitude, longitude, featureClass, elevation
        FROM locations
        WHERE latitude BETWEEN ? AND ?
          AND longitude BETWEEN ? AND ?
        LIMIT ?
        """

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK {
            throw DatabaseError.prepareFailed(String(cString: sqlite3_errmsg(db)))
        }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_double(statement, 1, box.minLat)
        sqlite3_bind_double(statement, 2, box.maxLat)
        sqlite3_bind_double(statement, 3, box.minLon)
        sqlite3_bind_double(statement, 4, box.maxLon)
        sqlite3_bind_int(statement, 5, Int32(request.resultLimit))

        var results: [GISFeature] = []

        while sqlite3_step(statement) == SQLITE_ROW {
            guard
                let locationC = sqlite3_column_text(statement, 0),
                let featureClassC = sqlite3_column_text(statement, 3)
            else {
                continue
            }

            let location = String(cString: locationC)
            let latitude = sqlite3_column_double(statement, 1)
            let longitude = sqlite3_column_double(statement, 2)
            let featureClass = String(cString: featureClassC)
            let elevation = sqlite3_column_double(statement, 4)

            let distanceMiles = GeoMath.distanceMiles(
                fromLatitude: request.currentLatitude,
                fromLongitude: request.currentLongitude,
                toLatitude: latitude,
                toLongitude: longitude
            )

            // distance safety filter
            guard distanceMiles <= request.distanceLimitMiles else {
                continue
            }

            // elevation filter
            guard elevation >= request.minElevation else {
                continue
            }

            // feature class filter
            if !request.selectedFeatureClasses.isEmpty &&
                !request.selectedFeatureClasses.contains(featureClass) {
                continue
            }

            let bearingDegrees = GeoMath.bearingDegrees(
                fromLatitude: request.currentLatitude,
                fromLongitude: request.currentLongitude,
                toLatitude: latitude,
                toLongitude: longitude
            )

            // optional heading filter
            if let heading = request.headingDegrees {
                if !GeoMath.isWithinHeadingTolerance(
                    headingDegrees: heading,
                    targetBearingDegrees: bearingDegrees,
                    toleranceDegrees: request.headingToleranceDegrees
                ) {
                    continue
                }
            }

            results.append(
                GISFeature(
                    location: location,
                    latitude: latitude,
                    longitude: longitude,
                    featureClass: featureClass,
                    elevation: elevation,
                    distanceMiles: distanceMiles,
                    bearingDegrees: bearingDegrees
                )
            )
        }

        return results.sorted { $0.distanceMiles < $1.distanceMiles }
    }
}
