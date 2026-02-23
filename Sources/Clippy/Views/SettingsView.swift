import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)

            HStack {
                Text("Max item size:")
                Picker("", selection: $settings.maxItemSize) {
                    ForEach(SettingsStore.itemSizeOptions, id: \.value) { option in
                        Text(option.label).tag(option.value)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 120)
            }

            HStack {
                Text("Max total size:")
                Picker("", selection: $settings.maxTotalSize) {
                    ForEach(SettingsStore.totalSizeOptions, id: \.value) { option in
                        Text(option.label).tag(option.value)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 120)
            }
        }
        .padding()
        .frame(width: 260)
    }
}
