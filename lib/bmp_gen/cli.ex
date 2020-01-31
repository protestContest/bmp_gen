defmodule BmpGen.CLI do
  def main(args) do
    options = [switches: [in: :string, out: :string, method: :string], aliases: [i: :in, o: :out, m: :method]]
    { opts, _, _ } = OptionParser.parse(args, options)

    BmpGen.convert(opts[:in], opts[:out], opts[:method])
  end
end