import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import avatar from "discourse/helpers/avatar";
import { ajax } from "discourse/lib/ajax";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import formatDate from "discourse/helpers/format-date";

@block("theme:skills:latest-replies", {
  description: "Displays the latest replies in topics",
  args: {
    title: { type: "string" },
    count: { type: "number", default: 5 },
  },
})
export default class BlockLatestReplies extends Component {
  @service siteSettings;

  @bind
  async fetchLatestReplies() {
    const count = this.args.count || 5;
    const data = await ajax("/posts.json");

    if (!data.latest_posts?.length) {
      return [];
    }

    // Filter to only show replies (post_number > 1) and limit to count
    const replies = data.latest_posts
      .filter((post) => post.post_number > 1)
      .slice(0, count);

    return replies;
  }

  <template>
    <AsyncContent @asyncData={{this.fetchLatestReplies}}>
      <:loading>
        <div class="block-latest-replies__loading"><div class="spinner" /></div>
      </:loading>

      <:empty>
        <div class="block-latest-replies__empty">
          {{i18n (themePrefix "gamer_sidebar.latest_replies.empty")}}
        </div>
      </:empty>

      <:content as |replies|>
        <div class="block-latest-replies__layout">
          {{#if @title}}
            <h2 class="block-latest-replies__title">
              {{i18n (themePrefix @title)}}
            </h2>
          {{/if}}

          <div class="block-latest-replies__list">
            {{#each replies as |reply|}}
              <a
                href="/t/{{reply.topic_slug}}/{{reply.topic_id}}/{{reply.post_number}}"
                class="block-latest-replies__row"
              >
                <div class="block-latest-replies__avatar">
                  {{avatar reply imageSize="small"}}
                </div>
                <div class="block-latest-replies__content">
                  <span class="block-latest-replies__topic">
                    {{reply.topic_title}}
                  </span>
                  <div class="block-latest-replies__meta">
                    <span class="block-latest-replies__username">
                      {{reply.username}}
                    </span>
                    <span class="block-latest-replies__date">
                      {{formatDate reply.created_at format="tiny"}}
                    </span>
                  </div>
                </div>
              </a>
            {{/each}}
          </div>
        </div>
      </:content>
    </AsyncContent>
  </template>
}
