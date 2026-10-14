import SwiftUI
import PhotosUI

/// Wraps the chosen photo so it can be used as a navigation value.
struct PickedPhoto: Identifiable, Hashable {
    let id = UUID()
    let image: PlatformImage

    static func == (lhs: PickedPhoto, rhs: PickedPhoto) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

/// Screen 1: choose a photo and tap it to pick colours by hand.
struct CaptureView: View {
    private let maxPicked = 8

    @State private var pickerItem: PhotosPickerItem?
    @State private var image: PlatformImage?
    @State private var pickedHexes: [String] = []
    @State private var autoFill = true
    @State private var selectedPhoto: PickedPhoto?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacing) {
                    if let image {
                        photoCard(for: image)
                        eyedropperCard
                        extractButton(for: image)
                    } else {
                        emptyState
                    }
                    pickerButton
                }
                .padding()
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Capture")
            .overlay { if isLoading { ProgressView() } }
            .navigationDestination(item: $selectedPhoto) { photo in
                ResultView(image: photo.image,
                           pickedHexes: pickedHexes,
                           autoFill: autoFill)
            }
            .onChange(of: pickerItem) { _, newItem in loadImage(from: newItem) }
            .alert("Couldn't load photo",
                   isPresented: Binding(get: { errorMessage != nil },
                                        set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    // MARK: - Pieces of the screen

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "paintpalette")
                .font(.system(size: 56))
                .foregroundStyle(AppTheme.accent)
                .accessibilityHidden(true)
            Text("Turn any photo into a palette")
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
            Text("Pick a photo, then tap it to choose your own colours, or let ColorHub find them for you.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    private func photoCard(for image: PlatformImage) -> some View {
        Image(platformImage: image)
            .resizable()
            .aspectRatio(image.size, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
            .overlay {
                // Tap anywhere on the photo to add that exact colour.
                GeometryReader { proxy in
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            SpatialTapGesture().onEnded { value in
                                let x = value.location.x / proxy.size.width
                                let y = value.location.y / proxy.size.height
                                addColor(atX: x, y: y, in: image)
                            }
                        )
                }
            }
            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
            .accessibilityLabel("Selected photo. Tap to pick a colour.")
    }

    private var eyedropperCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your picked colours").font(.headline)
                Spacer()
                if !pickedHexes.isEmpty {
                    Button("Clear") {
                        withAnimation { pickedHexes.removeAll() }
                    }
                    .font(.subheadline)
                }
            }

            if pickedHexes.isEmpty {
                Text("Tap the photo to pick colours. Up to \(maxPicked).")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(pickedHexes.enumerated()), id: \.offset) { index, hex in
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 44, height: 44)
                                    .overlay(Circle().stroke(Color.secondary.opacity(0.4), lineWidth: 1))
                                Text(hex)
                                    .font(.caption2.monospaced())
                                    .foregroundStyle(.secondary)
                            }
                            .onTapGesture {
                                withAnimation { _ = pickedHexes.remove(at: index) }
                            }
                        }
                    }
                }
                Text("Tap a colour to remove it.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Toggle("Also fill with automatic colours", isOn: $autoFill)
                .font(.subheadline)
                .tint(AppTheme.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private func extractButton(for image: PlatformImage) -> some View {
        Button {
            selectedPhoto = PickedPhoto(image: image)
        } label: {
            Label("Extract palette", systemImage: "wand.and.stars")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(AppTheme.accent)
        .disabled(!autoFill && pickedHexes.isEmpty)
    }

    private var pickerButton: some View {
        PhotosPicker(selection: $pickerItem, matching: .images) {
            Label(image == nil ? "Choose a photo" : "Choose a different photo",
                  systemImage: "photo.on.rectangle")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .tint(AppTheme.accent)
    }

    // MARK: - Logic

    private func addColor(atX x: CGFloat, y: CGFloat, in image: PlatformImage) {
        guard pickedHexes.count < maxPicked,
              let color = ColorExtractor.color(atX: x, y: y, in: image) else { return }
        let hex = color.hexString
        guard !pickedHexes.contains(hex) else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            pickedHexes.append(hex)
        }
    }

    private func loadImage(from item: PhotosPickerItem?) {
        guard let item else { return }
        isLoading = true
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let loaded = PlatformImage(data: data) {
                    image = loaded.normalized()
                    pickedHexes = []
                } else {
                    errorMessage = "That photo couldn't be read. Please try another one."
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
