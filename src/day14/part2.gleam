import gleam/set.{type Set}
import gleam/int
import gleam/io
import gleam/list
import gleam/iterator
import day14/common

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

    let total_robots = robots |> list.length

    iterator.range(0, 10_000)
        |> iterator.each(fn(s) {
            let positions = 
                robots
                |> list.map(fn(r) { common.move_robots(r, s, robots_space_x, robots_space_y) })
                |> set.from_list

            case total_robots == positions |> set.size {
                True -> {
                    io.println("Second: " <> s |> int.to_string)
                    io.println("************")
                    print_positions(robots_space_x, robots_space_y, positions)
                    io.println("************")
                }
                False -> Nil
            }
        })

    Nil
}

fn print_positions(max_x: Int, max_y: Int, positions: Set(common.Position)) -> Nil {
    iterator.range(0, max_y)
    |> iterator.each(fn(y) {
        iterator.range(0, max_x)
        |> iterator.each(fn(x) {
            let char = case positions |> set.contains(#(x, y)) {
                True -> "#"
                False -> "."
            }

            io.print(char)
        })

        io.println("")
    })
}