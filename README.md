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
| `mosquitto_config` | array of settings | `[]` |
| `mosquitto_server` | enable and configure `mosquitto` server if yes (or any `True` value). Set `mosquitto_server` to `no` (or `False` value) when you do not want to run `mosquitto` server. | `yes` |


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

- `reallyenglish.redhat-repo` when `ansible_os_family` is RedHat

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - reallyenglish.redhat-repo
    - ansible-role-mosquitto
  vars:
    mosquitto_bind_address: "{{ ansible_default_ipv4.address }}"
    mosquitto_config:
      - "user {{ mosquitto_user }}"
      - "pid_file {{ mosquitto_pid_file }}"
      - "bind_address {{ mosquitto_bind_address }}"
      - "port {{ mosquitto_port }}"
      - "log_dest syslog"
      - "autosave_interval 1800"
      - "persistence true"
      - "persistence_location {{ mosquitto_db_dir }}/"
      - "persistence_file mosquitto.db"
    redhat_repo_extra_packages:
      - epel-release
    redhat_repo:
      epel:
        mirrorlist: "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-{{ ansible_distribution_major_version }}&arch={{ ansible_architecture }}"
        gpgcheck: yes
        enabled: yes
        description: EPEL
```

# License

```
Copyright (c) 2017 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

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

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

This README was created by [qansible](https://github.com/trombik/qansible)
