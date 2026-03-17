# homelab

Personal homelab running on a single self-hosted server. All services are containerised with Docker Compose and organised into independent stacks, each with a focused responsibility.

## Architecture

```
                        Internet
                            │
                     ┌──────▼──────┐
                     │    www      │
                     │   *SWAG     │  reverse proxy + TLS (Let's Encrypt)
                     └──────┬──────┘
                            │ www_default network
          ┌─────────────────┼──────────────────┐
          │                 │                  │
   ┌──────▼──────┐  ┌───────▼──────┐  ┌──────▼────────┐
   │  mediacenter│  │  datacenter  │  │  monitoring   │
   │             │  │              │  │               │
   │ *Jellyfin   │  │ *Nextcloud   │  │  homepage     │
   │ *Seerr      │  │  Postgres    │  │  librespeed   │
   │  Sonarr     │  │  Backrest    │  │  portainer    │
   │  Radarr     │  └──────────────┘  │  scrutiny     │
   │  Prowlarr   │                    └───────────────┘
   │  qBittorrent│
   └─────────────┘

* = exposed publicly
```

## Stacks

### `www` — reverse proxy
Entry point for all public traffic. SWAG handles TLS certificate issuance and renewal via Let's Encrypt (DNS challenge with Infomaniak), and routes incoming HTTPS requests to the appropriate internal services over the shared `www_default` Docker network.

### `mediacenter` — media automation
Full *arr stack for automated media acquisition and streaming. Prowlarr indexes trackers, Sonarr and Radarr manage TV shows and movies, qBittorrent handles downloads, Jellyfin serves the library, and Seerr provides a user-friendly request interface.

### `datacenter` — personal data
Self-hosted personal cloud and backup. Nextcloud (backed by Postgres) handles file sync, contacts, and calendar. Backrest manages encrypted off-site backups of critical data.

### `monitoring` — observability
Internal-only stack for keeping an eye on the server. Homepage provides a unified dashboard, Portainer gives a Docker management UI, and Scrutiny monitors disk health via S.M.A.R.T. data.

## Usage

### First run
Each stack has a `.env.example` file. Copy it to `.env` and fill in the required values before starting:

```bash
cp .env.example .env
```

The `www` stack must be started first — it creates the `www_default` Docker network that other stacks depend on.

```bash
cd www && docker compose up -d
```

Then start the remaining stacks with the update script

```bash
./update-all.sh
```

### Updating all stacks
Setup a cron schedule to run this script at your convenience. Recommended: 0 4 * * * (every day at 04:00).

```bash
./update-all.sh
```

Pulls the latest Git changes, recreates all stacks with updated images, and prunes unused Docker resources.
