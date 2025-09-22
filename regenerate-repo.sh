#!/bin/bash
# regenerate-repo.sh: Automate Debian repo metadata and signing
set -e

REPO_DIR="/workspaces/debian13-amd64-repo"
DIST_DIR="$REPO_DIR/dists"
POOL_DIR="$REPO_DIR/pool"

echo "Packages.gz updated."
# 1. Regenerate Packages.gz
echo "Generating Packages.gz..."
dpkg-scanpackages "$POOL_DIR" /dev/null | gzip -9 > "$DIST_DIR/Packages.gz"
echo "Packages.gz updated."

# 2. Update Release file (basic example)
cat > "$DIST_DIR/Release" <<EOF
Archive: custom
Component: main
Origin: CustomDebian13
Label: CustomDebian13
Architecture: amd64
Date: $(date -Ru)
EOF

echo "Release file updated."

# 3. Sign the Release file (requires GPG key)
if gpg --list-keys | grep -q .; then
    echo "Signing Release file..."
    gpg --output "$DIST_DIR/Release.gpg" --detach-sign "$DIST_DIR/Release"
    gpg --clearsign --output "$DIST_DIR/InRelease" "$DIST_DIR/Release"
    echo "Release file signed."
else
    echo "No GPG key found. Skipping signing."
fi

echo "Repository metadata automation complete."
