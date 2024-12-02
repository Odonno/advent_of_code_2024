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
        1 -> run_part1(day, input, use_sample)
        2 -> run_part2(day, input, use_sample)
        _ -> panic as "Invalid part number"
    }

    let after = datetime.now_utc()

    display_execution_time(before, after)
}

fn display_execution_time(before, after) {
    let diff = datetime.difference(before, after)

    let total_seconds = diff |> duration.as_seconds
    let total_ms = diff |> duration.as_milliseconds
    
    case total_seconds {
        seconds if seconds > 3 -> io.println("Took " <> seconds |> int.to_string <> " seconds. Really slow...")
        seconds if seconds > 0 -> io.println("Took " <> seconds |> int.to_string <> "s. A bit slow, right?")
        _ -> io.println("Took " <> total_ms |> int.to_string <> "ms")
    }
}

fn run_part1(day: Int, input: String, use_sample: Bool) {
    case day {
        1 -> day01_part1.main(input, use_sample)
        2 -> day02_part1.main(input, use_sample)
        _ -> panic as "Invalid day number"
    }
}

fn run_part2(day: Int, input: String, use_sample: Bool) {
    case day {
        1 -> day01_part2.main(input, use_sample)
        2 -> day02_part2.main(input, use_sample)
        _ -> panic as "Invalid day number"
    }
}

import tempo/datetime
import tempo/duration
import gleam/io
import gleam/int
import gleam/string
import simplifile
import day01/part1 as day01_part1
import day01/part2 as day01_part2
import day02/part1 as day02_part1
import day02/part2 as day02_part2
