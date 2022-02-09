defmodule Enux.Jsonc do
  @moduledoc false

  import Enux.Utils

  @doc """
  decodes the jsonc passed to it by `Enux.load` and format it into a keyword list
  """
  def decode(content, opts) do
    decode = get_decode_function()
    decoded = decode.(content)

    cond do
      is_map(decoded) -> decoded |> map_to_keyword_list(opts)
      true -> decoded
    end
  end

  defp get_decode_function do
    cond do
      is_list(Application.spec(:jsonc)) ->
        &JSONC.decode!/1

      true ->
        raise "No jsonc decoder found"
    end
  end
end
