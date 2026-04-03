import SwiftUI

struct FeatureRowView: View {
    let feature: GISFeature
    let isLikelyMatch: Bool

    var body: some View {
        NavigationLink(destination: FeatureDetailView(feature: feature)) {
            VStack(alignment: .leading, spacing: 6) {
                Text(feature.location)
                    .font(.headline)

                HStack(spacing: 14) {
                    Text(feature.featureClassDisplayName)
                    Text(feature.formattedDistance)
                    Text(feature.formattedBearing)
                    Text(feature.formattedElevation)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .contentShape(Rectangle())
        }
    }

    private var cardBackground: Color {
        isLikelyMatch
            ? Color.green.opacity(0.08)
            : Color(.secondarySystemGroupedBackground)
    }
}
