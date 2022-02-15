// swift-tools-version:5.2.0

import PackageDescription

let package = Package(
	name: "xcpnc",
	platforms: [
		.macOS(.v10_10),
	],
	products: [
		.executable(name: "xcpnc", targets: ["xcpnc"])
	],
	dependencies: [
		.package(url: "https://github.com/jakeheis/SwiftCLI", from: "6.0.0"),
		.package(url: "https://github.com/tuist/XcodeProj.git", from: "8.7.1"),
	],
	targets: [
		.target(name: "xcpnc", dependencies: ["SwiftCLI", "XcodeProj"])
	]
)
