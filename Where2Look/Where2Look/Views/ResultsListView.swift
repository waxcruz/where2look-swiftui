import SwiftUI

struct ResultsListView: View {
    @ObservedObject var viewModel: NearbyFeaturesViewModel
    @State private var isFiltersExpanded = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

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
                            Picker("Sort", selection: $viewModel.sortOption) {
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

                // Results Header
                HStack {
                    Text("Results")
                        .font(.headline)

                    Spacer()

                    Text("\(viewModel.sortedFeatures.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if viewModel.sortedFeatures.isEmpty {
                    Text("No nearby features found.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
}
