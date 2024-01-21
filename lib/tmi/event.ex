defmodule TMI.Event do
  @moduledoc false
  # Behaviour and implementation of Events.
  #
  # Use a list of `:fields` to build the struct and struct type for an event
  # module.
  #
  # This isn't great because we will only see the types in the LSP and docs.
  # However, it saves me a lot of time while writing this library.
  #
  # In the future I will either figure out some way to do codegen or manually
  # build the structs and types.
  #
  # ## Options
  #
  #   * `:fields` - A list of field names. Must match the types in `TMI.Fields`.
  #      Required.
  #
  # ## Example
  #
  #     defmodule TMI.Chat.Events.Foo
  #       use TMI.Event, fields: [:foo, :bar]
  #     end
  #

  @doc false
  defmacro __using__(opts) do
    fields = Keyword.fetch!(opts, :fields)

    field_types =
      for field_name <- fields do
        {field_name, quote(do: TMI.Fields.unquote(field_name))}
      end

    quote do
      @type t :: %__MODULE__{unquote_splicing(field_types)}
      defstruct(unquote(fields))
    end
  end
end
