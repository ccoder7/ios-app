import Foundation
import WCDBSwift

public class IdentityDAO: SignalDAO {
    
    public static let shared = IdentityDAO()
    
    public func saveLocalIdentity() {
        let registrationId = Int(AppGroupUserDefaults.Signal.registrationId)
        let publicKey = AppGroupUserDefaults.Signal.publicKey
        let privateKey = AppGroupUserDefaults.Signal.privateKey
        IdentityDAO.shared.insertOrReplace(obj: Identity(address: "-1", registrationId: registrationId, publicKey: publicKey, privateKey: privateKey, nextPreKeyId: nil, timestamp: Date().timeIntervalSince1970))
    }
    
    func getLocalIdentity() -> Identity? {
        return SignalDatabase.shared.getCodable(condition: Identity.Properties.address == "-1")
    }
    
    func getCount() -> Int {
        return SignalDatabase.shared.getCount(on: Identity.Properties.id.count(), fromTable: Identity.tableName)
    }
    
    func deleteIdentity(address: String) {
        SignalDatabase.shared.delete(table: Identity.tableName, condition: Identity.Properties.address == address)
    }
    
}
