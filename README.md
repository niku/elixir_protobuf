# Protobuf

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `protobuf` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:protobuf, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/protobuf](https://hexdocs.pm/protobuf).

## Integration Testing

To generate a python code `test/integration/integrationtest_pb2.py` for integration tests from `.proto` files:

```
$ docker run --rm -v $(pwd):/app niku/pytnoh3-protobuf \
    protoc \
        -I test/integration/proto \
        --python_out=test/integration/python \
        test/integration/proto/integrationtest.proto 
```

To generate json files based on protocol buffer messages for integration tests from `test/integration/input.yaml`:

```
$ docker run --rm -v $(pwd):/app niuk/python3-protobuf \
    python3 test/integration/python/generate_messages.py 
```

An object in json includes key that is expected value and value that is base64 encoded protocol buffer message representation.
