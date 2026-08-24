// swift-tools-version:5.9
import PackageDescription

// Binary distribution manifest for DCAdSDK. This repo carries only this
// small manifest + version tags -- the actual .xcframework is hosted at
// app.digitalcamp.co.kr, which is what SPM downloads and verifies against
// the checksum below. See the internal dc_sdk monorepo's
// DCAdSDK/VENDOR_GUIDE.md for integration instructions and
// DCAdSDK/Scripts/build-xcframework.sh for how each release is produced.
//
// The binaryTarget's real compiled module is named "DCAdSDKCore" (not
// "DCAdSDK") specifically so this file's "DCAdSDK" wrapper target can
// `@_exported import DCAdSDKCore` without colliding with its own module
// name -- see commit 396be4f for the earlier attempt that failed because
// both were named "DCAdSDK". The wrapper is an ordinary source target, so
// unlike a binaryTarget it CAN declare `dependencies`, which is how
// GoogleMobileAds is pulled in automatically for consumers instead of
// requiring a second manual package addition.

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
            name: "DCAdSDKCore",
            url: "https://app.digitalcamp.co.kr/ios/DCAdSDK-1.0.1.xcframework.zip",
            checksum: "4d372b73758ab88667c1c082bce833f3b6c27d5c57b4e5ec2e41d84bc1e2c959"
        ),
        .target(
            name: "DCAdSDK",
            dependencies: [
                "DCAdSDKCore",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
            ]
        )
    ]
)
