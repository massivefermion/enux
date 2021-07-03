defmodule Enux.Utils do
  @moduledoc """
  Some useful functions
  """

  @doc """
  throws an error if a key starts with a digit
  """
  def handle_number(key) when is_binary(key) do
    case key |> String.first() |> Integer.parse() do
      {_, ""} -> throw("#{key} starts with a digit")
      :error -> key
    end
  end

  @doc """
  if url_encoded: true is passed as an option to Enux.load, this function will url encode the binary values
  """
  def url_encode_conditional(value, opts)
      when is_binary(value) and is_list(opts) do
    case opts |> Keyword.get(:url_encoded, false) do
      true -> value |> URI.encode()
      false -> value
    end
  end

  def url_encode_conditional(value, _opts) do
    value
  end
end
