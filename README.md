[![Docker Image CI](https://github.com/aoudiamoncef/ubuntu-sshd/actions/workflows/ci.yml/badge.svg)](https://github.com/aoudiamoncef/ubuntu-sshd/actions/workflows/ci.yml)
[![Docker Image Deployment](https://github.com/aoudiamoncef/ubuntu-sshd/actions/workflows/cd.yml/badge.svg)](https://github.com/aoudiamoncef/ubuntu-sshd/actions/workflows/cd.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/aoudiamoncef/ubuntu-sshd.svg)](https://hub.docker.com/r/aoudiamoncef/ubuntu-sshd)
[![Maintenance](https://img.shields.io/badge/Maintained-Yes-green.svg)](https://github.com/aoudiamoncef/ubuntu-sshd)
[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template?templateUrl=https://github.com/aoudiamoncef/ubuntu-sshd)
[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/aoudiamoncef/ubuntu-sshd)

This Docker image provides an Ubuntu 24.04 base with SSH server enabled. It allows you to easily create SSH-accessible containers via SSH keys or with a default username and password.

## Usage

### Cloning the Repository

To get started, clone the GitHub [repository](https://github.com/aoudiamoncef/ubuntu-sshd) containing the Dockerfile and
scripts:

```bash
git clone https://github.com/aoudiamoncef/ubuntu-sshd
cd ubuntu-sshd
```

### Building the Docker Image

Build the Docker image from within the cloned repository directory:

```bash
docker build -t my-ubuntu-sshd:latest .
```

### Running a Container

To run a container based on the image, use the following command:

```bash
docker run -d \
  -p host-port:22 \
  -e SSH_USERNAME=myuser \
  -e SSH_PASSWORD=mysecretpassword \
  -e AUTHORIZED_KEYS="$(cat path/to/authorized_keys_file)" \
  -e SSHD_CONFIG_ADDITIONAL="your_additional_config" \
  -e SSHD_CONFIG_FILE="/path/to/your/sshd_config_file" \
  my-ubuntu-sshd:latest
```

- `-d` runs the container in detached mode.
- `-p host-port:22` maps a host port to port 22 in the container. Replace `host-port` with your desired port.
- `-e SSH_USERNAME=myuser` sets the SSH username in the container. Replace `myuser` with your desired username.
- `-e SSH_PASSWORD=mysecretpassword` sets the SSH user's password in the container. **This environment variable is
  required**. Replace `mysecretpassword` with your desired password.
- `-e AUTHORIZED_KEYS="$(cat path/to/authorized_keys_file)"` sets authorized SSH keys in the container. Replace `path/to/authorized_keys_file` with the path to your authorized_keys file.
- `-e SSHD_CONFIG_ADDITIONAL="your_additional_config"` allows you to pass additional SSHD configuration. Replace
  `your_additional_config` with your desired configuration.
- `-e SSHD_CONFIG_FILE="/path/to/your/sshd_config_file"` allows you to specify a file containing additional SSHD
  configuration. Replace `/path/to/your/sshd_config_file` with the path to your configuration file.
- `my-ubuntu-sshd:latest` should be replaced with your Docker image's name and tag.

### Running with systemd and systemctl (optional)

This image can also run `systemd` as PID 1 inside the container, which enables full `systemctl` support. To use this mode,
you must run the container with additional privileges and enable systemd via an environment variable:

```bash
docker run -d \
  --privileged \
  --cgroupns=host \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -p host-port:22 \
  -e SSH_USERNAME=myuser \
  -e SSH_PASSWORD=mysecretpassword \
  -e ENABLE_SYSTEMD=1 \
  my-ubuntu-sshd:latest
```

In this mode:

- `systemd` runs as PID 1 inside the container.
- `openssh-server` is managed by `systemd` (via the `ssh` service).
- The SSH user is added to the `sudo` group so you can run `systemctl` via `sudo`:

```bash
ssh -p host-port myuser@localhost
sudo systemctl status ssh
sudo systemctl restart ssh
```

### SSH Access

Once the container is running, you can SSH into it using the following command:

```bash
ssh -p host-port myuser@localhost
```

- `host-port` should match the port you specified when running the container.
- Use the provided password or SSH key for authentication, depending on your configuration.

### Deploy to Railway

You can deploy this image directly to Railway using the button at the top of this README, or by visiting:

- https://railway.app/new/template?templateUrl=https://github.com/aoudiamoncef/ubuntu-sshd

On Railway, you will typically:

1. Select this repository as the template.
2. Configure the following environment variables:
   - `SSH_USERNAME` – SSH username inside the container (default: `ubuntu`).
   - `SSH_PASSWORD` – **required**, password for the SSH user.
   - `AUTHORIZED_KEYS` – optional, contents of your `authorized_keys` file; if set, password authentication is disabled.
   - `SSHD_CONFIG_ADDITIONAL` – optional, extra sshd configuration as a string.
   - `SSHD_CONFIG_FILE` – optional, path to a file (inside the container) with additional sshd configuration.
   - `ENABLE_SYSTEMD` – optional (`1` / `true`) to run systemd as PID 1 and enable full `systemctl` support. Note that Railway’s runtime may not expose full cgroup/systemd capabilities, so this mode is best-effort and primarily targeted at local or privileged Docker environments.

3. Expose port `22` in your Railway service configuration and use the assigned TCP endpoint to connect via SSH.

Example Railway SSH command (replace host and port with the values Railway gives you):

```bash
ssh -p <railway_port> SSH_USERNAME@<railway_host>
```

Use the configured password or your SSH key depending on your setup.

### Deploy to Vercel (note)

A Vercel deploy button is provided for convenience:

- https://vercel.com/new/clone?repository-url=https://github.com/aoudiamoncef/ubuntu-sshd

However, Vercel’s platform is designed for HTTP-based, stateless workloads (serverless functions and web apps), and does
**not** expose a raw TCP port for SSH access. This repository is primarily intended for Docker-based environments where you
can bind port `22` and run long-lived SSH sessions. The Vercel button is mainly useful if you want to clone or adapt this
project into a Vercel-compatible HTTP service, not to run an SSH daemon directly.

### Deploy to Firebase (note)

Firebase Hosting and Cloud Functions are also optimized for HTTP(S) and event-driven workloads. They do not provide a
general-purpose Linux VM or container with exposed TCP ports like `22`, so you cannot run this SSHD-based Docker image
_directly_ on Firebase as an SSH-accessible host.

You **can**:

- Use Firebase as a frontend or control panel (web UI, API) to manage metadata or configuration (e.g., which SSH hosts
  to connect to).
- Run this image on a compatible container platform (GCE, GKE, Cloud Run with TCP proxy in front, or any of the platforms
  listed below) and have Firebase front it via HTTP APIs or act as a management plane.

But you **cannot** use Firebase alone to expose port `22` for SSH.

### Deploy to other Docker-based platforms

Because this image is a standard Ubuntu + SSHD Docker image, it can be deployed to many other platforms that support
long-lived Docker containers and TCP port binding, such as:

- Render
- Fly.io
- DigitalOcean Apps / Droplets
- AWS ECS / Fargate
- Kubernetes clusters (GKE, AKS, EKS, etc.)
- Red Hat OpenShift or other Red Hat-based Kubernetes distributions
- Plain Docker hosts or Swarm

At a high level, you will:

1. Build and push the image to a registry (e.g. Docker Hub, GHCR):

   ```bash
   docker build -t your-registry/ubuntu-sshd:latest .
   docker push your-registry/ubuntu-sshd:latest
   ```

2. Create a service on your platform that uses the image and sets environment variables:
   - `SSH_USERNAME`
   - `SSH_PASSWORD`
   - `AUTHORIZED_KEYS` (optional)
   - `SSHD_CONFIG_ADDITIONAL` (optional)
   - `SSHD_CONFIG_FILE` (optional)
   - `ENABLE_SYSTEMD` (optional; requires a privileged / systemd-capable runtime)

3. Expose container port `22` and map it to a public TCP port, then connect via SSH:

   ```bash
   ssh -p <public_port> SSH_USERNAME@<public_host>
   ```

Make sure your platform’s security groups / firewalls allow inbound TCP connections on the chosen SSH port.

#### Example: Render (Docker service)

For Render, you typically:

1. Push the image to a registry (or let Render build from this repo).
2. Create a **Web Service** using the image or repo.
3. Set environment variables in the Render dashboard:
   - `SSH_USERNAME`
   - `SSH_PASSWORD`
   - `AUTHORIZED_KEYS` (optional)
   - `SSHD_CONFIG_ADDITIONAL` / `SSHD_CONFIG_FILE` (optional)
4. Expose port `22` as the service port. Render will give you a host and port; connect with:

   ```bash
   ssh -p <render_port> SSH_USERNAME@<render_host>
   ```

Systemd mode (`ENABLE_SYSTEMD=1`) may not be fully supported because Render does not run privileged containers with full cgroup access.

#### Example: Fly.io

For Fly.io, you can use a minimal `fly.toml`:

```toml
app = "ubuntu-sshd"

[build]
  image = "your-registry/ubuntu-sshd:latest"

[[services]]
  internal_port = 22
  protocol = "tcp"

  [[services.ports]]
    handlers = ["tls"]
    port = 2222
```

Then:

```bash
fly launch    # or fly deploy if app already exists
fly secrets set SSH_USERNAME=myuser SSH_PASSWORD=mysecretpassword
```

Connect via:

```bash
ssh -p 2222 myuser@<your-app>.fly.dev
```

Fly.io also does not run with full systemd/cgroup privileges by default, so `ENABLE_SYSTEMD` is not recommended there.

#### Example: Red Hat OpenShift / Red Hat-based Kubernetes

On OpenShift or other Red Hat-based Kubernetes platforms, you typically run this image as a Deployment with a Service:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ubuntu-sshd
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ubuntu-sshd
  template:
    metadata:
      labels:
        app: ubuntu-sshd
    spec:
      containers:
        - name: ubuntu-sshd
          image: your-registry/ubuntu-sshd:latest
          ports:
            - containerPort: 22
          env:
            - name: SSH_USERNAME
              value: "ubuntu"
            - name: SSH_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: ubuntu-sshd-secret
                  key: ssh_password
---
apiVersion: v1
kind: Service
metadata:
  name: ubuntu-sshd
spec:
  type: LoadBalancer
  selector:
    app: ubuntu-sshd
  ports:
    - port: 22
      targetPort: 22
      protocol: TCP
```

- Create a Secret (`ubuntu-sshd-secret`) with `ssh_password` set.
- OpenShift may impose security constraints (e.g. non-root UIDs, restricted SCCs). If needed, adjust the securityContext or SCC to allow this image to run `sshd` as required.
- Systemd mode (`ENABLE_SYSTEMD`) usually requires privileged containers with host-level cgroup access and is generally **not recommended** on multi-tenant Kubernetes/OpenShift clusters.

### Note

- If the `AUTHORIZED_KEYS` environment variable is empty when starting the container, it will still launch the SSH server, but no authorized keys will be configured. You have to mount your own authorized keys file or manually configure the keys in the container.
- If `AUTHORIZED_KEYS` is provided, password authentication will be disabled for enhanced security.

## License

This Docker image is provided under the [MIT License](LICENSE).
