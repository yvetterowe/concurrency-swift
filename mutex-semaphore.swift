import UIKit


var sharedValue: Int = 0

let thread1 = DispatchQueue.global(qos: .userInitiated)
let thread2 = DispatchQueue.global(qos: .utility)

let semaphore = DispatchSemaphore(value: 1)

func enterCriticalSection(from queue: DispatchQueue, symbol: String) {
    queue.async {
        print("\(symbol) wait")
        semaphore.wait()
        
        for i in 0..<5 {
            sharedValue += 1
            print("\(symbol) \(sharedValue)")
        }
        
        print("\(symbol) signal")
        semaphore.signal()
    }
}

enterCriticalSection(from: thread2, symbol: "💚")
enterCriticalSection(from: thread1, symbol: "💙")

/**
 results:
 💙 wait
 💚 wait
 💙 1
 💙 2
 💙 3
 💙 4
 💙 5
 💙 signal
 💚 6
 💚 7
 💚 8
 💚 9
 💚 10
 💚 signal
 */
