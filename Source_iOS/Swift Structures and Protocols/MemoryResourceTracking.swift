import Foundation

#if DEBUG
	
	/// Resource utilization information
	public struct MemoryResourceTracking {
		/// Counts internal Rx resource allocations (Observables, Observers, Disposables, etc.). This provides a simple way to detect leaks during development.
		public static var total: Int {
			return Int(__get_atomic_count())
		}
		
		/// Increments `Resources.total` resource count.
		public static func incrementTotal(_ file: String = #file, line: UInt = #line, function: String = #function) -> Swift.Void {
			__atomic_increment()
			print(String(repeating:"-", count:Int(self.total)) + ">\(file.components(separatedBy: "/").last!.components(separatedBy: ".").first!) count: \(self.total)")
		}
		
		/// Decrements `Resources.total` resource count
		public static func decrementTotal(_ file: String = #file, line: UInt = #line, function: String = #function) -> Swift.Void {
			guard __get_atomic_count() > 0 else { return }
			__atomic_decrement()
			print("<" + String(repeating:"-", count:Int(self.total+1)) + "\(file.components(separatedBy: "/").last!.components(separatedBy: ".").first!) count: \(self.total)")
		}
	}
	
	extension Int32 {
		func value() -> Int32 {
			return self
		}
	}
#endif
