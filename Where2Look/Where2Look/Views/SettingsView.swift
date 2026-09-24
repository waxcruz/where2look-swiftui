import SwiftUI

struct SettingsView: View {

    @AppStorage("volume") private var volume: Double = 0.5

    // 🔧 Proximity settings (added)
    @AppStorage("proximitySensitivity") private var proximitySensitivity: Double = 0.003
    @AppStorage("useDistanceAdaptiveSensitivity") private var useDistanceAdaptiveSensitivity: Bool = true
    @AppStorage("useHaptics") private var useHaptics: Bool = false

    var body: some View {
        Form {

            Section(header: Text("Audio")) {

                VStack(alignment: .leading) {
                    HStack {
                        Text("Volume")
                        Spacer()
                        Text("\(Int(volume * 100))%")
                            .foregroundStyle(.secondary)
                    }

                    Slider(value: $volume, in: 0...1)
                }
                .padding(.vertical, 4)
            }

            // 🔥 New Section (Proximity Feedback)
            Section(header: Text("Proximity Feedback")) {

                Toggle("Distance Adaptive Sensitivity", isOn: $useDistanceAdaptiveSensitivity)

                VStack(alignment: .leading) {
                    HStack {
                        Text("Sensitivity")
                        Spacer()
                        Text(String(format: "%.4f", proximitySensitivity))
                            .foregroundStyle(.secondary)
                    }

                    Slider(value: $proximitySensitivity, in: 0.001...0.02, step: 0.001)
                        .disabled(useDistanceAdaptiveSensitivity)
                }
                .padding(.vertical, 4)

                Toggle("Haptic Feedback", isOn: $useHaptics)
            }
        }
        .navigationTitle("Settings")
    }
}
