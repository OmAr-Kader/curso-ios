import Foundation

typealias Unit = ()

var durationList: [String] {
    return ["15 min", "30 min", "45 min", "1 hour", "1.5 hour", "2 hour"]
}

var currentTime: Int64 {
    return Int64(NSDate.now.timeIntervalSince1970 * 1000.0)
}

@inlinable func catchy(completion: () throws -> ()) {
    do {
        try completion()
    } catch {
        print("==>" + error.localizedDescription)
    }
}

@inlinable func catchyR<R>(completion: () throws -> R) -> R? {
    do {
        return try completion()
    } catch let error {
        loggerError("catchy", error.localizedDescription)
        return nil
    }
}

extension Array {
        
    @inlinable func ifNotEmpty<R>(defaultValue: ([Element]) -> R) -> R? {
        if (!self.isEmpty) {
            return defaultValue(self)
        } else {
            return nil
        }
    }
}

extension String {
    var firstCapital: String {
        // 1
        let firstLetter = self.prefix(1).capitalized
        // 2
        let remainingLetters = self.dropFirst().lowercased()
        // 3
        return firstLetter + remainingLetters
    }
    
    var firstSpace: String {
        let it = self.firstIndex(of: " ")
        if (it == nil) {
            return self
        } else {
            // Get range 4 places from the start, and 6 from the end.
            let r = self.index(self.startIndex, offsetBy: 0)...self.index(it!, offsetBy: 0)
            return self[r].base
        }
    }
    
    @inlinable func ifNotEmpty<R>(defaultValue: (String) -> R) -> R? {
        if (!self.isEmpty) {
            return defaultValue(self)
        } else {
            return nil
        }
    }
    
    @inlinable func ifEmpty(defaultValue: () -> Self) -> Self {
        if (self.isEmpty) {
            return defaultValue()
        } else {
            return self
        }
    }

}

extension Int64 {
    
    var fetchHour: Int {
        return  Calendar.current.component(.hour,
              from: Date(timeIntervalSince1970: Double(integerLiteral: self) / 1000.0)
        )
    }
    
    var fetchMinute: Int {
        return Calendar.current.component(.minute,
              from: Date(timeIntervalSince1970: Double(integerLiteral: self) / 1000.0)
        )
    }
    
    
    func fetchTimeFromCalender(hour: Int, minute: Int) -> Int64 {
        let time = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0,
             of: Date(timeIntervalSince1970: Double(integerLiteral: self) / 1000.0)
        )!.timeIntervalSince1970 * 1000.0
        return Int64(time)
    }
    
    var toStr: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd"
        return dateFormatter.string(
            from: Date(timeIntervalSince1970: Double(integerLiteral: self) / 1000.0)
        )
    }

}
