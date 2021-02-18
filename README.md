## Description
The net-proto package provides a way to get protocol information.

This is a wrapper for the `getprotobyname`, `getprotobynumber` and
the `getprotoent` C functions.

## Installation
`gem install net-proto`

## Prerequisites
* ffi 1.0.0 or later.

## Synopsis
```ruby
require 'net/proto' # or 'net-proto'

# Using generic method
Net::Proto.get_protocol(1)      # => 'icmp'
Net::Proto.get_protocol('icmp') # => 1

# Using type specific methods
Net::Proto.getprotobynumber(6)   # => 'tcp'
Net::Proto.getprotobyname('tcp') # => 6

# Iterating over all protocols
Net::Proto.getprotoent do |ent|
  p ent
end
```

## Why should I use this?
Ruby has a predefined set of constants in socket.c in the general form of
IPPROTO_XXX, Y.  However, using constants in this fashion can be unreliable
because it's easy to define your own protocols (I set 'echo' to 7, for
example), or to modify/delete entries in /etc/protocols.

## Further Documentation
See the 'netproto.rdoc' file under the 'doc' directory for more details.  There
is also an example under the 'examples' directory.
