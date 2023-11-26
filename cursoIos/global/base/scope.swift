import Foundation
import RealmSwift

struct Scope {
    var previousTask: Task<Void, Error>?

     mutating func launch(block: @Sendable @escaping () async -> Void) {
        previousTask = Task(priority: .background) { [previousTask] in
            let _ = await previousTask?.result
            return await block()
        }
    }
    
    mutating func launchNew(block: @Sendable @escaping () async throws -> Void) {
        previousTask?.cancel()
        previousTask = Task(priority: .background) {
            return try await block()
        }
    }
    
    mutating func launchMain(block: @Sendable @escaping () async throws -> Void) {
        previousTask?.cancel()
        previousTask = Task { @MainActor in
            return try await block()
        }
    }
}

protocol ScopeFunc {}
extension NSObject: ScopeFunc {}

extension Optional where Wrapped: ScopeFunc {

    @inline(__always) func letSus<R>(block: (Wrapped) -> R) -> R? {
        guard let self = self else { return nil }
        return block(self)
    }
    
    
    @inline(__always) func letBack<R>(block: (Wrapped) async -> R) async -> R? {
        guard let self = self else { return nil }
        return await block(self)
    }
    
    @inline(__always) func letBackN<R>(block: (Wrapped?) async -> R?) async -> R? {
        guard let self = self else { return nil }
        return await block(self)
    }
    
    @inline(__always) func apply(_ block: (Self) -> ()) -> Self {
        guard let self = self else { return nil }
        block(self)
        return self
    }
}


extension Optional where Wrapped == ScopeFunc? {

    @inline(__always) func letSus<R>(block: (Wrapped?) -> R) -> R? {
        guard let self = self else { return nil }
        return block(self)
    }
    
    
    @inline(__always) func letBack<R>(block: (Wrapped?) async -> R) async -> R? {
        guard let self = self else { return nil }
        return await block(self)
    }
    
    @inline(__always) func apply(_ block: (Self) -> ()) -> Self {
        guard let self = self else { return nil }
        block(self)
        return self
    }
}

