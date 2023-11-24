import Foundation

protocol ChatRepo {

    func getMainChatFlow(
        courseId: String
    ) async -> ResultRealm<Conversation?>

    func getTimelineChatFlow(
        courseId: String,
        type: Int
    ) async -> ResultRealm<Conversation?>

    func createChat(conversation: Conversation) async -> ResultRealm<Conversation?>

    func editChat(
        conversation: Conversation,
        edit: Conversation
    ) async -> ResultRealm<Conversation?>
}
