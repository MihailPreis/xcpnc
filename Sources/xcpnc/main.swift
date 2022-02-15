import PathKit
import SwiftCLI
import XcodeProj
import Foundation

let execName = Bundle.main.executableURL?.lastPathComponent ?? ""

final class MainCommand: Command {

	let name = execName

	let longDescription: String = """
Reads path from [<files>] or pipe or stdin and return paths that are not in xcodeproj file.
Example: find Sources -name "*.swift" | \(execName) -0 Some.xcodeproj | xargs -I {} rm -f {}
"""

	@Param
	var xcodeprojPath: String

	@Flag("-0", "--null", description: "Use null delimiter (for pipe).")
	var hasNullDelimiter: Bool

	@CollectedParam
	var files: [String]

	func execute() throws {
		guard
			let cwd = URL(string: FileManager.default.currentDirectoryPath + "/"),
			let xcodeprojUrl = URL(string: xcodeprojPath, relativeTo: cwd)
		else {
			stderr <<< "Invalid xcodeproj path."
			exit(EXIT_FAILURE)
		}

		guard
			let xcodeproj = try? XcodeProj(path: Path(xcodeprojUrl.path))
		else {
			stderr <<< "Xcodeproj is invalid."
			exit(EXIT_FAILURE)
		}

		let projectFiles = Set(xcodeproj.pbxproj.fileReferences + xcodeproj.pbxproj.buildFiles.compactMap { $0.file })
		let sourceRoot = xcodeprojUrl.deletingLastPathComponent().path

		let checkPath: (String) -> Void = { input in
			guard let fileUrl = URL(string: input, relativeTo: cwd) else { return }
			if
				!projectFiles
					.filter({ $0.path?.hasSuffix(fileUrl.lastPathComponent) ?? false })
					.contains(where: { (try? $0.fullPath(sourceRoot: sourceRoot)) == fileUrl.path })
			{
				self.stdout <<< fileUrl.path
			}
		}

		if files.isEmpty {
			while
				let input = ReadStream.stdin.readLine(delimiter: hasNullDelimiter ? "\0" : "\n"),
				!input.isEmpty,
				input != (hasNullDelimiter ? "\0" : "\n")
			{
				checkPath(input)
			}
		} else {
			files.forEach(checkPath)
		}
	}

}

CLI(singleCommand: MainCommand()).go()
