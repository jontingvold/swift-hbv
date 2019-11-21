import Foundation


public func readFileContent(path: URL) -> String {
    do {
        let fileContent = try String(contentsOf: path, encoding: String.Encoding.utf8)
        return fileContent
        
    } catch let error as NSError {
        fatalError("An error took place: \(error)")
    }
}


public func writeFileContent(path: URL, fileContent: String) {
    do {
        try fileContent.write(to: path, atomically: false, encoding: String.Encoding.utf8)
    }
    catch let error as NSError {
        fatalError("An error took place: \(error)")
    }
}
