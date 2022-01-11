defmodule SimplePaxos.Acceptor do
  use GenServer

  def start_link({start_ballot, start_value}) do
    GenServer.start_link(__MODULE__, {start_ballot, start_value})
  end

  @doc """
  Receiving a proposal for ballot `proposing_ballot`
  if its the highest proposal we've seen then promise
  to enter that ballot and to not enter any other ballot
  that is lower
  """
  def propose(acceptor, proposing_ballot) do
    GenServer.call(acceptor, {:propose, proposing_ballot})
  end

  @doc """
  Accept the value that was part of the proposal we were part of
  We can only accept this value if this is the highest proposal we've
  received, otherwise we return the value we've accepted before
  """
  def accept(acceptor, ballot, new_value) do
    GenServer.call(acceptor, {:accept, ballot, new_value})
  end

  ## Server API

  @impl true
  def init({start_ballot, start_value}) do
    {:ok, {start_ballot, start_value}}
  end


  @impl true
  def handle_call({:propose, proposing_ballot}, _from, state) do
    {current_ballot, current_value} = state

    current_ballot = if proposing_ballot > current_ballot do
      proposing_ballot else current_ballot
    end

    new_state = {current_ballot, current_value}
    {:reply, {:join_proposal, current_ballot, current_value}, new_state}
  end

  @impl true
  def handle_call({:accept, ballot, new_value}, _from, state) do
    {current_ballot, current_value} = state

    new_value = if ballot == current_ballot do
      new_value else current_value
    end

    new_state = {current_ballot, new_value}
    {:reply, {:accepted, current_ballot, new_value}, new_state}
  end
end
