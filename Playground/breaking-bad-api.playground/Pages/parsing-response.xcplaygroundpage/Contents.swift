import Foundation

let path: String = Bundle.main.bundlePath
let fileName: String = "characters.json"
let fileUrl: URL = URL(fileReferenceLiteralResourceName: fileName)


func characters(from url: URL) throws -> [BreakingBadCharacter] {
    let jsonData: Data = try Data(contentsOf: url)
    let result: [BreakingBadCharacter] = try JSONDecoder()
        .decode([BreakingBadCharacter].self,
                from: jsonData)
    return result
}

do {
    let charactes: [BreakingBadCharacter] = try characters(from: fileUrl)
    debugPrint("🔧 \(#file) » \(#function) » \(#line)", charactes, separator: "\n")
}
catch {
    debugPrint("❌ \(#file) » \(#function) » \(#line)", error as NSError, separator: "\n")
}
