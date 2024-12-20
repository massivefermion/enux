defmodule Enux.Json do
  @moduledoc false

  import Enux.Utils

  @doc """
  decodes the json passed to it by `Enux.load` and format it into a keyword list
  """
  def decode(content, opts) do
    decode = get_decode_function()
    decoded = decode.(content)

    cond do
      is_map(decoded) -> map_to_keyword_list(decoded, opts)
      true -> decoded
    end
  end

  defp get_decode_function do
    cond do
      is_list(Application.spec(:jsonrs)) ->
        &Jsonrs.decode!/1

      is_list(Application.spec(:jason)) ->
        &Jason.decode!/1

      is_list(Application.spec(:poison)) ->
        &Poison.decode!/1

      is_list(Application.spec(:jaxon)) ->
        &Jaxon.decode!/1

      is_list(Application.spec(:json)) ->
        &JSON.decode!/1

      is_list(Application.spec(:jsone)) ->
        &:jsone.decode/1

      is_list(Application.spec(:euneus)) ->
        decode = &:euneus.decode/1

        fn input ->
          case decode.(input) do
            {:ok, output} ->
              output

            {:error, error} ->
              case is_tuple(error) do
                true -> raise error |> elem(0) |> to_string()
                false -> raise to_string(error)
              end
          end
        end

      is_list(Application.spec(:thoas)) ->
        decode = &:thoas.decode/1

        fn input ->
          case decode.(input) do
            {:ok, output} ->
              output

            {:error, error} ->
              case is_tuple(error) do
                true -> raise error |> elem(0) |> to_string()
                false -> raise to_string(error)
              end
          end
        end

      is_list(Application.spec(:jsonc)) ->
        &JSONC.decode!/1

      has_native_json_module() ->
        &:json.decode/1

      true ->
        raise "No json decoder found"
    end
  end
end
