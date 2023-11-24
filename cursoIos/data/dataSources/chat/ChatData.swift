import Foundation

class ChatData {
    var repository: ChatRepo
    
    init(repository: ChatRepo) {
        self.repository = repository
    }
    
    func getMainChatFlow(
        courseId: String
    ) async -> ResultRealm<Conversation?> {
        return await repository.getMainChatFlow(courseId: courseId)
    }

    func getTimelineChatFlow(
        courseId: String,
        type: Int
    ) async -> ResultRealm<Conversation?> {
        return await repository.getTimelineChatFlow(courseId: courseId, type: type)
    }

    func createChat(conversation: Conversation) async -> ResultRealm<Conversation?> {
        return await repository.createChat(conversation: conversation)
    }

    func editChat(
        conversation: Conversation,
        edit: Conversation
    ) async -> ResultRealm<Conversation?>  {
        return await repository.editChat(conversation: conversation, edit: edit)
    }

}
