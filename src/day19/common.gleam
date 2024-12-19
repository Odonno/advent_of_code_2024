import gleam/list
import gleam/io
import gleam/string
import gleam/int

pub type TowelPattern = String
pub type TowelPatterns = List(String)

pub type TowelDesign = String
pub type TowelDesigns = List(String)

pub fn parse(input: String) -> #(TowelPatterns, TowelDesigns) {
    let assert [patterns_str, designs_str] = input |> string.split("\r\n\r\n")

    let patterns = parse_patterns(patterns_str)
    let designs = parse_designs(designs_str)

    #(patterns, designs)
}

fn parse_patterns(patterns_str: String) -> List(String) {
    patterns_str
    |> string.split(",")
    |> list.map(string.trim)
}

fn parse_designs(designs_str: String) -> List(String) {
    designs_str
    |> string.split("\r\n")
    |> list.map(string.trim)
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