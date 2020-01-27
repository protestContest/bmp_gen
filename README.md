# BmpGen

This is a simple CLI app to convert PNGs to BMP files compatible with
Waveshare's [4.3-inch e-ink display](https://www.waveshare.com/wiki/4.3inch_e-Paper_UART_Module).

Images are converted to four shades of gray with Floyd-Steinberg dithering.

## Usage

```
./bmp_gen -i infile.png -o outfile.bmp
```

The input file _must_ be an 800x600 PNG. You can generate the executable by
running `mix escript build`.

## Bonus Info

BMP files must be in a very specific format variant:

1. File header (14 bytes):
  - 2B: "BM"
  - 4B: 240070, size of file
  - 4B: 0
  - 4B: 70, start of pixel array
2. DIB Header (40 bytes):
  - 4B: 40, header length
  - 4B: 800, image width
  - 4B: 600, image height
  - 2B: 1 (0x01 0x00)
  - 2B: 4, bits per pixel
  - 4B: 0, no compression
  - 4B: 0, image size dummy
  - 4B: 0, horiz res dummy
  - 4B: 0, vert res dummy
  - 4B: 4, number of colors
  - 4B: 0, no important colors
3. Color table (16 bytes)
  - 4B: 0x00 0x00 0x00 0x00 (black)
  - 4B: 0x55 0x55 0x55 0x00 (dk gray)
  - 4B: 0xAA 0xAA 0xAA 0x00 (lt gray)
  - 4B: 0xFF 0xFF 0xFF 0xFF (white)
4. Pixel array
  - Every 4 bits is a pixel (1 byte = 2 pixels)

More info about the BMP file format can be found [here](https://en.wikipedia.org/wiki/BMP_file_format)
