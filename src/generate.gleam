import gleam/int
import gleam/io
import gleam/list
import gleam/string_tree
import gleam/string
import simplifile

const template_folder = "./template"

pub fn main(folder: String) {
    // copy template folder to the new folder
    let assert Ok(_) = simplifile.copy(template_folder, folder)

    // replace "day00" by the folder name in part1/part2 files
    let folder_name = folder |> string.replace("src/", "")

    let part1_path = folder <> "/part1.gleam"
    let assert Ok(part1_content) = simplifile.read(part1_path)
    let part1_content = string.replace(part1_content, "day00", folder_name)
    let assert Ok(_) = simplifile.write(part1_path, part1_content)

    let part2_path = folder <> "/part2.gleam"
    let assert Ok(part2_content) = simplifile.read(part2_path)
    let part2_content = string.replace(part2_content, "day00", folder_name)
    let assert Ok(_) = simplifile.write(part2_path, part2_content)

    let assert Ok(_) = regenerate_run_function()

    io.println("The new puzzle day folder has been created.")
    io.println("Please re-run the program to execute your solution.")

    Ok(Nil)
}

fn regenerate_run_function() {
    let file_path = "./src/run.gleam"

    let assert Ok(puzzle_folders) = simplifile.read_directory("./src")
    let puzzle_folders = puzzle_folders |> list.filter(fn (f) { f |> string.starts_with("day") })

    io.debug(puzzle_folders)

    let tree = string_tree.new()

    let append_newline = fn (tree) {
        tree |> string_tree.append("\n")
    }

    let tree = tree |> string_tree.append("pub fn main(day: Int, part: Int, use_sample: Bool) {
    let folder = \"src/day\" <> int.to_string(day) |> string.pad_start(2, \"0\")

    let assert Ok(input) = case use_sample {
        True -> simplifile.read(folder <> \"/sample.txt\")
        False -> simplifile.read(folder <> \"/input.txt\")
    }

    io.println(\"==== Day \" <> int.to_string(day) <> \" ====\")
    io.println(\"==== Part \" <> int.to_string(part) <> \" ====\")

    case use_sample {
        True -> io.println(\"/!\\\\ Sample data /!\\\\\")
        False -> Nil
    }

    let before = datetime.now_utc()

    case part {
        1 -> run_part1(day, input, use_sample)
        2 -> run_part2(day, input, use_sample)
        _ -> panic as \"Invalid part number\"
    }

    let after = datetime.now_utc()

    display_execution_time(before, after)
}

fn display_execution_time(before, after) {
    let diff = datetime.difference(before, after)

    let total_seconds = diff |> duration.as_seconds
    let total_ms = diff |> duration.as_milliseconds
    
    case total_seconds {
        seconds if seconds > 3 -> io.println(\"Took \" <> seconds |> int.to_string <> \" seconds. Really slow...\")
        seconds if seconds > 0 -> io.println(\"Took \" <> seconds |> int.to_string <> \"s. A bit slow, right?\")
        _ -> io.println(\"Took \" <> total_ms |> int.to_string <> \"ms\")
    }
}")

    let tree = tree |> append_newline
    let tree = tree |> append_newline

    let tree = tree |> string_tree.append("fn run_part1(day: Int, input: String, use_sample: Bool) {
    case day {
")

    let tree = puzzle_folders |> list.fold(tree, fn (tree, folder) {
        let assert Ok(day) = folder |> string.slice(3, 5) |> int.parse
        let module_name = folder <> "_part1"

        tree 
            |> string_tree.append("        " <> day |> int.to_string <> " -> " <> module_name <> ".main(input, use_sample)")
            |> append_newline
    })

    let tree = tree |> string_tree.append("        _ -> panic as \"Invalid day number\"
    }
}")

    let tree = tree |> append_newline
    let tree = tree |> append_newline

    let tree = tree |> string_tree.append("fn run_part2(day: Int, input: String, use_sample: Bool) {
    case day {
")

    let tree = puzzle_folders |> list.fold(tree, fn (tree, folder) {
        let assert Ok(day) = folder |> string.slice(3, 5) |> int.parse
        let module_name = folder <> "_part2"

        tree 
            |> string_tree.append("        " <> day |> int.to_string <> " -> " <> module_name <> ".main(input, use_sample)")
            |> append_newline
    })
    
    let tree = tree |> string_tree.append("        _ -> panic as \"Invalid day number\"
    }
}")
    
    let tree = tree |> append_newline
    let tree = tree |> append_newline

    let tree = tree |> string_tree.append("import tempo/datetime
import tempo/duration
import gleam/io
import gleam/int
import gleam/string
import simplifile
")

    let tree = puzzle_folders |> list.fold(tree, fn (tree, folder) {
        let day = folder |> string.slice(3, 5)
        let part1_module = folder <> "/part1"
        let part2_module = folder <> "/part2"

        tree 
            |> string_tree.append("import " <> part1_module <> " as day" <> day <> "_part1")
            |> append_newline
            |> string_tree.append("import " <> part2_module <> " as day" <> day <> "_part2")
            |> append_newline
    })

    let assert Ok(_) = simplifile.write(file_path, tree |> string_tree.to_string)

    Ok(Nil)
}