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
| `mosquitto_pid_dir` | path to directory of PID file | `{{ __mosquitto_pid_dir }}` |
| `mosquitto_pid_file` | path to PID file. this variable has no effect on RedHat. on Debian family, this variable cannot changed from the default (`/var/run/mosquitto.pid`) because the path is hard-coded in the startup script | `{{ mosquitto_pid_dir }} /mosquitto.pid` |
| `mosquitto_flags` | flags to pass start up script (currently, FreeBSD only) | `""` |
| `mosquitto_port` | port to listen on | `1883` |
| `mosquitto_bind_address` | bind address | `""` |
| `mosquitto_server` | enable and configure `mosquitto` server if yes (or any `True` value). Set `mosquitto_server` to `no` (or `False` value) when you do not want to run `mosquitto` server. | `yes` |
| `mosquitto_extra_packages` | list of dict of extra packages to install (see below) | `[]` |
| `mosquitto_wait_for_timeout` | how long to wait for the service to start, or timeout in second for `wait_for` in task and handler | `30` |
| `mosquitto_include_x509_certificate` | If `true` value, include [`trombik.x509_certificate`](https://github.com/trombik/ansible-role-x509_certificate) `ansible` role during the play | `no` |
| `mosquitto_extra_groups` | List of dict of groups into which user `mosquitto_user` is added. If the group does not exist, the role will create it. | `[]` |
| `mosquitto_config` | string of `mosquitto.conf(5)` | `""` |
| `mosquitto_acl_files`| list of ACL files (see below) | `[]` |
| `mosquitto_accounts`| list of MQTT account (see below) | `[]` |
| `mosquitto_accounts_file` | path to MQTT account database file |

## `mosquitto_extra_packages`

This is a list of dict. Each element represents a package to install (or
uninstall).

| Key | Description | Mandatory? |
|-----|-------------|------------|
| `name` | package name | yes |
| `state` | either `present` or `absent`. `present` if omitted | no |


## `mosquitto_acl_files`

This is a list of dict of ACL files to create or delete.

| Key | Description | Mandatory? |
|-----|-------------|------------|
| `path` | path to ACL file | yes |
| `state` | either `present` or `absent` | yes |
| `content` | the content of the file | no |

## `mosquitto_accounts`

This is a list of MQTT accounts, pairs of user name and password. An element
must be a dict with keys below.

| Name | Description |
|------|-------------|
| `name` | Name of the MQTT account |
| `password` | Password of the account |

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
---
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
    ca_cert_file: "{{ mosquitto_conf_dir }}/certs/ca.pem"
    mosquitto_include_x509_certificate: yes
    mosquitto_bind_address: "{{ ansible_default_ipv4.address }}"
    mosquitto_extra_groups:
      - name: cert
    mosquitto_acl_files:
      - name: my acl
        path: "{{ mosquitto_conf_dir }}/my.acl"
        state: present
        content: |
          topic readwrite public/#
          topic read public_read/#
          topic write public_write/#
          user foo
          topic read $SYS/#
          topic readwrite foo/#
          user bar
          topic read $SYS/#
          topic readwrite bar/#
          user admin
          topic read $SYS/#
          topic readwrite foo/#
          topic readwrite bar/#
    mosquitto_accounts:
      - name: foo
        # `password`
        password: "$6$J8WUb3oFK94I6be3$lTvSR9GPnSZUhg0W0chY2rVcmY04sxGrLBq0it0j0zFiud/S2G8wooFaDVN2xJGGz/FoGk3HO0V4wvd8hlBvcw=="
      - name: bar
        password: "$6$J8WUb3oFK94I6be3$lTvSR9GPnSZUhg0W0chY2rVcmY04sxGrLBq0it0j0zFiud/S2G8wooFaDVN2xJGGz/FoGk3HO0V4wvd8hlBvcw=="
      - name: admin
        password: "$6$J8WUb3oFK94I6be3$lTvSR9GPnSZUhg0W0chY2rVcmY04sxGrLBq0it0j0zFiud/S2G8wooFaDVN2xJGGz/FoGk3HO0V4wvd8hlBvcw=="
    mosquitto_config: |
      user {{ mosquitto_user }}
      # XXX on Ubuntu, mosquitto_pid_file is hard-coded in the init script.
      # XXX on CentOS, the file is not written, and `pid_file` is ignored.
      pid_file {{ mosquitto_pid_file }}
      log_dest syslog
      autosave_interval 1800
      persistence true
      persistence_location {{ mosquitto_db_dir }}/
      persistence_file mosquitto.db
      allow_anonymous true
      acl_file {{ mosquitto_conf_dir }}/my.acl

      # plain MQTT
      listener {{ mosquitto_port }} {{ mosquitto_bind_address }}

      # MQTT/TLS
      listener 8883 {{ mosquitto_bind_address }}
      # even when self-signed cert is used, `cafile` must be set here. without
      # it, TLS will not be activated
      cafile {{ ca_cert_file }}
      keyfile {{ mosquitto_conf_dir }}/certs/private/mosquitto.key
      certfile {{ mosquitto_conf_dir }}/certs/public/mosquitto.pub
      # XXX OpenBSD 6.6 does not support TLS 1.3
      tls_version tlsv1.2

    x509_certificate_debug_log: yes
    x509_certificate:
      - name: ca
        state: present
        public:
          path: "{{ ca_cert_file }}"
          key: |
            -----BEGIN CERTIFICATE-----
            MIIDkTCCAnmgAwIBAgIUYVw5fBR144JGJrXP90d8KxMkkFIwDQYJKoZIhvcNAQEL
            BQAwWDELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoM
            GEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDERMA8GA1UEAwwIZHVtbXkuY2EwHhcN
            MjAwODA4MDYxOTU0WhcNMjUwODA4MDYxOTU0WjBYMQswCQYDVQQGEwJBVTETMBEG
            A1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0cyBQdHkg
            THRkMREwDwYDVQQDDAhkdW1teS5jYTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
            AQoCggEBAOe2IYvs5VWLs83VkGN0Geub3me1dRB/QFzyuykhAG1S7BqRkd37EjpZ
            9DcLKifiLohWWooB63irip8cf/ThFSLSsaQDKUoVKcFNEZg/uKaEGZ21nUnFcFcc
            rPjJBpAj4T1TDRGv911Zxcqu/OwYBwlgbVGQgA25PvFauB56WdzXhLvA0dPlvNA6
            4wscJyAmkF5BIBHArdxHzDZXvQMMC2xZOUeuaaS2sVbia1k3n31kkgrMHa4Q8BVa
            WN883Jz3kwp2344N9EkP25r45azyEHbc91JDwkJH7HYBJS6zxIx09SJ5BZH6JIgf
            OnOf8NrMCrlGAoWKD8jYK4UOSvbCE6sCAwEAAaNTMFEwHQYDVR0OBBYEFKMCHquf
            WmJtOxGayRQT5DUsWj2uMB8GA1UdIwQYMBaAFKMCHqufWmJtOxGayRQT5DUsWj2u
            MA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAEoQZg61krEA9OlB
            bZ1jcTSsW6sSIA+ectMr9+f579WwDpwtR/7Vgh660SxQxMCbir4u6m7dwJD+4bnW
            29iZidxXshJXh0g/g/0aF2AdnaQR9euS7uyW5iVtNC2IPFR83zyaJ4B8hBjvR99O
            Ex9LHdGUetuykFq6KjaaX+rh1DlUE7epiUiTfp7BVwa/UkFgBSpYG4c++Hj4+IbZ
            Uy+krYdt1BJTshfo0LuMumdy7+6+Kipi44xqzof8XRHWG8rcUKSASc/kUSdeAZXn
            uEZvvmJ7x3ijvrwXZunuL96Q6llo/WvRIMTMnKhBgOuM48g338wWaSQbAH4j8y+k
            o4Wxowc=
            -----END CERTIFICATE-----
      - name: mosquitto
        state: present
        public:
          path: "{{ mosquitto_conf_dir }}/certs/public/mosquitto.pub"
          mode: "0444"
          owner: "{{ mosquitto_user }}"
          group: "{{ mosquitto_group }}"
          key: |
            -----BEGIN CERTIFICATE-----
            MIIDMzCCAhsCFHw5MqZ+KtGCX1lvV5JWp8aSBbQNMA0GCSqGSIb3DQEBCwUAMFgx
            CzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRl
            cm5ldCBXaWRnaXRzIFB0eSBMdGQxETAPBgNVBAMMCGR1bW15LmNhMB4XDTIwMDgw
            ODA2MjExMVoXDTMwMDgwNjA2MjExMVowVDELMAkGA1UEBhMCQVUxEzARBgNVBAgM
            ClNvbWUtU3RhdGUxITAfBgNVBAoMGEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDEN
            MAsGA1UEAwwEbXF0dDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANtK
            v+eJMWHfvn9LIa5kWNctYLh7v0WBMD2f6kpzuKAQWRQFb/IHsVxbyfxAZyMD4Gek
            s9PPx8T7+p+zWg+gW2OxpT8/p81EQ5fgF+dKCcaMFaeBZPdFFiPLCko6uzTlPCi0
            sni+6IkxjTxitfx9YaDl7+YSwKXSaJaLzQ94ZeaqwdwCBgGuM3ArhCrag9DxYYVs
            RmXleGDfaQDZkBMuxR05nWiaxMrU1cvIs856NEFmyR002nwAflfQjPxfwgRuaM6M
            5iXr6wZV6arnYqJsHRYeg7B+evMXWpOILfhq8hbNR4n3fRDbFFz88s4c93306VyU
            dXeBvd2Cbz3YGoF16GUCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAPEFozRwEvN9a
            TzaFBqHzyfgYQewkbIWnvfif8Gdo6o6UeO5nMwHtU02UXcbcVLr0seeNqLfWQpP3
            DnSY76qwiKtKjVDRfI3wToFIaYDqbgzj8PWdcjty6Pfp/w1CkK0bWtZwBQcno0U7
            05xJFkuszKmzDZCOePyesMURZU6zHBNIWP7FttvwhjPeeo7fgBd5CCLiyMf8gQIt
            lfEupV6nHWIGQOwQQBWRyYKltRla2Ugw9zEnDmjbSeNdGOHHeietMfhZKXxAuMkS
            lfipiXzwyi0NBFHZJBf/rVy6TnIsWcppTcgBlDMhpC6I54rjo5+t6xNk470boBt4
            ZVzvKkfJcw==
            -----END CERTIFICATE-----
        secret:
          path: "{{ mosquitto_conf_dir }}/certs/private/mosquitto.key"
          owner: "{{ mosquitto_user }}"
          group: "{{ mosquitto_group }}"
          mode: "0440"
          key: |
            -----BEGIN RSA PRIVATE KEY-----
            MIIEowIBAAKCAQEA20q/54kxYd++f0shrmRY1y1guHu/RYEwPZ/qSnO4oBBZFAVv
            8gexXFvJ/EBnIwPgZ6Sz08/HxPv6n7NaD6BbY7GlPz+nzURDl+AX50oJxowVp4Fk
            90UWI8sKSjq7NOU8KLSyeL7oiTGNPGK1/H1hoOXv5hLApdJolovND3hl5qrB3AIG
            Aa4zcCuEKtqD0PFhhWxGZeV4YN9pANmQEy7FHTmdaJrEytTVy8izzno0QWbJHTTa
            fAB+V9CM/F/CBG5ozozmJevrBlXpqudiomwdFh6DsH568xdak4gt+GryFs1Hifd9
            ENsUXPzyzhz3ffTpXJR1d4G93YJvPdgagXXoZQIDAQABAoIBAGQvWU85cXMqmkhj
            lcarl57u31JJTtA9PkHZLlvHVKDj9x5bgZJMi24LjVMORVBM9BfFulZZhgXrrMuL
            T+j1tOrt/PXRaiMwPcVEHweO3rpzw2zcg7koOf4uQ8w32tFGrV5Xd3YMmgYbuk/N
            NSFeUt0ET76H8LWRVDD7O7sGoV9o6RRsfI5pm7sOdHhMleM2tmhAEyaYOJTrQJzl
            qI2kbI+dcq6FUKAkt2SIB2S0+JA6W0VMpcnDGvwvTKBmhWAAQyk7mJijuhZ7L9kv
            WqcPRfrTPzi//aPT851CrGqA+vo7oX7cpQNaQZOMLI0MLg/RNUzaik27RK7ebJO1
            z5kYHsECgYEA+UDCJNUwI9eJS/zdpLECL0d3NLcCXu3rqCFdqma3Xl6EOjUPa43C
            b6a6/R00N3CULlTaGN27sQ8CS0bBaKirHM+FZIvfb6JMEX2h2OS9ozIToJe37rUo
            FlqVTNSZjG8LqWmRZC1SM9jdevOFFFzXIZJ8JvbCIsKb4jbKi6TuPbECgYEA4Tpf
            GtqdYy9yujiQV8tx+VmCo5Xxce7uRKnoC0zibiy5JaP6k4MwT7cwaSl34BgUjmNK
            3pDHDGhcoqdSSfJVh1aroLjnSorATUJn5wlga+bjRhuG4308IOiVXFZlsf9soauw
            JrBTVir2z7abqCrlOF5j3OuhBLlRG4pPwCvEPvUCgYBR1JzoksU3Py/oLqBlzWc2
            NnRAbkTs/Zd8n1es9gQFi2pF4d2qJeRL26VQLCJUgTVk8J6Zw1I3kwHhzNz6i0WC
            M+9LT1CPyezHYUOdfZt01J/0/Vp5mCgNDrgtfS7cGCjv+aSuCuMN+ojcMM7kHIbU
            ks8Hy8N4vgOHhQ2CQyekQQKBgQCq4lreSRg49PsbB2ec9SMYiS1xaIa0ZxAo0LDa
            Qg9agFxJjszDtzmkgd0dLPVi9WJDVlqr2zTq2RPP5RuuN0tlUAEQBLqX+AZHmCa1
            SIv70kaGHsSNPautXEpWsMaf8qg9UcJo2EeijR6OIoKfaUxZJGSoba7RorlDKAGy
            UIKpMQKBgFdu5VdxvY8OcDDJGyUQ7cfbEgGy21f4ECZKnILkuy8MndFi/nYRbXIx
            fTYVEghz0n7btIpisSc6HPg3sJQh7BLH8ByUFdFHP9k6uxHxMHZt+4q62ZsGGt4k
            y2b3dRsFCRR+2bED8QtHL6HHd7uBhz5Qbvpwu1ZceMCY14qUwNk3
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
