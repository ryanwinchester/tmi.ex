defmodule Mix.Tasks.FetchTags do
  use Mix.Task

  @tag_ref_url "https://dev.twitch.tv/docs/irc/tags"

  def run(_) do
    Mix.shell().info("Fetching tags from #{@tag_ref_url}")

    Application.ensure_all_started(:tmi)

    tags =
      Req.get!(@tag_ref_url).body
      |> Floki.parse_document!()
      |> Floki.find("table")
      |> List.delete_at(0)
      |> Enum.flat_map(fn table ->
        table
        |> Floki.find("tr")
        |> Enum.map(fn row ->
          row
          |> Floki.find("td")
          |> Enum.map(&Floki.text/1)
          |> List.to_tuple()
        end)
      end)
      |> Enum.reject(&(&1 == {}))
      |> Enum.uniq_by(&elem(&1, 0))
      |> Enum.sort_by(&elem(&1, 0))

    File.write!(
      "priv/data/tags.ex",
      inspect(tags, pretty: true, limit: :infinity)
    )
  end
end
