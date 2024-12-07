import gleam/result
import gleam/list
import gleam/io
import gleam/string
import gleam/int

pub type Equation = #(Int, List(Int))
pub type Equations = List(Equation)

pub fn parse(input: String) -> Equations {
    input 
        |> string.split("\n")
        |> list.map(parse_line)
}

fn parse_line(line: String) -> Equation {
    let assert [left, right] = line |> string.split(":")

    let assert Ok(left) = left |> string.trim |> int.parse
    let right = 
        right 
        |> string.trim 
        |> string.split(" ") 
        |> list.map(int.parse)
        |> list.map(fn (x) { result.unwrap(x, 0) })

    #(left, right)
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