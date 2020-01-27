defmodule BmpGen do
  @moduledoc """
  Converts
  """

  def read_file(filename) do
    {:ok, image} = Imagineer.load(filename)
    image
  end

  def convert(infile, outfile) do
    read_file(infile)
    |> convert_pixels()
    |> write_file(outfile)
  end

  defp convert_pixels(image) do
    image.pixels
    |> grayscale(image.bit_depth)
    |> dither()
    |> pack()
  end

  def write_file(pixels, filename) do
    IO.puts("Writing")
    data = file_header() <> pixels
    {:ok, file} = File.open(filename, [:write])
    IO.binwrite(file, data)
    File.close(file)
  end

  defp grayscale(pixels, bit_depth) do
    IO.puts("Grayscaling")
    Enum.map(pixels, fn pixel_row ->
      Enum.map(pixel_row, fn { red, green, blue } -> (red*0.299 + green*0.587 + blue*0.114) / num_colors(bit_depth) end)
    end)
  end

  defp simple_dither(pixels) do
    IO.puts("Dithering")
    Enum.map(pixels, fn pixel_row ->
      Enum.map(pixel_row, fn pixel ->
        floor(pixel * 4)
      end)
    end)
  end

  defp dither(pixels) do
    IO.puts("Dithering")
    row_width = Enum.count(hd pixels)

    { dithered_pixels, _errors } = Enum.reduce(pixels, { [], List.duplicate(0, row_width + 1) }, fn pixel_row, { outrows, row_error } ->
      { new_row, next_row_errors } = dither_row(pixel_row, row_error)
      { outrows ++ [new_row], next_row_errors }
    end)

    dithered_pixels
  end

  defp dither_row(pixel_row, row_error) do
    row_width = Enum.count(pixel_row)

    { new_pixel_row, next_row_errors } = Enum.reduce(pixel_row, { [], row_error }, fn pixel, { outpixels, [ pixel_error | errors ] } ->
      # require IEx; IEx.pry
      new_pixel = floor((pixel + pixel_error) * 4)/4
      new_error = pixel - new_pixel

      new_errors = errors ++ [0]
      |> List.update_at(0,             fn err -> err + (7/16)*new_error end)
      |> List.update_at(row_width - 1, fn err -> err + (3/16)*new_error end)
      |> List.update_at(row_width,     fn err -> err + (5/16)*new_error end)
      |> List.update_at(row_width + 1, fn err -> err + (1/16)*new_error end)

      { outpixels ++ [new_pixel], new_errors }
    end)

    { new_pixel_row, next_row_errors }
  end

  defp pack(pixels) do
    IO.puts("Packing")
    Enum.reduce(pixels, "", fn pixel_row, bytes ->
      row_pairs = Enum.chunk_every(pixel_row, 2)
      Enum.reduce(row_pairs, "", fn [ first | [ last ] ], row_bytes ->
        first_index = floor(first*4)
        last_index = floor(last*4)

        row_bytes <> <<first_index::4, last_index::4>>
      end) <> bytes
    end)
  end

  defp num_colors(bit_depth) do
    :math.pow(2, bit_depth)
  end

  defp file_header() do
    <<0x42, 0x4D, 0xC6, 0xA9, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46, 0x00, 0x00, 0x00, 0x28, 0x00, 0x00, 0x00, 0x20, 0x03, 0x00, 0x00, 0x58, 0x02, 0x00, 0x00, 0x01, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x55, 0x55, 0x55, 0x00, 0xAA, 0xAA, 0xAA, 0x00, 0xFF, 0xFF, 0xFF, 0x00>>
  end

end