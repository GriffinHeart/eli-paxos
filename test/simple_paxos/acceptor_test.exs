defmodule SimplePaxos.AcceptorTest do
  use ExUnit.Case
  doctest SimplePaxos.Acceptor

  setup do
    acceptor = start_supervised!({SimplePaxos.Acceptor, {10, 5}})
    %{acceptor: acceptor}
  end

  test "accepts proposal when the highest its seen", %{acceptor: acceptor} do
    assert SimplePaxos.Acceptor.propose(acceptor, 15) ==
      {:join_proposal, 15, 5}
  end

  test "accepts proposal when not the highest but returns the highest seen",
  %{acceptor: acceptor} do
    assert SimplePaxos.Acceptor.propose(acceptor, 8) ==
      {:join_proposal, 10, 5}
  end

  test "confirms the accepted value when its the highest ballot",
  %{acceptor: acceptor} do
    SimplePaxos.Acceptor.propose(acceptor, 15)

    assert SimplePaxos.Acceptor.accept(acceptor, 15, 99) ==
      {:accepted, 15, 99}
  end
end
