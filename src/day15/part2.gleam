import day15/common
import gleam/dict
import gleam/int
import gleam/iterator
import gleam/list
import gleam/order.{Gt, Lt}
import gleam/set.{type Set}

pub fn main(input: String, use_sample: Bool) -> Nil {
  let #(map, sequences) = common.parse_2(input)

  let robot_position = common.get_robot_position(map)

  let #(map, _) =
    sequences
    |> list.fold(#(map, robot_position), fn(acc, move) {
      let #(map, robot_position) = acc

      case move {
        common.Up | common.Down -> {
          let next_cell_position = case move {
            common.Up -> #(robot_position.0, robot_position.1 - 1)
            common.Down -> #(robot_position.0, robot_position.1 + 1)
            _ -> panic as { "Not implemented" }
          }
          let assert Ok(next_cell) = map |> dict.get(next_cell_position)

          case next_cell {
            common.Wall -> acc
            common.Empty -> {
              let map = map |> dict.insert(next_cell_position, common.Robot)
              let map = map |> dict.insert(robot_position, common.Empty)
              let new_robot_position = next_cell_position

              #(map, new_robot_position)
            }
            common.LeftBox | common.RightBox -> {
              let #(can_push, box_positions) =
                get_pushable_boxes(
                  map,
                  get_two_boxes_positions(map, next_cell_position),
                  move,
                )

              case can_push {
                True -> {
                  let current_boxes =
                    box_positions
                    |> set.to_list
                    |> list.map(fn(p) {
                      let assert Ok(b) = map |> dict.get(p)
                      #(p, b)
                    })

                  // Remove cells of current boxes & current robot position
                  let map =
                    map
                    |> dict.delete(robot_position)

                  let map =
                    box_positions
                    |> set.to_list
                    |> list.fold(map, fn(map, p) { map |> dict.delete(p) })

                  // Set new robot position
                  let map = map |> dict.insert(next_cell_position, common.Robot)

                  // Set new boxes positions
                  let map =
                    current_boxes
                    |> list.fold(map, fn(map, x) {
                      let #(p, b) = x
                      let new_position = case move {
                        common.Up -> #(p.0, p.1 - 1)
                        common.Down -> #(p.0, p.1 + 1)
                        _ -> panic as { "Not implemented" }
                      }
                      map |> dict.insert(new_position, b)
                    })

                  // Fill empty cells
                  let map = fill_empty_cells(map)

                  let new_robot_position = next_cell_position
                  #(map, new_robot_position)
                }
                False -> acc
              }
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

  common.expect(use_sample, result, 9021)
}

fn get_two_boxes_positions(
  map: common.WarehouseMap,
  position: common.Position,
) -> List(common.Position) {
  let assert Ok(current_cell) = map |> dict.get(position)
  let second_box_position = case current_cell {
    common.LeftBox -> #(position.0 + 1, position.1)
    common.RightBox -> #(position.0 - 1, position.1)
    _ -> panic as { "Unexpected cell type" }
  }

  [position, second_box_position]
}

fn get_pushable_boxes(
  map: common.WarehouseMap,
  box_positions: List(common.Position),
  direction: common.Direction,
) -> #(Bool, Set(common.Position)) {
  case box_positions {
    [first, ..rest] -> {
      let next_cell_position = case direction {
        common.Up -> #(first.0, first.1 - 1)
        common.Down -> #(first.0, first.1 + 1)
        _ -> panic as { "Not implemented" }
      }

      let assert Ok(next_cell) = map |> dict.get(next_cell_position)

      let #(can_push, next_boxes) = case next_cell {
        common.Wall -> #(False, set.new())
        common.Empty -> #(True, set.new())
        common.LeftBox | common.RightBox -> {
          get_pushable_boxes(
            map,
            get_two_boxes_positions(map, next_cell_position),
            direction,
          )
        }
        _ -> panic as { "Not implemented" }
      }

      let #(rest_can_push, rest_positions) =
        get_pushable_boxes(map, rest, direction)

      case can_push, rest_can_push {
        True, True -> {
          let positions =
            set.new()
            |> set.insert(first)
            |> set.union(next_boxes)
            |> set.union(rest_positions)

          #(True, positions)
        }
        _, _ -> #(False, set.new())
      }
    }
    [] -> #(True, set.new())
  }
}

fn fill_empty_cells(map: common.WarehouseMap) -> common.WarehouseMap {
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
  |> iterator.fold(map, fn(map, y) {
    iterator.range(min_x, max_x)
    |> iterator.fold(map, fn(map, x) {
      let cell = map |> dict.get(#(x, y))

      case cell {
        Ok(_) -> map
        _ -> map |> dict.insert(#(x, y), common.Empty)
      }
    })
  })
}
