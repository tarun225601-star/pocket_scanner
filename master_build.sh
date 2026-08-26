echo "=== Step 1: Cleaning old broken platform files ==="
rm -rf android ios .metadata build .gradle

echo "=== Step 2: Creating fresh Flutter platform structure ==="
flutter create . --platforms=android

echo "=== Step 3: Staging and committing changes ==="
git add .
git commit -m "master-fix: auto-generated fresh android structure and paths"

echo "=== Step 4: Pushing to GitHub ==="
git push origin main
echo "=== Done! Ab GitHub Actions जाकर check kar le, APK ban raha hoga! ==="
