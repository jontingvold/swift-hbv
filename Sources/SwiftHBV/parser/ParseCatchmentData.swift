import Foundation


enum ParseError: Error {
    case wrongRowSize(String)
    case emptyValues(String)
    case notDoubleValue(String)
}


func parseCatchmentData(csv: String) throws -> [CatchmentTimestep] {
    let csvRows = parseCSV(csv)
    
    var dataset = [CatchmentTimestep]()
    dataset.reserveCapacity(csvRows.count)
    
    for row in csvRows {
        guard row.count > 1 && row[0] != "" else { continue }
        
        guard row.count == 5 else { throw ParseError.wrongRowSize("Row \(row) does not contain 5 columns") }
        
        guard row[0] != "" else { throw ParseError.emptyValues("First column of row \(row) is empty") }
        guard row[1] != "" else { throw ParseError.emptyValues("Second column of row \(row) is empty") }
        guard row[2] != "" else { throw ParseError.emptyValues("Third column of row \(row) is empty") }
        guard row[3] != "" else { throw ParseError.emptyValues("Fourth column of row \(row) is empty") }
        guard row[4] != "" else { throw ParseError.emptyValues("Fift column of row \(row) is empty") }
        
        let datetime = row[0]
        guard let p = Double(row[1]) else { throw ParseError.notDoubleValue("\(row[1]) is not a double") }
        guard let T_min = Double(row[2]) else { throw ParseError.notDoubleValue("\(row[2]) is not a double") }
        guard let T_max = Double(row[3]) else { throw ParseError.notDoubleValue("\(row[3]) is not a double") }
        guard let Q = Double(row[4]) else { throw ParseError.notDoubleValue("\(row[4]) is not a double") }
        
        let T = 0.5*(T_min + T_max)
        
        dataset.append((
            datetime: datetime,
            percepation_mm_per_timestep: p,
            temp: T,
            Q_m3_per_s: Q
        ))
    }

    return dataset
}
