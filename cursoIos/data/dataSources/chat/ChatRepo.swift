import Combine

protocol ChatRepo {

    @BackgroundActor
    func getMainChatFlow(
        courseId: String,
        invoke: @escaping (Conversation?) -> Unit
    ) async -> AnyCancellable?

    @BackgroundActor
    func getTimelineChatFlow(
        courseId: String,
        type: Int,
        invoke: @escaping (Conversation?) -> Unit
    ) async -> AnyCancellable?
    
    @BackgroundActor
    func createChat(conversation: Conversation) async -> ResultRealm<Conversation?>

    @BackgroundActor
    func editChat(
        conversation: Conversation,
        edit: Conversation
    ) async -> ResultRealm<Conversation?>
}
