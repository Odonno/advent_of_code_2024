pub fn main(day: Int, part: Int, use_sample: Bool) {
    let folder = "src/day" <> int.to_string(day) |> string.pad_start(2, "0")

    let assert Ok(input) = case use_sample {
        True -> simplifile.read(folder <> "/sample.txt")
        False -> simplifile.read(folder <> "/input.txt")
    }

    case part {
        1 -> run_part1(day, input)
        2 -> run_part2(day, input)
        _ -> panic as "Invalid part number"
    }
}

fn run_part1(day: Int, input: String) {
    case day {
        1 -> day01_part1.main(input)
        _ -> panic as "Invalid day number"
    }
}

fn run_part2(day: Int, input: String) {
    case day {
        1 -> day01_part2.main(input)
        _ -> panic as "Invalid day number"
    }
}

import gleam/int
import gleam/string
import simplifile
import day01/part1 as day01_part1
import day01/part2 as day01_part2