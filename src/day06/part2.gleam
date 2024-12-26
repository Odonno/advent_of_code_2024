import day06/common
import gleam/dict
import gleam/list

pub fn main(input: String, use_sample: Bool) -> Nil {
  let #(map, guard) = common.parse(input)

  let new_obstable_positions =
    map
    |> dict.to_list
    |> list.filter(fn(x) { x.1 == common.Empty })
    |> list.filter(fn(x) { x.0 != guard.0 })
    |> list.map(fn(x) { x.0 })

  let result =
    new_obstable_positions
    |> list.filter(fn(p) {
      let map_with_new_obstacle = map |> dict.insert(p, common.Obstruction)
      is_infinite_loop(map_with_new_obstacle, guard)
    })
    |> list.length

  common.expect(use_sample, result, 6)
}

fn is_infinite_loop(map: common.GuardMap, guard: common.Guard) -> Bool {
  is_infinite_loop_inner(map, guard, dict.new())
}

fn is_infinite_loop_inner(
  map: common.GuardMap,
  guard: common.Guard,
  visited: common.VisitedGuardMap,
) -> Bool {
  let already_visited = dict.get(visited, guard)
  let current_cell = dict.get(map, guard.0)

  case already_visited, current_cell {
    Ok(True), Ok(_) -> True
    _, Ok(_) -> {
      let visited = visited |> dict.insert(guard, True)

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

          is_infinite_loop_inner(map, #(guard.0, next_direction), visited)
        }
        _ ->
          is_infinite_loop_inner(
            map,
            #(next_forward_cell_position, guard.1),
            visited,
          )
      }
    }
    _, _ -> False
  }
}
