{:ok, connection} = AMQP.Connection.open
{:ok, channel} = AMQP.Channel.open(connection)

queue = "reports"
payload = "NEOMED"

AMQP.Queue.declare(channel, queue)
AMQP.Basic.publish(channel, "", queue, payload)
IO.puts " [x] Sent 'Hello World!'"
AMQP.Connection.close(connection)