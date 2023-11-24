import Foundation

class ChatRepoImp : BaseRepoImp, ChatRepo {

    func getMainChatFlow(
        courseId: String
    ) async -> ResultRealm<Conversation?>  {
        return await querySingleFlow(
            "getMainChat$courseId",
            "partition == $0 AND courseId == $1 AND type == $2",
            ["public", courseId, -1]
        )
    }
    
    func getTimelineChatFlow(
        courseId: String,
        type: Int
    ) async -> ResultRealm<Conversation?> {
        return await querySingleFlow(
            "getTimelineChat$courseId$type",
            "partition == $0 AND courseId == $1 AND type == $2",
            ["public", courseId, type]
        )
    }

    func createChat(conversation: Conversation) async -> ResultRealm<Conversation?> {
        return await insert(conversation)
    }

    func editChat(
        conversation: Conversation,
        edit: Conversation
    ) async -> ResultRealm<Conversation?> {
        return await self.edit(conversation._id) { it in it.copy(edit) }
    }

}
