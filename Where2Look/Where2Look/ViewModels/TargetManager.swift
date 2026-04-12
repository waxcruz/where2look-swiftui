//
//  TargetManager.swift
//  Where2Look
//
//  Created by Bill Weatherwax on 4/12/26.
//


import Foundation
import MapKit
import SwiftUI
import Combine

class TargetManager: ObservableObject {
    @Published var searchResults: [MKMapItem] = []
    @Published var selectedPlace: MKMapItem? = nil
    @Published var lockedPlace: MKMapItem? = nil
    
    func selectPlace(_ place: MKMapItem) {
        selectedPlace = place
        print("Selected: \(place.name ?? "Unknown")")
    }
    
    func lockSelected() {
        guard let selected = selectedPlace else {
            print("No selection to lock")
            return
        }
        lockedPlace = selected
        print("LOCKED: \(selected.name ?? "Unknown")")
    }
    
    func unlock() {
        print("UNLOCKED")
        lockedPlace = nil
    }
}
