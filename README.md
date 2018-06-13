# ansible-role-mosquitto

Configure mosquitto MQTT server.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `mosquitto_user` | mosquitto user name | `{{ __mosquitto_user }}` |
| `mosquitto_group` | mosquitto group | `{{ __mosquitto_group }}` |
| `mosquitto_log_dir` | log directory (you have to set `log_dest` to file) | `/var/log/mosquitto` |
| `mosquitto_db_dir` | `persistence_location` | `{{ __mosquitto_db_dir }}` |
| `mosquitto_service` | service name of mosquitto | `mosquitto` |
| `mosquitto_conf_dir` | directory of configuration files | `{{ __mosquitto_conf_dir }}` |
| `mosquitto_conf_file` | path to `mosquitto.conf` | `{{ __mosquitto_conf_dir }}/mosquitto.conf` |
| `mosquitto_package` | | `mosquitto` |
| `mosquitto_pid_file` | path to PID file | `/var/run/mosquitto.pid` |
| `mosquitto_flags` | flags to pass start up script (currently, FreeBSD only) | `""` |
| `mosquitto_port` | port to listen on | `1883` |
| `mosquitto_bind_address` | bind address | `""` |
| `mosquitto_server` | enable and configure `mosquitto` server if yes (or any `True` value). Set `mosquitto_server` to `no` (or `False` value) when you do not want to run `mosquitto` server. | `yes` |
| `mosquitto_extra_packages` | list of dict of extra packages to install (see below) | `[]` |
| `mosquitto_wait_for_timeout` | how long to wait for the service to start, or timeout in second for `wait_for` in task and handler | `30` |
| `mosquitto_config` | string of `mosquitto.conf(5)` | `""` |

## `mosquitto_extra_packages`

This is a list of dict. Each element represents a package to install (or
uninstall).

| Key | Description | Mandatory? |
|-----|-------------|------------|
| `name` | package name | yes |
| `state` | either `present` or `absent`. `present` if omitted | no |

## Debian

| Variable | Default |
|----------|---------|
| `__mosquitto_user` | `mosquitto` |
| `__mosquitto_group` | `nogroup` |
| `__mosquitto_db_dir` | `/var/lib/mosquitto` |
| `__mosquitto_conf_dir` | `/etc/mosquitto` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__mosquitto_user` | `nobody` |
| `__mosquitto_group` | `nobody` |
| `__mosquitto_db_dir` | `/var/db/mosquitto` |
| `__mosquitto_conf_dir` | `/usr/local/etc/mosquitto` |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__mosquitto_user` | `_mosquitto` |
| `__mosquitto_group` | `_mosquitto` |
| `__mosquitto_db_dir` | `/var/db/mosquitto` |
| `__mosquitto_conf_dir` | `/etc/mosquitto` |

## RedHat

| Variable | Default |
|----------|---------|
| `__mosquitto_user` | `mosquitto` |
| `__mosquitto_group` | `mosquitto` |
| `__mosquitto_db_dir` | `/var/lib/mosquitto` |
| `__mosquitto_conf_dir` | `/etc/mosquitto` |

# Dependencies

None

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - name: trombik.redhat-repo
      when:
        - ansible_os_family == 'RedHat'
    - name: trombik.apt-repo
      when:
        - ansible_distribution == 'Ubuntu'
        # XXX replace version_compare with `is version` when OpenBSD boxen get
        # updated to ansible 2.5.x
        # - ansible_distribution_version is version('18.04', '<')
        - ansible_distribution_version | version_compare('18.04', '<')
    - name: ansible-role-mosquitto
  vars:
    mosquitto_bind_address: "{{ ansible_default_ipv4.address }}"
    mosquitto_config: |
      user {{ mosquitto_user }}
      pid_file {{ mosquitto_pid_file }}
      bind_address {{ mosquitto_bind_address }}
      port {{ mosquitto_port }}
      log_dest syslog
      autosave_interval 1800
      persistence true
      persistence_location {{ mosquitto_db_dir }}/
      persistence_file mosquitto.db
    redhat_repo_extra_packages:
      - epel-release
    apt_repo_to_add:
      - ppa:mosquitto-dev/mosquitto-ppa
```

# License

```
Copyright (c) 2017 Tomoyuki Sakurai <y@trombik.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <y@trombik.org>

This README was created by [qansible](https://github.com/trombik/qansible)
