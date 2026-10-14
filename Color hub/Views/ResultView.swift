import SwiftUI
import SwiftData

/// Screen 2: shows the palette and tags, and lets the user save it.
struct ResultView: View {
    let image: PlatformImage
    var pickedHexes: [String] = []
    var autoFill: Bool = true

    @Environment(\.modelContext) private var modelContext

    @State private var hexColors: [String] = []
    @State private var tags: [String] = []
    @State private var isAnalysing = true
    @State private var paletteName = ""
    @State private var saved = false
    @State private var showSaveError = false
    @State private var copiedHex: String?

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacing) {
                Image(platformImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                    .accessibilityLabel("Your photo")

                paletteCard
                tagsCard
                saveCard
            }
            .padding()
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Your Palette")
        .inlineNavigationTitle()
        .task { await analyse() }
        .copyToast($copiedHex)
        .sensoryFeedback(.success, trigger: saved)
        .alert("Couldn't save palette", isPresented: $showSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Something went wrong while saving. Please try again.")
        }
    }

    // MARK: - Pieces of the screen

    private var paletteCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Palette").font(.headline)
            if hexColors.isEmpty {
                if isAnalysing {
                    ProgressView("Finding colours…")
                        .frame(maxWidth: .infinity)
                } else {
                    Text("No colours could be found in this photo.")
                        .foregroundStyle(.secondary)
                }
            } else {
                PaletteStrip(hexColors: hexColors,
                             height: 88,
                             animated: true,
                             showLabels: true,
                             onCopy: { hex in copyHex(hex, showing: $copiedHex) })
                Text("Long-press a swatch to copy its hex code.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var tagsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What's in the photo").font(.headline)
            if tags.isEmpty {
                Text(isAnalysing ? "Looking…" : "No tags found for this photo.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                TagChips(tags: tags)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var saveCard: some View {
        VStack(spacing: 12) {
            TextField("Name this palette", text: $paletteName)
                .textFieldStyle(.roundedBorder)

            Button(action: save) {
                Label(saved ? "Saved to Library" : "Save to Library",
                      systemImage: saved ? "checkmark.circle.fill" : "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(AppTheme.accent)
            .disabled(saved || hexColors.isEmpty)
        }
        .cardStyle()
    }

    // MARK: - Logic

    /// Your picked colours come first. Automatic colours fill the rest (up to 5 total) if enabled.
    private func analyse() async {
        guard hexColors.isEmpty else { return }
        isAnalysing = true

        let autoCount = autoFill ? max(0, 5 - pickedHexes.count) : 0
        var extracted: [String] = []
        if autoCount > 0 {
            extracted = ColorExtractor.dominantColors(from: image, count: autoCount).map(\.hexString)
            extracted.removeAll { pickedHexes.contains($0) }
        }
        hexColors = pickedHexes + extracted

        tags = await ImageTagger.tags(for: image)
        isAnalysing = false
    }

    private func save() {
        let trimmed = paletteName.trimmingCharacters(in: .whitespaces)
        let name = trimmed.isEmpty
            ? "Palette \(Date.now.formatted(date: .abbreviated, time: .shortened))"
            : trimmed
        let thumbnail = image.normalized(maxSide: 600).jpegDataRepresentation(compressionQuality: 0.7)

        modelContext.insert(SavedPalette(name: name, hexColors: hexColors, tags: tags, imageData: thumbnail))
        do {
            try modelContext.save()
            saved = true
        } catch {
            showSaveError = true
        }
    }
}
