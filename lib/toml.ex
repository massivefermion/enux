defmodule Enux.Toml do
  @moduledoc false

  import Enux.Utils

  @doc """
  decodes the toml passed to it by `Enux.load` and format it into a keyword list
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
      is_list(Application.spec(:toml)) ->
        &Toml.decode!/1

      is_list(Application.spec(:tomerl)) ->
        fn input ->
          case :tomerl.parse(input) do
            {:ok, result} -> result
            {:error, _} -> raise "tomerl decode error"
          end
        end

      is_list(Application.spec(:tomlex)) ->
        &Tomlex.load/1

      true ->
        raise "No toml decoder found"
    end
  end
end
