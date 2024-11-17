import tempo/datetime
import tempo/duration
import gleam/io

pub fn main(day: Int, part: Int, use_sample: Bool) {
    let folder = "src/day" <> int.to_string(day) |> string.pad_start(2, "0")

    let assert Ok(input) = case use_sample {
        True -> simplifile.read(folder <> "/sample.txt")
        False -> simplifile.read(folder <> "/input.txt")
    }

    io.println("==== Day " <> int.to_string(day) <> " ====")
    io.println("==== Part " <> int.to_string(part) <> " ====")

    case use_sample {
        True -> io.println("/!\\ Sample data /!\\")
        False -> Nil
    }

    let before = datetime.now_utc()

    case part {
        1 -> run_part1(day, input)
        2 -> run_part2(day, input)
        _ -> panic as "Invalid part number"
    }

    let after = datetime.now_utc()

    let diff = datetime.difference(before, after)

    let total_seconds = diff |> duration.as_seconds
    let total_ms = diff |> duration.as_milliseconds
    
    case total_seconds {
        seconds if seconds > 3 -> io.println("Took " <> seconds |> int.to_string <> " seconds. Really slow...")
        seconds if seconds > 0 -> io.println("Took " <> seconds |> int.to_string <> "s. A bit slow, right?")
        _ -> io.println("Took " <> total_ms |> int.to_string <> "ms")
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