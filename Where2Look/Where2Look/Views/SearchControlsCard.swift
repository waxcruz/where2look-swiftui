//
//  SearchControlsCard.swift
//  Where2Look
//
//  Created by Bill Weatherwax on 3/30/26.
//

import SwiftUI
import CoreLocation
import Combine

struct SearchControlsCard: View {
    let location: CLLocation
    let locationService: LocationService
    @ObservedObject var viewModel: NearbyFeaturesViewModel
    @Binding var isExpanded: Bool
    let onSearch: () -> Void

    private let freshnessTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var now = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text("Nearby Search")
                    .font(.headline)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(positionSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(locationStatusSummary)
                    .font(.caption)
                    .foregroundStyle(locationStatusColor)

                Text(headingSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if isExpanded {
                VStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Distance")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(Int(viewModel.distanceLimitMiles)) mi")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Slider(value: $viewModel.distanceLimitMiles, in: 1...50, step: 1)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Min Elevation")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text(formattedAltitude(Int(viewModel.minElevation)) + " ft")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Slider(value: $viewModel.minElevation, in: 0...12000, step: 100)
                    }

                    HStack {
                        Spacer()

                        Button {
                            locationService.requestLocationThen {
                                onSearch()
                            }
                        } label: {
                            if viewModel.isLoading {
                                VStack(spacing: 4) {
                                    HStack(spacing: 6) {
                                        ProgressView()
                                            .controlSize(.mini)

                                        Text("Getting a fresh location…")
                                    }

                                    Text("This improves nearby feature accuracy.")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            } else {
                                Text("Search Nearby")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .disabled(viewModel.isLoading)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onReceive(freshnessTimer) { _ in
            now = Date()
        }
    }

    private var positionSummary: String {
        let lat = String(format: "%.3f", location.coordinate.latitude)
        let lon = String(format: "%.3f", location.coordinate.longitude)
        let alt = formattedAltitude(Int(location.altitude * 3.28084))

        return "Lat \(lat)  •  Lon \(lon)  •  Alt \(alt) ft"
    }

    private var locationStatusSummary: String {
        let accuracyFeet = Int(location.horizontalAccuracy * 3.28084)
        let freshness = locationFreshnessText

        return "GPS ±\(accuracyFeet) ft  •  \(freshness)"
    }

    private var locationStatusColor: Color {
        guard let timestamp = locationService.lastLocationTimestamp else {
            return .secondary
        }

        let age = now.timeIntervalSince(timestamp)

        switch age {
        case ..<30:
            return .green
        case ..<120:
            return .orange
        default:
            return .red
        }
    }

    private var locationFreshnessText: String {
        guard let timestamp = locationService.lastLocationTimestamp else {
            return "stale"
        }

        let age = Int(now.timeIntervalSince(timestamp))

        switch age {
        case ..<15:
            return "fresh"
        case ..<60:
            return "\(age)s old"
        case ..<300:
            return "\(age / 60)m old"
        default:
            return "stale"
        }
    }

    private var headingSummary: String {
        guard let heading = locationService.currentHeading?.trueHeading,
              heading >= 0 else {
            return "Heading unavailable"
        }

        return "Heading \(Int(heading))°"
    }

    private func formattedAltitude(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
