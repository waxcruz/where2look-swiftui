import Foundation

struct SearchRequest {
    var nameQuery: String = ""
    var distanceLimitMiles: Double = 25
    var minElevation: Double = 0
    var currentLatitude: Double
    var currentLongitude: Double
    var selectedFeatureClasses: Set<String> = ["T"]
    var headingDegrees: Double? = nil
    var headingToleranceDegrees: Double = 10
    var resultLimit: Int = 100
    var useHeadingFilter: Bool = false
}

