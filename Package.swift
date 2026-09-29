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
//
// As of 1.0.5, AdMob support moved OUT of DCAdSDKCore entirely, into its own
// binaryTarget (DCAdSDKAdMob), because GoogleMobileAds performs its own
// launch-time check of Info.plist's GADApplicationIdentifier and crashes the
// process if it's missing -- confirmed live 2026-09-29 that this fires
// automatically shortly after launch merely from GoogleMobileAds being linked
// into the process, entirely independent of whether any of DCAdSDKCore's own
// code ever calls a GoogleMobileAds API. There was no way to make that key
// truly optional while GoogleMobileAds stayed linked into DCAdSDKCore, so two
// products are offered instead:
//   - "DCAdSDK" (same name as before): DCAdSDKCore + DCAdSDKAdMob +
//     GoogleMobileAds, same feature set as pre-1.0.5, but now requires an
//     explicit `DCAdSDKAdMob.activate()` call once at launch -- Swift
//     disallows overriding `+load`/`+initialize` ("which is not permitted by
//     Swift"), so unlike the old single-binary SDK this can't happen
//     automatically just from linking the package.
//   - "DCAdSDKCoreOnly": DCAdSDKCore alone, no GoogleMobileAds at all, no
//     GADApplicationIdentifier requirement, no activate() call. Always falls
//     back to the SSP/VAST ad server, even for AdMob-priority zones.
// DCAdSDKAdMob depends on DCAdSDKCore as a genuine cross-package dependency
// (not a second target in the same package as DCAdSDKCore) specifically
// because same-package target dependencies get statically inlined by
// `xcodebuild archive` regardless of the dependency's own declared library
// type -- confirmed via `nm` (a same-package attempt produced a DCAdSDKAdMob
// binary containing a full duplicate copy of every DCAdSDKCore symbol).

let package = Package(
    name: "DCAdSDK",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "DCAdSDK", targets: ["DCAdSDK"]),
        .library(name: "DCAdSDKCoreOnly", targets: ["DCAdSDKCoreOnly"])
    ],
    dependencies: [
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "11.0.0")
    ],
    targets: [
        .binaryTarget(
            name: "DCAdSDKCore",
            url: "https://app.digitalcamp.co.kr/ios/DCAdSDK-1.0.5.xcframework.zip",
            checksum: "5a6f62ce8167d121d20d3ad0b497fbc0fb5d3e8e334e41f16793533b0c14323a"
        ),
        .binaryTarget(
            name: "DCAdSDKAdMob",
            url: "https://app.digitalcamp.co.kr/ios/DCAdSDKAdMob-1.0.5.xcframework.zip",
            checksum: "8e8080ce78a441dfa85e079bda1dab00a0628ff9347bcfe8dcebf2bb38f3db2e"
        ),
        .binaryTarget(
            name: "OMSDK_Digitalcamp",
            url: "https://app.digitalcamp.co.kr/ios/OMSDK_Digitalcamp-1.6.10.xcframework.zip",
            checksum: "5707e3a605dc5e9b862eedc5d3dee54ae283b6b8dcbc6d400328b031dea46153"
        ),
        .target(
            name: "DCAdSDKCoreOnly",
            dependencies: ["DCAdSDKCore", "OMSDK_Digitalcamp"]
        ),
        .target(
            name: "DCAdSDK",
            dependencies: [
                "DCAdSDKCore",
                "OMSDK_Digitalcamp",
                "DCAdSDKAdMob",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
            ]
        )
    ]
)
