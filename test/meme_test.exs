defmodule MemeTest do
  use ExUnit.Case

  import Meme
  import ExUnit.CaptureLog

  doctest Meme

  @ttl 1000
  @randlimit 6_000_000_000

  defmemo rand_public(limit), timeout: @ttl do
    :rand.uniform(limit)
  end

  test "defmemo" do
    result = __MODULE__.rand_public(@randlimit)
    assert result == __MODULE__.rand_public(@randlimit)
    _ = :timer.sleep(@ttl * 2)
    assert result != __MODULE__.rand_public(@randlimit)
  end

  test "get the value from cache" do
    __MODULE__.rand_public(@randlimit)

    assert capture_log(fn ->
             __MODULE__.rand_public(@randlimit)
           end) =~ "cached_value"
  end

  defmemo rand_public_when(limit) when is_integer(limit) and limit > 0, timeout: @ttl do
    :rand.uniform(limit)
  end

  test "defmemo + when" do
    result = __MODULE__.rand_public_when(@randlimit)
    assert result == __MODULE__.rand_public_when(@randlimit)
    _ = :timer.sleep(@ttl * 2)
    assert result != __MODULE__.rand_public_when(@randlimit)
  end

  defmemop rand_private(limit), timeout: @ttl do
    :rand.uniform(limit)
  end

  test "defmemop generates private function" do
    assert false == :erlang.function_exported(__MODULE__, :rand_private, 1)
  end

  test "defmemop" do
    result = rand_private(@randlimit)
    assert result == rand_private(@randlimit)
    _ = :timer.sleep(@ttl * 2)
    assert result != rand_private(@randlimit)
  end

  defmemop rand_private_when(limit) when is_integer(limit) and limit > 0, timeout: @ttl do
    :rand.uniform(limit)
  end

  test "defmemop + when generates private function" do
    assert false == :erlang.function_exported(__MODULE__, :rand_private_when, 1)
  end

  test "defmemop + when" do
    result = rand_private_when(@randlimit)
    assert result == rand_private_when(@randlimit)
    _ = :timer.sleep(@ttl * 2)
    assert result != rand_private_when(@randlimit)
  end

  defmemop pm_test(%{data: limit}), timeout: @ttl do
    :rand.uniform(limit)
  end

  test "P.M. support" do
    result = pm_test(%{data: @randlimit})
    assert result == pm_test(%{data: @randlimit})
    _ = :timer.sleep(@ttl * 2)
    assert result != pm_test(%{data: @randlimit})
  end

  defmemop args_context(arg2, arg1, arg0), timeout: @ttl do
    {arg2, arg1, arg0}
  end

  test "args context" do
    assert {1, 2, 3} = args_context(1, 2, 3)
  end

  defmemop args_context_pm(%{data: arg0}), timeout: @ttl do
    arg0
  end

  test "args context pm inside" do
    assert 1 == args_context_pm(%{data: 1})
  end

  defmemop args_context_pm_left(arg1 = %{data: arg0}), timeout: @ttl do
    {arg0, arg1}
  end

  test "args context pm left" do
    assert {1, %{data: 1}} = args_context_pm_left(%{data: 1})
  end

  defmemop args_context_pm_right(%{data: arg0} = arg1), timeout: @ttl do
    {arg0, arg1}
  end

  test "args context pm right" do
    assert {1, %{data: 1}} = args_context_pm_right(%{data: 1})
  end
end
