defmodule BmpGen.CLI do
  def main(args) do
    options = [
      switches: [
        in: :string,
        out: :string,
        method: :string,
        colors: :number
      ],
      aliases: [i: :in, o: :out, m: :method, c: :colors]
    ]

    { opts, _, _ } = OptionParser.parse(args, options)

    num_colors = if is_nil(opts[:colors]), do: 4, else: String.to_integer(opts[:colors])

    BmpGen.convert(opts[:in], opts[:out], opts[:method], num_colors)
  end
end