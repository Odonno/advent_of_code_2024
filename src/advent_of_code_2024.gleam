import dot_env
import dot_env/env
import generate
import gleam/int
import gleam/string
import run
import simplifile

pub fn main() {
  dot_env.new()
  |> dot_env.set_path("./.env")
  |> dot_env.set_debug(False)
  |> dot_env.load

  let assert Ok(day) = env.get_int("DAY")
  let assert Ok(part) = env.get_int("PART")
  let use_sample = env.get_bool_or("USE_SAMPLE", True)

  let folder = "src/day" <> int.to_string(day) |> string.pad_start(2, "0")

  let assert Ok(exists) = simplifile.is_directory(folder)

  let assert Ok(_) = case exists {
    True -> {
      run.main(day, part, use_sample)
      Ok(Nil)
    }
    False -> generate.main(folder)
  }
}
