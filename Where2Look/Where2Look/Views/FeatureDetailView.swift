import SwiftUI
import CoreLocation
import Combine

struct FeatureDetailView: View {
    let feature: GISFeature
    @ObservedObject var navigationService: NavigationService

    @StateObject private var locationService = LocationService()

    @State private var displayDelta: Double = 0
    @State private var alignmentDelta: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            Text(feature.location)
                .font(.largeTitle)
                .fontWeight(.semibold)

            if navigationService.lockedFeature?.id == feature.id {
                VStack(alignment: .leading, spacing: 10) {

                    Text("Heading Alignment")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ZStack {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 180, height: 180)

                        // Dial ring: green at top, yellow on the shoulders, red toward bottom
                        Circle()
                            .stroke(
                                AngularGradient(
                                    stops: [
                                        .init(color: .green,  location: 0.00),
                                        .init(color: .green,  location: 0.06),
                                        .init(color: .yellow, location: 0.12),
                                        .init(color: .red,    location: 0.22),
                                        .init(color: .red,    location: 0.78),
                                        .init(color: .yellow, location: 0.88),
                                        .init(color: .green,  location: 0.94),
                                        .init(color: .green,  location: 1.00)
                                    ],
                                    center: .center,
                                    startAngle: .degrees(-90),
                                    endAngle: .degrees(270)
                                ),
                                style: StrokeStyle(lineWidth: 16, lineCap: .butt)
                            )
                            .frame(width: 180, height: 180)
                            .rotationEffect(.degrees(-displayDelta))
                            .animation(.easeOut(duration: 0.15), value: displayDelta)

                        // Fixed top target marker
                        Triangle()
                            .fill(Color.primary)
                            .frame(width: 14, height: 14)
                            .offset(y: -90)

                        // Fixed needle
                        Rectangle()
                            .fill(Color.primary)
                            .frame(width: 4, height: 80)
                            .offset(y: -40)

                        // Center status dot based on live alignment
                        Circle()
                            .fill(alignmentColor)
                            .frame(width: 16, height: 16)
                    }
                    .frame(height: 200)
                }
            }

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
                    resetDial()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Lock & Navigate") {
                    navigationService.selectedFeature = feature
                    navigationService.lockSelected()
                    resetDial()
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
            updateHeading()
        }
        .onReceive(locationService.$heading) { _ in
            guard navigationService.lockedFeature?.id == feature.id else { return }
            updateHeading()
        }
    }

    // MARK: - Heading Logic

    private func updateHeading() {
        let heading = locationService.heading
        guard heading >= 0 else { return }

        let rawDelta = signedHeadingDeltaDegrees(from: heading, to: feature.bearingDegrees)
        alignmentDelta = rawDelta

        let diff = shortestAngleDelta(from: displayDelta, to: rawDelta)
        displayDelta += diff * 0.2
    }

    private func resetDial() {
        displayDelta = 0
        alignmentDelta = 0
    }

    private func signedHeadingDeltaDegrees(from currentHeading: Double, to targetBearing: Double) -> Double {
        (targetBearing - currentHeading + 540)
            .truncatingRemainder(dividingBy: 360) - 180
    }

    private func shortestAngleDelta(from: Double, to: Double) -> Double {
        var delta = to - from
        while delta > 180 { delta -= 360 }
        while delta < -180 { delta += 360 }
        return delta
    }

    private var alignmentColor: Color {
        let magnitude = abs(alignmentDelta)

        if magnitude < 10 {
            return .green
        } else if magnitude < 30 {
            return .yellow
        } else {
            return .red
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
