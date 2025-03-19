defmodule GlowClient do
  defstruct username: ""

  def start do
    "Started"
  end

  defp login do
    name = Util.ask("What's you username")
    %GlowClient{username: name}
  end

  defp max_length, do: 1024

  defp handle_message(client) do

  end
end

\
