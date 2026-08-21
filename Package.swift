// swift-tools-version:5.9
import PackageDescription

// Binary distribution manifest for DCAdSDK. This repo carries only this
// small manifest + version tags -- the actual .xcframework is hosted at
// app.digitalcamp.co.kr, which is what SPM downloads and verifies against
// the checksum below. See the internal dc_sdk monorepo's
// DCAdSDK/VENDOR_GUIDE.md for integration instructions and
// DCAdSDK/Scripts/build-xcframework.sh for how each release is produced.
//
// Consumers must also add GoogleMobileAds as a separate package dependency
// (see VENDOR_GUIDE.md step 1) -- a binaryTarget can't declare
// `dependencies`, so this can't be pulled in automatically the way a
// source target could.

let package = Package(
    name: "DCAdSDK",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "DCAdSDK", targets: ["DCAdSDK"])
    ],
    targets: [
        .binaryTarget(
            name: "DCAdSDK",
            url: "https://app.digitalcamp.co.kr/ios/DCAdSDK-1.0.0.xcframework.zip",
            checksum: "1a32818dd546a4eacef7e5982e7c20c9d4cd1487820f42f51c6efe9c96f091be"
        )
    ]
)
