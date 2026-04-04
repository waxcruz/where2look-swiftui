//
//  LocationService.swift
//  Where2Look
//
//  Created by Bill Weatherwax on 3/30/26.
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationService: NSObject, ObservableObject {
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var currentHeading: CLHeading?
    @Published var errorMessage: String = ""

    @Published var lastLocationTimestamp: Date?
    @Published var lastHeadingTimestamp: Date?

    private let manager = CLLocationManager()
    private var pendingLocationRequest: (() -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.headingFilter = 1
    }

    func requestAccess() {
        authorizationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            start()

        case .restricted, .denied:
            errorMessage = "Location access is denied. Please enable it in Settings."

        @unknown default:
            break
        }
    }

    func start() {
        if CLLocationManager.headingAvailable() {
            manager.startUpdatingHeading()
        }

        requestSingleLocation()
    }

    func requestSingleLocation() {
        manager.requestLocation()
    }

    func requestLocationThen(_ action: @escaping () -> Void) {
        pendingLocationRequest = action
        manager.requestLocation()
    }

    func stop() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus

            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.start()

            case .restricted, .denied:
                self.errorMessage = "Location access is denied. Please enable it in Settings."

            case .notDetermined:
                break

            @unknown default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        Task { @MainActor in
            self.currentLocation = location
            self.lastLocationTimestamp = Date()

            if let action = self.pendingLocationRequest {
                self.pendingLocationRequest = nil
                action()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        Task { @MainActor in
            self.currentHeading = newHeading
            self.lastHeadingTimestamp = Date()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.errorMessage = error.localizedDescription
            self.pendingLocationRequest = nil
        }
    }
}
