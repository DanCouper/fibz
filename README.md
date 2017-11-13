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

Running `Fibz.stop/1` will stop the GenServer - as the restart is by default permanent, the server will
immediately restart - the only visible change will be that the cache has now been emptied.

```
$> iex --sname fibz@localhost -S mix
```

*NOTE* amend the name according to what you want to do - I am just testing by running multiple nodes locally,
and ran into [this issue](https://github.com/elixir-lang/elixir/issues/3955) on OSX. I have to add the
`@localhost` suffix to the shortname, as the non-local hostname doesn't seem to exist: tl/dr I can't use `Node.connect/1` without doing this.

```
iex(fibz@localhost)1> Fibz.compute 1
1
iex(fibz@localhost)1> Fibz.compute 3
"fizz"
iex(fibz@localhost)1> Fibz.compute 5
"buzz"
iex(fibz@localhost)1> Fibz.compute 15
"fizzbuzz"
```

## Connecting to Fibz from another node

In a new terminal

```
$> iex --sname one@localhost
```

Then

```
iex(one@localhost)1> Node.connect :"fibz@localhost"
true
iex(one@localhost)1> :pg2.which_groups
[Fibz.Server]
iex(one@localhost)1> :pg2.join Fibz.Server, self()
:ok
iex(one@localhost)1> Fibz.compute 5
"buzz"
```

*NOTE* this worked the first time I tried it, second time it failed - `which_groups` just gave
an empty list :\


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
