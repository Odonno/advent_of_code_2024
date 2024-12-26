import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub type Report =
  List(Int)

pub type SafeReportValue {
  Asc
  Desc
}

pub fn parse(input: String) -> List(Report) {
  input |> string.split("\n") |> list.map(parse_line)
}

fn parse_line(line: String) -> Report {
  line
  |> string.trim
  |> string.split(" ")
  |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
}

pub fn is_safe_report(report: Report) -> Bool {
  let inner_list =
    report
    |> list.window_by_2
    |> list.map(fn(r) {
      let diff = r.1 - r.0

      case diff {
        d if 1 <= d && d <= 3 -> Ok(Asc)
        d if -3 <= d && d <= -1 -> Ok(Desc)
        _ -> Error(Nil)
      }
    })

  let is_all_asc = inner_list |> list.all(fn(y) { y == Ok(Asc) })
  let is_all_desc = inner_list |> list.all(fn(y) { y == Ok(Desc) })

  is_all_asc || is_all_desc
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
          panic as {
            "Expected: "
            <> sample_expected |> int.to_string
            <> ", got "
            <> result |> int.to_string
          }
      }
    }
    False -> {
      io.debug("Result: " <> result |> int.to_string)
      Nil
    }
  }
}
