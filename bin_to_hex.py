import sys
import os

def bin_to_hex(bin_filename, hex_filename, word_size_bytes=4):
    """
    Converts a raw binary file to a hex text file (one word per line).

    Args:
        bin_filename (str): Path to the input raw binary file.
        hex_filename (str): Path for the output hex text file.
        word_size_bytes (int): The size of each memory word in bytes (e.g., 4 for 32-bit).
    """
    if not os.path.exists(bin_filename):
        print(f"Error: Input file not found: {bin_filename}")
        sys.exit(1)

    with open(bin_filename, 'rb') as f_bin, open(hex_filename, 'w') as f_hex:
        words = 0
        while True:
            # Read a word's worth of bytes
            word_bytes = f_bin.read(word_size_bytes)
            if not word_bytes:
                break # End of file

            # Convert bytes to integer (assuming little-endian)
            word_val = int.from_bytes(word_bytes, byteorder='little')

            # Write as hex (uppercase, 8 digits for 32-bit word)
            f_hex.write(f"{word_val:0{word_size_bytes*2}X}\n")
            words += 1
        for _ in range(words, 200): # fill with NOPs
            f_hex.write(f"{0x13:0{word_size_bytes*2}X}\n")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python bin_to_hex.py <input_raw_binary_file> <output_hex_text_file>")
        sys.exit(1)

    input_bin = sys.argv[1]
    output_hex = sys.argv[2]

    bin_to_hex(input_bin, output_hex)
    print(f"Successfully converted '{input_bin}' to '{output_hex}'")
