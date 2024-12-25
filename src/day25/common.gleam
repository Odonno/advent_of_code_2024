import gleam/iterator
import gleam/result
import gleam/dict
import gleam/list
import gleam/io
import gleam/string
import gleam/int

type GridCell {
    Filled
    Empty
}

pub type SchematicType {
    Lock
    Key
}

pub type Schematic {
    Schematic(t: SchematicType, heights: List(Int))
}

pub type Schematics = List(Schematic)

pub fn parse(input: String) -> Schematics {
    input 
    |> string.split("\r\n\r\n")
    |> list.map(parse_schematic)
}

fn parse_schematic(schematic_str: String) -> Schematic {
    let grid = 
        schematic_str
        |> string.split("\r\n")
        |> list.index_fold(dict.new(), fn(acc, line, y) {
            line 
            |> string.split("")
            |> list.index_fold(acc, fn(acc, char, x) {
                let cell = case char {
                    "." -> Empty
                    "#" -> Filled
                    _ -> panic as "Unexpected character"
                }

                acc |> dict.insert(#(x, y), cell)
            })
        })

    let is_lock = 
        grid
        |> dict.filter(fn(key, _) { key.1 == 0 })
        |> dict.values
        |> list.all(fn(cell) { cell == Filled })

    let t = case is_lock {
        True -> Lock
        False -> Key
    }

    let max_x = grid |> dict.keys |> list.map(fn(x) { x.0 }) |> list.sort(int.compare) |> list.last |> result.unwrap(0)

    let heights = 
        iterator.range(0, max_x)
        |> iterator.map(fn(x) {
            let h = 
                grid
                |> dict.filter(fn(key, _) { key.0 == x })
                |> dict.values
                |> list.filter(fn(cell) { cell == Filled })
                |> list.length

            h - 1
        })
        |> iterator.to_list

    Schematic(t, heights)
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