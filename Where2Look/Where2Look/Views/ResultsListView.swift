import SwiftUI

struct ResultsListView: View {
    @ObservedObject var viewModel: NearbyFeaturesViewModel
    @ObservedObject var navigationService: NavigationService

    let searchText: String
    let onSelect: (GISFeature) -> Void

    private var filteredFeatures: [GISFeature] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return viewModel.sortedFeatures
        }

        return viewModel.sortedFeatures.filter {
            $0.location.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                HStack {
                    Text("Results")
                        .font(.headline)

                    Spacer()

                    Text("\(filteredFeatures.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if filteredFeatures.isEmpty {
                    Text("No nearby features matched your search.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)

                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(filteredFeatures) { feature in
                            let isSelected = navigationService.selectedFeature?.id == feature.id
                            let isLocked = navigationService.lockedFeature?.id == feature.id

                            Button {
                                print("TAPPED:", feature.location)
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
                                .background(rowBackground(isSelected: isSelected, isLocked: isLocked))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding()
        }
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
