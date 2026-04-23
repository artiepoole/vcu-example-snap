#!/usr/bin/env bash

if [ "${1:-}" = "--help" ]; then
  echo "Usage: $(basename "$0") [--remove]"
  echo ""
  echo "  (no args)  Apply the FPGA overlay for the VCU bitstream"
  echo "  --remove   Remove the FPGA overlay"
  echo "  --help     Show this help message"
  exit 0
elif [ "${1:-}" = "--remove" ]; then
  echo "[vcu-example.deinit] Removing FPGA overlay..."
  remove_output=$(dbus-send --system --print-reply \
    --dest=com.canonical.fpgad \
    /com/canonical/fpgad/control \
    com.canonical.fpgad.control.RemoveOverlay \
    string:"universal" string:"vcu-example" 2>&1)
  remove_status=$?

  if [ $remove_status -eq 0 ]; then
    echo "[vcu-example.deinit] Overlay removed successfully"
  else
    echo "[vcu-example.deinit] ERROR: Failed to remove overlay. Is it applied? Use vcu-example.init to load it." >&2
    echo "$remove_output" >&2
    exit 1
  fi
else
  echo "[vcu-example.init] Applying FPGA overlay..."
  apply_output=$(dbus-send --system --print-reply \
    --dest=com.canonical.fpgad \
    /com/canonical/fpgad/control \
    com.canonical.fpgad.control.ApplyOverlay \
    string:"universal" string:"vcu-example" string:"/snap/vcu-example/current/data/vcu-bitstreams/kv260-smartcam.dtbo" string:"" 2>&1)
  apply_status=$?

  if [ $apply_status -eq 0 ]; then
    echo "[vcu-example.init] Overlay applied successfully"
  elif echo "$apply_output" | grep -q "already exists"; then
    echo "[vcu-example.init] Overlay already exists, skipping. Use vcu-example.deinit to remove it."
  else
    echo "[vcu-example.init] ERROR: Failed to apply overlay" >&2
    echo "$apply_output" >&2
    exit 1
  fi
fi

