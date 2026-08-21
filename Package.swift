// swift-tools-version:5.9
import PackageDescription

// Binary distribution manifest for DCAdSDK. The `DCAdSDKBinary` binary
// target resolves to a precompiled .xcframework hosted on our own server --
// this repo only carries this small manifest + version tags, which is what
// SPM's dependency resolution is built around; the actual SDK implementation
// stays private. See the internal dc_sdk monorepo's DCAdSDK/VENDOR_GUIDE.md
// for integration instructions and DCAdSDK/Scripts/build-xcframework.sh for
// how each release's .xcframework is produced.
//
// `DCAdSDK` is a thin re-export target rather than exposing the binaryTarget
// directly, purely so it can declare the GoogleMobileAds dependency (a
// binaryTarget by itself can't declare `dependencies`) -- this keeps SPM
// pulling GoogleMobileAds in automatically for consumers, same as before
// this SDK was distributed as a binary.

let package = Package(
    name: "DCAdSDK",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "DCAdSDK", targets: ["DCAdSDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "11.0.0")
    ],
    targets: [
        .binaryTarget(
            name: "DCAdSDKBinary",
            url: "https://app.digitalcamp.co.kr/ios/DCAdSDK-1.0.0.xcframework.zip",
            checksum: "1a32818dd546a4eacef7e5982e7c20c9d4cd1487820f42f51c6efe9c96f091be"
        ),
        .target(
            name: "DCAdSDK",
            dependencies: [
                "DCAdSDKBinary",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
            ]
        )
    ]
)
