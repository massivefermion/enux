defmodule Enux.Env do
  @moduledoc """
  handles env files
  """
  import Enux.Utils

  @doc """
  decodes the content of the env file passed to it by Enux.load and format it into a keyword list
  """
  def decode(content, opts) do
    content
    |> Enum.filter(fn l -> String.trim(l) != "" end)
    |> Enum.map(fn l ->
      Regex.run(~r/(?<k>[A-Za-z0-9_\s]+)=(?<v>.*)/, l, capture: :all_but_first)
    end)
    |> Enum.map(fn l -> l |> Enum.map(fn i -> String.trim(i) end) end)
    |> Enum.map(fn [k, v] ->
      {k |> handle_number() |> String.to_atom(), v |> url_encode_conditional(opts)}
    end)
  end
end
