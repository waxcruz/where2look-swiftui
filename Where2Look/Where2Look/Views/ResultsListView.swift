//
//  ResultsListView.swift
//  Where2Look
//
//  Created by Bill Weatherwax on 3/30/26.
//

import SwiftUI

struct ResultsListView: View {
    @ObservedObject var viewModel: NearbyFeaturesViewModel
    @State private var isFiltersExpanded = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                if viewModel.hasSearched {
                    // Result Filters Header
                    HStack {
                        Text("Result Filters")
                            .font(.headline)

                        Spacer()

                        if isFiltersExpanded && viewModel.hasActiveFilters {
                            Button("Reset") {
                                viewModel.resetFilters()
                            }
                            .font(.subheadline)
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                        }

                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isFiltersExpanded.toggle()
                            }
                        } label: {
                            Image(systemName: isFiltersExpanded ? "chevron.up" : "chevron.down")
                                .foregroundStyle(.secondary)
                        }
                    }

                    if isFiltersExpanded {
                        VStack(alignment: .leading, spacing: 16) {

                            // Feature Class Filters
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(viewModel.availableFeatureClasses, id: \.self) { featureClass in
                                        let isSelected = viewModel.selectedFeatureClasses.contains(featureClass)

                                        Button {
                                            viewModel.toggleFeatureClass(featureClass)
                                        } label: {
                                            Text(viewModel.displayName(for: featureClass))
                                                .font(.subheadline)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(
                                                    isSelected
                                                    ? Color.accentColor
                                                    : Color(.secondarySystemBackground)
                                                )
                                                .foregroundStyle(
                                                    isSelected
                                                    ? Color.white
                                                    : Color.primary
                                                )
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }

                            // Direction Filter Controls
                            VStack(alignment: .leading, spacing: 8) {
                                Toggle("Filter by direction", isOn: $viewModel.isDirectionFilterEnabled)

                                if viewModel.isDirectionFilterEnabled {
                                    HStack {
                                        Text("±\(Int(viewModel.headingToleranceDegrees))°")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)

                                        Slider(
                                            value: $viewModel.headingToleranceDegrees,
                                            in: 1...45,
                                            step: 1
                                        )
                                    }
                                }
                            }

                            // Sort Controls
                            HStack(spacing: 12) {
                                Picker("Sort", selection: Binding(
                                    get: { viewModel.sortOption },
                                    set: { viewModel.sortOption = $0 }
                                )) {
                                    ForEach(SortOption.allCases, id: \.self) {
                                        Text($0.rawValue)
                                    }
                                }
                                .pickerStyle(.segmented)

                                Button {
                                    viewModel.sortOrder = viewModel.sortOrder == .ascending ? .descending : .ascending
                                } label: {
                                    Image(systemName: viewModel.sortOrder == .ascending ? "arrow.up" : "arrow.down")
                                        .font(.headline)
                                }
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    Divider()
                        .padding(.vertical, 4)
                }

                // Results Header
                HStack {
                    Text("Results")
                        .font(.headline)

                    Spacer()

                    Text("\(viewModel.sortedFeatures.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if viewModel.hasSearched {
                    activeSearchSummary
                }

                if !viewModel.hasSearched {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Find nearby named features from your current location.")
                            .font(.subheadline)

                        Text("Open Nearby Search to begin.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                } else if viewModel.sortedFeatures.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("No nearby features matched your search settings.")
                            .font(.subheadline)

                        Text("Try increasing distance, lowering minimum elevation, or clearing result filters.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)

                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.sortedFeatures) { feature in
                            FeatureRowView(
                                feature: feature,
                                isLikelyMatch: viewModel.isLikelyMatch(feature)
                            )
                        }
                    }
                }
            }
            .padding()
            .animation(.easeInOut(duration: 0.2), value: viewModel.hasActiveFilters)
            .animation(.easeInOut(duration: 0.2), value: isFiltersExpanded)
        }
    }

    private var activeSearchSummary: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                summaryChip("\(Int(viewModel.distanceLimitMiles)) mi")
                summaryChip("\(formattedAltitude(Int(viewModel.minElevation))) ft+")

                if viewModel.isDirectionFilterEnabled {
                    summaryChip("±\(Int(viewModel.headingToleranceDegrees))°")
                }

                if !viewModel.selectedFeatureClasses.isEmpty {
                    ForEach(Array(viewModel.selectedFeatureClasses).sorted(), id: \.self) { featureClass in
                        summaryChip(viewModel.displayName(for: featureClass))
                    }
                } else {
                    summaryChip("All features")
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func summaryChip(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.secondarySystemBackground))
            .foregroundStyle(.secondary)
            .clipShape(Capsule())
    }

    private func formattedAltitude(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
