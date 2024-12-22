import gleam/result
import gleam/list
import gleam/io
import gleam/string
import gleam/int

pub fn parse(input: String) -> List(Int) {
    input 
    |> string.split("\r\n")
    |> list.map(fn(x) { x |> int.parse |> result.unwrap(0) } )
}

pub fn iterate(value: Int) -> Int {
    let result = value * 64
    let value = mix(value, result)
    let value = prune(value)

    let result = value / 32
    let value = mix(value, result)
    let value = prune(value)

    let result = value * 2048
    let value = mix(value, result)
    let value = prune(value)

    value
}

fn mix(value: Int, secret: Int) -> Int {
    int.bitwise_exclusive_or(value, secret)
}

fn prune(value: Int) -> Int {
    value % 16777216
}

pub fn expect(use_sample: Bool, result: Int, sample_expected: Int) -> Nil {
    case use_sample {
        True -> {
            case result == sample_expected {
                True -> {
                    io.debug("Sample OK")
                    Nil
                }
                False -> 
                    panic as { "Expected: " <> sample_expected |> int.to_string <> ", got " <> result |> int.to_string }
            }
        }
        False -> {
            io.debug("Result: " <> result |> int.to_string)
            Nil
        }
    }
}