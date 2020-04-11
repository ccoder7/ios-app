import Foundation
import UIKit

public class RefreshConversationJob: BaseJob {
    
    let conversationId: String
    
    public init(conversationId: String) {
        self.conversationId = conversationId
    }
    
    override public func getJobId() -> String {
        return "refresh-coversation-\(conversationId)"
    }
    
    override public func run() throws {
        guard !conversationId.isEmpty && conversationId != User.systemUser && conversationId != myUserId else {
            return
        }
        guard ConversationDAO.shared.getConversationStatus(conversationId: conversationId) != ConversationStatus.START.rawValue else {
            return
        }
        
        switch ConversationAPI.shared.getConversation(conversationId: conversationId) {
        case let .success(response):
            if response.category == ConversationCategory.GROUP.rawValue {
                ConversationDAO.shared.updateConversation(conversation: response)
                CircleConversationDAO.shared.update(conversation: response)
            } else if response.category == ConversationCategory.CONTACT.rawValue {
                ConcurrentJobQueue.shared.addJob(job: RefreshUserJob(userIds: [response.creatorId]))
            }
        case let .failure(error):
            if error.code == 404 || error.code == 403 {
                ConversationDAO.shared.exitGroup(conversationId: conversationId)
            } else {
                throw error
            }
        }
    }
    
}
