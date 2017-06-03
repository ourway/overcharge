defmodule SlackWebhook do

  @slackurl "https://hooks.slack.com/services/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"

  def send(msg), do: __MODULE__.send(msg, @slackurl )

  @doc """
  Sends message to selected webhook url.
  Use if your application uses more than one hook.
  """
  def send(msg, url), do: HTTPoison.post(url, get_content(msg), [])

  @doc """
  Sends asynchronous message to selected webhook url.
  Use when you want to "fire and forget" your notifications.
  """
  def async_send(msg), do: __MODULE__.async_send(msg, @slackurl )

  @doc """
  Sends asynchronous message to selected webhook url.
  """
  def async_send(msg, url), do: HTTPoison.post(url, get_content(msg), [], [ ssl: [{:versions, [:'tlsv1.2']}], hackney: [:async]])

  def mo_notification(msg, slackid) do
      async_send(msg, "https://hooks.slack.com/services/" <> slackid)
  end

  #defp get_url, do: Application.get_env(:slack_webhook, :url, "")
  defp get_content(msg), do: """
  {
    "text": "#{msg}"
  }
  """

end
