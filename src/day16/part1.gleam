import gleam/result
import gleam/int
import gleam/dict
import gleam/order
import gleam/list
import day16/common

pub fn main(input: String, use_sample: Bool) -> Nil {
    let #(maze, start_position, end_position) = common.parse(input)

    let initial_direction = common.East

    let initial_path = common.Path(position: start_position, direction: initial_direction)
    let shortest_path = find_shortest_path(
        maze, 
        end_position, 
        dict.new() |> dict.insert(initial_path, 0),
        dict.new() |> dict.insert(initial_path, calculate_path_distance(initial_path, end_position)),
        dict.new(),
        [initial_path]
    ) 

    let result = shortest_path
        |> list.window_by_2
        |> list.map(fn(x) {
            let #(a, b) = x
            
            case a.direction != b.direction {
                True -> 1_001
                False -> 1
            }
        })
        |> list.fold(0, fn(acc, v) { acc + v })

    common.expect(use_sample, result, 7036)
}

fn reconstruct_path(parents: common.ParentMap, current: common.Path) -> List(common.Path) {
    case parents |> dict.get(current) {
        Ok(next) -> [current, ..reconstruct_path(parents, next)]
        _ -> [current]
    }
}

fn find_shortest_path(
    maze: common.ReeinderMaze, 
    target: common.Position,
    g_scores: common.ScoreMap,
    f_scores: common.ScoreMap,
    parents: common.ParentMap,
    visitable_paths: List(common.Path)
) -> List(common.Path) {
    let assert Ok(current_path) = visitable_paths
        |> list.sort(fn(a, b) {
            let assert Ok(a_score) = f_scores |> dict.get(a)
            let assert Ok(b_score) = f_scores |> dict.get(b)
            
            case a_score < b_score {
                True -> order.Lt
                False -> order.Gt
            }
        })
        |> list.first

    case current_path.position == target {
        True -> {
            reconstruct_path(parents, current_path)
        }
        False -> {
            let neighbors_with_score = get_neighbors(maze, current_path)

            let #(g_scores, f_scores, parents, next_paths) = neighbors_with_score
                |> list.fold(#(g_scores, f_scores, parents, []), fn(acc, neighbor_with_score) {
                    let #(g_scores, f_scores, parents, next_paths) = acc
                    let #(neighbor, score) = neighbor_with_score

                    let assert Ok(current_g_score) = g_scores |> dict.get(current_path)
                    let tentative_g_score = current_g_score + score

                    let neighbor_g_score = g_scores
                        |> dict.get(neighbor)
                        |> result.unwrap(1_000_000_000)

                    case tentative_g_score < neighbor_g_score {
                        True -> {
                            let parents = parents |> dict.insert(neighbor, current_path)

                            let g_scores = g_scores |> dict.insert(neighbor, tentative_g_score)
                                        
                            let h_score = calculate_path_distance(neighbor, target)
                            let f_score = tentative_g_score + h_score
                            let f_scores = f_scores |> dict.insert(neighbor, f_score)

                            #(g_scores, f_scores, parents, [neighbor, ..next_paths])
                        }
                        False -> #(g_scores, f_scores, parents, next_paths)
                    }
                })

            find_shortest_path(
                maze, 
                target, 
                g_scores, 
                f_scores, 
                parents,
                visitable_paths |> list.filter(fn(x) { x != current_path }) |> list.append(next_paths)
            )
        }
    }
}

fn calculate_path_distance(path: common.Path, target: common.Position) -> Int {
    let #(x1, y1) = path.position
    let #(x2, y2) = target

    let distance_to_turn_back = 2

    let additional_distance = case path.direction {
        common.North if y2 > y1 -> distance_to_turn_back
        common.South if y2 < y1 -> distance_to_turn_back
        common.West if x2 > x1 -> distance_to_turn_back
        common.East if x2 < x1 -> distance_to_turn_back
        _ -> 0
    }

    calculate_distance(path.position, target) + additional_distance
}

fn calculate_distance(origin: common.Position, target: common.Position) -> Int {
    let #(x1, y1) = origin
    let #(x2, y2) = target

    let x_distance = int.absolute_value(x1 - x2)
    let y_distance = int.absolute_value(y1 - y2)

    x_distance + y_distance
}

fn get_neighbors(maze: common.ReeinderMaze, path: common.Path) -> List(#(common.Path, Int)) {
    let forward_direction_with_score = #(path.direction, 1)

    let turn_directions = case path.direction {
        common.North | common.South -> [common.West, common.East]
        common.West | common.East -> [common.North, common.South]
    }
    let turn_directions_with_score = turn_directions
        |> list.map(fn(x) { #(x, 1_001) })

    let directions_with_score = [forward_direction_with_score, ..turn_directions_with_score]

    directions_with_score
        |> list.flat_map(fn(x) {
            let #(direction, score) = x

            let next_cell_position = case direction {
                common.North -> #(path.position.0, path.position.1 - 1)
                common.South -> #(path.position.0, path.position.1 + 1)
                common.West -> #(path.position.0 - 1, path.position.1)
                common.East -> #(path.position.0 + 1, path.position.1)
            }

            let assert Ok(next_cell) = maze |> dict.get(next_cell_position)
            
            case next_cell {
                common.Empty -> {
                    let next_path = #(common.Path(    
                        position: next_cell_position, 
                        direction: direction,
                    ), score)
                    [next_path]
                }
                common.Wall -> []
            }
        })
}