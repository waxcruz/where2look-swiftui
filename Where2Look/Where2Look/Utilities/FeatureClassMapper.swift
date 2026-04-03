//
//  FeatureClassMapper.swift
//  Where2Look
//
//  Created by Bill Weatherwax on 3/30/26.
//


struct FeatureClassMapper {
    static func displayName(for code: String) -> String {
        switch code.uppercased() {
        case "A": return "Area"
        case "H": return "Historic / Landmark"
        case "L": return "Lake"
        case "P": return "Place"
        case "R": return "Ridge"
        case "S": return "Summit"
        case "T": return "Trail"
        case "U": return "Tunnel"
        case "V": return "Valley"
        default: return "Other"
        }
    }
}
