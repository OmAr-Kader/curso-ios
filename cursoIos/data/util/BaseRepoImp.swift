import Foundation
import RealmSwift

class BaseRepoImp {
    var realmSync: RealmSync
    
    init(realmSync: RealmSync) {
        self.realmSync = realmSync
    }
    
    @inlinable func insert<T : Object>(
        _ item: T,
        updatePolicy: Realm.UpdatePolicy = Realm.UpdatePolicy.all
    ) async -> ResultRealm<T?>  {
        let realm = realmSync.cloud()
        if (realm == nil) {
            return ResultRealm(value: nil, result: REALM_FAILED)
        }
        do {
            try await realm!.asyncWrite {
               realm!.add(item, update: updatePolicy)
            }
            return ResultRealm(
                value: item,
                result: REALM_SUCCESS
            )
        } catch {
            return ResultRealm(value: nil, result: REALM_FAILED)
        }
    }
    
    @inlinable func edit<T : Object> (
        _ id: ObjectId,
        _ edit: (T) -> T
    ) async -> ResultRealm<T?> {
        let realm = realmSync.cloud()
        if (realm == nil) {
            return ResultRealm(value: nil, result: REALM_FAILED)
        }
        do {
            let op = realm!.object(ofType: T.self, forPrimaryKey: id)
            if (op == nil) {
                return ResultRealm(value: nil, result: REALM_FAILED)
            }
            try await realm!.asyncWrite {
                edit(op!)
            }
            return ResultRealm(value: op, result: REALM_SUCCESS)
        } catch {
            return ResultRealm(value: nil, result: REALM_FAILED)
        }
    }
    
    @inlinable func delete<T : Object>(
        _ dumny: T,
        _ query: String,
        _ args: Any...
    ) async -> Int {
        let realm = realmSync.cloud()
        if (realm == nil) {
            return REALM_FAILED
        }
        do {
            let op = realm!.objects(T.self).filter(query, args).first
            if (op == nil) {
                return REALM_FAILED
            }
            try await realm!.asyncWrite {
                realm!.delete(op!)
            }
            return REALM_SUCCESS
        } catch {
            return REALM_FAILED
        }
    }
    
    @inlinable func querySingleFlow<T : Object>(
        _ queryName: String,
        _ query: String,
        _ args: Any...
    ) async -> ResultRealm<T?> {
        let realm = realmSync.cloud()
        if (realm == nil) {
            return ResultRealm(value: nil, result: REALM_FAILED)
        }
        do {
            let op = try await realm!.objects(T.self).filter(query, args).subscribe(
                name: queryName,
                waitForSync: .onCreation
            ).first
            return ResultRealm(
                value: op,
                result: op == nil ? REALM_FAILED : REALM_SUCCESS
            )
        } catch {
            return ResultRealm(value: nil, result: REALM_FAILED)
        }
    }
    
    @inlinable func querySingle<T : Object>(
        _ invoke: (ResultRealm<T?>) -> (),
        _ queryName: String,
        _ query: String,
        _ args: Any...
    ) async {
        let realm = realmSync.cloud()
        if (realm == nil) {
            invoke(ResultRealm(value: nil, result: REALM_FAILED))
            return
        }
        do {
            let op = try await realm!.objects(T.self).filter(query, args).subscribe(
                name: queryName,
                waitForSync: .onCreation
            ).first
            invoke(
                ResultRealm(
                    value: op,
                    result: op == nil ? REALM_FAILED : REALM_SUCCESS
                )
            )
        } catch {
            invoke(ResultRealm(value: nil, result: REALM_FAILED))
        }
    }

    @inlinable func query<T : Object>(
        _ invoke: (ResultRealm<[T]>) -> (),
        _ queryName: String,
        _ query: String,
        _ args: Any...
      ) async {
          let realm = realmSync.cloud()
          if (realm == nil) {
              invoke(ResultRealm(value: [], result: REALM_FAILED))
              return
          }
          do {
              let op: [T] = try await realm!.objects(T.self).filter(query, args).subscribe(
                  name: queryName,
                  waitForSync: .onCreation
              ).map { it in
                  it
              }
              invoke(
                  ResultRealm(
                    value: op,
                      result: REALM_SUCCESS
                  )
              )
          } catch {
              invoke(ResultRealm(value: [], result: REALM_FAILED))
          }
      }
    
    
    @inlinable func queryLess<T : Object>(
        _ invoke: (ResultRealm<[T]>) -> Unit,
        _ query: String,
        _ args: Any...
    ) async {
        let realm = realmSync.cloud()
        if (realm == nil) {
            invoke(ResultRealm(value: [], result: REALM_FAILED))
            return
        }
        let op: [T] = realm!.objects(T.self).filter(query, args).map { it in
            it
        }
        invoke(
            ResultRealm(
              value: op,
                result: REALM_SUCCESS
            )
        )

    }

    
}
