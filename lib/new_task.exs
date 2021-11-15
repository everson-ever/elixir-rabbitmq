{:ok, connection} = AMQP.Connection.open
{:ok, channel} = AMQP.Channel.open(connection)

queue = "reports_queue"
AMQP.Queue.declare(channel, queue, durable: true)

message =
  case System.argv do
    []    -> "Hello World!"
    words -> Enum.join(words, " ")
  end


AMQP.Basic.publish(channel, "", queue, message, persistent: true)
IO.puts " [x] Sent #{message}"
AMQP.Connection.close(connection)
