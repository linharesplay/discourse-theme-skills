import Component from "@glimmer/component";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import avatar from "discourse/helpers/avatar";
import { ajax } from "discourse/lib/ajax";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import formatDate from "discourse/helpers/format-date";

@block("theme:skills:latest-users", {
  description: "Displays the latest registered users",
  args: {
    title: { type: "string" },
    count: { type: "number", default: 5 },
  },
})
export default class BlockLatestUsers extends Component {
  @bind
  async fetchLatestUsers() {
    const count = this.args.count || 5;
    const data = await ajax("/directory_items.json", {
      data: {
        period: "all",
        order: "days_visited",
        asc: false,
        page: 0,
      },
    });

    if (!data.directory_items?.length) {
      return [];
    }

    // Sort by created_at to get newest users
    const sortedUsers = data.directory_items
      .sort((a, b) => new Date(b.user.created_at) - new Date(a.user.created_at))
      .slice(0, count);

    return sortedUsers.map((item) => item.user);
  }

  <template>
    <AsyncContent @asyncData={{this.fetchLatestUsers}}>
      <:loading>
        <div class="block-latest-users__loading"><div class="spinner" /></div>
      </:loading>

      <:empty>
        <div class="block-latest-users__empty">
          {{i18n (themePrefix "gamer_sidebar.latest_users.empty")}}
        </div>
      </:empty>

      <:content as |users|>
        <div class="block-latest-users__layout">
          {{#if @title}}
            <h2 class="block-latest-users__title">
              {{i18n (themePrefix @title)}}
            </h2>
          {{/if}}

          <div class="block-latest-users__list">
            {{#each users as |user|}}
              <div class="block-latest-users__row">
                <div
                  class="block-latest-users__user"
                  data-user-card={{user.username}}
                >
                  {{avatar user imageSize="medium"}}
                  <div class="block-latest-users__info">
                    <span class="block-latest-users__name">
                      {{user.username}}
                    </span>
                    {{#if user.created_at}}
                      <span class="block-latest-users__date">
                        {{formatDate user.created_at format="tiny"}}
                      </span>
                    {{/if}}
                  </div>
                </div>
              </div>
            {{/each}}
          </div>
        </div>
      </:content>
    </AsyncContent>
  </template>
}
