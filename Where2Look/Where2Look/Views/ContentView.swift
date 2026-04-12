import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var viewModel = NearbyFeaturesViewModel()
    @StateObject private var locationService = LocationService()
    @StateObject private var navigationService = NavigationService()

    @State private var isSearchExpanded = false
    @State private var searchText = ""

    // ✅ Navigation source of truth
    @State private var selectedFeatureForNav: GISFeature?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopBarView()

                // 🔒 Locked target indicator only
                if let locked = navigationService.lockedFeature {
                    Text("Locked: \(locked.location)")
                        .font(.headline)
                        .foregroundStyle(.green)
                        .padding(.top, 4)
                }

                if let location = locationService.location {
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

                    ResultsListView(
                        viewModel: viewModel,
                        navigationService: navigationService,
                        searchText: searchText,
                        onSelect: { feature in
                            print("🔥 CONTENT VIEW SELECTED:", feature.location)
                            selectedFeatureForNav = feature
                        }
                    )
                    .searchable(text: $searchText, prompt: "Search features")

                } else {
                    Spacer()
                    ProgressView("Getting your location...")
                    Spacer()
                }
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                navigationService.start(locationService: locationService)
            }

            // ✅ Navigation happens HERE only
            .navigationDestination(item: $selectedFeatureForNav) { feature in
                FeatureDetailView(
                    feature: feature,
                    navigationService: navigationService
                )
            }

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }

    private func reload(for location: CLLocation) {
        let heading = locationService.heading
        let usableHeading = heading >= 0 ? heading : nil

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
