defmodule BenchVersion do
  import Kernel, except: [match?: 2]

  def lexer(string) do
    string
    |> Version.Parser.lexer([])
    |> Enum.map(fn
      op when is_atom(op) -> op
      version when is_binary(version) -> elem(Version.Parser.parse_version(version, true), 1)
    end)
  end

  def match?(version, string, opts \\ []) do
    allow_pre = Keyword.get(opts, :allow_pre, true)
    matchable_pattern = to_matchable(version, allow_pre)

    do_match?(lexer(string), matchable_pattern)
  end

  def lexed_match?(version, lexed_requirement, opts \\ []) do
    allow_pre = Keyword.get(opts, :allow_pre, true)
    matchable_pattern = to_matchable(version, allow_pre)

    do_match?(lexed_requirement, matchable_pattern)
  end

  defp do_compare({major1, minor1, patch1, pre1, _}, {major2, minor2, patch2, pre2, _}) do
    cond do
      {major1, minor1, patch1} > {major2, minor2, patch2} -> :gt
      {major1, minor1, patch1} < {major2, minor2, patch2} -> :lt
      pre1 == [] and pre2 != [] -> :gt
      pre1 != [] and pre2 == [] -> :lt
      pre1 > pre2 -> :gt
      pre1 < pre2 -> :lt
      true -> :eq
    end
  end

  defp do_match?([operator, req, :&& | rest], version) do
    do_match?([operator, req], version) and do_match?(rest, version)
  end

  defp do_match?([operator, req, :|| | rest], version) do
    do_match?([operator, req], version) or do_match?(rest, version)
  end

  defp do_match?([:==, req], version) do
    do_compare(version, req) == :eq
  end

  defp do_match?([:!=, req], version) do
    do_compare(version, req) != :eq
  end

  defp do_match?([:~>, {major, minor, nil, req_pre, _}], {_, _, _, pre, allow_pre} = version) do
    (allow_pre or req_pre != [] or pre == []) and
      do_compare(version, {major, minor, 0, [], nil}) in [:eq, :gt] and
      do_compare(version, {major + 1, 0, 0, [0], nil}) == :lt
  end

  defp do_match?([:~>, {major, minor, _, req_pre, _} = req], {_, _, _, pre, allow_pre} = version) do
    (allow_pre or req_pre != [] or pre == []) and
      do_compare(version, req) in [:eq, :gt] and
      do_compare(version, {major, minor + 1, 0, [0], nil}) == :lt
  end

  defp do_match?([:>, {_, _, _, req_pre, _} = req], {_, _, _, pre, allow_pre} = version) do
    (allow_pre or req_pre != [] or pre == []) and do_compare(version, req) == :gt
  end

  defp do_match?([:>=, {_, _, _, req_pre, _} = req], {_, _, _, pre, allow_pre} = version) do
    (allow_pre or req_pre != [] or pre == []) and do_compare(version, req) in [:eq, :gt]
  end

  defp do_match?([:<, req], version) do
    do_compare(version, req) == :lt
  end

  defp do_match?([:<=, req], version) do
    do_compare(version, req) in [:eq, :lt]
  end

  defp to_matchable(%Version{major: major, minor: minor, patch: patch, pre: pre}, allow_pre?) do
    {major, minor, patch, pre, allow_pre?}
  end

  defp to_matchable(string, allow_pre?) do
    case Version.Parser.parse_version(string) do
      {:ok, {major, minor, patch, pre, _build_parts}} ->
        {major, minor, patch, pre, allow_pre?}

      :error ->
        throw(:oops)
    end
  end
end
