#!/usr/bin/env python3
import os

tag = os.environ.get("RELEASE_TAG", "latest")
title = os.environ.get("RELEASE_TITLE", "Libre Edu (Latest Release)")
is_rolling = os.environ.get("IS_ROLLING", "false").lower() == "true"
sha = os.environ.get("GITHUB_SHA", "")
repo = os.environ.get("GITHUB_REPOSITORY", "chandranshB/libre_edu")
run_id = os.environ.get("GITHUB_RUN_ID", "")
run_number = os.environ.get("GITHUB_RUN_NUMBER", "")
ref_name = os.environ.get("GITHUB_REF_NAME", "main")

commit_short = sha[:7] if sha else "HEAD"
commit_link = f"[`{commit_short}`](https://github.com/{repo}/commit/{sha})" if sha else "`HEAD`"
run_link = f"[#{run_number}](https://github.com/{repo}/actions/runs/{run_id})" if run_id else "N/A"

if is_rolling:
    status_callout = (
        f"> 🔄 **Continuous / Rolling Release:** This build is automatically generated from the "
        f"`{ref_name}` branch and kept up-to-date with every push."
    )
else:
    status_callout = f"> 🎉 **Official Release:** Version `{tag}` built from branch `{ref_name}`."

checksums_path = "release-assets/SHA256SUMS.txt"
if os.path.exists(checksums_path):
    with open(checksums_path, "r", encoding="utf-8") as f:
        checksums_content = f.read().strip()
else:
    checksums_content = "No checksums available."

body = f"""## 🎓 {title}

{status_callout}

- **Commit:** {commit_link}
- **Workflow Run:** {run_link}
- **Live Web Demo:** [chandranshb.github.io/libre_edu](https://chandranshb.github.io/libre_edu/)

---

### 📦 Download Binaries

| Platform | Download Link | Description |
| :--- | :--- | :--- |
| 📱 **Android** | [`libre_edu-android.apk`](https://github.com/{repo}/releases/download/{tag}/libre_edu-android.apk) | Android APK installer for phones and tablets |
| 🪟 **Windows** | [`libre_edu-windows.zip`](https://github.com/{repo}/releases/download/{tag}/libre_edu-windows.zip) | Windows 64-bit portable application |
| 🐧 **Linux** | [`libre_edu-linux.zip`](https://github.com/{repo}/releases/download/{tag}/libre_edu-linux.zip) | Linux 64-bit standalone bundle |
| 🍎 **macOS** | [`libre_edu-macos.zip`](https://github.com/{repo}/releases/download/{tag}/libre_edu-macos.zip) | macOS application archive |
| 🌐 **Web** | [`libre_edu-web.zip`](https://github.com/{repo}/releases/download/{tag}/libre_edu-web.zip) | Web production build assets |
| 🔒 **Checksums** | [`SHA256SUMS.txt`](https://github.com/{repo}/releases/download/{tag}/SHA256SUMS.txt) | SHA-256 verification hashes |

---

### 🔐 SHA-256 Checksums
```
{checksums_content}
```
"""

output_path = "release_body.md"
with open(output_path, "w", encoding="utf-8") as f:
    f.write(body)

print(f"Successfully generated {output_path}")
