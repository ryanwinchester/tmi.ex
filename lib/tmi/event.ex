defmodule TMI.Event do
  defmacro __using__(opts) do
    mappings =
      opts
      |> Keyword.get(:param_tags, [])
      |> Enum.map(&param_tag_mapping/1)

    quote do
      defstruct []

      def from_tags(tags) do
        TMI.Event.from_tags(__MODULE__, unquote(mappings), tags)
      end
    end
  end

  def from_tags(module, params_tags, tags) do
    #
  end

  def param_tag_mapping("msg-param-" <> param = tag) do
    param =
      tag
      |> String.replace("-", "_")
      |> String.replace(~r/[a-z]([A-Z])/, )

    {tag, String.replace(tag, "-", "_")}
  end
end
