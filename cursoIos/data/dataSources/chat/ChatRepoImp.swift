import Combine
import Foundation

class ChatRepoImp : BaseRepoImp, ChatRepo {

    @BackgroundActor
    func getMainChatFlow(
        courseId: String,
        invoke: @escaping (Conversation?) -> Unit
    ) async -> AnyCancellable?  {
        return await querySingleFlow(
            invoke,
            "getMainChat\(courseId)",
            "%K == %@ AND %K == %@ AND %K == %@",
            "partition", "public",
            "courseId", NSString(string: courseId),
            "type", NSNumber(value: -1)
        )
    }
    
    @BackgroundActor
    func getTimelineChatFlow(
        courseId: String,
        type: Int,
        invoke: @escaping (Conversation?) -> Unit
    ) async -> AnyCancellable?  {
        return await querySingleFlow(
            invoke,
            "getTimelineChat\(courseId)\(type)",
            "%K == %@ AND %K == %@ AND %K == %@",
            "partition", "public",
            "courseId", NSString(string: courseId),
            "type", NSNumber(value: type)
        )
    }

    @BackgroundActor
    func createChat(conversation: Conversation) async -> ResultRealm<Conversation?> {
        return await insert(conversation)
    }

    @BackgroundActor
    func editChat(
        conversation: Conversation,
        edit: Conversation
    ) async -> ResultRealm<Conversation?> {
        return await self.edit(conversation._id) { it in it.copy(edit) }
    }

}
