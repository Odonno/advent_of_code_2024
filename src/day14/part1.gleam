import day14/common
import gleam/list

pub fn main(input: String, use_sample: Bool) -> Nil {
  let robots = common.parse(input)

  let robots_space_x = case use_sample {
    True -> 11
    False -> 101
  }
  let robots_space_y = case use_sample {
    True -> 7
    False -> 103
  }

  let waiting_seconds = 100

  let positions_after_seconds =
    robots
    |> list.map(fn(r) {
      common.move_robots(r, waiting_seconds, robots_space_x, robots_space_y)
    })

  let middle_x = robots_space_x / 2
  let middle_y = robots_space_y / 2

  let top_left_quadrant = #(#(0, 0), #(middle_x - 1, middle_y - 1))
  let top_right_quadrant = #(#(middle_x + 1, 0), #(
    robots_space_x - 1,
    middle_y - 1,
  ))
  let bottom_left_quadrant = #(#(0, middle_y + 1), #(
    middle_x - 1,
    robots_space_y - 1,
  ))
  let bottom_right_quadrant = #(#(middle_x + 1, middle_y + 1), #(
    robots_space_x - 1,
    robots_space_y - 1,
  ))

  let quadrants = [
    top_left_quadrant,
    top_right_quadrant,
    bottom_left_quadrant,
    bottom_right_quadrant,
  ]

  let result =
    quadrants
    |> list.map(fn(q) {
      let #(top_left, bottom_right) = q

      positions_after_seconds
      |> list.filter(fn(p) {
        let #(x, y) = p
        top_left.0 <= x
        && x <= bottom_right.0
        && top_left.1 <= y
        && y <= bottom_right.1
      })
      |> list.length
    })
    |> list.fold(1, fn(acc, v) { acc * v })

  common.expect(use_sample, result, 12)
}
