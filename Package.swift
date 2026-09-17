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
//
// As of 1.0.3, DCAdSDKCore also dynamically links OMSDK_Digitalcamp (IAB's
// Open Measurement SDK, self-certified/rebuilt under a "Digitalcamp"
// namespace -- confirmed via `otool -L` on the compiled binary). Unlike
// GoogleMobileAds this has no public package source, so it's vendored the
// same way as DCAdSDKCore itself: hosted as its own xcframework zip and
// added as a second binaryTarget dependency of the wrapper, so consumers
// get it linked/embedded transitively without a manual package addition.

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
            url: "https://app.digitalcamp.co.kr/ios/DCAdSDK-1.0.3-omid-test.xcframework.zip",
            checksum: "95ce68faa0610378f427f5d6ef9e33fcf4a61c8c92f1ad9f052353826044dfaa"
        ),
        .binaryTarget(
            name: "OMSDK_Digitalcamp",
            url: "https://app.digitalcamp.co.kr/ios/OMSDK_Digitalcamp-1.6.10.xcframework.zip",
            checksum: "5707e3a605dc5e9b862eedc5d3dee54ae283b6b8dcbc6d400328b031dea46153"
        ),
        .target(
            name: "DCAdSDK",
            dependencies: [
                "DCAdSDKCore",
                "OMSDK_Digitalcamp",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
            ]
        )
    ]
)
