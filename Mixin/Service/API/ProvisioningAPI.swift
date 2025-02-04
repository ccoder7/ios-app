import MixinServices

final class ProvisioningAPI: BaseAPI {
    
    static let shared = ProvisioningAPI()
    
    private enum url {
        static let code = "device/provisioning/code"
        static func update(id: String) -> String {
            return "provisionings/" + id
        }
    }
    
    func code(completion: @escaping (BaseAPI.Result<ProvisioningCodeResponse>) -> Void) {
        request(method: .get, url: url.code, completion: completion)
    }
    
    func update(id: String, secret: String, completion: @escaping (BaseAPI.Result<ProvisioningResponse>) -> Void) {
        let params = ["secret": secret]
        request(method: .post, url: url.update(id: id), parameters: params, completion: completion)
    }
    
}
