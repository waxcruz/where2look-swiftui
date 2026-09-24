import SwiftUI
import CoreLocation
import Combine

struct SearchControlsCard: View {
    let location: CLLocation
    let locationService: LocationService
    @ObservedObject var viewModel: NearbyFeaturesViewModel
    @Binding var isExpanded: Bool
    let onSearch: () -> Void

    @State private var isFeatureTypesExpanded = false
    @State private var isSortExpanded = false

    private let featureColumns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            statusBlock

            if isExpanded {
                expandedContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            if !viewModel.selectedFeatureClasses.isEmpty {
                isFeatureTypesExpanded = true
            }

            if viewModel.sortOption != .distance || viewModel.sortOrder != .ascending {
                isSortExpanded = true
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Nearby Search")
                .font(.headline)

            Spacer()

            if viewModel.hasActiveFilters {
                Text("Filters active")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

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
    }

    private var statusBlock: some View {
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
    }

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            distanceSection
            elevationSection

            actionRow

            featureTypesSection

            directionSection

            sortSection
        }
    }

    private var distanceSection: some View {
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
    }

    private var elevationSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Min Elevation")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(formattedAltitude(Int(viewModel.minElevation))) ft")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Slider(value: $viewModel.minElevation, in: 0...12000, step: 100)
        }
    }

    private var actionRow: some View {
        HStack {
            Button("Reset") {
                viewModel.resetFilters()
            }
            .buttonStyle(.bordered)

            Spacer()

            Button("Search Nearby") {
                onSearch()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.top, 2)
    }

    private var featureTypesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isFeatureTypesExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Feature Types")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    featureTypeSummary

                    Image(systemName: isFeatureTypesExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isFeatureTypesExpanded {
                LazyVGrid(columns: featureColumns, alignment: .leading, spacing: 8) {
                    ForEach(viewModel.availableFeatureClasses, id: \.self) { featureClass in
                        let isSelected = viewModel.selectedFeatureClasses.contains(featureClass)

                        Button {
                            viewModel.toggleFeatureClass(featureClass)
                        } label: {
                            Text(viewModel.displayName(for: featureClass))
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .padding(.horizontal, 6)
                                .background(
                                    isSelected
                                    ? Color.blue.opacity(0.18)
                                    : Color(.tertiarySystemGroupedBackground)
                                )
                                .foregroundStyle(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var featureTypeSummary: some View {
        if !viewModel.selectedFeatureClasses.isEmpty {
            Text("\(viewModel.selectedFeatureClasses.count) selected")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var directionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Filter by current heading", isOn: $viewModel.isDirectionFilterEnabled)

            if viewModel.isDirectionFilterEnabled {
                HStack {
                    Text("Heading tolerance")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    Text("\(Int(viewModel.headingToleranceDegrees))°")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Slider(value: $viewModel.headingToleranceDegrees, in: 1...45, step: 1)
            }
        }
    }

    private var sortSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isSortExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Sort Options")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    Text("\(viewModel.sortOption.rawValue) • \(viewModel.sortOrder.rawValue)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Image(systemName: isSortExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isSortExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Sort By")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Picker("Sort By", selection: Binding(
                        get: { viewModel.sortOption },
                        set: { viewModel.sortOption = $0 }
                    )) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text("Sort Order")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Picker("Sort Order", selection: Binding(
                        get: { viewModel.sortOrder },
                        set: { viewModel.sortOrder = $0 }
                    )) {
                        ForEach(SortOrder.allCases, id: \.self) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
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
