import gleam/set
import gleam/io
import gleam/string
import gleam/int
import gleam/list
import gleam/dict.{type Dict}

pub type Position = #(Int, Int)
pub type CellValue = Int

pub type Map = Dict(Position, CellValue)

pub fn parse(input: String) -> Map {
    input
        |> string.split("\n")
        |> list.index_fold([], fn(acc, line, y) {
            line
                |> string.trim
                |> string.split("")
                |> list.index_fold(acc, fn(acc2, char, x) {
                    let assert Ok(value) = char |> int.parse
                    let item = #(#(x, y), value)

                    [item, ..acc2]
                })
        })
        |> dict.from_list
}

pub fn get_trailheads(map: Map, positions: List(Position), value: Int, unique_paths: Bool) -> Int {
    let next_value = value + 1

    case next_value == 10 {
        True -> {
            case unique_paths {
                True -> positions |> set.from_list |> set.size
                False -> positions |> list.length
            }
        }
        False -> {
            let next_positions = 
                positions
                |> list.fold([], fn(acc, p) {
                    acc |> list.append(get_next_positions(map, p, next_value))
                })

            get_trailheads(map, next_positions, next_value, unique_paths)
        }
    }
}

fn get_next_positions(map: Map, position: Position, value: Int) -> List(Position) {
    let left = #(position.0 - 1, position.1)
    let right = #(position.0 + 1, position.1)
    let top = #(position.0, position.1 - 1)
    let bottom = #(position.0, position.1 + 1)
    
    let near_positions = [left, right, top, bottom]

    near_positions
        |> list.filter(fn(p) {
            case map |> dict.get(p) {
                Ok(v) -> value == v
                _ -> False
            }
        })
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