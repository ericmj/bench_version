defmodule BenchVersionTest do
  use ExUnit.Case, async: true

  alias BenchVersion, as: Version

  test "==" do
    assert Version.match?("2.3.0", "2.3.0")
    refute Version.match?("2.4.0", "2.3.0")

    assert Version.match?("2.3.0", "== 2.3.0")
    refute Version.match?("2.4.0", "== 2.3.0")

    assert Version.match?("1.0.0", "1.0.0")
    assert Version.match?("1.0.0", "1.0.0")

    assert Version.match?("1.2.3-alpha", "1.2.3-alpha")

    assert Version.match?("0.9.3", "== 0.9.3+dev")

    # {:ok, vsn} = Version.parse("2.3.0")
    # assert Version.match?(vsn, "2.3.0")
  end

  test "!=" do
    assert Version.match?("2.4.0", "!2.3.0")
    refute Version.match?("2.3.0", "!2.3.0")

    assert Version.match?("2.4.0", "!= 2.3.0")
    refute Version.match?("2.3.0", "!= 2.3.0")
  end

  test ">" do
    assert Version.match?("2.4.0", "> 2.3.0")
    refute Version.match?("2.2.0", "> 2.3.0")
    refute Version.match?("2.3.0", "> 2.3.0")

    assert Version.match?("1.2.3", "> 1.2.3-alpha")
    assert Version.match?("1.2.3-alpha.1", "> 1.2.3-alpha")
    assert Version.match?("1.2.3-alpha.beta.sigma", "> 1.2.3-alpha.beta")
    refute Version.match?("1.2.3-alpha.10", "< 1.2.3-alpha.1")
    refute Version.match?("0.10.2-dev", "> 0.10.2")
  end

  test ">=" do
    assert Version.match?("2.4.0", ">= 2.3.0")
    refute Version.match?("2.2.0", ">= 2.3.0")
    assert Version.match?("2.3.0", ">= 2.3.0")

    assert Version.match?("2.0.0", ">= 1.0.0")
    assert Version.match?("1.0.0", ">= 1.0.0")
  end

  test "<" do
    assert Version.match?("2.2.0", "< 2.3.0")
    refute Version.match?("2.4.0", "< 2.3.0")
    refute Version.match?("2.3.0", "< 2.3.0")

    assert Version.match?("0.10.2-dev", "< 0.10.2")

    refute Version.match?("1.0.0", "< 1.0.0-dev")
    refute Version.match?("1.2.3-dev", "< 0.1.2")
  end

  test "<=" do
    assert Version.match?("2.2.0", "<= 2.3.0")
    refute Version.match?("2.4.0", "<= 2.3.0")
    assert Version.match?("2.3.0", "<= 2.3.0")
  end

  describe "~>" do
    test "regular cases" do
      assert Version.match?("3.0.0", "~> 3.0")
      assert Version.match?("3.2.0", "~> 3.0")
      refute Version.match?("4.0.0", "~> 3.0")
      refute Version.match?("4.4.0", "~> 3.0")

      assert Version.match?("3.0.2", "~> 3.0.0")
      assert Version.match?("3.0.0", "~> 3.0.0")
      refute Version.match?("3.1.0", "~> 3.0.0")
      refute Version.match?("3.4.0", "~> 3.0.0")

      assert Version.match?("3.6.0", "~> 3.5")
      assert Version.match?("3.5.0", "~> 3.5")
      refute Version.match?("4.0.0", "~> 3.5")
      refute Version.match?("5.0.0", "~> 3.5")

      assert Version.match?("3.5.2", "~> 3.5.0")
      assert Version.match?("3.5.4", "~> 3.5.0")
      refute Version.match?("3.6.0", "~> 3.5.0")
      refute Version.match?("3.6.3", "~> 3.5.0")

      assert Version.match?("0.9.3", "~> 0.9.3-dev")
      refute Version.match?("0.10.0", "~> 0.9.3-dev")

      refute Version.match?("0.3.0-dev", "~> 0.2.0")

      # assert_raise Version.InvalidRequirementError, fn ->
      #   Version.match?("3.0.0", "~> 3")
      # end
    end

    test "~> will never include pre-release versions of its upper bound" do
      refute Version.match?("2.2.0-dev", "~> 2.1.0")
      refute Version.match?("2.2.0-dev", "~> 2.1.0", allow_pre: false)
      refute Version.match?("2.2.0-dev", "~> 2.1.0-dev")
      refute Version.match?("2.2.0-dev", "~> 2.1.0-dev", allow_pre: false)
    end
  end

  test "allow_pre" do
    assert Version.match?("1.1.0", "~> 1.0", allow_pre: true)
    assert Version.match?("1.1.0", "~> 1.0", allow_pre: false)
    assert Version.match?("1.1.0-beta", "~> 1.0", allow_pre: true)
    refute Version.match?("1.1.0-beta", "~> 1.0", allow_pre: false)
    assert Version.match?("1.0.1-beta", "~> 1.0.0-beta", allow_pre: false)

    assert Version.match?("1.1.0", ">= 1.0.0", allow_pre: true)
    assert Version.match?("1.1.0", ">= 1.0.0", allow_pre: false)
    assert Version.match?("1.1.0-beta", ">= 1.0.0", allow_pre: true)
    refute Version.match?("1.1.0-beta", ">= 1.0.0", allow_pre: false)
    assert Version.match?("1.1.0-beta", ">= 1.0.0-beta", allow_pre: false)
  end

  test "and" do
    assert Version.match?("0.9.3", "> 0.9.0 and < 0.10.0")
    refute Version.match?("0.10.2", "> 0.9.0 and < 0.10.0")
  end

  test "or" do
    assert Version.match?("0.9.1", "0.9.1 or 0.9.3 or 0.9.5")
    assert Version.match?("0.9.3", "0.9.1 or 0.9.3 or 0.9.5")
    assert Version.match?("0.9.5", "0.9.1 or 0.9.3 or 0.9.5")

    refute Version.match?("0.9.6", "0.9.1 or 0.9.3 or 0.9.5")
  end
end
