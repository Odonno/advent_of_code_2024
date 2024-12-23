import gleam/list
import gleam/io
import gleam/string
import gleam/int
import gleam/dict.{type Dict}

pub const forward_cost = 1
pub const turn_cost = 1_001

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

pub fn get_neighbors(maze: ReeinderMaze, path: Path) -> List(#(Path, Int)) {
    let forward_direction_with_score = #(path.direction, forward_cost)

    let turn_directions = case path.direction {
        North | South -> [West, East]
        West | East -> [North, South]
    }
    let turn_directions_with_score = turn_directions
        |> list.map(fn(x) { #(x, turn_cost) })

    let directions_with_score = [forward_direction_with_score, ..turn_directions_with_score]

    directions_with_score
        |> list.flat_map(fn(x) {
            let #(direction, score) = x

            let next_cell_position = case direction {
                North -> #(path.position.0, path.position.1 - 1)
                South -> #(path.position.0, path.position.1 + 1)
                West -> #(path.position.0 - 1, path.position.1)
                East -> #(path.position.0 + 1, path.position.1)
            }

            let assert Ok(next_cell) = maze |> dict.get(next_cell_position)
            
            case next_cell {
                Empty -> {
                    let next_path = #(Path(    
                        position: next_cell_position, 
                        direction: direction,
                    ), score)
                    [next_path]
                }
                Wall -> []
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