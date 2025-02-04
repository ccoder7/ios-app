import WCDBSwift

public struct Participant: BaseCodable {
    
    public static let tableName: String = "participants"
    
    public let conversationId: String
    public let userId: String
    public let role: String
    public let status: Int
    public let createdAt: String
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = Participant
        case conversationId = "conversation_id"
        case userId = "user_id"
        case role
        case status
        case createdAt = "created_at"
        
        public static let objectRelationalMapping = TableBinding(CodingKeys.self)
        public static var tableConstraintBindings: [TableConstraintBinding.Name: TableConstraintBinding]? {
            return  [
                "_multi_primary": MultiPrimaryBinding(indexesBy: conversationId, userId)
            ]
        }
    }
}

public enum ParticipantRole: String {
    case OWNER
    case ADMIN
}

public enum ParticipantAction: String {
    case ADD
    case REMOVE
    case JOIN
    case EXIT
    case ROLE
}

public enum ParticipantStatus: Int {
    case START = 0
    case SUCCESS = 1
    case ERROR = 2
}
