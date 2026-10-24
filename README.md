# SailOps Sandbox CLI

Use a SailOps agent sandbox as a remote workspace from Claude Code, Codex, OpenCode, Cursor, VS Code, or SSH.

```sh
curl -fsSL https://raw.githubusercontent.com/herewecloud/sailops-sandbox/main/install.sh | sh
sailops-sandbox init
sailops-sandbox up my-project
sailops-sandbox sync my-project .
ssh sailops-my-project
```

Create a project API key in SailOps with `containers:list`, `containers:update`, `sandboxes:connect`, and `sandboxes:exec`. `init` registers the MCP server in supported coding tools and configures SSH. The key stays on your machine.

Commands and file changes requested through the SailOps MCP tools execute inside the sandbox. Files under `/home/agent/workspace` persist across stops. Compute is billed while running; storage remains billed while stopped.

Supported release targets: macOS and Linux, Intel/AMD64 and ARM64. Release assets contain the CLI, not the private SailOps server source.

[Documentation](https://docs.sailops.io/ai/sandboxes)

Network access:

```sh
sailops-sandbox network show my-project
sailops-sandbox network set my-project --private-access connected-services --internet false
```

SSH wake (CLI 0.1.3 and later): after the initial `up` registers your SSH key, `ssh sailops-my-project` starts a stopped sandbox and waits for it automatically. No separate start command is needed for SSH, scp or rsync. Update existing entries with `sailops-sandbox ssh-config --all`. Generated hosts allow cold starts; IDEs overriding SSH connection timeouts may need `remote.SSH.connectTimeout` set to `660`.

Graphical applications (CLI 0.2.0 and a current managed sandbox image):

```sh
# Browser viewer; no local Xpra installation required.
sailops-sandbox app my-project --browser -- sailops-browser

# A native application window; requires Xpra on your computer.
sailops-sandbox app my-project -- xterm

# Lightweight Linux desktop.
sailops-sandbox desktop my-project --browser

sailops-sandbox apps my-project
sailops-sandbox app-attach my-project --browser SESSION_ID
sailops-sandbox app-stop my-project SESSION_ID
```

Programs run as the sandbox user and use its workspace. A stopped sandbox starts automatically. Browser mode opens a private local URL; keep the CLI running. Closing the browser releases the tunnel after two minutes with no viewer. Connected sessions keep compute running and billed. Files persist after shutdown; graphical processes do not. Clipboard, file transfer, audio, printing and webcam forwarding are disabled. The desktop's right-click menu opens the browser and terminal.

Native windows require an [Xpra client](https://xpra.org/). Only Linux applications installed in the sandbox can run remotely; Windows/macOS-only software and GPU acceleration are not supported.
