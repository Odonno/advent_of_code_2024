import gleam/list
import gleam/io
import gleam/string
import gleam/int
import gleam/dict.{type Dict}

pub type Position = #(Int, Int)
pub type Direction {
    North
    East
    South
    West
}

pub type MazeCell {
    Empty
    Wall
}

pub type ReeinderMaze = Dict(Position, MazeCell)

pub type ParentMap = Dict(Path, Path)
pub type ScoreMap = Dict(Path, Int)

pub type Path {
    Path(position: Position, direction: Direction)
}

pub fn parse(input: String) -> #(ReeinderMaze, Position, Position) {
    input
        |> string.split("\r\n")
        |> list.index_fold(#(dict.new(), #(0, 0), #(0, 0)), fn(acc, line, y) {
            line
                |> string.split("")
                |> list.index_fold(acc, fn(acc, char, x) {
                    let #(maze, start_position, end_position) = acc

                    let cell = case char {
                        "#" -> Wall
                        _ -> Empty
                    }

                    let start_position = case char {
                        "S" -> #(x, y)
                        _ -> start_position
                    }

                    let end_position = case char {
                        "E" -> #(x, y)
                        _ -> end_position
                    }

                    let maze = maze |> dict.insert(#(x, y), cell)

                    #(maze, start_position, end_position)
                })
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