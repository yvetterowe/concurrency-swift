import UIKit

let emptySemaphore = DispatchSemaphore(value: 3)
let fullSemaphore = DispatchSemaphore(value: 0)
let mutexSemaphore = DispatchSemaphore(value: 1)

var sharedBuffer: [String] = []

final class Producer {
    
    private let queue = DispatchQueue.global(qos: .utility)
    private let symbol = "💚"
    
    func produce() {
        let symbol = self.symbol
        queue.async {
            print("\(symbol) try produce")
            emptySemaphore.wait()
            mutexSemaphore.wait()
            
            sharedBuffer.append("🌽")
            print("\(symbol) \(sharedBuffer)")
            
            mutexSemaphore.signal()
            fullSemaphore.signal()
        }
    }
}

final class Consumer {
    
    private let queue = DispatchQueue.global(qos: .userInitiated)
    private let symbol = "💙"
    
    func consume() {
        let symbol = self.symbol
        queue.async {
            print("\(symbol) try consume")
            fullSemaphore.wait()
            mutexSemaphore.wait()
            
            sharedBuffer.removeFirst()
            print("\(symbol) \(sharedBuffer)")
            
            mutexSemaphore.signal()
            emptySemaphore.signal()
        }
    }
}

let producer = Producer()
let consumer = Consumer()

for i in 0..<5 {
    producer.produce()
    consumer.consume()
}

/**
 💚 try produce
 💙 try consume
 💚 try produce
 💙 try consume
 💚 try produce
 💚 ["🌽"]
 💙 try consume
 💙 try consume
 💙 try consume
 💚 try produce
 💚 ["🌽", "🌽"]
 💚 try produce
 💚 ["🌽", "🌽", "🌽"]
 💙 ["🌽", "🌽"]
 💙 ["🌽"]
 💙 []
 💚 ["🌽"]
 💙 []
 💚 ["🌽"]
 💙 []
 */
