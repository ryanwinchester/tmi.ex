import Config

config :dicebot,
  bots: [
    [
      bot: Dicebot,
      user: "myname",
      pass: "oauth:mypass",
      channels: ["mychannel"],
      debug: false
    ]
  ]
