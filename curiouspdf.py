#!/usr/bin/env python3
import argparse
import os
import subprocess
import sys
from shutil import which

# Ordered list of viewers to try when handling a file directly
PREFERRED_VIEWERS = [
    "evince", "okular", "xreader", "atril", "mupdf", "zathura", "xpdf", "firefox"
]

def is_exe(name: str) -> bool:
    return which(name) is not None

def launch_viewer(file_path: str) -> int:
    if not os.path.isfile(file_path):
        print(f"Error: '{file_path}' not found.", file=sys.stderr)
        return 1

    # Try preferred native viewers directly to avoid xdg-open recursion
    for viewer in PREFERRED_VIEWERS:
        if is_exe(viewer):
            try:
                # run detached so our launcher can exit
                subprocess.Popen([viewer, file_path])
                return 0
            except Exception as e:
                print(f"Warn: failed to launch {viewer}: {e}", file=sys.stderr)

    # Fallback: xdg-open (safe here if app isn't the default; we tried natives first)
    if is_exe("xdg-open"):
        try:
            subprocess.Popen(["xdg-open", file_path])
            return 0
        except Exception as e:
            print(f"Error: xdg-open failed: {e}", file=sys.stderr)

    print("Error: no PDF viewer found. Install one like 'evince' or 'okular'.", file=sys.stderr)
    return 1

def interactive_picker():
    # Lazy import to avoid Tk dependency during headless use
    import tkinter as tk
    from tkinter import filedialog, messagebox

    root = tk.Tk()
    root.withdraw()
    file_path = filedialog.askopenfilename(
        title="Select a PDF",
        filetypes=[("PDF files", "*.pdf")]
    )
    if not file_path:
        return 0
    code = launch_viewer(file_path)
    if code != 0:
        messagebox.showerror("CuriousPDF", "Could not launch a PDF viewer.")
    return code

def main():
    parser = argparse.ArgumentParser(
        prog="curiouspdf",
        description="A minimal desktop-friendly PDF opener/launcher for Linux."
    )
    parser.add_argument(
        "file",
        nargs="?",
        help="Path to a PDF file (when launched via file association)."
    )
    parser.add_argument(
        "--pick",
        action="store_true",
        help="Show a file picker to select a PDF."
    )
    args = parser.parse_args()

    if args.file:
        # Handler mode (e.g., from file association): open the file directly
        sys.exit(launch_viewer(args.file))
    else:
        # No file passed: open picker by default, unless user only wants CLI
        if args.pick or sys.stdout.isatty():
            sys.exit(interactive_picker())
        else:
            print("Usage: curiouspdf [--pick] [file.pdf]", file=sys.stderr)
            sys.exit(2)

if __name__ == "__main__":
    main()