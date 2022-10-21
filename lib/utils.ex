defmodule Enux.Utils do
  @moduledoc false

  @doc """
  transforms a map into a keyword list
  """
  def map_to_keyword_list(map, opts) when is_map(map) do
    Enum.map(map, fn {k, v} ->
      k =
        case is_binary(k) do
          true ->
            k |> handle_number() |> handle_whitespace() |> String.to_atom()

          false ->
            k
        end

      case {k, v} do
        {k, v} when is_map(v) and not is_struct(v) ->
          {k, map_to_keyword_list(v, opts)}

        {k, v} ->
          {k, url_encode_conditional(v, opts)}
      end
    end)
    |> Keyword.new()
  end

  @doc """
  raises an error if a key contains whitespace
  """
  def handle_whitespace(key) when is_binary(key) do
    case ["\t", "\s"] |> Enum.any?(fn s -> String.contains?(key, s) end) do
      true -> raise "#{key} contains whitespace"
      false -> key
    end
  end

  @doc """
  raises an error if a key starts with a digit
  """
  def handle_number(key) when is_binary(key) do
    case key |> String.first() |> Integer.parse() do
      {_, ""} -> raise "#{key} starts with a digit"
      :error -> key
    end
  end

  @doc """
  if url_encoded: true is passed as an option to `Enux.load`, this function will url encode the binary values
  """
  def url_encode_conditional(value, opts)
      when is_binary(value) and is_list(opts) do
    case Keyword.get(opts, :url_encoded, false) do
      true -> URI.encode(value)
      false -> value
    end
  end

  def url_encode_conditional(value, _opts) do
    value
  end
end
