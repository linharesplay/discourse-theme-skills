import { apiInitializer } from "discourse/lib/api";
import BlockLatestUsers from "../blocks/block-latest-users";
import BlockLatestReplies from "../blocks/block-latest-replies";
import BlockTopUsers from "../blocks/block-top-users";

export default apiInitializer((api) => {
  api.renderBlocks("gamer-nation-sidebar", [
    {
      block: BlockLatestUsers,
      id: "latest-users",
      args: {
        title: "gamer_sidebar.latest_users.title",
        count: settings.gamer_sidebar_latest_users_count,
      },
    },
    {
      block: BlockLatestReplies,
      id: "latest-replies",
      args: {
        title: "gamer_sidebar.latest_replies.title",
        count: settings.gamer_sidebar_latest_replies_count,
      },
    },
    {
      block: BlockTopUsers,
      id: "top-users",
      args: {
        title: "gamer_sidebar.top_users.title",
        count: settings.gamer_sidebar_top_users_count,
        period: settings.gamer_sidebar_top_users_period,
      },
    },
  ]);
});
