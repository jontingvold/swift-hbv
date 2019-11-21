import Foundation


func parseCSV(_ data: String, seperator: String = ",") -> [[String]] {
    var arrayOfStringArrays: [[String]] = []
    let rows = data.components(separatedBy: .newlines)
    arrayOfStringArrays.reserveCapacity(rows.count)
    
    for row in rows {
        let columns = row.components(separatedBy: seperator)
        arrayOfStringArrays.append(columns)
    }
    return arrayOfStringArrays
}

func makeCSV(arrayOfStringArrays: [[String]], headers: [String] = [], separator: String = ",") -> String {
    var s = ""
    if !headers.isEmpty
        { s += headers.joined(separator: separator) + "\n" }
    for row in arrayOfStringArrays
        { s += row.joined(separator: separator) + "\n" }
    return s
}
