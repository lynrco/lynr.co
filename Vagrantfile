# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.5.0"

Vagrant.configure("2") do |c|

  certs = <<CERTS
-----BEGIN CERTIFICATE-----
MIIFXDCCA0SgAwIBAgIBBDANBgkqhkiG9w0BAQsFADAyMTAwLgYDVQQDDCdQdXBw
ZXQgQ0E6IGxvY2FsaG9zdC5tZW1iZXJzLmxpbm9kZS5jb20wHhcNMTQwMzI3MjEw
MTE2WhcNMTkwMzI3MjEwMTE2WjAVMRMwEQYDVQQDDAp2bS5seW5yLmNvMIICIjAN
BgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAuU2UUR4X/MFD9zxwaS20ZsrPUnlz
F/kKm4iFImW60eP4yky4+Y8XFDbcZCf87VoZVLZqiAxEqz5yyLJ3KcxrB5/mN0yX
hwY2zADqZiprEWfxNh9ovhd7FSpHWizyVM5tzUTtorLv76dkA1uLI12z8++Yd+iC
AEZmYKFwzYxbZPCN8INC3aaKfapr4WiKzNIfvEaogI+swMDbzBKRmSRwHJt/LiSC
oRFitBtGmbrEZTXSd4nSwYloVslpe7JrNo1Rsevl/ucexR3n4MPwdt1LGZbcEVHG
6jbDvl5TfinsIbd2pG/evmZTLXSi50l5rLsFiMvwEDTDnA+Oc3O4EFT2As+18/gb
dF+VarnsqNq2pdJ7mzf04z28R6VTa+fsKQH2sybW9pH7lE6XfpOI/GCCx/3+tbo1
1VJj5Yi7mq/srD/qpftiya1wamRDPaHjKRqjQH7fGdEEV9E/Tp1/SnpDsocj0VRb
1JHqn59N+Ava/A8bUfq0/3r7Nm2JAOBUhz1eMGCFNFFHLiMFCztcnHy8n/sL287l
Y0gYUdhff2JWbAtoA87YJGvRymUayKZK8AQcuOP9+1CLO1bwlxCviI7lwM7wV2Bg
yQqaU0ae4YfsZsSz1nWLfKPZ0IBRrBL5BgZSOjR/UO3sMlEuxNVWf3ysK+VbMu+u
+QkQRzrcOgZiFSsCAwEAAaOBmTCBljAdBgNVHQ4EFgQUNCl+KmqfQDpk5csth6YN
CojGSkwwNQYJYIZIAYb4QgENBChQdXBwZXQgUnVieS9PcGVuU1NMIEludGVybmFs
IENlcnRpZmljYXRlMA4GA1UdDwEB/wQEAwIFoDAgBgNVHSUBAf8EFjAUBggrBgEF
BQcDAQYIKwYBBQUHAwIwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEA
XUKvz571W72cPvcexblWxg7yg1Ea2WfAaGNSXxXfCscPa6K1aQqODLPbOnKSe1nU
eaRq/SA+dHuMbTxSkZC9oezPOD7WQxoJ7HHfkOoETLs4F2I9YDss+RF9Cf1CT3vR
RWPC0WJizgLIHR2aUzSZH9+imESGDtww3yiGKMsx0VHdOjiB5DgYP3MXIZxtgQNq
ZXY5WdiIq7tpO3/cubRZ8CVUsqg9Th5kHvvl4l4f2sdRT0PUP0GeXkpsgGtTeFCs
AHLm/Cd4WzE+fHv1wI7mapPyPXoqTfu7fto85HD545N1Azq+EwmFKFGtcyYlV7vp
1HXKBqwgKZSZsfADQt+bHZsq0dAc+joEYpYNoqTeYz+9YM1RQGPWdGW3xn0ebPeE
S/I8B0dCFE8IV8ZwrQKuGHRHdrYlkvSkSAX7QlN6r3q4MrEVvpFOJ8s3D3UwAmFC
eesMG0qQb98m4HWwID4XNKr4wiGFLEwzkYeL+zYKdlDEpCsrlH4XCzlFYP+JK+/9
QeiHHh13QYOpogBPweMcH9sXFIhJbW7rgZcDB064uJDSEangLmeD0O3iPzOfSIEV
7DGygWBpoqvp64kDWIXgzSaKlFHm1ABbgOm5TjFgA1xtDDJ9bHh8+Xm7udDXUz9r
h7wROpJ+Z+JGbR7pS/c2knHggXIjwGNTo8EPQA1IdNo=
-----END CERTIFICATE-----
CERTS

  privs = <<PRIVS
-----BEGIN RSA PRIVATE KEY-----
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
-----END RSA PRIVATE KEY-----
PRIVS

  # Write pem files to tmp files so they can be copied over to box
  Dir.mkdir("vm") unless File.directory?('vm')
  File.open("vm/cert.pem", "w") { |cert_file| cert_file.puts certs }
  File.open("vm/priv.pem", "w") { |priv_file| priv_file.puts privs }

  c.vm.define :db do |config|

    # # [VagrantCloud](https://vagrantcloud.com) box
    config.vm.box = "hashicorp/precise64"

    # # VM settings
    config.vm.provider :virtualbox do |vbox, override|
      vbox.name = "lynrco_db"
      vbox.customize ["modifyvm", :id, "--memory", 1024]
      vbox.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
    end

    # # Networking
    config.vm.network "forwarded_port", guest:  5672, host:  5672
    config.vm.network "forwarded_port", guest:  8080, host:  7887
    config.vm.network "forwarded_port", guest:  9200, host:  9200
    config.vm.network "forwarded_port", guest: 27017, host: 27017
    config.vm.synced_folder ".", "/vagrant", type: "rsync"

    # # Provisioning
    config.vm.provision "shell", inline: <<-SHELL
      mkdir -p /etc/puppet/ssl/certs;
      mkdir -p /etc/puppet/ssl/private_keys;
      cp /vagrant/vm/cert.pem /etc/puppet/ssl/certs/vm.lynr.co.pem;
      cp /vagrant/vm/priv.pem /etc/puppet/ssl/private_keys/vm.lynr.co.pem;
    SHELL
    config.vm.provision "puppet_server" do |puppet|
      puppet.puppet_node = "vm.lynr.co"
      puppet.puppet_server = "puppetmaster.lynr.co"
      puppet.options = "--verbose --onetime --no-daemonize --environment=production"
    end

  end

end
