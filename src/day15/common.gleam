import gleam/list
import gleam/io
import gleam/string
import gleam/int
import gleam/dict.{type Dict}
import gleam/iterator

pub type WarehouseMapCell {
    Wall
    Empty
    Robot
    Box
    LeftBox
    RightBox
}

pub type Position = #(Int, Int)

pub type WarehouseMap = Dict(Position, WarehouseMapCell)

pub type Direction {
    Left
    Up
    Right
    Down
}

pub type MoveSequence = List(Direction)

pub fn parse(input: String) -> #(WarehouseMap, MoveSequence) {
    let assert [map_lines, sequences_lines] = input |> string.split("\r\n\r\n")

    let sequences_line = 
        sequences_lines 
        |> string.split("\r\n") 
        |> list.fold("", fn(acc, line) { acc <> line })

    #(parse_map(map_lines), parse_sequence(sequences_line))
}

pub fn parse_2(input: String) -> #(WarehouseMap, MoveSequence) {
    let assert [map_lines, sequences_lines] = input |> string.split("\r\n\r\n")

    let sequences_line = 
        sequences_lines 
        |> string.split("\r\n") 
        |> list.fold("", fn(acc, line) { acc <> line })

    #(parse_map_2(map_lines), parse_sequence(sequences_line))
}

fn parse_map(map_lines: String) -> WarehouseMap {
    map_lines
    |> string.split("\r\n")
    |> list.index_fold(dict.new(), fn(acc, line, y) {
        line
        |> string.split("")
        |> list.index_fold(acc, fn(acc, char, x) {
            let cell_type = case char {
                "#" -> Wall
                "." -> Empty
                "@" -> Robot
                "O" -> Box
                _ -> panic as { "Unknown cell type: " <> char }
            }

            dict.insert(acc, #(x, y), cell_type)
        })
    })
}

fn parse_map_2(map_lines: String) -> WarehouseMap {
    map_lines
    |> string.split("\r\n")
    |> list.index_fold(dict.new(), fn(acc, line, y) {
        line
        |> string.split("")
        |> list.index_fold(acc, fn(acc, char, x) {
            let x = x * 2

            case char {
                "#" -> {
                    acc 
                    |> dict.insert(#(x, y), Wall)
                    |> dict.insert(#(x + 1, y), Wall)
                }
                "." -> {
                    acc 
                    |> dict.insert(#(x, y), Empty)
                    |> dict.insert(#(x + 1, y), Empty)
                }
                "@" -> {
                    acc 
                    |> dict.insert(#(x, y), Robot)
                    |> dict.insert(#(x + 1, y), Empty)
                }
                "O" -> {
                    acc 
                    |> dict.insert(#(x, y), LeftBox)
                    |> dict.insert(#(x + 1, y), RightBox)
                }
                _ -> panic as { "Unknown cell type: " <> char }
            }

        })
    })
}

fn parse_sequence(sequences_line: String) -> MoveSequence {
    sequences_line
    |> string.split("")
    |> list.map(fn(char) {
        case char {
            "v" -> Down
            "^" -> Up
            "<" -> Left
            ">" -> Right
            _ -> panic as { "Unknown direction: " <> char }
        }
    })
}

pub fn get_robot_position(map: WarehouseMap) -> Position {
    let assert Ok(#(robot_position, _)) = 
        map 
        |> dict.to_list 
        |> list.find(fn(x) {
            let #(_, cell) = x
            cell == Robot
        })

    robot_position
}

pub fn calculate_result(map: WarehouseMap) -> Int {
    map 
        |> dict.to_list 
        |> list.filter(fn(x) {
            let #(_, cell) = x
            cell == Box || cell == LeftBox
        })
        |> list.map(fn(x) {
            let #(pos, _) = x
            pos.0 + pos.1 * 100
        })
        |> list.fold(0, fn(acc, v) { acc + v })
}

pub fn print_warehouse(map: WarehouseMap) -> Nil {
    let min_x = 0
    let max_x = 
        map
        |> dict.keys
        |> list.map(fn(p) { p.0 })
        |> list.fold(0, fn(acc, x) { int.max(acc, x) })
    
    let min_y = 0
    let max_y = 
        map
        |> dict.keys
        |> list.map(fn(p) { p.1 })
        |> list.fold(0, fn(acc, y) { int.max(acc, y) })

    iterator.range(min_y, max_y)
        |> iterator.each(fn(y) {
            iterator.range(min_x, max_x)
            |> iterator.each(fn(x) {
                let cell = case map |> dict.get(#(x, y)) {
                    Ok(cell) -> cell
                    _ -> panic as { "Unknown cell" }
                }

                let char = case cell {
                    Wall -> "#"
                    Empty -> "."
                    Robot -> "@"
                    Box -> "O"
                    LeftBox -> "["
                    RightBox -> "]"
                }

                io.print(char)
            })

            io.println("")
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