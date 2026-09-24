import SwiftUI

struct ResultsListView: View {
    @ObservedObject var viewModel: NearbyFeaturesViewModel
    @ObservedObject var navigationService: NavigationService

    let searchText: String
    let onSelect: (GISFeature) -> Void

    @State private var internalSearchText = ""
    @FocusState private var isSearchFocused: Bool

    private var filteredFeatures: [GISFeature] {
        let text = internalSearchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if text.isEmpty {
            return viewModel.sortedFeatures
        }

        return viewModel.sortedFeatures.filter { feature in
            matches(feature, searchText: text)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar

            ScrollView {
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    Section(header: resultsHeader) {
                        if filteredFeatures.isEmpty {
                            Text("No nearby features matched your search.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding()
                        } else {
                            ForEach(filteredFeatures) { feature in
                                let isSelected = navigationService.selectedFeature?.id == feature.id
                                let isLocked = navigationService.lockedFeature?.id == feature.id

                                Button {
                                    isSearchFocused = false
                                    onSelect(feature)
                                } label: {
                                    HStack(spacing: 12) {
                                        FeatureRowView(
                                            feature: feature,
                                            isLikelyMatch: viewModel.isLikelyMatch(feature)
                                        )

                                        Spacer(minLength: 0)

                                        if isLocked {
                                            Image(systemName: "lock.fill")
                                                .foregroundStyle(.green)
                                        } else if isSelected {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.blue)
                                        }
                                    }
                                    .padding(8)
                                    .background(
                                        rowBackground(
                                            isSelected: isSelected,
                                            isLocked: isLocked
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }

    private var searchBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Results")
                    .font(.headline)

                Spacer()

                Text("\(filteredFeatures.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                TextField("Search feature results", text: $internalSearchText)
                    .textFieldStyle(.plain)
                    .focused($isSearchFocused)
                    .submitLabel(.done)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit {
                        isSearchFocused = false
                    }

                if !internalSearchText.isEmpty {
                    Button {
                        internalSearchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                if isSearchFocused {
                    Button("Done") {
                        isSearchFocused = false
                    }
                    .font(.subheadline)
                    .buttonStyle(.plain)
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    private var resultsHeader: some View {
        Color.clear.frame(height: 0)
    }

    private func matches(_ feature: GISFeature, searchText: String) -> Bool {
        feature.location.localizedCaseInsensitiveContains(searchText) ||
        feature.featureClass.localizedCaseInsensitiveContains(searchText) ||
        feature.featureClassDisplayName.localizedCaseInsensitiveContains(searchText) ||
        feature.formattedDistance.localizedCaseInsensitiveContains(searchText) ||
        feature.formattedBearing.localizedCaseInsensitiveContains(searchText) ||
        feature.formattedElevation.localizedCaseInsensitiveContains(searchText)
    }

    private func rowBackground(isSelected: Bool, isLocked: Bool) -> Color {
        if isLocked {
            return Color.green.opacity(0.15)
        }
        if isSelected {
            return Color.blue.opacity(0.12)
        }
        return Color(.secondarySystemBackground)
    }
}
