import Combine

class ChatData {
    var repository: ChatRepo
    
    init(repository: ChatRepo) {
        self.repository = repository
    }
    
    @BackgroundActor
    func getMainChatFlow(
        courseId: String,
        invoke: @escaping (Conversation?) -> Unit
    ) async -> AnyCancellable? {
        return await repository.getMainChatFlow(courseId: courseId, invoke: invoke)
    }

    @BackgroundActor
    func getTimelineChatFlow(
        courseId: String,
        type: Int,
        invoke: @escaping (Conversation?) -> Unit
    ) async -> AnyCancellable? {
        return await repository.getTimelineChatFlow(
            courseId: courseId,
            type: type,
            invoke: invoke
        )
    }

    @BackgroundActor
    func createChat(conversation: Conversation) async -> ResultRealm<Conversation?> {
        return await repository.createChat(conversation: conversation)
    }

    @BackgroundActor
    func editChat(
        conversation: Conversation,
        edit: Conversation
    ) async -> ResultRealm<Conversation?>  {
        return await repository.editChat(conversation: conversation, edit: edit)
    }

}
