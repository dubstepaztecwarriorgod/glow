defmodule Util do
  alias IO.ANSI

  def ask(question), do: IO.gets(question <> "?\n>") |> String.trim()
  
  def ask(question, answers) do
    IO.puts(question <> "?")
    Enum.with_index(answers, fn answer, i -> IO.puts("#{i + 1}. #{answer}") end)

    input = IO.gets(">") |> String.trim()

    case Enum.member?(answers, input) do
      true -> input
      false ->
        IO.puts("Unrecognized input please choose an answer from: " <> Enum.join(answers, ", "))
        ask(question, answers)
    end
  end

  def warn(message), do: IO.puts(ANSI.yellow() <> "Warning: " <> message <> ANSI.reset())

  def announce(message), do: IO.puts(ANSI.cyan() <> "Announcement: " <> message <> ANSI.reset())
end
