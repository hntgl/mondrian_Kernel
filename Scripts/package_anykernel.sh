#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "${KERNEL_DIR}/out/arch/arm64/boot/Image" ]; then
  echo "ERROR: kernel Image not found"
  exit 1
fi

cp "${KERNEL_DIR}/out/arch/arm64/boot/Image" "${ANYKERNEL_DIR}/"
cp "${KERNEL_DIR}/out/arch/arm64/boot/Image.gz" "${ANYKERNEL_DIR}/" 2>/dev/null || true

cp Scripts/anykernel.sh "${ANYKERNEL_DIR}/anykernel.sh"
sed -i 's/kernel.string=.*/kernel.string=NP2 Kernel - ReSukiSU/' "${ANYKERNEL_DIR}/anykernel.sh"

cd "${ANYKERNEL_DIR}"
ZIP_NAME="ReSukiSU-NP2-Pong.zip"
zip -r9 "../${ZIP_NAME}" ./*
