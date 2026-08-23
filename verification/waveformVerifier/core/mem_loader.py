from pathlib import Path

def load_mem_file(path: str | Path) -> list[int]:
    """Read one 32-bit hexadecimal instruction per line.

    Empty lines and text following // or # are ignored. 0x prefixes and
    underscores are accepted.
    """
    words: list[int] = []
    for line_number, raw in enumerate(Path(path).read_text(encoding="utf-8").splitlines(), 1):
        text = raw.split("//", 1)[0].split("#", 1)[0].strip()
        if not text:
            continue
        text = text.replace("_", "")
        if text.lower().startswith("0x"):
            text = text[2:]
        try:
            value = int(text, 16)
        except ValueError as exc:
            raise ValueError(f"Line {line_number}: invalid hexadecimal value '{raw.strip()}'") from exc
        if not 0 <= value <= 0xFFFFFFFF:
            raise ValueError(f"Line {line_number}: instruction exceeds 32 bits")
        words.append(value)
    if not words:
        raise ValueError("The MEM file contains no instructions.")
    return words
