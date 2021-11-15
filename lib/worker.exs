defmodule Worker do

  def wait_for_messages(channel) do
    receive do
      {:basic_deliver, payload, meta} ->
        IO.puts " [x] Received #{payload}"
        payload
        |> to_char_list
        |> Enum.count(fn x -> x == ?. end)
        |> Kernel.*(1000)
        |> :timer.sleep
        IO.puts " [x] Done."
        AMQP.Basic.ack(channel, meta.delivery_tag)

        wait_for_messages(channel)
      end
  end

  def generate_pdf(text) do
    Pdf.build([size: :a4, compress: true], fn pdf ->
      pdf
      |> Pdf.set_info(title: "Laudo Neomed")
      |> Pdf.set_font("Helvetica", 60)
      |> Pdf.set_line_cap(:square)
      |> Pdf.set_line_join(:miter)
      |> Pdf.set_fill_color(:black)
      |> Pdf.text_at({200,600}, text)
      |> Pdf.write_to("pdfs/neomed-#{:os.system_time(:millisecond)}.pdf")
    end)
  end
end

queue = "reports_queue"

{:ok, connection} = AMQP.Connection.open
{:ok, channel} = AMQP.Channel.open(connection)

AMQP.Queue.declare(channel, queue, durable: true)
AMQP.Basic.qos(channel, prefetch_count: 1)

AMQP.Basic.consume(channel, queue)
IO.puts " [*] Waiting for messages. To exit press CTRL+C, CTRL+C"

Worker.wait_for_messages(channel)
