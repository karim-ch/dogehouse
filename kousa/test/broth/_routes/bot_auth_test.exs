defmodule BrothTest.Routes.BotAuthTest do
  use ExUnit.Case, async: true
  use KousaTest.Support.EctoSandbox

  alias Beef.Schemas.User
  alias KousaTest.Support.Factory
  alias BrothTest.HttpRequest

  setup do
    user = Factory.create(User)

    {:ok, user: user}
  end

  describe "the post /bot/auth route" do
    test "trade apiKey for access and refresh tokens", t do
      bot = Factory.create(User, apiKey: UUID.uuid4(), botOwnerId: t.user.id)

      {:ok, resp_body} = HttpRequest.post("/bot/auth", %{apiKey: bot.apiKey})

      assert is_binary(resp_body["accessToken"])
      assert is_binary(resp_body["refreshToken"])
    end

    test "gets rate limited on X bad requests", t do
      bot = Factory.create(User, apiKey: UUID.uuid4(), botOwnerId: t.user.id)

      Enum.each(0..5, fn _ ->
        HttpRequest.post("/bot/auth", %{apiKey: UUID.uuid4()})
      end)

      assert {:ok, %Finch.Response{status: 429}} =
               HttpRequest.post("/bot/auth", %{apiKey: bot.apiKey})
    end
  end
end
