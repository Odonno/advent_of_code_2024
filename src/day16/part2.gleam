import gleam/result
import gleam/set
import gleam/list
import gleam/dict.{type Dict}
import day16/common

pub type DistanceMap = Dict(common.Path, Int)
pub type NextNeighbors = Dict(common.Path, List(common.Path))

pub fn main(input: String, use_sample: Bool) -> Nil {
    let #(maze, start_position, end_position) = common.parse(input)

    let best_path_score = case use_sample {
        True -> 7036
        False -> 85480
    }

    let initial_direction = common.East
    let initial_path = common.Path(position: start_position, direction: initial_direction)

    let distance_map = create_distance_map(maze, initial_path, best_path_score)
    let next_neihbors = create_next_neihbors_map(distance_map)

    let all_valid_paths = get_valid_paths(next_neihbors, initial_path, end_position)

    let result = 
        all_valid_paths
        |> list.flat_map(fn(p) {
            p |> list.map(fn(p) { p.position })
        })
        |> set.from_list
        |> set.size

    common.expect(use_sample, result, 45)
}

fn create_distance_map(map: common.ReeinderMaze, start_path: common.Path, max_score: Int) -> DistanceMap {
    create_distance_map_inner([#(start_path, 0)] |> dict.from_list, map, start_path, max_score, 0)
}

fn create_distance_map_inner(
    current_map: DistanceMap, 
    map: common.ReeinderMaze, 
    path: common.Path,
    max_score: Int,
    acc_distance: Int
) -> DistanceMap {
    let valid_paths = common.get_neighbors(map, path)

    valid_paths
    |> list.fold(current_map, fn(current_map, p) {
        let #(next_path, score) = p 

        let new_distance = acc_distance + score

        let current_distance = current_map |> dict.get(next_path)

        case current_distance {
            Ok(d) if d <= new_distance || new_distance > max_score -> current_map
            _ -> {
                create_distance_map_inner(
                    current_map |> dict.insert(next_path, new_distance),
                    map,
                    next_path,
                    max_score,
                    new_distance
                )
            }
        }
    })
}

fn create_next_neihbors_map(distance_map: DistanceMap) -> NextNeighbors {
    distance_map
    |> dict.map_values(fn(path, score) {
        distance_map
            |> dict.filter(fn(_, value) {
                value == score + common.forward_cost || value == score + common.turn_cost
            })
            |> dict.filter(fn(key, _) {
                is_neighbor(key.position, path.position)
            })
            |> dict.keys
    })
}

fn is_neighbor(position: common.Position, other_position: common.Position) -> Bool {
    let a = position.0 == other_position.0 && { position.1 == other_position.1 - 1 || position.1 == other_position.1 + 1 }
    let b = position.1 == other_position.1 && { position.0 == other_position.0 - 1 || position.0 == other_position.0 + 1 }

    a || b
}

fn get_valid_paths(
    next_neihbors: NextNeighbors,
    current_path: common.Path, 
    target: common.Position
) -> List(List(common.Path)) {
    get_valid_paths_inner(next_neihbors, current_path, target, [current_path])
}

fn get_valid_paths_inner(
    next_neihbors: NextNeighbors,
    current_path: common.Path, 
    target: common.Position,
    acc: List(common.Path)
) -> List(List(common.Path)) {
    let current_position = current_path.position

    case target == current_position {
        True -> [acc]
        _ -> {
            next_neihbors
                |> dict.get(current_path)
                |> result.unwrap([])
                |> list.flat_map(fn(next_path) {
                    get_valid_paths_inner(
                        next_neihbors,
                        next_path,
                        target,
                        [next_path, ..acc]
                    )
                })
        }
    }
}