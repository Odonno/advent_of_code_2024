import day20/common
import gleam/dict
import gleam/int
import gleam/iterator.{type Iterator}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/result

pub type Cheat =
  common.Position

pub fn main(input: String, use_sample: Bool) -> Nil {
  let #(map, start_position, end_position) = common.parse(input)

  let current_course_time =
    find_shortest_time(
      map,
      end_position,
      dict.new() |> dict.insert(start_position, 0),
      dict.new()
        |> dict.insert(
          start_position,
          common.calculate_distance(start_position, end_position),
        ),
      dict.new(),
      [start_position],
      None,
    )

  let assert Ok(max_x) =
    map
    |> dict.keys
    |> list.map(fn(x) { x.0 })
    |> list.sort(int.compare)
    |> list.last
  let assert Ok(max_y) =
    map
    |> dict.keys
    |> list.map(fn(x) { x.1 })
    |> list.sort(int.compare)
    |> list.last

  let possible_cheats: Iterator(Cheat) =
    iterator.range(1, max_y - 1)
    |> iterator.flat_map(fn(y) {
      iterator.range(1, max_x - 1)
      |> iterator.flat_map(fn(x) {
        let p = #(x, y)

        case map |> dict.get(p) {
          Ok(common.Wall) -> iterator.single(p)
          _ -> iterator.empty()
        }
      })
    })

  let saved_times =
    possible_cheats
    |> iterator.map(fn(cheat) {
      let cheat_course_time =
        find_shortest_time(
          map,
          end_position,
          dict.new() |> dict.insert(start_position, 0),
          dict.new()
            |> dict.insert(
              start_position,
              common.calculate_distance(start_position, end_position),
            ),
          dict.new(),
          [start_position],
          Some(cheat),
        )

      current_course_time - cheat_course_time
    })

  let limit = case use_sample {
    True -> 1
    False -> 100
  }

  let result =
    saved_times
    |> iterator.filter(fn(x) { x >= limit })
    |> iterator.length

  common.expect(use_sample, result, 44)
}

fn find_shortest_time(
  map: common.Map,
  target: common.Position,
  g_scores: common.ScoreMap,
  f_scores: common.ScoreMap,
  parents: common.ParentMap,
  visitable_positions: List(common.Position),
  cheat_opt: Option(Cheat),
) -> Int {
  let ordered_positions =
    visitable_positions
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
          calculate_shortest_time(parents, current_position, cheat_opt)
        }
        False -> {
          let neighbors = get_neighbors(map, current_position, cheat_opt)

          let #(g_scores, f_scores, parents, next_positions) =
            neighbors
            |> list.fold(#(g_scores, f_scores, parents, []), fn(acc, neighbor) {
              let #(g_scores, f_scores, parents, next_positions) = acc

              let score = case cheat_opt {
                Some(cheat) if cheat == neighbor -> -1
                _ -> 1
              }

              let assert Ok(current_g_score) =
                g_scores |> dict.get(current_position)
              let tentative_g_score = current_g_score + score

              let neighbor_g_score =
                g_scores
                |> dict.get(neighbor)
                |> result.unwrap(1_000_000_000)

              case tentative_g_score < neighbor_g_score {
                True -> {
                  let parents =
                    parents |> dict.insert(neighbor, current_position)

                  let g_scores =
                    g_scores |> dict.insert(neighbor, tentative_g_score)

                  let h_score = common.calculate_distance(neighbor, target)
                  let f_score = tentative_g_score + h_score
                  let f_scores = f_scores |> dict.insert(neighbor, f_score)

                  #(g_scores, f_scores, parents, [neighbor, ..next_positions])
                }
                False -> #(g_scores, f_scores, parents, next_positions)
              }
            })

          find_shortest_time(
            map,
            target,
            g_scores,
            f_scores,
            parents,
            remaining_positions |> list.append(next_positions),
            cheat_opt,
          )
        }
      }
    }
    _ -> panic as "Unexpected"
  }
}

fn calculate_shortest_time(
  parents: common.ParentMap,
  current: common.Position,
  cheat_opt: Option(Cheat),
) -> Int {
  case parents |> dict.get(current) {
    Ok(next) -> 1 + calculate_shortest_time(parents, next, cheat_opt)
    _ -> 0
  }
}

fn get_neighbors(
  map: common.Map,
  position: common.Position,
  cheat_opt: Option(Cheat),
) -> List(common.Position) {
  let left_position = #(position.0 - 1, position.1)
  let right_position = #(position.0 + 1, position.1)
  let up_position = #(position.0, position.1 - 1)
  let down_position = #(position.0, position.1 + 1)

  let positions = [left_position, right_position, up_position, down_position]

  positions
  |> list.filter(fn(p) {
    let cell = map |> dict.get(p)

    case cell {
      Ok(common.Track) -> True
      Ok(common.Wall) -> {
        case cheat_opt {
          Some(cheat) -> cheat == p
          _ -> False
        }
      }
      _ -> False
    }
  })
}
