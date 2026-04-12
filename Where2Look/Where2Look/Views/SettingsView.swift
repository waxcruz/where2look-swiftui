import SwiftUI

struct SettingsView: View {

    @AppStorage("volume") private var volume: Double = 0.5

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
        }
        .navigationTitle("Settings")
    }
}
