defmodule Enux.Json do
  @moduledoc """
  handles json files
  """
  import Enux.Utils

  @doc """
  decodes the json passed to it by `Enux.load` and format it into a keyword list
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
      is_list(Application.spec(:jason)) ->
        &Jason.decode!/1

      is_list(Application.spec(:poison)) ->
        &Poison.decode!/1

      is_list(Application.spec(:jaxon)) ->
        &Jaxon.decode!/1

      is_list(Application.spec(:jsone)) ->
        &:jsone.decode/1

      is_list(Application.spec(:thoas)) ->
        decode = &:thoas.decode/1

        fn input ->
          case decode.(input) do
            {:ok, output} ->
              output

            {:error, error} ->
              case is_tuple(error) do
                true -> raise error |> elem(0) |> to_string()
                false -> raise error |> to_string()
              end
          end
        end

      true ->
        raise "No json decoder found"
    end
  end

  defp map_to_keyword_list(map, opts) when is_map(map) do
    map
    |> Enum.map(fn {k, v} ->
      case {k, v} do
        {k, v} when is_map(v) ->
          {k |> handle_number() |> String.to_atom(), v |> map_to_keyword_list(opts)}

        {k, v} ->
          {k |> handle_number() |> String.to_atom(), v |> url_encode_conditional(opts)}
      end
    end)
    |> Keyword.new()
  end
end
