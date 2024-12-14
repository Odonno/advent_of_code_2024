import gleam/option
import gleam/regex
import gleam/list
import gleam/io
import gleam/string
import gleam/int

pub type Position = #(Int, Int)
pub type Velocity = #(Int, Int)

pub type Robot {
    Robot(position: Position, velocity: Velocity)
} 

pub type Robots = List(Robot)

pub type Quadrant = #(Position, Position)

pub fn parse(input: String) -> Robots {
    input
        |> string.split("\r\n")
        |> list.map(parse_line)
}

fn parse_line(line: String) -> Robot {
    let assert Ok(re) = regex.from_string("p=(-?\\d+),(-?\\d+) v=(-?\\d+),(-?\\d+)")
    let assert [match] = re |> regex.scan(line)

    let assert [px, py, vx, vy] = match.submatches

    let assert Ok(px) = px |> option.unwrap("0") |> int.parse
    let assert Ok(py) = py |> option.unwrap("0") |> int.parse
    let assert Ok(vx) = vx |> option.unwrap("0") |> int.parse
    let assert Ok(vy) = vy |> option.unwrap("0") |> int.parse

    Robot(
        position: #(px, py),
        velocity: #(vx, vy)
    )
}

pub fn move_robots(robot: Robot, seconds: Int, robots_space_x: Int, robots_space_y: Int) -> Position {
    let x = { robot.position.0 + robot.velocity.0 * seconds} % robots_space_x
    let x = case x < 0 { 
        True -> x + robots_space_x
        False -> x 
    }

    let y = { robot.position.1 + robot.velocity.1 * seconds } % robots_space_y
    let y = case y < 0 { 
        True -> y + robots_space_y
        False -> y
    }
    
    #(x, y)
}

pub fn expect(use_sample: Bool, result: Int, sample_expected: Int) -> Nil {
    case use_sample {
        True -> {
            case result == sample_expected {
                True -> {
                    io.debug("Sample OK")
                    Nil
                }
                False -> 
                    panic as { "Expected: " <> sample_expected |> int.to_string <> ", got " <> result |> int.to_string }
            }
        }
        False -> {
            io.debug("Result: " <> result |> int.to_string)
            Nil
        }
    }
}