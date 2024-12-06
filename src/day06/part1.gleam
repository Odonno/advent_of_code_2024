import gleam/list
import gleam/dict
import day06/common

pub fn main(input: String, use_sample: Bool) -> Nil {
    let #(map, guard) = common.parse(input)

    let visited_map = 
        map 
        |> dict.to_list 
        |> list.map(fn(x) { #(x.0, False) }) 
        |> dict.from_list

    let #(visited_map, _) = visit_map(map, guard, visited_map)

    let result = visited_map 
        |> dict.to_list 
        |> list.filter(fn(x) { x.1 == True }) 
        |> list.length

    common.expect(use_sample, result, 41)
}

fn visit_map(map: common.GuardMap, guard: common.Guard, visited_map: common.VisitedGuardPositionMap) 
    -> #(common.VisitedGuardPositionMap, common.Guard) {
    let current_cell = dict.get(map, guard.0)

    case current_cell {
        Ok(_) -> {
            let visited_map = dict.insert(visited_map, guard.0, True)

            let next_forward_cell_position = case guard.1 {
                common.North -> #(guard.0.0, guard.0.1 - 1)
                common.South -> #(guard.0.0, guard.0.1 + 1)
                common.West -> #(guard.0.0 - 1, guard.0.1)
                common.East -> #(guard.0.0 + 1, guard.0.1)
            }

            let next_forward_cell = dict.get(map, next_forward_cell_position)

            case next_forward_cell {
                Ok(common.Obstruction) -> {
                    let next_direction = case guard.1 {
                        common.North -> common.East
                        common.East -> common.South
                        common.South -> common.West
                        common.West -> common.North
                    }
                    
                    visit_map(map, #(guard.0, next_direction), visited_map)
                }
                _ -> visit_map(map, #(next_forward_cell_position, guard.1), visited_map)
            }
        }
        _ -> #(visited_map, guard)
    }
}