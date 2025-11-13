#!/bin/bash

# Script to fix GitHub auth and push all files
# Run this in WSL or Linux

echo "🔧 Fixing GitHub authentication and pushing all files..."
echo ""

# Step 1: Add all files
echo "📦 Adding all files to git..."
git add .

# Step 2: Commit everything
echo "💾 Committing all files..."
git commit -m "Initial commit: Full-stack production simulation app

- React frontend with Nginx
- Flask backend API with PostgreSQL
- Docker Compose setup
- Prometheus and Grafana monitoring
- CI/CD pipelines (GitHub Actions + Jenkins)
- Complete documentation"

# Step 3: Check remote
echo "🔍 Checking remote configuration..."
git remote -v

echo ""
echo "✅ Files committed!"
echo ""
echo "📤 To push, choose one of these options:"
echo ""
echo "Option 1: Use Personal Access Token (Quick)"
echo "  1. Create token: https://github.com/settings/tokens"
echo "  2. Run: git push -u origin main"
echo "  3. Username: abhi0xdev"
echo "  4. Password: <paste your token>"
echo ""
echo "Option 2: Use SSH (Recommended)"
echo "  1. Generate key: ssh-keygen -t ed25519 -C 'your_email@example.com'"
echo "  2. Add to GitHub: https://github.com/settings/keys"
echo "  3. Change remote: git remote set-url origin git@github.com:abhi0xdev/prod_simulation.git"
echo "  4. Push: git push -u origin main"
echo ""
echo "See GITHUB_AUTH_FIX.md for detailed instructions!"

