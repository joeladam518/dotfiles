# GPG Commit Signing Setup

Reference: [GitHub docs — Managing commit signature verification](https://docs.github.com/en/authentication/managing-commit-signature-verification)

---

## 1. Generate a GPG key

```bash
gpg --full-generate-key
```

At the prompts:
- Key type: **RSA and RSA** (option 1)
- Key size: **4096**
- Expiration: your preference (`0` = no expiration)
- Name / email: use the email associated with your GitHub account

Verify the key was created:

```bash
gpg --list-secret-keys --keyid-format=long
```

Output looks like:

```
sec   rsa4096/3AA5C34371567BD2 2024-01-01 [SC]
      ...
uid   [ultimate] Joel Haker <joelh815@gmail.com>
```

The key ID is the part after `rsa4096/` — e.g., `3AA5C34371567BD2`.

---

## 2. Export the public key to add to GitHub

```bash
gpg --armor --export 3AA5C34371567BD2
```

Copy the entire output (including the `-----BEGIN PGP PUBLIC KEY BLOCK-----` header and footer).

---

## 3. Add the key to GitHub

1. Go to **GitHub → Settings → SSH and GPG keys**
   — or navigate directly: https://github.com/settings/keys
2. Click **New GPG key**
3. Paste the exported public key block
4. Click **Add GPG key**

Reference: [Adding a GPG key to your GitHub account](https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-gpg-key-to-your-github-account)

---

## 4. Configure git to use the key

```bash
git config --global user.signingkey 3AA5C34371567BD2
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

Tell git which `gpg` binary to use (usually already correct, but explicit is safer):

```bash
git config --global gpg.program gpg
```

---

## 5. Tell GPG which TTY to use (avoid "Inappropriate ioctl" errors)

Add this to your `~/.bashrc` / `~/.zshrc`:

```bash
export GPG_TTY=$(tty)
```

---

## 6. Test it

```bash
echo "test" | gpg --clearsign
```

Then make a signed commit and verify:

```bash
git commit -S -m "test signed commit"
git log --show-signature -1
```

---

## Troubleshooting

**`gpg: signing failed: No secret key`**
Run `gpg --list-secret-keys` and make sure `user.signingkey` in git config matches exactly.

**Passphrase prompt never appears / hangs**
Make sure `GPG_TTY=$(tty)` is exported in your shell. If using a GUI app, you may need `pinentry-mac` (Mac) or `pinentry-gnome3` (Linux).

**Key expired**
Extend it: `gpg --edit-key <KEY_ID>`, then `expire`, set new date, `save`.

**Rotating or revoking a key**
See: [Generating a new GPG key](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key)

---

## Useful commands

```bash
# List keys
gpg --list-secret-keys --keyid-format=long

# Delete a key (public + secret)
gpg --delete-secret-and-public-key <KEY_ID>

# Backup a key
gpg --export-secret-keys --armor <KEY_ID> > my-key-backup.asc

# Import a backed-up key
gpg --import my-key-backup.asc
```
