import gleam/int
import gleam/iterator
import gleam/list
import gleam/dict.{type Dict}
import day20/common

pub type DistanceMap = Dict(common.Position, Int)

pub fn main(input: String, use_sample: Bool) -> Nil {
    let #(map, start_position, _) = common.parse(input)

    let distance_map = create_distance_map(map, start_position)

    let assert Ok(max_distance) = distance_map |> dict.values |> list.sort(int.compare) |> list.last
    
    let max_cheat_duration = 20

    let min_diff = case use_sample {
        True -> 50
        False -> 100
    }

    let possible_cheats = 
        iterator.range(0, max_distance - min_diff)
        |> iterator.flat_map(fn(start) {
            let start_positions = 
                distance_map
                |> dict.filter(fn(_, value) {
                    value == start
                })
                |> dict.keys

            let possible_end_positions =
                distance_map
                |> dict.filter(fn(_, value) {
                    value > { start + min_diff }
                })
                |> dict.keys

            start_positions
                |> list.flat_map(fn(s) {
                    possible_end_positions
                    |> list.map(fn(e) { #(s, e) })
                })
                |> iterator.from_list
        })

    let valid_cheats = 
        possible_cheats
        |> iterator.filter_map(fn(c) {
            let #(s, e) = c
            let cheat_duration = common.calculate_distance(s, e)

            case cheat_duration <= max_cheat_duration {
                True -> Ok(#(c, cheat_duration))
                False -> Error(Nil)
            }
        })
        |> iterator.filter(fn(c) {
            let #(c, duration) = c

            let assert Ok(a) = distance_map |> dict.get(c.0)
            let assert Ok(b) = distance_map |> dict.get(c.1)

            let v = b - a - duration

            v >= min_diff
        })

    let result = valid_cheats |> iterator.length

    common.expect(use_sample, result, 285)
}

fn create_distance_map(map: common.Map, start_position: common.Position) -> DistanceMap {
    create_distance_map_inner([#(start_position, 0)] |> dict.from_list, map, start_position, 0)
}

fn create_distance_map_inner(current_map: DistanceMap, map: common.Map, position: common.Position, acc_distance: Int) -> DistanceMap {
    let valid_positions = 
        get_neighbors(position)
        |> list.filter(fn(p) {
            let cell = map |> dict.get(p)
            cell == Ok(common.Track)
        })

    let new_distance = acc_distance + 1

    valid_positions
    |> list.fold(current_map, fn(current_map, p) {
        let current_distance = current_map |> dict.get(p)

        case current_distance {
            Ok(d) if d <= new_distance -> current_map
            _ -> {
                create_distance_map_inner(
                    current_map |> dict.insert(p, new_distance),
                    map,
                    p,
                    new_distance
                )
            }
        }
    })
}

fn get_neighbors(position: common.Position) -> List(common.Position) {
    let #(x, y) = position

    let left = #(x - 1, y)
    let right = #(x + 1, y)
    let top = #(x, y - 1)
    let down = #(x, y + 1)

    [left, right, top, down]
}