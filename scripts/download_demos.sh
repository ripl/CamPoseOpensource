#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$ROOT/temp"

rm -rf "$TMP"
mkdir -p "$TMP"

gdown \
    --folder \
    --remaining-ok \
    --id 1dmv-ueaP8F0ElqgVXsdmX-S9hvfQb7Yf \
    -O "$TMP"

mkdir -p \
    "$ROOT/policy_maniskill/demos" \
    "$ROOT/policy_robosuite/demos"

cp -a \
    "$TMP/demos_maniskill/." \
    "$ROOT/policy_maniskill/demos/"

cp -a \
    "$TMP/demos_robosuite/." \
    "$ROOT/policy_robosuite/demos/"

rm -rf "$TMP"