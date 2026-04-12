import SwiftUI
import CoreLocation
import Combine

struct SearchControlsCard: View {
    let location: CLLocation
    let locationService: LocationService
    @ObservedObject var viewModel: NearbyFeaturesViewModel
    @Binding var isExpanded: Bool
    let onSearch: () -> Void

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
                    .foregroundStyle(.secondary)

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

                        Button("Search Nearby") {
                            onSearch()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var positionSummary: String {
        let lat = String(format: "%.3f", location.coordinate.latitude)
        let lon = String(format: "%.3f", location.coordinate.longitude)
        let alt = formattedAltitude(Int(location.altitude * 3.28084))

        return "Lat \(lat)  •  Lon \(lon)  •  Alt \(alt) ft"
    }

    private var locationStatusSummary: String {
        let accuracyFeet = Int(location.horizontalAccuracy * 3.28084)
        return "GPS ±\(accuracyFeet) ft"
    }

    private var headingSummary: String {
        let heading = locationService.heading

        guard heading >= 0 else {
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
