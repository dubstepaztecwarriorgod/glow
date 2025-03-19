defmodule Util do
  def ask(question) do
    IO.gets(question <> "?\n> ") |> String.trim()
  end

  def ask(question, answers) do
    IO.puts(question <> "?")
    Enum.with_index(answers, fn answer, i -> IO.puts("#{i + 1}. #{answer}") end)

    input = IO.gets("> ") |> String.trim()

    case Enum.member?(answers, input) do
      true -> input
      false ->
        IO.puts("Unrecognized input please choose an answer from: " <> Enum.join(answers, ", "))
        ask(question, answers)
    end
  end
end

defmodule GlowError do
  defexception [:message]
end
