# Fix GitHub Authentication Error

## Problem
```
remote: Invalid username or token. Password authentication is not supported for Git operations.
fatal: Authentication failed
```

GitHub no longer accepts passwords. You need a **Personal Access Token (PAT)** or **SSH keys**.

## Solution 1: Personal Access Token (Quick Fix)

### Step 1: Create Personal Access Token

1. Go to GitHub.com → Click your profile → **Settings**
2. Scroll down → **Developer settings** (left sidebar)
3. Click **Personal access tokens** → **Tokens (classic)**
4. Click **Generate new token** → **Generate new token (classic)**
5. Give it a name: `prod-simulation-push`
6. Select expiration (30 days, 90 days, or no expiration)
7. **Select scopes**:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `workflow` (Update GitHub Action workflows)
8. Click **Generate token**
9. **COPY THE TOKEN IMMEDIATELY** (you won't see it again!)

### Step 2: Use Token Instead of Password

```bash
# When pushing, use the token as password
git push -u origin main

# Username: abhi0xdev
# Password: <paste your token here>
```

### Step 3: Store Credentials (Optional but Recommended)

**Windows (Git Credential Manager):**
```bash
# Git will prompt and save credentials
git push -u origin main
# Enter username: abhi0xdev
# Enter password: <your-token>
```

**Linux/WSL:**
```bash
# Store credentials in cache (15 minutes)
git config --global credential.helper cache

# Or store permanently (less secure)
git config --global credential.helper store
```

## Solution 2: SSH Keys (More Secure, Recommended)

### Step 1: Generate SSH Key

```bash
# Generate SSH key (if you don't have one)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Press Enter to accept default location
# Enter passphrase (optional but recommended)
```

### Step 2: Add SSH Key to GitHub

```bash
# Copy your public key
cat ~/.ssh/id_ed25519.pub
# Or on Windows:
cat /mnt/c/Users/YourName/.ssh/id_ed25519.pub
```

1. Copy the entire output (starts with `ssh-ed25519`)
2. Go to GitHub.com → **Settings** → **SSH and GPG keys**
3. Click **New SSH key**
4. Title: `WSL/Linux Key` (or any name)
5. Paste the key
6. Click **Add SSH key**

### Step 3: Change Remote to SSH

```bash
# Remove HTTPS remote
git remote remove origin

# Add SSH remote
git remote add origin git@github.com:abhi0xdev/prod_simulation.git

# Test connection
ssh -T git@github.com
# Should say: "Hi abhi0xdev! You've successfully authenticated..."

# Now push (no password needed!)
git push -u origin main
```

## Solution 3: GitHub CLI (Easiest)

```bash
# Install GitHub CLI
# Windows: winget install GitHub.cli
# WSL/Linux: sudo apt install gh

# Login
gh auth login

# Follow prompts:
# - GitHub.com
# - HTTPS or SSH
# - Authenticate in browser

# Now you can push without issues
git push -u origin main
```

## Complete Push Workflow (After Fixing Auth)

```bash
# 1. Make sure you're in the project directory
cd /mnt/e/Desktop/Devops/prod_simulation

# 2. Check current status
git status

# 3. Add ALL files (not just README.md)
git add .

# 4. Commit everything
git commit -m "Initial commit: Full-stack production simulation app

- React frontend with Nginx
- Flask backend API with PostgreSQL  
- Docker Compose setup
- Prometheus and Grafana monitoring
- CI/CD pipelines
- Complete documentation"

# 5. Push to GitHub
git push -u origin main
```

## Quick Fix Commands (Copy-Paste Ready)

### If Using Personal Access Token:
```bash
git remote set-url origin https://abhi0xdev@github.com/abhi0xdev/prod_simulation.git
git push -u origin main
# Username: abhi0xdev
# Password: <paste-token-here>
```

### If Using SSH:
```bash
git remote set-url origin git@github.com:abhi0xdev/prod_simulation.git
git push -u origin main
```

## Verify Push

1. Go to https://github.com/abhi0xdev/prod_simulation
2. You should see all your files:
   - frontend/
   - backend/
   - docker-compose.yml
   - README.md
   - etc.

## Troubleshooting

### "Permission denied (publickey)"
- SSH key not added to GitHub
- Run: `ssh -T git@github.com` to test

### "Repository not found"
- Check repository name: `prod_simulation` (not `prod-simulation`)
- Verify you have push access

### "Updates were rejected"
```bash
# Pull first, then push
git pull origin main --rebase
git push -u origin main
```

## Recommended: Use SSH (One-Time Setup)

SSH is more secure and convenient once set up:

```bash
# 1. Generate key (if needed)
ssh-keygen -t ed25519 -C "abhi0xdev@github.com"

# 2. Copy public key
cat ~/.ssh/id_ed25519.pub

# 3. Add to GitHub (Settings → SSH keys)

# 4. Change remote
git remote set-url origin git@github.com:abhi0xdev/prod_simulation.git

# 5. Test
ssh -T git@github.com

# 6. Push
git push -u origin main
```

Once SSH is set up, you'll never need to enter credentials again! 🎉

