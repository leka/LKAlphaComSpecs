// swift-tools-version:4.2
// Managed by ice

import PackageDescription

let package = Package(

    name: "LKAlphaComSpecs",

    products: [
        .library(name: "LKAlphaComSpecs", targets: ["LKAlphaComSpecs"]),
    ],

    targets: [

        .target(name: "LKAlphaComSpecs", dependencies: [], path: "Sources", exclude: ["LKAlphaComSpecs.h"]),
        .testTarget(name: "LKAlphaComSpecsTests", dependencies: ["LKAlphaComSpecs"]),

    ]

)
