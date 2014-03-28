# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.5.0"

Vagrant.configure("2") do |c|

  certs = <<CERTS
-----BEGIN CERTIFICATE-----
MIIFXzCCA0egAwIBAgIBCDANBgkqhkiG9w0BAQsFADAzMTEwLwYDVQQDDChQdXBw
ZXQgQ0E6IGlwLTEwLTIwNC00Mi0yMzkuZWMyLmludGVybmFsMB4XDTEzMDIyNDE5
MDg0NFoXDTE4MDIyNDE5MDg0NFowFTETMBEGA1UEAwwKdm0ubHluci5jbzCCAiIw
DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAJtI7CSgR+NbutSl6nf6Aaw/m6dv
n7UiHGLKjpmWunozQkKAjHQRZ2p4k4Tvyy76VtwzlXZMckLa7UlZ/xtiF0GeGyB0
cKxZPHf6CfiYwjQKBQWWCDrs4q6Vsi4IJUdBp4MIpVeSHcz6F5weIGc+1vjoeMT7
nRxPwUCheKF0JX6r7exbTcyxm6a8dwijtNNJM7NhuNbwn6zQALV+fYFOKdQjt6os
LyRcpXCSQAAMPqFB8XasJsA0MclA6Ugu7drvkjRlJ4vBATIfMotMqrDbFiw2U/7n
gM24HKY+HZqoX2CQ/1ziztnojillJzBugUbHSJ0gt1MBe9ir7Dl9lqbuPa+eL0+m
Obakm+Up3QDRt1/b5RR+0P+pkOEZT/XoYQab5EMJGraYYVzjC1zO+YEXXMYbuOXD
e5swgI1+qco0UqbAbbr73PT9iMzDgnzhujsQUSjMDPT+m2ipcqg2r2ac/Xx+EYcG
8Y4pyYo5XbQD4Zt5ZPEnmwvbiBXbzZtiVliQ/iIo6B/+fvZm3bCSxiKEp6rqJ2m1
/QURW7crzdYmaZSq8YTBL2RVy7SSnxMv2EISjW2Z3mWISToY3SWsnIgrR6/Dtfhi
dtRCrz+2n/I9r41N9QqQgoFIOfSqvgeEsLrKkwM/FM841gLUU7AEOQrSkg1NZB0d
oeEt4WpwRLhhZsNpAgMBAAGjgZswgZgwDAYDVR0TAQH/BAIwADAgBgNVHSUBAf8E
FjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwNwYJYIZIAYb4QgENBCoWKFB1cHBldCBS
dWJ5L09wZW5TU0wgSW50ZXJuYWwgQ2VydGlmaWNhdGUwHQYDVR0OBBYEFHXEcqyx
UXpod8pWJIeUP5azGzzYMA4GA1UdDwEB/wQEAwIFoDANBgkqhkiG9w0BAQsFAAOC
AgEAoI6S2N9438mmnH3MUZWv/5oQFWiI+fExvWFbUPNpxMvhJUkTDgNZsoWJwN7G
G8oKr0khs+aiFBcppEm9ZeFwgrtIYVhk6rMxo1jce+ftBcc01GrKL1iMrIHd2q0U
VQNcK2ldftR/30byJ98fvkxdTvrlAvdhzdEi90UreaVq4XKGx4dlWCgueYWBCLeY
ntD8nGHHynx1SZmr9Tpjrt5vOt9nZGeFhvMKEl6Vt6ODuRzMc3cHUDBkOZGQGGXZ
Gn+AboAWTGUg0p9or0uEMmKDHdVXPXdvYwS/0jMXW0E31BvNiAvO+sTYGa1TdAHd
xDjM0+HM78yAudlsGbtlO1nYLsugiIBjgDbRVCyi9tU8qQc4yLIh+xCspzrYzX3q
zQJHk9Rn3zryl/QTSng5sMMZ1lYzkfQ/B8JhgqxtpKvBcslnPGrntO15tEgyYpQO
f+tqpqv1ZaJc68xhP1elTT7vQR3Oc7zAU/a1wEr8i26wALFtc9d918b2R2Yz+fPY
wYkHPH8dudRDYIwaM6KS7gH0Xk2Rc8g3mKoJIxJTZ802sKqIqZpUxNDoypXPqpZE
GHXVcNZ2mF6BJp0/q9dCUzXPg6IIW+D5rSExvZFtzWhJ9kaVMInsB93e0Vz9ho2q
JubaEksCnU/ELhgCarsncbgkzwyZUSaww1Pk5jpXI997L6k=
-----END CERTIFICATE-----
CERTS

  privs = <<PRIVS
-----BEGIN RSA PRIVATE KEY-----
MIIJKAIBAAKCAgEAm0jsJKBH41u61KXqd/oBrD+bp2+ftSIcYsqOmZa6ejNCQoCM
dBFnaniThO/LLvpW3DOVdkxyQtrtSVn/G2IXQZ4bIHRwrFk8d/oJ+JjCNAoFBZYI
OuzirpWyLgglR0GngwilV5IdzPoXnB4gZz7W+Oh4xPudHE/BQKF4oXQlfqvt7FtN
zLGbprx3CKO000kzs2G41vCfrNAAtX59gU4p1CO3qiwvJFylcJJAAAw+oUHxdqwm
wDQxyUDpSC7t2u+SNGUni8EBMh8yi0yqsNsWLDZT/ueAzbgcpj4dmqhfYJD/XOLO
2eiOKWUnMG6BRsdInSC3UwF72KvsOX2Wpu49r54vT6Y5tqSb5SndANG3X9vlFH7Q
/6mQ4RlP9ehhBpvkQwkatphhXOMLXM75gRdcxhu45cN7mzCAjX6pyjRSpsBtuvvc
9P2IzMOCfOG6OxBRKMwM9P6baKlyqDavZpz9fH4RhwbxjinJijldtAPhm3lk8Seb
C9uIFdvNm2JWWJD+IijoH/5+9mbdsJLGIoSnquonabX9BRFbtyvN1iZplKrxhMEv
ZFXLtJKfEy/YQhKNbZneZYhJOhjdJayciCtHr8O1+GJ21EKvP7af8j2vjU31CpCC
gUg59Kq+B4SwusqTAz8UzzjWAtRTsAQ5CtKSDU1kHR2h4S3hanBEuGFmw2kCAwEA
AQKCAgBTRfrk9VM32LRLXyJq7pZBEedeFh02XLGORQPN16fu6lgpI5iukbq8vSaX
DqUOb09vTPZk9z/7HD5NrMaCn8rK9IelkuvtcPldeagpOXpDv+/LfBazyt8RMtPX
naSoHsw/F77bRE9Y4fERVpKX63oLB1fkgu5RBXAkQbNYGdoVoQu5SYliMQjAlKbc
6jWJbOMd2lTuZyGp4e3PZqLVWd5SlkjjKEirnkdWJAfQPsDDZ4Ke2lj5j8P3Iik3
/XqugvULxgc8CeejQlmvnBCZQRQV55iJxQosyAQNHphvnMVxGrDm1faJow3Boy4t
6cTH+Qy2vpmxGMWafy/x8Kh+oppPIpOliLX0KKaDQMMWH94VELEvgyDBp//dZY5W
Mn2pIzpVKLEF1Hx1aFEbbYKXPasqWFEG+hMakgD9b8MJdt2uDQf4bJRr0zGouht3
HaYBwmylZ7ynk4Lo0ygp11hHlvR8qF6wsJhYR+xrDKqXa9MpoVr7tFp23jIyJjaf
gjj4IZ06TLQRTvKUu1KR2zUfIc0LYDcr4uBj3mXy9FhZvRsTBTdCiVLpjUWBIPcP
ene6LglE8tMYphygZEzolzciQeJyFgJISzcMY9zEi22ZyeDbcQcPpNwRqRAbgK8S
mycKqy4Re12jWNP5+4xpLCe4JIp4E569XPSGeIRiDCYgy5ulpQKCAQEAyC/iZEcp
iK5XfKu6a0fQmzsBC+16eGnIWhj2s8XfTc79x4j+5/Tzw9FyJZNYcxieDXui1Wrm
O264asobg1BY0YHTITeZx5OgtL5LZJfIXQGKcHIn6Dt3SGq+6tCIYZieQkwXqDsC
8+yI7EjSbmVblzx6t4WGBe5TUpg+gkiLB/mD3NHeNda0YqQLWk2mpCo5VkZvMZn+
Q+uvieveW3oXROub24ZswEi3d/XqVB8881IFBa/CQeGWNfsvbhNWHS1jx/LU12A2
e1ktdXYT1LHmne4gajkcJuiYtyVKx2Rw4kJYA7MxuOmSStudWlYoxZRjNFqqjS3j
wbROy3TnIDKliwKCAQEAxpQyVXcfeLj8Fkj+LbSkfqSchNPajmZr/JXcEXYWYKd1
s9sFYLQ/Tjg07Q3A2xVe25U44mj8TerJSzNNZBoyaKOI5PnVnaD/XTUhvV9KC3BA
rJMMbcX0UkJBzUd35zQnoRN5/tMmPlCnstuVcKrOZoj0bbkI6/KjWYdAtWyAQP17
BVGz1pmPle8tu9M78AS5DCSLlG6D9aeN00ngCTGzk1t6XSF2Naq+EGVmS8A2RQTM
tnm2LtxQOLWJcquYTU8g8DbaG8ya+ZSydbXF6QEb1rlMLf7RCTWHnw2WOgp6Y46O
n8UgIwUL9EXm6UBjDsViBzbKjR4moOKUhQtlAA0hWwKCAQEAvTid2sF1HfAFXB+K
vzsLkJ8uNxMLD2SV76vnDTh9AbQlJ4VzxNdBzxdbuO7UzT44r2/tE6PO6eCXSsGt
TesVeTso0R4YKpB9eDrjUrsxtc/uBqmw1Q/YiUf1HElukCnNdcctGWRmPyCWsBmJ
ZrZB4+tT58K7U0HZ2plzhHyDhk8wd/qb+vHuYcrDvGDnogcTWVyMYCs6LwNJUqnz
7S2zbv7xvIgMpZhWa3q0Oz2nxCsD+kMO8G0GKhI62+ZFIKE1ztrWmpokBWXe1Ud+
KS7bWO6sDxvaY2C6cWs7isuC9CtXvG+WET4efMmnq6sDMPc46lTFH1uADCmdzSy8
BzA4TwKCAQAeLREFCcgfiUTNgiQV//hrQkqCqMryjr/kL0W05ZP69hed0C+eBWYF
Vec9CrT+1d2HUsLFLR0CHiaepdoh1xVH72nzGcALZxbHLDbHVz6iRFmfn+zolYdO
JMFpF24yFSvcf2AviBisqYcCV/n6mAorbK5wKgkgCcwm47XCnA1VUu+p3EOO3eEC
8MirXSsjiyQvozIOyUiGQQL9U6GW5BWc0+7hTh9vglXFmhMUec4FaPhO1moH7vTF
2Vhcs5S+UsL3ne5BATOfr6f62TeM890uIRRhfPJ5CshkNCVbBpKYpGYqA0Oh7rdl
VGYFlgI3kWkXHY1kKmvGUQguu4+KlXQ3AoIBAEr/YSSdeAdFJae664j1q5ywQEXF
mxM9YTM9T2n81H22MZY8hKO9OZZvVpQSlKxaTE8ksYzI9DrlG5Krjjc4z3H5CFFY
CSg1OBj+Z7xMZhVTa05Ai9gSQtILtP1EjN3vXSj/8Yn7Gp9lc7Gi5L43qWs0sM10
n1hI9O3GJ9DlT4MBrcq9jXO45FiffY1YZKtDmk/uemZuYiBIoUuH+kYxMV9wQq36
SLaJV0yR02c8qNWeXRXDMmA3F8y+IwEdNsCwvBTDLwD6GgcN+zvfXvVWZUjJ3vb8
YULayq/fPB7G3gbzZVvYgwuohbpbLR0GwOGPtAqfMUGOz5js9wE4m5wFln8=
-----END RSA PRIVATE KEY-----
PRIVS

  # Write pem files to tmp files so they can be copied over to box
  Dir.mkdir("vm")
  File.open("vm/cert.pem", "w") { |cert_file| cert_file.puts certs }
  File.open("vm/priv.pem", "w") { |priv_file| priv_file.puts privs }

  c.vm.define :db do |config|

    # # Box base files
    config.vm.box = "precise64"
    config.vm.box_url = "http://files.vagrantup.com/precise64.box"
    config.vm.box_download_checksum = "5803ee2fa7c5ded51a59f7928a2fead0"
    config.vm.box_download_checksum_type = "md5"

    # # VM settings
    config.vm.provider :virtualbox do |vbox, override|
      vbox.customize ["modifyvm", :id, "--memory", 1024]
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
      puppet.puppet_server = "puppet.bryanwrit.es"
      puppet.options = "--verbose --onetime --no-daemonize --environment=production"
    end

  end

end
