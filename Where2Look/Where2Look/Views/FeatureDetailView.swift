import SwiftUI

struct FeatureDetailView: View {
    let feature: GISFeature
    @ObservedObject var navigationService: NavigationService

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            Text(feature.location)
                .font(.largeTitle)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 10) {
                Text("Type: \(feature.featureClassDisplayName)")
                Text("Distance: \(feature.formattedDistance)")
                Text("Bearing: \(feature.formattedBearing)")
                Text("Elevation: \(feature.formattedElevation)")
            }
            .font(.body)

            Divider()

            if navigationService.lockedFeature?.id == feature.id {
                Button("Unlock Target") {
                    navigationService.unlock()
                }
                .buttonStyle(.borderedProminent)

            } else {
                Button("Lock & Navigate") {
                    navigationService.selectedFeature = feature
                    navigationService.lockSelected()
                }
                .buttonStyle(.borderedProminent)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Feature")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            navigationService.selectedFeature = feature
        }
    }
}
