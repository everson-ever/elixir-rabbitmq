defmodule Receive do

  def wait_for_messages do
    receive do
      {:basic_deliver, payload, _meta} ->
        generate_pdf(payload)
        IO.puts "PDF genarated"
        wait_for_messages()
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

queue = "reports"

{:ok, connection} = AMQP.Connection.open
{:ok, channel} = AMQP.Channel.open(connection)
AMQP.Queue.declare(channel, queue)
AMQP.Basic.consume(channel, queue, nil, no_ack: true)
IO.puts " [*] Waiting for messages. To exit press CTRL+C, CTRL+C"

Receive.wait_for_messages()