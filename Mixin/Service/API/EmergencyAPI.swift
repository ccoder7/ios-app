import MixinServices

final class EmergencyAPI: BaseAPI {
    
    static let shared = EmergencyAPI()
    
    private enum Url {
        static let create = "emergency_verifications"
        static let show = "emergency_contact"
        static let delete = "emergency_contact/delete"
        static func verify(id: String) -> String {
            return "emergency_verifications/" + id
        }
    }
    
    func createContact(identityNumber: String, completion: @escaping (BaseAPI.Result<EmergencyResponse>) -> Void) {
        let req = EmergencyRequest(phone: nil,
                                   identityNumber: identityNumber,
                                   pin: nil,
                                   code: nil,
                                   purpose: .contact)
        request(method: .post,
                url: Url.create,
                parameters: req.toParameters(),
                encoding: EncodableParameterEncoding<EmergencyRequest>(),
                completion: completion)
    }
    
    func verifyContact(pin: String, id: String, code: String, completion: @escaping (BaseAPI.Result<Account>) -> Void) {
        KeyUtil.aesEncrypt(pin: pin, completion: completion) { (encryptedPin) in
            let req = EmergencyRequest(phone: nil,
                                       identityNumber: nil,
                                       pin: encryptedPin,
                                       code: code,
                                       purpose: .contact)
            request(method: .post,
                    url: Url.verify(id: id),
                    parameters: req.toParameters(),
                    encoding: EncodableParameterEncoding<EmergencyRequest>(),
                    completion: completion)
        }
    }
    
    func createSession(phoneNumber: String, identityNumber: String, completion: @escaping (BaseAPI.Result<EmergencyResponse>) -> Void) {
        let req = EmergencyRequest(phone: phoneNumber,
                                   identityNumber: identityNumber,
                                   pin: nil,
                                   code: nil,
                                   purpose: .session)
        request(method: .post,
                url: Url.create,
                parameters: req.toParameters(),
                encoding: EncodableParameterEncoding<EmergencyRequest>(),
                checkLogin: false,
                completion: completion)
    }
    
    func verifySession(id: String, code: String, sessionSecret: String?, registrationId: Int?, completion: @escaping (BaseAPI.Result<Account>) -> Void) {
        let req = EmergencySessionRequest(code: code,
                                          sessionSecret: sessionSecret,
                                          registrationId: registrationId)
        request(method: .post,
                url: Url.verify(id: id),
                parameters: req.toParameters(),
                encoding: EncodableParameterEncoding<EmergencySessionRequest>(),
                checkLogin: false,
                completion: completion)
    }
    
    func show(pin: String, completion: @escaping (BaseAPI.Result<User>) -> Void) {
        KeyUtil.aesEncrypt(pin: pin, completion: completion) { (encryptedPin) in
            let param = ["pin": encryptedPin]
            request(method: .post, url: Url.show, parameters: param, completion: completion)
        }
    }
    
    func delete(pin: String, completion: @escaping (BaseAPI.Result<Account>) -> Void) {
        KeyUtil.aesEncrypt(pin: pin, completion: completion) { (encryptedPin) in
            let param = ["pin": encryptedPin]
            request(method: .post, url: Url.delete, parameters: param, completion: completion)
        }
    }
    
}
