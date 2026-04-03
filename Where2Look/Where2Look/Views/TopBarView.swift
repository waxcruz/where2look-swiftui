import SwiftUI

struct TopBarView: View {

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            appIcon

            VStack(alignment: .leading, spacing: 2) {
                Text("Where2Look")
                    .font(.headline)
                    .fontWeight(.bold)

                Text("Nearby named features")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private var appIcon: some View {
        if UIImage(named: "NavIcon") != nil {
            Image("NavIcon")
                .resizable()
                .interpolation(.high)
                .frame(width: 34, height: 34)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 1)
        } else {
            Image(systemName: "location.north.circle.fill")
                .font(.system(size: 30))
                .foregroundStyle(.blue)
        }
    }
}
