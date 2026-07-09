# ani-cli — AA_CRYPTO_MISSING error, no valid sources (AllAnime backend change)

**Date**: 2026-07-10
**System**: archy (Arch Linux / HyDE / Hyprland)
**Category**: CLI Application / Upstream API Break

---

## Versions at time of issue

| Package | Version |
|---|---|
| ani-cli (pacman) | 4.14-1 |
| ani-cli (~/bin, patched) | 4.14-1 + PR #1772 |
| nodejs | v26.4.0 |

---

## Symptoms

- Every episode attempt fails: "Episode is released, but no valid sources!"
- Anime search works normally; source extraction is the failing step.
- Raw API response from api.allanime.day:
  ```json
  {"errors":[{"message":"AA_CRYPTO_MISSING"}],"data":{"episode":null}}
  ```
- Not a VPN or region issue — SG and US endpoints failed identically.

---

## Root Cause

AllAnime backend (api.allanime.day) changed its episode-sources API:

1. **New auth requirement**: GET query extensions now require an encrypted `aaReq` token. Old requests without it return `AA_CRYPTO_MISSING`.
2. **Encryption scheme changed**: Payload decryption moved from AES-256-CTR to AES-256-GCM. New payload layout: byte 0 = version, bytes 1–12 = IV, middle bytes = ciphertext, last 16 bytes = GCM auth tag.
3. **Key rotated**: The hardcoded key changed to `22196fa6afca95309fdabe9a3534b87cd2454e50efeabfcbdbdfd3de678b3982`.
4. **POST fallback removed**: The fallback code path no longer works with the new API.

---

## Resolution

Applied upstream ani-cli PR #1772 ("handle AllAnime aaReq token") manually to `~/bin/ani-cli` — the copy that wins in PATH over `/usr/bin/ani-cli`.

**Backup saved**: `/home/cruxx/bin/ani-cli.bak`

### Four edits made to `~/bin/ani-cli`

1. **`process_response()` decrypt block**: CTR → GCM via node one-liner, using the new payload layout (byte0 version, bytes1-12 IV, middle ciphertext, last 16 auth tag).

2. **`get_episode_url()` query extensions**: Builds encrypted `aaReq` token via node. Token payload: `{v:1, ts, epoch:4128, buildId:'9', qh}` where `ts` is floored to 300000 ms. IV derived as first 12 bytes of `sha256('4128:9:' + qh + ':' + ts)`. POST fallback block removed entirely.

3. **`allanime_key`**: Replaced with new hardcoded hex key `22196fa6afca95309fdabe9a3534b87cd2454e50efeabfcbdbdfd3de678b3982`.

4. **`dep_ch "node"`**: Added nodejs as an explicit dependency check (new runtime dependency).

---

## Verification

```bash
# Syntax check
sh -n ~/bin/ani-cli   # clean, no errors

# End-to-end test: Dandadan ep 1 (sub), id iPbyFKbQWjfeDminj
ANI_CLI_PLAYER=debug ani-cli -S 2 -e 1 dandadan
```

Results:
- API returned `tobeparsed` field (no `AA_CRYPTO_MISSING`)
- GCM decrypt yielded valid `sourceUrls` JSON
- Resolved playable MP4 at `https://tools.fast4speed.rsvp/media9/videos/iPbyFKbQWjfeDminj/sub/1?Authorization=...`
- HTTP 206 confirmed; `ftyp` MP4 signature present in response body

---

## Rollback

```bash
cp /home/cruxx/bin/ani-cli.bak /home/cruxx/bin/ani-cli
```

---

## Lessons & Prevention

**a) ~/bin shadows pacman package — future updates won't apply automatically.**
When upstream releases 4.15 (or any version that includes PR #1772 natively), consider removing `~/bin/ani-cli` and reverting to the pacman copy:
```bash
rm ~/bin/ani-cli
# verify: which ani-cli  → should show /usr/bin/ani-cli
```

**b) GCM decrypt errors are silenced (`2>/dev/null`).**
A future key rotation will again present as "no valid sources" with no obvious error message. When this recurs, check the raw API response first:
```bash
# Check for AA_CRYPTO_* in raw response before assuming a local issue
curl -s 'https://api.allanime.day/...' | jq '.errors'
```

**c) Not a region/VPN issue.**
If the symptom returns, skip VPN troubleshooting — both SG and US failed identically this time. Go straight to raw API inspection.
