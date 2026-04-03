import Foundation
import Combine
import SwiftUI

enum SortOption: String, CaseIterable {
    case distance = "Distance"
    case elevation = "Elevation"
}

enum SortOrder: String, CaseIterable {
    case ascending = "Ascending"
    case descending = "Descending"
}

@MainActor
final class NearbyFeaturesViewModel: ObservableObject {
    @Published var features: [GISFeature] = []
    @Published var errorMessage: String = ""

    @AppStorage("distanceLimitMiles") var distanceLimitMiles: Double = 25
    @AppStorage("minElevation") var minElevation: Double = 0

    @AppStorage("useHeadingFilter") var useHeadingFilter: Bool = false
    @AppStorage("isDirectionFilterEnabled") var isDirectionFilterEnabled: Bool = false
    @AppStorage("headingToleranceDegrees") var headingToleranceDegrees: Double = 10

    @Published var currentHeadingDegrees: Double? = nil

    @AppStorage("sortOption") private var sortOptionRaw: String = SortOption.distance.rawValue
    @AppStorage("sortOrder") private var sortOrderRaw: String = SortOrder.ascending.rawValue

    @AppStorage("selectedFeatureClasses") private var selectedFeatureClassesRaw: String = ""

    let availableFeatureClasses: [String] = [
        "A", "H", "L", "P", "R", "S", "T", "U", "V"
    ]

    var sortOption: SortOption {
        get { SortOption(rawValue: sortOptionRaw) ?? .distance }
        set {
            sortOptionRaw = newValue.rawValue
            objectWillChange.send()
        }
    }

    var sortOrder: SortOrder {
        get { SortOrder(rawValue: sortOrderRaw) ?? .ascending }
        set {
            sortOrderRaw = newValue.rawValue
            objectWillChange.send()
        }
    }

    var selectedFeatureClasses: Set<String> {
        get {
            Set(
                selectedFeatureClassesRaw
                    .split(separator: ",")
                    .map { String($0) }
                    .filter { !$0.isEmpty }
            )
        }
        set {
            selectedFeatureClassesRaw = newValue.sorted().joined(separator: ",")
            objectWillChange.send()
        }
    }
    
    var hasActiveFilters: Bool {
        return distanceLimitMiles != 25
            || minElevation != 0
            || useHeadingFilter
            || isDirectionFilterEnabled
            || headingToleranceDegrees != 10
            || sortOption != .distance
            || sortOrder != .ascending
            || !selectedFeatureClasses.isEmpty
    }
    
    
    func resetFilters() {
        distanceLimitMiles = 25
        minElevation = 0

        useHeadingFilter = false
        isDirectionFilterEnabled = false
        headingToleranceDegrees = 10

        sortOption = .distance
        sortOrder = .ascending

        selectedFeatureClasses = []
    }

    func loadNearbyFeatures(latitude: Double, longitude: Double, headingDegrees: Double?) {
        do {
            currentHeadingDegrees = headingDegrees

            let request = SearchRequest(
                nameQuery: "",
                distanceLimitMiles: distanceLimitMiles,
                minElevation: minElevation,
                currentLatitude: latitude,
                currentLongitude: longitude,
                selectedFeatureClasses: [],
                headingDegrees: nil,
                headingToleranceDegrees: headingToleranceDegrees,
                resultLimit: 100
            )

            features = try GISDatabaseService.shared.nearbyFeatures(request: request)
            errorMessage = ""
        } catch {
            features = []
            errorMessage = error.localizedDescription
        }
    }

    var sortedFeatures: [GISFeature] {
        guard !features.isEmpty else { return [] }

        var base = features

        // Feature class filter
        if !selectedFeatureClasses.isEmpty {
            base = base.filter { selectedFeatureClasses.contains($0.featureClass) }
        }

        // Direction filter
        if isDirectionFilterEnabled,
           let heading = currentHeadingDegrees {

            base = base.filter { feature in
                GeoMath.isWithinHeadingTolerance(
                    headingDegrees: heading,
                    targetBearingDegrees: feature.bearingDegrees,
                    toleranceDegrees: headingToleranceDegrees
                )
            }
        }

        // Heading ranking mode
        if useHeadingFilter, let heading = currentHeadingDegrees {
            return base.sorted {
                score(for: $0, heading: heading) > score(for: $1, heading: heading)
            }
        }

        // Standard sorting
        let sorted: [GISFeature]

        switch sortOption {
        case .distance:
            sorted = base.sorted { $0.distanceMiles < $1.distanceMiles }

        case .elevation:
            sorted = base.sorted { $0.elevation < $1.elevation }
        }

        return sortOrder == .ascending ? sorted : Array(sorted.reversed())
    }

    func isLikelyMatch(_ feature: GISFeature) -> Bool {
        let topCandidates = Array(sortedFeatures.prefix(3))
        return topCandidates.contains(where: { $0.id == feature.id })
    }

    func toggleFeatureClass(_ featureClass: String) {
        var current = selectedFeatureClasses

        if current.contains(featureClass) {
            current.remove(featureClass)
        } else {
            current.insert(featureClass)
        }

        selectedFeatureClasses = current
        objectWillChange.send()
    }

    func displayName(for featureClass: String) -> String {
        FeatureClassMapper.displayName(for: featureClass)
    }

    private func score(for feature: GISFeature, heading: Double) -> Double {
        let bearingPenalty = headingDifference(feature.bearingDegrees, heading) * 2.5
        let distancePenalty = feature.distanceMiles * 4.0
        return 1000 - bearingPenalty - distancePenalty
    }

    private func headingDifference(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b).truncatingRemainder(dividingBy: 360)
        return min(diff, 360 - diff)
    }
}
