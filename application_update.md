### Application update

SkillRx-Beacon is a Rails application that needs periodic updates. Since devices operate in low-connectivity areas, we optimize for **minimal bandwidth on updates** while allowing larger initial installs.

#### 1. Layered Architecture

The application is split into layers by change frequency:

| Layer | Contents | Typical Size | Change Frequency |
|-------|----------|--------------|------------------|
| `runtime` | Ruby, system dependencies | ~50 MB | Rarely (major upgrades) |
| `gems` | vendor/bundle (bundled gems) | ~80-150 MB | Occasionally (Gemfile changes) |
| `app` | Application code + compiled assets | ~5-20 MB | Frequently (each release) |

This separation means most updates only require downloading the small `app` layer.

---

#### 2. Binary Delta Updates

For the `app` layer, we use binary diffs to minimize download size.

**On build server (CI/CD):**
```bash
# Package new release
tar -czf app-v43.tar.gz app-v43/

# Generate delta from previous version
bsdiff app-v42.tar.gz app-v43.tar.gz app-v43-from-v42.patch

# Also generate delta from v41 (for devices that skipped v42)
bsdiff app-v41.tar.gz app-v43.tar.gz app-v43-from-v41.patch
```

**Typical sizes:**
```
app-v43.tar.gz:            10 MB   (full archive)
app-v43-from-v42.patch:   150 KB   (delta - code changes only)
app-v43-from-v41.patch:   300 KB   (delta - two versions)
```

**Tools:**
- `bsdiff` / `bspatch` — best compression ratio, slower
- `xdelta3` — faster, good compression
- `zstd --patch-from` — very fast, decent compression

---

#### 3. App Update Manifest

**Request:**
```
GET /api/v1/devices/me/app-manifest
Authorization: Bearer {api_key}
```

**Response:**
```json
{
  "app_manifest_version": "v43",
  "generated_at": "2024-01-15T12:00:00Z",
  "layers": [
    {
      "name": "runtime",
      "version": "1.0.0",
      "checksum": "sha256:aaa111...",
      "url": "/releases/runtime-1.0.0.tar.gz",
      "size_bytes": 52000000
    },
    {
      "name": "gems",
      "version": "2.1.0",
      "checksum": "sha256:bbb222...",
      "url": "/releases/gems-2.1.0.tar.gz",
      "size_bytes": 120000000
    },
    {
      "name": "app",
      "version": "43",
      "checksum": "sha256:ccc333...",
      "full": {
        "url": "/releases/app-v43.tar.gz",
        "size_bytes": 15000000
      },
      "deltas": [
        {
          "from_version": "42",
          "url": "/releases/app-v43-from-v42.patch",
          "size_bytes": 156000
        },
        {
          "from_version": "41",
          "url": "/releases/app-v43-from-v41.patch",
          "size_bytes": 312000
        }
      ]
    }
  ],
  "migrations_pending": true,
  "min_app_version": "40"
}
```

---

#### 4. Update Flow

```
┌─────────────────┐                    ┌─────────────────┐
│  SkillRx Beacon │                    │     SkillRx     │
└────────┬────────┘                    └────────┬────────┘
         │                                      │
         │  1. GET /app-manifest                │
         │─────────────────────────────────────>│
         │                                      │
         │  2. App manifest (layers + deltas)   │
         │<─────────────────────────────────────│
         │                                      │
         │  3. Compare local layer versions     │
         │     - runtime: 1.0.0 ✓ (unchanged)   │
         │     - gems: 2.1.0 ✓ (unchanged)      │
         │     - app: 42 → 43 (needs update)    │
         │                                      │
         │  4. Find best delta (from v42)       │
         │     GET /releases/app-v43-from-v42.patch
         │─────────────────────────────────────>│
         │                                      │
         │  5. Patch file (156 KB)              │
         │<─────────────────────────────────────│
         │                                      │
         │  6. Apply patch locally:             │
         │     bspatch v42.tar.gz v43.tar.gz    │
         │                                      │
         │  7. Verify checksum of v43.tar.gz    │
         │                                      │
         │  8. Extract, migrate, restart        │
         │                                      │
         │  9. POST /sync-status                │
         │─────────────────────────────────────>│
         │                                      │
```

**Decision logic for app layer:**
1. If device has version in `deltas` list → download delta, apply patch
2. If device version too old (below `min_app_version`) → download full archive
3. If patch application fails → fallback to full archive

---

#### 5. Directory Structure on Device

```
/opt/skillrx_beacon/
├── current -> releases/v43           # symlink to active release
├── releases/
│   ├── v42/                          # previous release (rollback)
│   │   ├── app/
│   │   ├── config/
│   │   ├── db/
│   │   └── ...
│   ├── v43/                          # current release
│   │   ├── app/
│   │   ├── config/
│   │   ├── db/
│   │   └── ...
│   └── archives/
│       ├── app-v42.tar.gz            # keep for next delta
│       └── app-v43.tar.gz            # latest archive
├── shared/                           # persists across releases
│   ├── config/
│   │   ├── database.yml
│   │   ├── master.key
│   │   └── settings.local.yml
│   ├── storage/                      # ActiveStorage files
│   ├── log/
│   └── tmp/
├── layers/
│   ├── runtime-1.0.0/                # Ruby + system deps
│   └── gems-2.1.0/                   # vendor/bundle
└── updating/                         # temp dir during update
```

**Symlinks in each release:**
```
releases/v43/config/database.yml -> /opt/skillrx_beacon/shared/config/database.yml
releases/v43/config/master.key -> /opt/skillrx_beacon/shared/config/master.key
releases/v43/log -> /opt/skillrx_beacon/shared/log
releases/v43/storage -> /opt/skillrx_beacon/shared/storage
releases/v43/vendor/bundle -> /opt/skillrx_beacon/layers/gems-2.1.0
```

---

#### 6. Update Script

```bash
#!/bin/bash
# /opt/skillrx_beacon/bin/update.sh
set -e

APP_ROOT="/opt/skillrx_beacon"
RELEASES_DIR="$APP_ROOT/releases"
ARCHIVES_DIR="$RELEASES_DIR/archives"
UPDATING_DIR="$APP_ROOT/updating"
SHARED_DIR="$APP_ROOT/shared"

CURRENT_VERSION=$(basename $(readlink "$APP_ROOT/current") | tr -d 'v')
NEW_VERSION="$1"
PATCH_FILE="$2"        # optional: path to downloaded patch
FULL_ARCHIVE="$3"      # optional: path to full archive (fallback)
EXPECTED_CHECKSUM="$4"

cleanup() {
  rm -rf "$UPDATING_DIR"
}
trap cleanup EXIT

mkdir -p "$UPDATING_DIR" "$ARCHIVES_DIR"

# Step 1: Create new archive via patch or use full download
if [ -n "$PATCH_FILE" ] && [ -f "$ARCHIVES_DIR/app-v$CURRENT_VERSION.tar.gz" ]; then
  echo "Applying delta patch from v$CURRENT_VERSION to v$NEW_VERSION..."
  bspatch \
    "$ARCHIVES_DIR/app-v$CURRENT_VERSION.tar.gz" \
    "$UPDATING_DIR/app-v$NEW_VERSION.tar.gz" \
    "$PATCH_FILE"
else
  echo "Using full archive..."
  cp "$FULL_ARCHIVE" "$UPDATING_DIR/app-v$NEW_VERSION.tar.gz"
fi

# Step 2: Verify checksum
echo "Verifying checksum..."
echo "$EXPECTED_CHECKSUM  $UPDATING_DIR/app-v$NEW_VERSION.tar.gz" | sha256sum -c -

# Step 3: Extract to new release directory
echo "Extracting..."
mkdir -p "$RELEASES_DIR/v$NEW_VERSION"
tar -xzf "$UPDATING_DIR/app-v$NEW_VERSION.tar.gz" -C "$RELEASES_DIR/v$NEW_VERSION" --strip-components=1

# Step 4: Create symlinks to shared resources
echo "Linking shared resources..."
ln -sfn "$SHARED_DIR/config/database.yml" "$RELEASES_DIR/v$NEW_VERSION/config/database.yml"
ln -sfn "$SHARED_DIR/config/master.key" "$RELEASES_DIR/v$NEW_VERSION/config/master.key"
ln -sfn "$SHARED_DIR/log" "$RELEASES_DIR/v$NEW_VERSION/log"
ln -sfn "$SHARED_DIR/storage" "$RELEASES_DIR/v$NEW_VERSION/storage"
ln -sfn "$SHARED_DIR/tmp" "$RELEASES_DIR/v$NEW_VERSION/tmp"

# Step 5: Link to gems layer (version from manifest)
GEMS_VERSION=$(cat "$RELEASES_DIR/v$NEW_VERSION/.gems-version" 2>/dev/null || echo "current")
ln -sfn "$APP_ROOT/layers/gems-$GEMS_VERSION" "$RELEASES_DIR/v$NEW_VERSION/vendor/bundle"

# Step 6: Run migrations
echo "Running migrations..."
cd "$RELEASES_DIR/v$NEW_VERSION"
RAILS_ENV=production bin/rails db:migrate

# Step 7: Atomic swap
echo "Activating new release..."
ln -sfn "$RELEASES_DIR/v$NEW_VERSION" "$APP_ROOT/current"

# Step 8: Restart application
echo "Restarting application..."
systemctl restart skillrx_beacon

# Step 9: Move archive to permanent storage
mv "$UPDATING_DIR/app-v$NEW_VERSION.tar.gz" "$ARCHIVES_DIR/"

# Step 10: Cleanup old releases (keep current + 1 previous)
echo "Cleaning up old releases..."
cd "$RELEASES_DIR"
ls -d v* 2>/dev/null | sort -V | head -n -2 | xargs -r rm -rf
cd "$ARCHIVES_DIR"
ls app-v*.tar.gz 2>/dev/null | sort -V | head -n -2 | xargs -r rm -f

echo "Update complete: v$CURRENT_VERSION → v$NEW_VERSION"
```

---

#### 7. Rollback

If an update causes issues:

```bash
#!/bin/bash
# /opt/skillrx_beacon/bin/rollback.sh

APP_ROOT="/opt/skillrx_beacon"
RELEASES_DIR="$APP_ROOT/releases"

CURRENT=$(basename $(readlink "$APP_ROOT/current"))
PREVIOUS=$(ls -d "$RELEASES_DIR"/v* | sort -V | grep -B1 "$CURRENT" | head -1)

if [ -z "$PREVIOUS" ] || [ "$PREVIOUS" = "$RELEASES_DIR/$CURRENT" ]; then
  echo "No previous release to rollback to"
  exit 1
fi

echo "Rolling back from $CURRENT to $(basename $PREVIOUS)..."

# Rollback database if needed
cd "$PREVIOUS"
RAILS_ENV=production bin/rails db:rollback STEP=1

# Swap symlink
ln -sfn "$PREVIOUS" "$APP_ROOT/current"

# Restart
systemctl restart skillrx_beacon

echo "Rollback complete"
```

---

#### 8. API Endpoints for App Updates

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/v1/devices/me/app-manifest` | Get app update manifest with layers and deltas |
| HEAD | `/api/v1/devices/me/app-manifest` | Check if app update available (ETag) |
| GET | `/api/v1/releases/{filename}` | Download release archive or patch |

---

#### 9. Build Pipeline (CI/CD)

On each release, the build server should:

1. **Build the app archive:**
   ```bash
   # Compile assets
   RAILS_ENV=production bin/rails assets:precompile

   # Package (exclude gems, logs, tmp)
   tar -czf app-v43.tar.gz \
     --exclude='vendor/bundle' \
     --exclude='log/*' \
     --exclude='tmp/*' \
     --exclude='storage/*' \
     app/
   ```

2. **Generate deltas from recent versions:**
   ```bash
   # Keep deltas for last 3 versions
   for prev_version in 42 41 40; do
     if [ -f "app-v$prev_version.tar.gz" ]; then
       bsdiff "app-v$prev_version.tar.gz" "app-v43.tar.gz" "app-v43-from-v$prev_version.patch"
     fi
   done
   ```

3. **Calculate checksums:**
   ```bash
   sha256sum app-v43.tar.gz > app-v43.tar.gz.sha256
   ```

4. **Upload to release storage** (S3, server filesystem, etc.)

5. **Update app manifest** in SkillRx database

---

#### 10. Gems Layer Updates

When `Gemfile.lock` changes:

1. Build new gems layer:
   ```bash
   bundle config set --local path 'vendor/bundle'
   bundle config set --local deployment 'true'
   bundle install
   tar -czf gems-2.2.0.tar.gz vendor/bundle/
   ```

2. Upload to release storage

3. Update manifest with new gems version

4. Device downloads full gems archive (no delta — binary gems don't diff well)

---

#### 11. Error Handling

| Scenario | Behavior |
|----------|----------|
| Delta patch fails | Fallback to full archive download |
| Checksum mismatch after patch | Discard, download full archive |
| Migration fails | Abort update, keep previous release active, report error |
| Disk space insufficient | Abort before extraction, report error |
| Service fails to start | Auto-rollback to previous release |

---

#### 12. Sync Status with App Version

The existing `sync-status` endpoint includes app version info:

```json
{
  "status": "synced",
  "manifest_version": "v43",
  "device_info": {
    "hostname": "clinic-pc-001",
    "os_version": "Ubuntu 22.04",
    "app_version": "43",
    "runtime_version": "1.0.0",
    "gems_version": "2.1.0"
  }
}
```

This allows SkillRx admin to see which devices need app updates.
