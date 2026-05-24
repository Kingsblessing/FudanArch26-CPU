def bin_to_coe(bin_path, coe_path):
    with open(bin_path, "rb") as f:
        content = f.read()
    if len(content) % 4 != 0:
        raise ValueError("Binary length is not aligned to 4 bytes (one instruction)")

    lines = []

    for i in range(0, len(content), 8):  
        instr1 = content[i:i+4]
        instr2 = content[i+4:i+8] if i + 4 < len(content) else b'\x00\x00\x00\x00'
        hex1 = ''.join(f'{b:02x}' for b in instr2[::-1])
        hex2 = ''.join(f'{b:02x}' for b in instr1[::-1])
        lines.append(hex1 + hex2)

    with open(coe_path, "w") as f:
        f.write("memory_initialization_radix = 16;\n")
        f.write("memory_initialization_vector =\n")
        for i, line in enumerate(lines):
            if i == len(lines) - 1:
                f.write(line + ";\n")  
            else:
                f.write(line + "\n")

bin_to_coe("kernel.bin", "kernel.coe")
