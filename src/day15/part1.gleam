import day15/common
import gleam/dict
import gleam/iterator
import gleam/list
import gleam/order.{Gt, Lt}

pub fn main(input: String, use_sample: Bool) -> Nil {
  let #(map, sequences) = common.parse(input)

  let robot_position = common.get_robot_position(map)

  let #(map, _) =
    sequences
    |> list.fold(#(map, robot_position), fn(acc, move) {
      let #(map, robot_position) = acc

      case move {
        common.Up -> {
          let next_wall_or_empty_items =
            map
            |> dict.filter(fn(pos, cell) {
              { cell == common.Wall || cell == common.Empty }
              && pos.0 == robot_position.0
              && pos.1 < robot_position.1
            })

          let closest_item =
            next_wall_or_empty_items
            |> dict.to_list
            |> list.sort(fn(a, b) {
              case a.0.1 > b.0.1 {
                True -> Gt
                False -> Lt
              }
            })
            |> list.last()

          case closest_item {
            Ok(#(pos, common.Empty)) -> {
              let map =
                iterator.range(pos.1, robot_position.1 - 1)
                |> iterator.fold(map, fn(map, y) {
                  let current_y = y
                  let previous_y = y + 1

                  let assert Ok(previous_cell) =
                    map |> dict.get(#(pos.0, previous_y))

                  map |> dict.insert(#(pos.0, current_y), previous_cell)
                })

              let map = map |> dict.insert(robot_position, common.Empty)
              let new_robot_position = #(robot_position.0, robot_position.1 - 1)

              #(map, new_robot_position)
            }
            _ -> acc
          }
        }
        common.Left -> {
          let next_wall_or_empty_items =
            map
            |> dict.filter(fn(pos, cell) {
              { cell == common.Wall || cell == common.Empty }
              && pos.0 < robot_position.0
              && pos.1 == robot_position.1
            })

          let closest_item =
            next_wall_or_empty_items
            |> dict.to_list
            |> list.sort(fn(a, b) {
              case a.0.0 > b.0.0 {
                True -> Gt
                False -> Lt
              }
            })
            |> list.last()

          case closest_item {
            Ok(#(pos, common.Empty)) -> {
              let map =
                iterator.range(pos.0, robot_position.0 - 1)
                |> iterator.fold(map, fn(map, x) {
                  let current_x = x
                  let previous_x = x + 1

                  let assert Ok(previous_cell) =
                    map |> dict.get(#(previous_x, pos.1))

                  map |> dict.insert(#(current_x, pos.1), previous_cell)
                })

              let map = map |> dict.insert(robot_position, common.Empty)
              let new_robot_position = #(robot_position.0 - 1, robot_position.1)

              #(map, new_robot_position)
            }
            _ -> acc
          }
        }
        common.Down -> {
          let next_wall_or_empty_items =
            map
            |> dict.filter(fn(pos, cell) {
              { cell == common.Wall || cell == common.Empty }
              && pos.0 == robot_position.0
              && pos.1 > robot_position.1
            })

          let closest_item =
            next_wall_or_empty_items
            |> dict.to_list
            |> list.sort(fn(a, b) {
              case a.0.1 > b.0.1 {
                True -> Gt
                False -> Lt
              }
            })
            |> list.first()

          case closest_item {
            Ok(#(pos, common.Empty)) -> {
              let map =
                iterator.range(pos.1, robot_position.1 + 1)
                |> iterator.fold(map, fn(map, y) {
                  let current_y = y
                  let previous_y = y - 1

                  let assert Ok(previous_cell) =
                    map |> dict.get(#(pos.0, previous_y))

                  map |> dict.insert(#(pos.0, current_y), previous_cell)
                })

              let map = map |> dict.insert(robot_position, common.Empty)
              let new_robot_position = #(robot_position.0, robot_position.1 + 1)

              #(map, new_robot_position)
            }
            _ -> acc
          }
        }
        common.Right -> {
          let next_wall_or_empty_items =
            map
            |> dict.filter(fn(pos, cell) {
              { cell == common.Wall || cell == common.Empty }
              && pos.0 > robot_position.0
              && pos.1 == robot_position.1
            })

          let closest_item =
            next_wall_or_empty_items
            |> dict.to_list
            |> list.sort(fn(a, b) {
              case a.0.0 > b.0.0 {
                True -> Gt
                False -> Lt
              }
            })
            |> list.first()

          case closest_item {
            Ok(#(pos, common.Empty)) -> {
              let map =
                iterator.range(pos.0, robot_position.0 + 1)
                |> iterator.fold(map, fn(map, x) {
                  let current_x = x
                  let previous_x = x - 1

                  let assert Ok(previous_cell) =
                    map |> dict.get(#(previous_x, pos.1))

                  map |> dict.insert(#(current_x, pos.1), previous_cell)
                })

              let map = map |> dict.insert(robot_position, common.Empty)
              let new_robot_position = #(robot_position.0 + 1, robot_position.1)

              #(map, new_robot_position)
            }
            _ -> acc
          }
        }
      }
    })

  common.print_warehouse(map)

  let result = common.calculate_result(map)

  common.expect(use_sample, result, 10_092)
}
