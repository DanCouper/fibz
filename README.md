# Fibz

An over-engineered FizzBuzz implementation.

## Basic functionality

Just a GenServer with a `compute` function that accepts an integer and returns
a value according to the rules of FizzBuzz:

> Write a program that prints the numbers from 1 to 100. But for multiples of three print “Fizz” instead of the number and for the multiples of five print “Buzz”. For numbers which are multiples of both three and five print “FizzBuzz”.

The GenServer is supervised, and the Application is started as normal via mix in the project root. Starting the server registers a process group using the `:pg2` module. And the server state is an ETS table used to
cache computed values.

The module that handles the FizzBuzz computation, `Fibz.Fizbuzz`, wraps the main function (`parse_int/1`)
in a function that sleeps for a randomised number of milliseconds before returning - this makes it obvious
when running the server what is a cache miss and what is a cache hit.

Casting `:stop` to `Fibz.FizzbuzzServer.compute/1` will stop the GenServer - as the restart is by default permanent, the server will
immediately restart - the only visible change will be that the cache has now been emptied.

```
$> iex -S mix
```

```
iex> Fibz.FizzbuzzServer.compute 1
1
iex> Fibz.FizzbuzzServer.compute 3
"fizz"
iex> Fibz.FizzbuzzServer.compute 5
"buzz"
iex> Fibz.FizzbuzzServer.compute 15
"fizzbuzz"
```

## Connecting to Fibz from another node

### Terminal 1

In this terminal, start up the the Fibz application with a name:

```
iex> iex --name fibz1@127.0.0.1 --cookie monster -S mix
iex(fibz1@127.0.0.1)1> :pg2.which_groups
[Fibz.FizzbuzzServer]
```

**If I don't do this _after_ connecting a new node, the other nodes fail to see that the server process is part of the group. Why?**

### Terminal 2

In this terminal, do same as above and connect:


```
iex> iex --name fibz2@127.0.0.1 --cookie monster -S mix
iex(fibz2@127.0.0.1)1> Node.connect :"fibz1@127.0.0.1"
true
iex(fibz2@127.0.0.1)2> :pg2.get_members Fibz.FizzbuzzServer
```

This should give a list with two PIDs. May have to run something
to "refresh" the `fibz1` terminal to pick up that they're in the same process group (_How to I avoid needing to do this?_).

### Terminal 3

Open a new terminal:

```
$> iex --name client1@127.0.0.1 --cookie monster
iex(client1@127.0.0.1)1> Node.connect :"fibz1@127.0.0.1"
true
iex(client1@127.0.0.1)2> :pg2.get_members Fibz.FizzbuzzServer
```
_This won't immediately pick up any members - need to run again in one of the first terminals. Why?_

```
iex(client1@127.0.0.1)3> GenServer.call(:pg2.get_closest_pid(Fibz.FizzbuzzServer), {:compute, 1})
1
iex(client1@127.0.0.1)4> GenServer.call(:pg2.get_closest_pid(Fibz.FizzbuzzServer), {:compute, 1})
1
```

In the first & second terminals, should see (note pid will be different):

```
"Value of '1' computed using Fibz' Fizzbuzz server via a call from node {#PID<15791.90.0>, #Reference<15791.4064742516.2291400709.230530>}"
"Value of '1' pulled from cache using Fibz' Fizzbuzz server via a call from node {#PID<15791.90.0>, #Reference<15791.4064742516.2291400709.230546>}"
```

Then try:

```
iex(client1@127.0.0.1)5> GenServer.cast(:pg2.get_closest_pid(Fibz.FizzbuzzServer), :stop
:ok)
```

And in the first and second terminals, there should be the message:

```
":stop message cast to Fibz' Fizzbuzz server. Cache cleared down, server restarted."
```

_Again, if further operations are then ran, need to do something in the first/second terminal otherwise it starts throwing errors. Why?_

## Future Reference

_I didn't know how pg2 worked prior to this_

- [:pg2](http://erlang.org/documentation/doc-5.8.4//lib/kernel-2.14.4/doc/html/pg2.html)
- :pg2 and You: Getting Distributed with Elixir - [video](https://youtu.be/_O-bLuVhcCA) and [supporting slides](https://speakerdeck.com/antipax/pg2-and-you-getting-distributed-with-elixir)
- [RePG2](https://hexdocs.pm/repg2/readme.html)
- [Elixir Sips 083:pg2](http://elixirsips.com/episodes/083_pg2.html)
- [Erlang :pg2 Failure Semantics](http://christophermeiklejohn.com/erlang/2013/06/03/erlang-pg2-failure-semantics.html)
- [A Survival Guide on :pg2 Erlang Module](https://pdincau.wordpress.com/2012/01/12/a-survival-guide-on-pg2-erlang-module/)
- [Elixirpalooza](https://gist.github.com/rozap/247e8cfce79d86f86d9dc200041ed022)

and

- [Property tested Haskell FizzBuzz implementation](https://github.com/jsl/fizz-buzz-hs/blob/master/FB.lhs)


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `fibz` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fibz, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/fibz](https://hexdocs.pm/fibz).
