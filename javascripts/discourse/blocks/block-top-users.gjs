import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import avatar from "discourse/helpers/avatar";
import number from "discourse/helpers/number";
import { ajax } from "discourse/lib/ajax";
import { bind } from "discourse/lib/decorators";
import { or } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";

@block("theme:skills:top-users", {
  description: "Displays top users by likes received",
  args: {
    title: { type: "string" },
    count: { type: "number", default: 5 },
    period: { type: "string", default: "weekly" },
  },
})
export default class BlockTopUsers extends Component {
  @service siteSettings;

  @bind
  async fetchTopUsers() {
    const count = this.args.count || 5;
    const period = this.args.period || "weekly";
    
    const data = await ajax("/directory_items.json", {
      data: {
        period: period,
        order: "likes_received",
        asc: false,
        page: 0,
      },
    });

    if (!data.directory_items?.length) {
      return [];
    }

    return data.directory_items.slice(0, count).map((item, index) => ({
      ...item.user,
      likes_received: item.likes_received,
      post_count: item.post_count,
      rank: index + 1,
    }));
  }

  <template>
    <AsyncContent @asyncData={{this.fetchTopUsers}}>
      <:loading>
        <div class="block-top-users__loading"><div class="spinner" /></div>
      </:loading>

      <:empty>
        <div class="block-top-users__empty">
          {{i18n (themePrefix "gamer_sidebar.top_users.empty")}}
        </div>
      </:empty>

      <:content as |users|>
        <div class="block-top-users__layout">
          {{#if @title}}
            <h2 class="block-top-users__title">
              {{i18n (themePrefix @title)}}
            </h2>
          {{/if}}

          <div class="block-top-users__list">
            {{#each users as |user|}}
              <div class="block-top-users__row {{if (eq user.rank 1) '--top-rank'}}">
                <span class="block-top-users__rank">
                  {{#if (eq user.rank 1)}}
                    <svg class="block-top-users__crown" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M5 16L3 5l5.5 5L12 4l3.5 6L21 5l-2 11H5zm14 3c0 .6-.4 1-1 1H6c-.6 0-1-.4-1-1v-1h14v1z"/>
                    </svg>
                  {{else}}
                    #{{user.rank}}
                  {{/if}}
                </span>
                <div
                  class="block-top-users__user"
                  data-user-card={{user.username}}
                >
                  {{avatar user imageSize="small"}}
                  <div class="block-top-users__info">
                    <span class="block-top-users__name">
                      {{#if this.siteSettings.prioritize_username_in_ux}}
                        {{user.username}}
                      {{else}}
                        {{or user.name user.username}}
                      {{/if}}
                    </span>
                  </div>
                </div>
                <div class="block-top-users__stats">
                  <span class="block-top-users__likes" title="Likes received">
                    <svg viewBox="0 0 24 24" fill="currentColor" class="block-top-users__icon">
                      <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                    </svg>
                    {{number user.likes_received}}
                  </span>
                </div>
              </div>
            {{/each}}
          </div>
        </div>
      </:content>
    </AsyncContent>
  </template>
}
