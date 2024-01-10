defmodule TMI.Fields.TagParserTest do
  use ExUnit.Case, async: true

  alias TMI.Fields.TagParser

  doctest TagParser

  test "subgift" do
    tagstring =
      "@badge-info=subscriber/47;badges=broadcaster/1,subscriber/0,sub-gifter/5;color=#5DA5D9;display-name=ShyRyan;emotes=;flags=;id=11052334-9acb-4c3d-8bdd-b58b084ec3d5;login=shyryan;mod=0;msg-id=subgift;msg-param-community-gift-id=3338120729465115224;msg-param-gift-months=1;msg-param-months=1;msg-param-origin-id=3338120729465115224;msg-param-recipient-display-name=im_rab;msg-param-recipient-id=597882881;msg-param-recipient-user-name=im_rab;msg-param-sender-count=0;msg-param-sub-plan-name=T1;msg-param-sub-plan=1000;room-id=146616692;subscriber=1;system-msg=ShyRyan\\sgifted\\sa\\sTier\\s1\\ssub\\sto\\sim_rab!;tmi-sent-ts=1704839998707;user-id=146616692;user-type=;vip=0"

    expected = %{
      badge_info: [{"subscriber", 47}],
      badges: [{"broadcaster", 1}, {"subscriber", 0}, {"sub-gifter", 5}],
      channel_id: "146616692",
      color: "#5DA5D9",
      community_gift_id: "3338120729465115224",
      display_name: "ShyRyan",
      emotes: [],
      event: "subgift",
      flags: [],
      id: "11052334-9acb-4c3d-8bdd-b58b084ec3d5",
      mod?: false,
      sub?: true,
      vip?: false,
      user_name: "shyryan",
      origin_id: "3338120729465115224",
      plan: :t1,
      sender_count: 0,
      system_message: "ShyRyan gifted a Tier 1 sub to im_rab!",
      timestamp: ~U[2024-01-09 22:39:58.707Z],
      user_id: "146616692",
      user_type: :normal,
      cumulative_months: 1,
      gift_months: 1,
      plan_name: "T1",
      recipient_display_name: "im_rab",
      recipient_id: "597882881",
      recipient_user_name: "im_rab"
    }

    assert {:ok, tags} = TagParser.parse(tagstring)
    assert tags == expected
  end

  test "submystergift" do
    tagstring =
      "@badge-info=subscriber/47;badges=broadcaster/1,subscriber/0,sub-gifter/1;color=#5DA5D9;display-name=ShyRyan;emotes=;flags=;id=46c76cb5-0f3f-4605-92b7-66d010f544a1;login=shyryan;mod=0;msg-id=submysterygift;msg-param-community-gift-id=3338120729465115224;msg-param-mass-gift-count=5;msg-param-origin-id=3338120729465115224;msg-param-sender-count=0;msg-param-sub-plan=1000;room-id=146616692;subscriber=1;system-msg=ShyRyan\\sis\\sgifting\\s5\\sTier\\s1\\sSubs\\sto\\sShyRyan's\\scommunity!;tmi-sent-ts=1704839998029;user-id=146616692;user-type=;vip=0"

    expected = %{
      badge_info: [{"subscriber", 47}],
      badges: [{"broadcaster", 1}, {"subscriber", 0}, {"sub-gifter", 1}],
      color: "#5DA5D9",
      community_gift_id: "3338120729465115224",
      count: 5,
      display_name: "ShyRyan",
      emotes: [],
      event: "submysterygift",
      flags: [],
      id: "46c76cb5-0f3f-4605-92b7-66d010f544a1",
      mod?: false,
      sub?: true,
      vip?: false,
      user_name: "shyryan",
      origin_id: "3338120729465115224",
      plan: :t1,
      sender_count: 0,
      system_message: "ShyRyan is gifting 5 Tier 1 Subs to ShyRyan's community!",
      timestamp: ~U[2024-01-09 22:39:58.029Z],
      user_id: "146616692",
      user_type: :normal,
      channel_id: "146616692"
    }

    assert {:ok, tags} = TagParser.parse(tagstring)
    assert tags == expected
  end
end
