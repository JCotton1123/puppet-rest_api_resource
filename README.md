# REST API Resource

A Puppet module that includes a type/provider for performing configurations on a RESTful API.

## Platforms

Any platform that Puppet runs on.

## Usage

```puppet
rest_resource { "user import":
  ensure    => present,
  base_url  => "https://api.example.com",
  auth_type => "basic",
  identity  => "username",
  secret    => "password",
  exists    => {
    endpoint => "/users/import",
    status   => "200"
  },
  create   => {
    endpoint => "/users",
    method   => "POST",
    body     => {
      username => "import",
      password => "afxfjr6s4qdfst",
      description => "A user for importing data",
    },
    status => "201"
  }
}
```
