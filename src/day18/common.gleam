import gleam/result
import gleam/order
import gleam/iterator
import gleam/list
import gleam/io
import gleam/string
import gleam/int
import gleam/dict.{type Dict}
import gleam/option.{type Option, Some, None}

pub type Position = #(Int, Int)

pub type MemoryCell {
    Safe
    Corrupted
}

pub type MemorySpace = Dict(Position, MemoryCell)

pub type Path = List(Position)

pub type ParentMap = Dict(Position, Position)
pub type ScoreMap = Dict(Position, Int)

pub fn parse(input: String) -> List(Position) {
    input
        |> string.split("\r\n")
        |> list.map(parse_line)
}

fn parse_line(line: String) -> Position {
    let assert [x, y] = line |> string.split(",")

    let assert Ok(x) = x |> int.parse
    let assert Ok(y) = y |> int.parse

    #(x, y)
}

pub fn create_memory_space(positions: List(Position), max_x: Int, max_y: Int) -> MemorySpace {
    let map = positions
        |> list.fold(dict.new(), fn(acc, p) {
            acc |> dict.insert(p, Corrupted)
        })

    let map = 
        iterator.range(0, max_y)
        |> iterator.fold(map, fn(acc, y) {
            iterator.range(0, max_x)
            |> iterator.fold(acc, fn(acc, x) {
                let p = #(x, y)

                case acc |> dict.get(p) {
                    Ok(_) -> acc
                    _ -> acc |> dict.insert(p, Safe)
                }
            })
        })

    map
}

pub fn find_shortest_path(
    map: MemorySpace, 
    target: Position,
    g_scores: ScoreMap,
    f_scores: ScoreMap,
    parents: ParentMap,
    visitable_positions: List(Position)
) -> Option(Path) {
    let ordered_positions = visitable_positions
        |> list.sort(fn(a, b) {
            let assert Ok(a_score) = f_scores |> dict.get(a)
            let assert Ok(b_score) = f_scores |> dict.get(b)
            
            case a_score < b_score {
                True -> order.Lt
                False -> order.Gt
            }
        })

    case ordered_positions {
        [current_position, ..remaining_positions] -> {
            case current_position == target {
                True -> {
                    Some(reconstruct_path(parents, current_position))
                }
                False -> {
                    let neighbors = get_neighbors(map, current_position)

                    let #(g_scores, f_scores, parents, next_positions) = neighbors
                        |> list.fold(#(g_scores, f_scores, parents, []), fn(acc, neighbor) {
                            let #(g_scores, f_scores, parents, next_positions) = acc

                            let score = 1

                            let assert Ok(current_g_score) = g_scores |> dict.get(current_position)
                            let tentative_g_score = current_g_score + score

                            let neighbor_g_score = g_scores
                                |> dict.get(neighbor)
                                |> result.unwrap(1_000_000_000)

                            case tentative_g_score < neighbor_g_score {
                                True -> {
                                    let parents = parents |> dict.insert(neighbor, current_position)

                                    let g_scores = g_scores |> dict.insert(neighbor, tentative_g_score)
                                                
                                    let h_score = calculate_distance(neighbor, target)
                                    let f_score = tentative_g_score + h_score
                                    let f_scores = f_scores |> dict.insert(neighbor, f_score)

                                    #(g_scores, f_scores, parents, [neighbor, ..next_positions])
                                }
                                False -> #(g_scores, f_scores, parents, next_positions)
                            }
                        })

                    find_shortest_path(
                        map, 
                        target, 
                        g_scores, 
                        f_scores, 
                        parents,
                        remaining_positions |> list.append(next_positions)
                    )
                }
            }
        }
        _ -> None
    }
}

fn reconstruct_path(parents: ParentMap, current: Position) -> Path {
    case parents |> dict.get(current) {
        Ok(next) -> [current, ..reconstruct_path(parents, next)]
        _ -> [current]
    }
}

pub fn calculate_distance(origin: Position, target: Position) -> Int {
    let #(x1, y1) = origin
    let #(x2, y2) = target

    let x_distance = int.absolute_value(x1 - x2)
    let y_distance = int.absolute_value(y1 - y2)

    x_distance + y_distance
}

fn get_neighbors(map: MemorySpace, position: Position) -> List(Position) {
    let left_position = #(position.0 - 1, position.1)
    let right_position = #(position.0 + 1, position.1)
    let up_position = #(position.0, position.1 - 1)
    let down_position = #(position.0, position.1 + 1)

    let positions = [left_position, right_position, up_position, down_position]

    positions
        |> list.filter(fn(p) {
            let cell = map |> dict.get(p)
            cell == Ok(Safe)
        })
}

pub fn expect(use_sample: Bool, result: Int, sample_expected: Int) -> Nil {
    expect_str(use_sample, result |> int.to_string, sample_expected |> int.to_string)
}

pub fn expect_str(use_sample: Bool, result: String, sample_expected: String) -> Nil {
    case use_sample {
        True -> {
            case result == sample_expected {
                True -> {
                    io.debug("Sample OK")
                    Nil
                }
                False -> 
                    panic as { "Expected: " <> sample_expected <> ", got " <> result }
            }
        }
        False -> {
            io.debug("Result: " <> result)
            Nil
        }
    }
}