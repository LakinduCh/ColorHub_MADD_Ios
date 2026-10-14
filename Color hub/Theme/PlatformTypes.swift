import SwiftUI
#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
typealias PlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
typealias PlatformColor = NSColor
#endif

// MARK: - Image helpers

extension PlatformImage {
    /// Cross-platform access to the underlying CGImage.
    var cgImageRepresentation: CGImage? {
        #if canImport(UIKit)
        return cgImage
        #else
        return cgImage(forProposedRect: nil, context: nil, hints: nil)
        #endif
    }

    /// Cross-platform JPEG data (UIImage.jpegData doesn't exist on macOS).
    func jpegDataRepresentation(compressionQuality: CGFloat) -> Data? {
        #if canImport(UIKit)
        return jpegData(compressionQuality: compressionQuality)
        #else
        guard let tiff = tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff) else { return nil }
        return rep.representation(using: .jpeg,
                                  properties: [.compressionFactor: compressionQuality])
        #endif
    }
}

extension Image {
    init(platformImage: PlatformImage) {
        #if canImport(UIKit)
        self.init(uiImage: platformImage)
        #else
        self.init(nsImage: platformImage)
        #endif
    }
}

// MARK: - Colour helpers

extension Color {
    init(platformColor: PlatformColor) {
        #if canImport(UIKit)
        self.init(uiColor: platformColor)
        #else
        self.init(nsColor: platformColor)
        #endif
    }
}

extension PlatformColor {
    convenience init(hexValue: UInt32) {
        self.init(red: CGFloat((hexValue >> 16) & 0xFF) / 255,
                  green: CGFloat((hexValue >> 8) & 0xFF) / 255,
                  blue: CGFloat(hexValue & 0xFF) / 255,
                  alpha: 1)
    }

    /// The colour as a hex string like "#FF8800".
    var hexString: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        #if canImport(UIKit)
        getRed(&r, green: &g, blue: &b, alpha: &a)
        #else
        guard let rgb = usingColorSpace(.sRGB) else { return "#000000" }
        rgb.getRed(&r, green: &g, blue: &b, alpha: &a)
        #endif
        return String(format: "#%02X%02X%02X",
                      Int(round(r * 255)), Int(round(g * 255)), Int(round(b * 255)))
    }
}

// MARK: - View helpers

extension View {
    /// Inline navigation title on iOS; does nothing on macOS (where the API doesn't exist).
    func inlineNavigationTitle() -> some View {
        #if os(iOS)
        return self.navigationBarTitleDisplayMode(.inline)
        #else
        return self
        #endif
    }
}
