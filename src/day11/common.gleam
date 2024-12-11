import gleam/list
import gleam/io
import gleam/string
import gleam/int

pub type Stone = Int
pub type Stones = List(Stone)

pub fn parse(input: String) -> Stones {
    input 
        |> string.split(" ")
        |> list.map(string.trim)
        |> list.map(fn(x) {
            let assert Ok(x) = x |> int.parse
            x
        })
}

pub fn blink_stone(stone: Stone) -> Stones {
    let total_digits = stone |> int.to_string |> string.length

    case stone {
        0 -> [1]
        _ -> {
            case total_digits % 2 == 0 {
                True -> {
                    let half = total_digits / 2

                    let assert Ok(left) = stone |> int.to_string |> string.slice(0, half) |> int.parse
                    let assert Ok(right) = stone |> int.to_string |> string.slice(half, half) |> int.parse

                    [left, right]
                }
                False -> [stone * 2024]
            }
        }
    }
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