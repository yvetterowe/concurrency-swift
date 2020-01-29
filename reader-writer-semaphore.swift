import UIKit

let readWriteMutex = DispatchSemaphore(value: 1)
let readMutex = DispatchSemaphore(value: 1)
var readCount = 0

final class Reader {
    
    var symbol: String {
        return "📖\(identifier)"
    }
    
    private let identifier: Int
    private let queue: DispatchQueue
    
    init(identifier: Int) {
        self.identifier = identifier
        self.queue = DispatchQueue(label: "reader.\(identifier)", qos: .userInitiated)
    }
    
    func read() {
        queue.async {
            readMutex.wait()
            readCount += 1
            if readCount == 1 {
                readWriteMutex.wait()
            }
            readMutex.signal()
            
            // reading...
            print("\(self.symbol) reading \(readCount)")
            
            readMutex.wait()
            readCount -= 1
            if readCount == 0 {
                readWriteMutex.signal()
            }
            readMutex.signal()
        }
    }
}

final class Writer {
    
    var symbol: String {
        return "✍️\(identifier)"
    }
    
    private let identifier: Int
    private let queue: DispatchQueue
    
    init(identifier: Int) {
        self.identifier = identifier
        self.queue = DispatchQueue(label: "writer.\(identifier)", qos: .userInitiated)
    }
    
    func write() {
        queue.async {
            readWriteMutex.wait()
            
            // writing...
            print("\(self.symbol) writing")
            
            readWriteMutex.signal()
        }
    }
}

for i in 0..<5 {
    let reader = Reader(identifier: i)
    let writer = Writer(identifier: i)
    reader.read()
    writer.write()
}

/**
 📖0 reading 1
 📖1 reading 2
 ✍️0 writing
 ✍️1 writing
 📖2 reading 1
 ✍️2 writing
 📖3 reading 1
 ✍️3 writing
 📖4 reading 1
 ✍️4 writing
 */
