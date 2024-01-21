defmodule TMI.Chat.TagsExamplesTest do
  use ExUnit.Case, async: true

  alias TMI.Chat.Tags

  # ----------------------------------------------------------------------------
  # communitypayforward
  # ----------------------------------------------------------------------------

  describe "communitypayforward" do
    test "single" do
      tagstring =
        "@badge-info=subscriber/1;badges=subscriber/0,turbo/1;color=#5DA5D9;display-name=RyanWinchester_;emotes=;flags=;id=d5ae6331-16be-4299-bdb4-c395ee9cd689;login=ryanwinchester_;mod=0;msg-id=communitypayforward;msg-param-prior-gifter-anonymous=false;msg-param-prior-gifter-display-name=1000needlesss;msg-param-prior-gifter-id=903424197;msg-param-prior-gifter-user-name=1000needlesss;room-id=866686220;subscriber=1;system-msg=RyanWinchester_\\sis\\spaying\\sforward\\sthe\\sGift\\sthey\\sgot\\sfrom\\s1000needlesss\\sto\\sthe\\scommunity!;tmi-sent-ts=1705107305409;user-id=146616692;user-type=;vip=0"

      expected = %{
        badge_info: [{"subscriber", 1}],
        badges: [{"subscriber", 0}, {"turbo", 1}],
        channel_id: "866686220",
        color: "#5DA5D9",
        display_name: "RyanWinchester_",
        emotes: [],
        event: :pay_it_forward,
        flags: [],
        id: "d5ae6331-16be-4299-bdb4-c395ee9cd689",
        is_mod?: false,
        is_sub?: true,
        is_vip?: false,
        login: "ryanwinchester_",
        system_message:
          "RyanWinchester_ is paying forward the Gift they got from 1000needlesss to the community!",
        timestamp: ~U[2024-01-13 00:55:05.409Z],
        user_id: "146616692",
        user_type: :normal,
        prior_gifter_anon?: false,
        prior_gifter_display_name: "1000needlesss",
        prior_gifter_id: "903424197",
        prior_gifter_login: "1000needlesss"
      }

      assert Tags.parse!(tagstring) == expected
    end
  end

  # ----------------------------------------------------------------------------
  # message
  # ----------------------------------------------------------------------------

  describe "message" do
    test "with emotes" do
      tagstring =
        "@badge-info=subscriber/1;badges=subscriber/0;client-nonce=cc77b2873a3b9bcba8a4ff9a50271153;color=#0000FF;display-name=fam1u;emotes=965738:0-7;first-msg=0;flags=;id=bbf8cf7c-d60d-4f77-b63e-2465ed440b61;mod=0;returning-chatter=0;room-id=151368796;subscriber=1;tmi-sent-ts=1705328197484;turbo=0;user-id=957119524;user-type="

      expected = %{
        badge_info: [{"subscriber", 1}],
        badges: [{"subscriber", 0}],
        channel_id: "151368796",
        client_nonce: "cc77b2873a3b9bcba8a4ff9a50271153",
        color: "#0000FF",
        display_name: "fam1u",
        emotes: [{"965738", [0..7]}],
        first_message?: false,
        flags: [],
        id: "bbf8cf7c-d60d-4f77-b63e-2465ed440b61",
        is_mod?: false,
        is_sub?: true,
        is_turbo?: false,
        returning_chatter?: false,
        timestamp: ~U[2024-01-15 14:16:37.484Z],
        user_id: "957119524",
        user_type: :normal
      }

      assert Tags.parse!(tagstring) == expected
    end

    test "with multiple same emotes" do
      tagstring =
        "@badge-info=subscriber/1;badges=vip/1,subscriber/0;color=#FF0000;display-name=thedevdad_;emote-only=1;emotes=emotesv2_d75c1e6b2d474ec8b0ae3b973fd9b6eb:0-9,11-20,22-31;first-msg=0;flags=;id=18fed7e1-a5fb-4743-9291-b3cfefa7c005;mod=0;returning-chatter=0;room-id=62338636;subscriber=1;tmi-sent-ts=1705354188210;turbo=0;user-id=722784403;user-type=;vip=1"

      expected = %{
        badge_info: [{"subscriber", 1}],
        badges: [{"vip", 1}, {"subscriber", 0}],
        channel_id: "62338636",
        color: "#FF0000",
        display_name: "thedevdad_",
        emote_only?: true,
        emotes: [{"emotesv2_d75c1e6b2d474ec8b0ae3b973fd9b6eb", [0..9, 11..20, 22..31]}],
        first_message?: false,
        flags: [],
        id: "18fed7e1-a5fb-4743-9291-b3cfefa7c005",
        is_mod?: false,
        is_sub?: true,
        is_turbo?: false,
        is_vip?: true,
        returning_chatter?: false,
        timestamp: ~U[2024-01-15 21:29:48.210Z],
        user_id: "722784403",
        user_type: :normal
      }

      assert Tags.parse!(tagstring) == expected
    end

    test "with multiple different emotes" do
      tagstring =
        "@badge-info=founder/1;badges=moderator/1,founder/0,turbo/1;client-nonce=d530ef6de047f084f13a07ef4c9482c8;color=#5DA5D9;display-name=RyanWinchester_;emote-only=1;emotes=emotesv2_638b796ee62e47499e8cf3e02e2fc01c:0-22/emotesv2_8dacc6af211a42cd82ab5dbda8ded800:24-36;first-msg=0;flags=;id=0d4df5c5-1238-4ec4-a8ee-672bb3589b85;mod=1;returning-chatter=0;room-id=62338636;subscriber=1;tmi-sent-ts=1705356946007;turbo=1;user-id=146616692;user-type=mod"

      expected = %{
        badge_info: [{"founder", 1}],
        badges: [{"moderator", 1}, {"founder", 0}, {"turbo", 1}],
        channel_id: "62338636",
        client_nonce: "d530ef6de047f084f13a07ef4c9482c8",
        color: "#5DA5D9",
        display_name: "RyanWinchester_",
        emote_only?: true,
        emotes: [
          {"emotesv2_638b796ee62e47499e8cf3e02e2fc01c", [0..22]},
          {"emotesv2_8dacc6af211a42cd82ab5dbda8ded800", [24..36]}
        ],
        first_message?: false,
        flags: [],
        id: "0d4df5c5-1238-4ec4-a8ee-672bb3589b85",
        is_mod?: true,
        is_sub?: true,
        is_turbo?: true,
        returning_chatter?: false,
        timestamp: ~U[2024-01-15 22:15:46.007Z],
        user_id: "146616692",
        user_type: :mod
      }

      assert Tags.parse!(tagstring) == expected
    end
  end

  # ----------------------------------------------------------------------------
  # raid
  # ----------------------------------------------------------------------------

  describe "raid" do
    test "10" do
      tagstring =
        "@badge-info=;badges=;color=#6EB319;display-name=Piq9117;emotes=;flags=;id=65dadc6f-5659-4aa3-892a-1963495f4faf;login=piq9117;mod=0;msg-id=raid;msg-param-displayName=Piq9117;msg-param-login=piq9117;msg-param-profileImageURL=https://static-cdn.jtvnw.net/jtv_user_pictures/22e8d110-3304-4b8e-aba6-d87c64066611-profile_image-%s.png;msg-param-viewerCount=10;room-id=62338636;subscriber=0;system-msg=10\\sraiders\\sfrom\\sPiq9117\\shave\\sjoined!;tmi-sent-ts=1705375362901;user-id=96440066;user-type=;vip=0"

      expected = %{
        :badge_info => nil,
        :badges => nil,
        :channel_id => "62338636",
        :color => "#6EB319",
        :display_name => "Piq9117",
        :emotes => [],
        :event => :raid,
        :flags => [],
        :id => "65dadc6f-5659-4aa3-892a-1963495f4faf",
        :is_mod? => false,
        :is_sub? => false,
        :is_vip? => false,
        :login => "piq9117",
        :system_message => "10 raiders from Piq9117 have joined!",
        :timestamp => ~U[2024-01-16 03:22:42.901Z],
        :user_id => "96440066",
        :user_type => :normal,
        :viewer_count => 10,
        :profile_image_url =>
          "https://static-cdn.jtvnw.net/jtv_user_pictures/22e8d110-3304-4b8e-aba6-d87c64066611-profile_image-%s.png"
      }

      assert Tags.parse!(tagstring) == expected
    end
  end

  # ----------------------------------------------------------------------------
  # sub
  # ----------------------------------------------------------------------------

  describe "sub" do
    test "with goals" do
      tagstring =
        "@badge-info=subscriber/1;badges=subscriber/0,premium/1;color=;display-name=litereader;emotes=;flags=;id=ea68c906-8a33-4883-b0a6-2a032c4fadcf;login=litereader;mod=0;msg-id=sub;msg-param-cumulative-months=1;msg-param-goal-contribution-type=SUBS;msg-param-goal-current-contributions=57802;msg-param-goal-description=You're\\smadlads.;msg-param-goal-target-contributions=77777;msg-param-goal-user-contributions=1;msg-param-months=0;msg-param-multimonth-duration=1;msg-param-multimonth-tenure=0;msg-param-should-share-streak=0;msg-param-sub-plan-name=Download\\sA\\sPirate;msg-param-sub-plan=Prime;msg-param-was-gifted=false;room-id=151368796;subscriber=1;system-msg=litereader\\ssubscribed\\swith\\sPrime.;tmi-sent-ts=1705328433445;user-id=501433610;user-type=;vip=0"

      expected = %{
        :flags => [],
        :id => "ea68c906-8a33-4883-b0a6-2a032c4fadcf",
        :timestamp => ~U[2024-01-15 14:20:33.445Z],
        :user_type => :normal,
        :color => nil,
        :plan => :prime,
        :emotes => [],
        :badge_info => [{"subscriber", 1}],
        :badges => [{"subscriber", 0}, {"premium", 1}],
        :display_name => "litereader",
        :login => "litereader",
        :is_mod? => false,
        :event => :sub,
        :cumulative_months => 1,
        :months => 0,
        :goal_type => :subs,
        :goal_current => 57802,
        :goal_description => "You're madlads.",
        :goal_target => 77777,
        :goal_contributions => 1,
        :share_streak? => false,
        :plan_name => "Download A Pirate",
        :channel_id => "151368796",
        :is_sub? => true,
        :system_message => "litereader subscribed with Prime.",
        :user_id => "501433610",
        :is_vip? => false,
        :gifted? => false,
        # Not sure about these next two...
        :multimonth_duration => 1,
        :multimonth_tenure => 0
      }

      assert Tags.parse!(tagstring) == expected
    end
  end

  # ----------------------------------------------------------------------------
  # subgift
  # ----------------------------------------------------------------------------

  describe "subgift" do
    test "single" do
      tagstring =
        "@badge-info=subscriber/47;badges=broadcaster/1,subscriber/0,sub-gifter/5;color=#5DA5D9;display-name=ShyRyan;emotes=;flags=;id=11052334-9acb-4c3d-8bdd-b58b084ec3d5;login=shyryan;mod=0;msg-id=subgift;msg-param-community-gift-id=3338120729465115224;msg-param-gift-months=1;msg-param-months=1;msg-param-origin-id=3338120729465115224;msg-param-recipient-display-name=im_rab;msg-param-recipient-id=597882881;msg-param-recipient-user-name=im_rab;msg-param-sender-count=0;msg-param-sub-plan-name=T1;msg-param-sub-plan=1000;room-id=146616692;subscriber=1;system-msg=ShyRyan\\sgifted\\sa\\sTier\\s1\\ssub\\sto\\sim_rab!;tmi-sent-ts=1704839998707;user-id=146616692;user-type=;vip=0"

      expected = %{
        id: "11052334-9acb-4c3d-8bdd-b58b084ec3d5",
        badge_info: [{"subscriber", 47}],
        badges: [{"broadcaster", 1}, {"subscriber", 0}, {"sub-gifter", 5}],
        channel_id: "146616692",
        color: "#5DA5D9",
        community_gift_id: "3338120729465115224",
        display_name: "ShyRyan",
        emotes: [],
        event: :sub_gift,
        flags: [],
        is_mod?: false,
        is_sub?: true,
        is_vip?: false,
        login: "shyryan",
        origin_id: "3338120729465115224",
        plan: :t1,
        cumulative_total: 0,
        system_message: "ShyRyan gifted a Tier 1 sub to im_rab!",
        timestamp: ~U[2024-01-09 22:39:58.707Z],
        user_id: "146616692",
        user_type: :normal,
        months: 1,
        gift_months: 1,
        plan_name: "T1",
        recipient_display_name: "im_rab",
        recipient_id: "597882881",
        recipient_login: "im_rab"
      }

      assert Tags.parse!(tagstring) == expected
    end

    test "with goals" do
      tagstring =
        "@badge-info=subscriber/1;badges=subscriber/0,sub-gift-leader/1;color=#00FF7F;display-name=ShyRyan;emotes=;flags=;id=c350a1c6-1885-4ae9-aeb0-a05c107c06b2;login=shyryan;mod=0;msg-id=subgift;msg-param-gift-months=1;msg-param-goal-contribution-type=SUBS;msg-param-goal-current-contributions=101;msg-param-goal-target-contributions=1000;msg-param-goal-user-contributions=1;msg-param-months=1;msg-param-origin-id=6106034385646135666;msg-param-recipient-display-name=SpirodonFL;msg-param-recipient-id=514459618;msg-param-recipient-user-name=spirodonfl;msg-param-sender-count=21;msg-param-sub-plan-name=Subscription\\s(spirodonfl);msg-param-sub-plan=1000;room-id=62338636;subscriber=1;system-msg=ShyRyan\\sgifted\\sa\\sTier\\s1\\ssub\\sto\\sspirodonfl!\\sThey\\shave\\sgiven\\s21\\sGift\\sSubs\\sin\\sthe\\schannel!;tmi-sent-ts=1705115570671;user-id=512159808;user-type=;vip=0"

      expected = %{
        :badge_info => [{"subscriber", 1}],
        :badges => [{"subscriber", 0}, {"sub-gift-leader", 1}],
        :channel_id => "62338636",
        :color => "#00FF7F",
        :months => 1,
        :display_name => "ShyRyan",
        :emotes => [],
        :event => :sub_gift,
        :flags => [],
        :gift_months => 1,
        :id => "c350a1c6-1885-4ae9-aeb0-a05c107c06b2",
        :is_mod? => false,
        :is_sub? => true,
        :is_vip? => false,
        :origin_id => "6106034385646135666",
        :plan => :t1,
        :plan_name => "Subscription (spirodonfl)",
        :recipient_display_name => "SpirodonFL",
        :recipient_id => "514459618",
        :recipient_login => "spirodonfl",
        :cumulative_total => 21,
        :system_message =>
          "ShyRyan gifted a Tier 1 sub to spirodonfl! They have given 21 Gift Subs in the channel!",
        :timestamp => ~U[2024-01-13 03:12:50.671Z],
        :user_id => "512159808",
        :login => "shyryan",
        :user_type => :normal,
        :goal_type => :subs,
        :goal_current => 101,
        :goal_target => 1000,
        :goal_contributions => 1
      }

      assert Tags.parse!(tagstring) == expected
    end
  end

  # ----------------------------------------------------------------------------
  # submysterygift
  # ----------------------------------------------------------------------------

  describe "submysterygift" do
    test "without goals" do
      tagstring =
        "@badge-info=subscriber/47;badges=broadcaster/1,subscriber/0,sub-gifter/1;color=#5DA5D9;display-name=ShyRyan;emotes=;flags=;id=46c76cb5-0f3f-4605-92b7-66d010f544a1;login=shyryan;mod=0;msg-id=submysterygift;msg-param-community-gift-id=3338120729465115224;msg-param-mass-gift-count=5;msg-param-origin-id=3338120729465115224;msg-param-sender-count=0;msg-param-sub-plan=1000;room-id=146616692;subscriber=1;system-msg=ShyRyan\\sis\\sgifting\\s5\\sTier\\s1\\sSubs\\sto\\sShyRyan's\\scommunity!;tmi-sent-ts=1704839998029;user-id=146616692;user-type=;vip=0"

      expected = %{
        id: "46c76cb5-0f3f-4605-92b7-66d010f544a1",
        badge_info: [{"subscriber", 47}],
        badges: [{"broadcaster", 1}, {"subscriber", 0}, {"sub-gifter", 1}],
        color: "#5DA5D9",
        community_gift_id: "3338120729465115224",
        total: 5,
        display_name: "ShyRyan",
        emotes: [],
        event: :community_sub_gift,
        flags: [],
        is_mod?: false,
        is_sub?: true,
        is_vip?: false,
        login: "shyryan",
        origin_id: "3338120729465115224",
        plan: :t1,
        cumulative_total: 0,
        system_message: "ShyRyan is gifting 5 Tier 1 Subs to ShyRyan's community!",
        timestamp: ~U[2024-01-09 22:39:58.029Z],
        user_id: "146616692",
        user_type: :normal,
        channel_id: "146616692"
      }

      assert Tags.parse!(tagstring) == expected
    end
  end

  # ----------------------------------------------------------------------------
  # thread
  # ----------------------------------------------------------------------------

  describe "thread" do
    test "reply" do
      tagstring =
        "@badge-info=;badges=;client-nonce=e3c392468efe2e988ef2b819559fc66b;color=#008000;display-name=shoodyDK;emotes=;first-msg=0;flags=;id=c33560e7-5edc-4f70-9721-7c3d1e6070e5;mod=0;reply-parent-display-name=Nightbot;reply-parent-msg-body=Are\\syou\\sinterested\\sin\\sbackend\\sdev?\\s\\sCheck\\sout\\shttps://boot.dev/?promo=PRIME\\s.\\s\\sIt\\sis\\salso\\s_the\\sbest\\sway_\\sto\\ssupport\\sme!;reply-parent-msg-id=27755263-8244-4608-86e6-44c6f0da7985;reply-parent-user-id=19264788;reply-parent-user-login=nightbot;reply-thread-parent-display-name=Nightbot;reply-thread-parent-msg-id=27755263-8244-4608-86e6-44c6f0da7985;reply-thread-parent-user-id=19264788;reply-thread-parent-user-login=nightbot;returning-chatter=0;room-id=167160215;subscriber=0;tmi-sent-ts=1705166149366;turbo=0;user-id=36828239;user-type="

      expected = %{
        badge_info: nil,
        badges: nil,
        channel_id: "167160215",
        color: "#008000",
        display_name: "shoodyDK",
        emotes: [],
        flags: [],
        id: "c33560e7-5edc-4f70-9721-7c3d1e6070e5",
        is_mod?: false,
        is_sub?: false,
        is_turbo?: false,
        parent_id: "27755263-8244-4608-86e6-44c6f0da7985",
        parent_message:
          "Are you interested in backend dev?  Check out https://boot.dev/?promo=PRIME .  It is also _the best way_ to support me!",
        parent_user_id: "19264788",
        thread_parent_id: "27755263-8244-4608-86e6-44c6f0da7985",
        timestamp: ~U[2024-01-13 17:15:49.366Z],
        user_id: "36828239",
        user_type: :normal,
        client_nonce: "e3c392468efe2e988ef2b819559fc66b",
        first_message?: false,
        parent_user_display_name: "Nightbot",
        parent_user_login: "nightbot",
        returning_chatter?: false,
        thread_parent_user_display_name: "Nightbot",
        thread_parent_user_id: "19264788",
        thread_parent_user_login: "nightbot"
      }

      assert Tags.parse!(tagstring) == expected
    end
  end

  # ----------------------------------------------------------------------------
  # viewermilestone
  # ----------------------------------------------------------------------------

  describe "viewermilestone" do
    test "consecutive streams" do
      tagstring =
        "@badge-info=;badges=;color=#006600;display-name=Zullfix_;emotes=;flags=;id=9841acf0-ae26-4327-a897-340044a93d82;login=zullfix_;mod=0;msg-id=viewermilestone;msg-param-category=watch-streak;msg-param-copoReward=450;msg-param-id=bff2925e-aba5-4002-aaa6-e3f0904aee23;msg-param-value=15;room-id=866686220;subscriber=0;system-msg=Zullfix_\\swatched\\s15\\sconsecutive\\sstreams\\sthis\\smonth\\sand\\ssparked\\sa\\swatch\\sstreak!;tmi-sent-ts=1705107852086;user-id=187886731;user-type=;vip=0"

      expected = %{
        :badge_info => nil,
        :badges => nil,
        :channel_id => "866686220",
        :channel_points => "450",
        :color => "#006600",
        :display_name => "Zullfix_",
        :emotes => [],
        :event => :viewer_milestone,
        :flags => [],
        :id => "9841acf0-ae26-4327-a897-340044a93d82",
        :is_mod? => false,
        :is_sub? => false,
        :is_vip? => false,
        :login => "zullfix_",
        :milestone => :watch_streak,
        :system_message =>
          "Zullfix_ watched 15 consecutive streams this month and sparked a watch streak!",
        :timestamp => ~U[2024-01-13 01:04:12.086Z],
        :total => 15,
        :user_id => "187886731",
        :user_type => :normal,
        :ignore => "bff2925e-aba5-4002-aaa6-e3f0904aee23"
      }

      assert Tags.parse!(tagstring) == expected
    end
  end
end
