import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var viewModel = NearbyFeaturesViewModel()
    @StateObject private var locationService = LocationService()
    @State private var isSearchExpanded = false


    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopBarView()

                if let location = locationService.currentLocation {
                    SearchControlsCard(
                        location: location,
                        locationService: locationService,
                        viewModel: viewModel,
                        isExpanded: $isSearchExpanded,
                        onSearch: {
                            reload(for: location)
                        }
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)

                    Divider()
                        .padding(.top, 8)

                    ResultsListView(viewModel: viewModel)
                } else {
                    Spacer()
                    ProgressView("Getting your location...")
                    Spacer()
                }
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                locationService.requestAccess()
            }
        }
    }
    
    private func reload(for location: CLLocation) {
        let heading = locationService.currentHeading?.trueHeading
        let usableHeading = (heading ?? -1) >= 0 ? heading : nil
        viewModel.loadNearbyFeatures(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            headingDegrees: usableHeading
        )
    }
}

#Preview {
    ContentView()
}
