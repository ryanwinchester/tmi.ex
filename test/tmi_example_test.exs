defmodule TMIExampleTest do
  use ExUnit.Case, async: true

  describe "emote_mode" do
    test "emote_only_on" do
      message =
        {:unrecognized, "@msg-id=emote_only_on",
         %ExIRC.Message{
           server: [],
           nick: [],
           user: [],
           host: [],
           ctcp: false,
           cmd: "@msg-id=emote_only_on",
           args: ["tmi.twitch.tv NOTICE #spirodonfl :This room is now in emote-only mode."]
         }}

      expected = %TMI.Chat.Events.EmoteMode{channel: "#spirodonfl", emote_only?: true}

      assert TMI.parse_message(message) == expected
    end

    test "emote_only_off" do
      message =
        {:unrecognized, "@msg-id=emote_only_off",
         %ExIRC.Message{
           server: [],
           nick: [],
           user: [],
           host: [],
           ctcp: false,
           cmd: "@msg-id=emote_only_off",
           args: ["tmi.twitch.tv NOTICE #spirodonfl :This room is no longer in emote-only mode."]
         }}

      expected = %TMI.Chat.Events.EmoteMode{channel: "#spirodonfl", emote_only?: false}

      assert TMI.parse_message(message) == expected
    end
  end

  describe "communitysubgift" do
    test "message" do
      message =
        {:unrecognized,
         "@badge-info=subscriber/1;badges=subscriber/0,premium/1;color=;display-name=CkPuffin;emotes=;flags=;id=87c56a84-2802-4ff8-9f71-433b4eab98b9;login=ckpuffin;mod=0;msg-id=submysterygift;msg-param-community-gift-id=17130216016315839265;msg-param-goal-contribution-type=SUBS;msg-param-goal-current-contributions=142;msg-param-goal-target-contributions=1000;msg-param-goal-user-contributions=5;msg-param-mass-gift-count=5;msg-param-origin-id=17130216016315839265;msg-param-sender-count=5;msg-param-sub-plan=1000;room-id=62338636;subscriber=1;system-msg=CkPuffin\\sis\\sgifting\\s5\\sTier\\s1\\sSubs\\sto\\sSpirodonFL's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s5\\sin\\sthe\\schannel!;tmi-sent-ts=1705423028822;user-id=611203908;user-type=;vip=0",
         %ExIRC.Message{
           server: [],
           nick: [],
           user: [],
           host: [],
           ctcp: false,
           cmd:
             "@badge-info=subscriber/1;badges=subscriber/0,premium/1;color=;display-name=CkPuffin;emotes=;flags=;id=87c56a84-2802-4ff8-9f71-433b4eab98b9;login=ckpuffin;mod=0;msg-id=submysterygift;msg-param-community-gift-id=17130216016315839265;msg-param-goal-contribution-type=SUBS;msg-param-goal-current-contributions=142;msg-param-goal-target-contributions=1000;msg-param-goal-user-contributions=5;msg-param-mass-gift-count=5;msg-param-origin-id=17130216016315839265;msg-param-sender-count=5;msg-param-sub-plan=1000;room-id=62338636;subscriber=1;system-msg=CkPuffin\\sis\\sgifting\\s5\\sTier\\s1\\sSubs\\sto\\sSpirodonFL's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s5\\sin\\sthe\\schannel!;tmi-sent-ts=1705423028822;user-id=611203908;user-type=;vip=0",
           args: ["tmi.twitch.tv USERNOTICE #spirodonfl"]
         }}

      expected = %TMI.Chat.Events.CommunitySubGift{
        badge_info: [{"subscriber", 1}],
        badges: [{"subscriber", 0}, {"premium", 1}],
        channel: "#spirodonfl",
        channel_id: "62338636",
        color: nil,
        cumulative_months: nil,
        cumulative_total: 5,
        display_name: "CkPuffin",
        emotes: [],
        event: :community_sub_gift,
        gift_theme: nil,
        goal_contributions: 5,
        goal_current: 142,
        goal_target: 1000,
        goal_type: :subs,
        id: "87c56a84-2802-4ff8-9f71-433b4eab98b9",
        is_mod?: false,
        is_sub?: true,
        is_turbo?: nil,
        is_vip?: false,
        login: "ckpuffin",
        plan: :t1,
        plan_name: nil,
        recipient_display_name: nil,
        recipient_id: nil,
        recipient_login: nil,
        system_message:
          "CkPuffin is gifting 5 Tier 1 Subs to SpirodonFL's community! They've gifted a total of 5 in the channel!",
        timestamp: ~U[2024-01-16 16:37:08.822Z],
        total: 5,
        user_id: "611203908",
        user_type: :normal
      }

      assert TMI.parse_message(message) == expected
    end
  end

  describe "payitforward" do
    test "message" do
      message =
        {:unrecognized,
         "@badge-info=subscriber/1;badges=subscriber/0,premium/1;color=;display-name=CkPuffin;emotes=;flags=;id=c2c9207d-8fce-498f-852b-20ab50634d74;login=ckpuffin;mod=0;msg-id=communitypayforward;msg-param-prior-gifter-anonymous=false;msg-param-prior-gifter-display-name=Master_Sn00ds;msg-param-prior-gifter-id=512159808;msg-param-prior-gifter-user-name=master_sn00ds;room-id=62338636;subscriber=1;system-msg=CkPuffin\\sis\\spaying\\sforward\\sthe\\sGift\\sthey\\sgot\\sfrom\\sMaster_Sn00ds\\sto\\sthe\\scommunity!;tmi-sent-ts=1705423028746;user-id=611203908;user-type=;vip=0",
         %ExIRC.Message{
           server: [],
           nick: [],
           user: [],
           host: [],
           ctcp: false,
           cmd:
             "@badge-info=subscriber/1;badges=subscriber/0,premium/1;color=;display-name=CkPuffin;emotes=;flags=;id=c2c9207d-8fce-498f-852b-20ab50634d74;login=ckpuffin;mod=0;msg-id=communitypayforward;msg-param-prior-gifter-anonymous=false;msg-param-prior-gifter-display-name=Master_Sn00ds;msg-param-prior-gifter-id=512159808;msg-param-prior-gifter-user-name=master_sn00ds;room-id=62338636;subscriber=1;system-msg=CkPuffin\\sis\\spaying\\sforward\\sthe\\sGift\\sthey\\sgot\\sfrom\\sMaster_Sn00ds\\sto\\sthe\\scommunity!;tmi-sent-ts=1705423028746;user-id=611203908;user-type=;vip=0",
           args: ["tmi.twitch.tv USERNOTICE #spirodonfl"]
         }}

      expected = %TMI.Chat.Events.PayItForward{
        badge_info: [{"subscriber", 1}],
        badges: [{"subscriber", 0}, {"premium", 1}],
        channel: "#spirodonfl",
        channel_id: "62338636",
        color: nil,
        cumulative_months: nil,
        cumulative_total: nil,
        display_name: "CkPuffin",
        gift_months: nil,
        id: "c2c9207d-8fce-498f-852b-20ab50634d74",
        is_mod?: false,
        is_sub?: true,
        is_turbo?: nil,
        is_vip?: false,
        login: "ckpuffin",
        system_message:
          "CkPuffin is paying forward the Gift they got from Master_Sn00ds to the community!",
        timestamp: ~U[2024-01-16 16:37:08.746Z],
        total: nil,
        user_id: "611203908",
        user_type: :normal
      }

      assert TMI.parse_message(message) == expected
    end
  end

  describe "subgift" do
    test "message" do
      message =
        {:unrecognized,
         "@badge-info=subscriber/1;badges=subscriber/0,sub-gift-leader/2;color=;display-name=CkPuffin;emotes=;flags=;id=bc2d37f2-c443-47b8-85a2-131e2b86e6eb;login=ckpuffin;mod=0;msg-id=subgift;msg-param-community-gift-id=17130216016315839265;msg-param-gift-months=1;msg-param-months=1;msg-param-origin-id=17130216016315839265;msg-param-recipient-display-name=Insanit13s;msg-param-recipient-id=46556277;msg-param-recipient-user-name=insanit13s;msg-param-sender-count=0;msg-param-sub-plan-name=Subscription\\s(spirodonfl);msg-param-sub-plan=1000;room-id=62338636;subscriber=1;system-msg=CkPuffin\\sgifted\\sa\\sTier\\s1\\ssub\\sto\\sInsanit13s!;tmi-sent-ts=1705423030121;user-id=611203908;user-type=;vip=0",
         %ExIRC.Message{
           server: [],
           nick: [],
           user: [],
           host: [],
           ctcp: false,
           cmd:
             "@badge-info=subscriber/1;badges=subscriber/0,sub-gift-leader/2;color=;display-name=CkPuffin;emotes=;flags=;id=bc2d37f2-c443-47b8-85a2-131e2b86e6eb;login=ckpuffin;mod=0;msg-id=subgift;msg-param-community-gift-id=17130216016315839265;msg-param-gift-months=1;msg-param-months=1;msg-param-origin-id=17130216016315839265;msg-param-recipient-display-name=Insanit13s;msg-param-recipient-id=46556277;msg-param-recipient-user-name=insanit13s;msg-param-sender-count=0;msg-param-sub-plan-name=Subscription\\s(spirodonfl);msg-param-sub-plan=1000;room-id=62338636;subscriber=1;system-msg=CkPuffin\\sgifted\\sa\\sTier\\s1\\ssub\\sto\\sInsanit13s!;tmi-sent-ts=1705423030121;user-id=611203908;user-type=;vip=0",
           args: ["tmi.twitch.tv USERNOTICE #spirodonfl"]
         }}

      expected = %TMI.Chat.Events.SubGift{
        badge_info: [{"subscriber", 1}],
        badges: [{"subscriber", 0}, {"sub-gift-leader", 2}],
        channel: "#spirodonfl",
        channel_id: "62338636",
        color: nil,
        cumulative_months: nil,
        cumulative_total: 0,
        display_name: "CkPuffin",
        gift_months: 1,
        gift_theme: nil,
        id: "bc2d37f2-c443-47b8-85a2-131e2b86e6eb",
        is_anon?: nil,
        is_mod?: false,
        is_sub?: true,
        is_turbo?: nil,
        is_vip?: false,
        plan: :t1,
        plan_name: "Subscription (spirodonfl)",
        recipient_display_name: "Insanit13s",
        recipient_id: "46556277",
        recipient_login: "insanit13s",
        system_message: "CkPuffin gifted a Tier 1 sub to Insanit13s!",
        timestamp: ~U[2024-01-16 16:37:10.121Z],
        user_id: "611203908",
        user_type: :normal
      }

      assert TMI.parse_message(message) == expected
    end
  end

  describe "sub" do
    test "message" do
      message =
        {:unrecognized,
         "@badge-info=subscriber/1;badges=subscriber/0,sub-gifter/100;color=#D2691E;display-name=hmida74;emotes=;flags=;id=d43ae6b6-15a1-4edd-b2d6-fa40970eb976;login=hmida74;mod=0;msg-id=sub;msg-param-cumulative-months=1;msg-param-goal-contribution-type=SUBS;msg-param-goal-current-contributions=244;msg-param-goal-target-contributions=1000;msg-param-goal-user-contributions=1;msg-param-months=0;msg-param-multimonth-duration=6;msg-param-multimonth-tenure=0;msg-param-should-share-streak=0;msg-param-sub-plan-name=Subscription\\s(spirodonfl):\\sTier\\s3\\sSub;msg-param-sub-plan=3000;msg-param-was-gifted=false;room-id=62338636;subscriber=1;system-msg=hmida74\\ssubscribed\\sat\\sTier\\s3.;tmi-sent-ts=1705439514873;user-id=453527071;user-type=;vip=0",
         %ExIRC.Message{
           server: [],
           nick: [],
           user: [],
           host: [],
           ctcp: false,
           cmd:
             "@badge-info=subscriber/1;badges=subscriber/0,sub-gifter/100;color=#D2691E;display-name=hmida74;emotes=;flags=;id=d43ae6b6-15a1-4edd-b2d6-fa40970eb976;login=hmida74;mod=0;msg-id=sub;msg-param-cumulative-months=1;msg-param-goal-contribution-type=SUBS;msg-param-goal-current-contributions=244;msg-param-goal-target-contributions=1000;msg-param-goal-user-contributions=1;msg-param-months=0;msg-param-multimonth-duration=6;msg-param-multimonth-tenure=0;msg-param-should-share-streak=0;msg-param-sub-plan-name=Subscription\\s(spirodonfl):\\sTier\\s3\\sSub;msg-param-sub-plan=3000;msg-param-was-gifted=false;room-id=62338636;subscriber=1;system-msg=hmida74\\ssubscribed\\sat\\sTier\\s3.;tmi-sent-ts=1705439514873;user-id=453527071;user-type=;vip=0",
           args: ["tmi.twitch.tv USERNOTICE #spirodonfl"]
         }}

      expected = %TMI.Chat.Events.Sub{
        badge_info: [{"subscriber", 1}],
        badges: [{"subscriber", 0}, {"sub-gifter", 100}],
        channel: "#spirodonfl",
        channel_id: "62338636",
        color: "#D2691E",
        cumulative_months: 1,
        display_name: "hmida74",
        gifted?: false,
        goal_contributions: 1,
        goal_current: 244,
        goal_target: 1000,
        goal_type: :subs,
        id: "d43ae6b6-15a1-4edd-b2d6-fa40970eb976",
        is_mod?: false,
        is_sub?: true,
        is_turbo?: nil,
        is_vip?: false,
        login: "hmida74",
        months: 0,
        plan: :t3,
        plan_name: "Subscription (spirodonfl): Tier 3 Sub",
        share_streak?: false,
        system_message: "hmida74 subscribed at Tier 3.",
        timestamp: ~U[2024-01-16 21:11:54.873Z],
        user_id: "453527071",
        user_type: :normal
      }

      assert TMI.parse_message(message) == expected
    end
  end

  describe "raid" do
    test "message" do
      message =
        {:unrecognized,
         "@badge-info=subscriber/1;badges=subscriber/0;color=;display-name=kristoff_it;emotes=;flags=;id=df6b34e1-45a6-4f3a-ae96-d4198c5c0423;login=kristoff_it;mod=0;msg-id=raid;msg-param-displayName=kristoff_it;msg-param-login=kristoff_it;msg-param-profileImageURL=https://static-cdn.jtvnw.net/jtv_user_pictures/903b2e36-528a-435f-85ea-ee194bda931e-profile_image-%s.png;msg-param-viewerCount=54;room-id=62338636;subscriber=1;system-msg=54\\sraiders\\sfrom\\skristoff_it\\shave\\sjoined!;tmi-sent-ts=1705428409218;user-id=102701971;user-type=;vip=0",
         %ExIRC.Message{
           server: [],
           nick: [],
           user: [],
           host: [],
           ctcp: false,
           cmd:
             "@badge-info=subscriber/1;badges=subscriber/0;color=;display-name=kristoff_it;emotes=;flags=;id=df6b34e1-45a6-4f3a-ae96-d4198c5c0423;login=kristoff_it;mod=0;msg-id=raid;msg-param-displayName=kristoff_it;msg-param-login=kristoff_it;msg-param-profileImageURL=https://static-cdn.jtvnw.net/jtv_user_pictures/903b2e36-528a-435f-85ea-ee194bda931e-profile_image-%s.png;msg-param-viewerCount=54;room-id=62338636;subscriber=1;system-msg=54\\sraiders\\sfrom\\skristoff_it\\shave\\sjoined!;tmi-sent-ts=1705428409218;user-id=102701971;user-type=;vip=0",
           args: ["tmi.twitch.tv USERNOTICE #spirodonfl"]
         }}

      expected = %TMI.Chat.Events.Raid{
        badge_info: [{"subscriber", 1}],
        badges: [{"subscriber", 0}],
        channel: "#spirodonfl",
        channel_id: "62338636",
        color: nil,
        display_name: "kristoff_it",
        emotes: [],
        id: "df6b34e1-45a6-4f3a-ae96-d4198c5c0423",
        is_mod?: false,
        is_sub?: true,
        is_turbo?: nil,
        is_vip?: false,
        login: "kristoff_it",
        profile_image_url:
          "https://static-cdn.jtvnw.net/jtv_user_pictures/903b2e36-528a-435f-85ea-ee194bda931e-profile_image-%s.png",
        system_message: "54 raiders from kristoff_it have joined!",
        timestamp: ~U[2024-01-16 18:06:49.218Z],
        user_id: "102701971",
        user_type: :normal,
        viewer_count: 54
      }

      assert TMI.parse_message(message) == expected
    end
  end
end
