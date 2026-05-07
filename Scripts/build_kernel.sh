#!/usr/bin/env bash
set -euo pipefail

cd "${KERNEL_DIR}"

make ${MAKE_ARGS} "${DEFCONFIG}" ${DEFCONFIG_FRAGS}

KCFG="./scripts/config --file out/.config"
"${KCFG}" -e KSU

if [ "${SUSFS_SUPPORT}" = "true" ]; then
  "${KCFG}" -e KSU_SUSFS
fi

if [ "${KPM_SUPPORT}" = "true" ]; then
  "${KCFG}" -e KPM
  "${KCFG}" -e KALLSYMS
  "${KCFG}" -e KALLSYMS_ALL
  "${KCFG}" -e KPROBES
fi

if [ "${BBG_SUPPORT}" = "true" ]; then
  "${KCFG}" -e BBG
fi

make ${MAKE_ARGS} olddefconfig
[ -f scripts/setlocalversion ] && sed -i 's/-dirty//g' scripts/setlocalversion || true

JOBS=$(( $(nproc) / 2 ))
[ "${JOBS}" -lt 1 ] && JOBS=1
make -j"${JOBS}" ${MAKE_ARGS} Image KCFLAGS="-Wno-error"

if [ "${KPM_SUPPORT}" = "true" ]; then
  cd out/arch/arm64/boot/
  python3 - <<'PY'
import json
import sys
import urllib.request

url = "https://api.github.com/repos/SukiSU-Ultra/SukiSU_KernelPatch_patch/releases/latest"
with urllib.request.urlopen(url) as resp:
  data = json.load(resp)

assets = data.get("assets", [])
match = next((a["browser_download_url"] for a in assets if "patch_linux" in a.get("name", "")), None)
if not match:
  print("ERROR: patch_linux asset not found", file=sys.stderr)
  sys.exit(1)

urllib.request.urlretrieve(match, "patch_linux")
PY
  chmod +x ./patch_linux
  ./patch_linux
  rm -f ./Image
  mv ./oImage ./Image
fi
