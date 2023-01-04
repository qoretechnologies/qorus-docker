See:
- [qorus-ce](qorus-ce) for detailed info about Docker images for the Community Edition
- [qorus-ee](qorus-ee) for detailed info about Docker images for the Enterprise Edition

## Quick Start for Qorus Community Edition in Docker
```
git clone https://github.com/qoretechnologies/qorus-docker.git
cd qorus-docker/qorus-ce
docker-compose up -d
```

Use `qorus-ee` instead of `qorus-ce` above for the Enterprise Edition (requires a license and support agreement from
Qore Technologies for production use).

This will create a PostgreSQL database schema for Qorus, local volumes for persistent data and will start Qorus with
an HTTPS listener on port 8011 using a self-signed certificate and with RBAC disabled (Enterprise Edition only; the
Community Edition does not support users and permissions in any case).

Point your browser to https://localhost:8011 to connect to Qorus; no authentication is required to connect to Qorus in
the default configuration.

See either the `qorus-ce` or `qorus-ee` subdirectories for detailed information on Qorus Docker images for the
Community Edition and the Enterprise Edition, respectively.

---
**NOTE**: The Qorus Python remote client has been moved to GitHub: https://github.com/qoretechnologies/qorus-remote
