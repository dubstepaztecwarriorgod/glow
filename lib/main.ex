defmodule Glow do
  def main do
    case Util.ask("What are you trying to start?", ["server", "client"]) do
      "server" -> GlowServer.start()
      "client" -> GlowClient.start()
    end
  end
end
