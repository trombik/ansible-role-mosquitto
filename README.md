# `ansible` role `mosquitto`

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
| `mosquitto_include_x509_certificate` | If `true` value, include [`trombik.x509_certificate`](https://github.com/trombik/ansible-role-x509_certificate) `ansible` role during the play | `no` |
| `mosquitto_extra_groups` | List of dict of groups into which user `mosquitto_user` is added. If the group does not exist, the role will create it. | `[]` |
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
    - name: trombik.redhat_repo
      when:
        - ansible_os_family == 'RedHat'
    - name: trombik.apt_repo
      when:
        - ansible_distribution == 'Ubuntu'
        - ansible_distribution_version is version('18.04', '<')
    - name: ansible-role-mosquitto
  vars:
    ca_cert_file: "{% if ansible_distribution == 'Ubuntu' and ansible_distribution_version is version('18.04', '>=') %}/etc/ssl/certs/ca-certificates.crt{% elif ansible_os_family == 'RedHat' %}/etc/ssl/certs/ca-bundle.crt{% else %}/etc/ssl/cert.pem{% endif %}"
    mosquitto_include_x509_certificate: yes
    mosquitto_bind_address: "{{ ansible_default_ipv4.address }}"
    mosquitto_extra_groups:
      - name: cert
    mosquitto_config: |
      user {{ mosquitto_user }}
      pid_file {{ mosquitto_pid_file }}
      log_dest syslog
      autosave_interval 1800
      persistence true
      persistence_location {{ mosquitto_db_dir }}/
      persistence_file mosquitto.db

      # plain MQTT
      listener {{ mosquitto_port }} {{ mosquitto_bind_address }}

      # MQTT/TLS
      listener 8883 {{ mosquitto_bind_address }}
      # even when self-signed cert is used, `cafile` must be set here. without
      # it, TLS will not be activated
      cafile {{ ca_cert_file }}
      keyfile {{ mosquitto_conf_dir }}/certs/private/mosquitto.key
      certfile {{ mosquitto_conf_dir }}/certs/public/mosquitto.pub
      tls_version tlsv1

    x509_certificate_debug_log: yes
    x509_certificate:
      - name: mosquitto
        state: present
        public:
          path: "{{ mosquitto_conf_dir }}/certs/public/mosquitto.pub"
          mode: "0444"
          owner: "{{ mosquitto_user }}"
          group: "{{ mosquitto_group }}"
          key: |
            -----BEGIN CERTIFICATE-----
            MIIDOjCCAiICCQDaGChPypIR9jANBgkqhkiG9w0BAQUFADBfMQswCQYDVQQGEwJB
            VTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0
            cyBQdHkgTHRkMRgwFgYDVQQDDA9mb28uZXhhbXBsZS5vcmcwHhcNMTcwNzE4MDUx
            OTAxWhcNMTcwODE3MDUxOTAxWjBfMQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29t
            ZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMRgwFgYD
            VQQDDA9mb28uZXhhbXBsZS5vcmcwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
            AoIBAQDZ9nd1isoGGeH4OFbQ6mpzlldo428LqEYSH4G7fhzLMKdYsIqkMRVl1J3s
            lXtsMQUUP3dcpnwFwKGzUvuImLHx8McycJKwOp96+5XD4QAoTKtbl59ZRFb3zIjk
            Owd94Wp1lWvptz+vFTZ1Hr+pEYZUFBkrvGtV9BoGRn87OrX/3JI9eThEpksr6bFz
            QvcGPrGXWShDJV/hTkWxwRicMMVZVSG6niPusYz2wucSsitPXIrqXPEBKL1J8Ipl
            8dirQLsH02ZZKcxGctEjlVgnpt6EI+VL6fs5P6A45oJqWmfym+uKztXBXCx+aP7b
            YUHwn+HV4qzZQld80PSTk6SS3hMXAgMBAAEwDQYJKoZIhvcNAQEFBQADggEBAKgf
            x3K9GHDK99vsWN8Ej10kwhMlBWBGuM0wkhY0fbxJ0gW3sflK8z42xMc2dhizoYsY
            sLfN0aylpN/omocl+XcYugLHnW2q8QdsavWYKXqUN0neIMr/V6d1zXqxbn/VKdGr
            CD4rJwewBattCIL4+S2z+PKr9oCrxjN4i3nujPhKv/yijhrtV+USw1VwuFqsYaqx
            iScC13F0nGIJiUVs9bbBwBKn1c6GWUHHiFCZY9VJ15SzilWAY/TULsRsHR53L+FY
            mGfQZBL1nwloDMJcgBFKKbG01tdmrpTTP3dTNL4u25+Ns4nrnorc9+Y/wtPYZ9fs
            7IVZsbStnhJrawX31DQ=
            -----END CERTIFICATE-----
        secret:
          path: "{{ mosquitto_conf_dir }}/certs/private/mosquitto.key"
          owner: "{{ mosquitto_user }}"
          group: "{{ mosquitto_group }}"
          mode: "0440"
          key: |
            -----BEGIN RSA PRIVATE KEY-----
            MIIEowIBAAKCAQEA2fZ3dYrKBhnh+DhW0Opqc5ZXaONvC6hGEh+Bu34cyzCnWLCK
            pDEVZdSd7JV7bDEFFD93XKZ8BcChs1L7iJix8fDHMnCSsDqfevuVw+EAKEyrW5ef
            WURW98yI5DsHfeFqdZVr6bc/rxU2dR6/qRGGVBQZK7xrVfQaBkZ/Ozq1/9ySPXk4
            RKZLK+mxc0L3Bj6xl1koQyVf4U5FscEYnDDFWVUhup4j7rGM9sLnErIrT1yK6lzx
            ASi9SfCKZfHYq0C7B9NmWSnMRnLRI5VYJ6behCPlS+n7OT+gOOaCalpn8pvris7V
            wVwsfmj+22FB8J/h1eKs2UJXfND0k5Okkt4TFwIDAQABAoIBAHmXVOztj+X3amfe
            hg/ltZzlsb2BouEN7okNqoG9yLJRYgnH8o/GEfnMsozYlxG0BvFUtnGpLmbHH226
            TTfWdu5RM86fnjVRfsZMsy+ixUO2AaIG444Y4as7HuKzS2qd5ZXS1XB8GbrCSq7r
            iF/4tscQrzoG0poQorP9f9y60+z3R45OX3QMVZxP4ZzxXAulHGnECERjLHM5QzTX
            ALV9PHkTRNd1tm9FSJWWGNO5j4CGxFsPL1kdMyvrC7TkYiIiCQ/dd2CIfQyWwyKc
            8cHBKnzon0ugr0xlf2B0C7RTXrGAcuBC0yyaLuQTFkocUofgDIFghItH8O8xvvAG
            j8HYOwECgYEA9uMLtm2C8SiWFuafrF/pPWvhkBtEHA2g22M29CANrVv1jCEVMti/
            7r53fd328/nVxtashnSFz7a3l3s9d9pTR/rk/rNpVS2i7JGvCXXE3DeoD6Zf4utD
            MLEs2bI0KabdamIywc77CkVj9WUKd53tlcdcn7AsHwESU4Zjk08ie0kCgYEA4gIa
            R+a9jmKEk9l5Gn7jroxDJdI0gEfuA7It5hshEDcSvjF+Fs5+1tVgfBI1Mx4/0Eaj
            6E57Ln3WFKPJKuG0HwLNanZcqLFgiC/7ANbyKxfONPVrqC2TClImBhkQ74BLafZg
            yY8/N/g/5RIMpYvQ9snBRsah9G2cBfuPTHjku18CgYBHylPQk12dJJEoTZ2msSkQ
            jDtF/Te79JaO1PXY3S08+N2ZBtG0PGTrVoVGm3HBFif8rtXyLxXuBZKzQMnp/Rl0
            d9d43NDHTQLwSZidZpp88s4y5s1BHeom0Y5aK0CR0AzYb3+U7cv/+5eKdvwpNkos
            4JDleoQJ6/TZRt3TqxI6yQKBgA8sdPc+1psooh4LC8Zrnn2pjRiM9FloeuJkpBA+
            4glkqS17xSti0cE6si+iSVAVR9OD6p0+J6cHa8gW9vqaDK3IUmJDcBUjU4fRMNjt
            lXSvNHj5wTCZXrXirgraw/hQdL+4eucNZwEq+Z83hwHWUUFAammGDHmMol0Edqp7
            s1+hAoGBAKCGZpDqBHZ0gGLresidH5resn2DOvbnW1l6b3wgSDQnY8HZtTfAC9jH
            DZERGGX2hN9r7xahxZwnIguKQzBr6CTYBSWGvGYCHJKSLKn9Yb6OAJEN1epmXdlx
            kPF7nY8Cs8V8LYiuuDp9UMLRc90AmF87rqUrY5YP2zw6iNNvUBKs
            -----END RSA PRIVATE KEY-----
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
