ExUnit.start()

defmodule BitsSigils do
  @moduledoc false
  require Logger

  @doc false
  defmacro sigil_b({:<<>>, meta, [arg]}, modifiers) do
    result = do_sigil_b(arg, modifiers)
    {:<<>>, meta, [Macro.escape(result)]}
  end

  @doc false
  defp do_sigil_b(term, _modifiers) do
    for <<c <- term>>,
      into: <<>> do
      case c do
        ^c when c in [?0, ?1] ->
          # It's a valid character as an element.
          <<c::1>>

        ^c when c in [?_, ?\s] ->
          # It's a valid character as a just placeholder.
          <<>>

        _ ->
          Logger.warn(
            "Given unexpected sigil_b character, just ignored. The character was \"#{:binary.encode_unsigned(c)}\", its integer value was #{
              c
            }."
          )

          <<>>
      end
    end
  end
end
