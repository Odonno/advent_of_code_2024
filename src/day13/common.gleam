import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regex
import gleam/string

pub type MachineConfiguration {
  MachineConfiguration(x: Int, y: Int)
}

pub type Machine {
  Machine(
    a: MachineConfiguration,
    b: MachineConfiguration,
    prize: MachineConfiguration,
  )
}

pub type Machines =
  List(Machine)

pub type ButtonPress {
  ButtonPress(a: Int, b: Int)
}

pub fn parse(input: String) -> Machines {
  input
  |> string.split("\r\n\r\n")
  |> list.map(fn(str) {
    let assert [a_str, b_str, prize_str] = str |> string.split("\r\n")

    Machine(
      a: parse_button_configuration(a_str),
      b: parse_button_configuration(b_str),
      prize: parse_prize_configuration(prize_str),
    )
  })
}

fn parse_button_configuration(str: String) -> MachineConfiguration {
  let assert Ok(re) = regex.from_string("X\\+(\\d+), Y\\+(\\d+)")
  let assert [match] = re |> regex.scan(str)

  let assert [x_str, y_str] = match.submatches

  let assert Ok(x) = x_str |> option.unwrap("0") |> int.parse
  let assert Ok(y) = y_str |> option.unwrap("0") |> int.parse

  MachineConfiguration(x: x, y: y)
}

fn parse_prize_configuration(str: String) -> MachineConfiguration {
  let assert Ok(re) = regex.from_string("X\\=(\\d+), Y\\=(\\d+)")
  let assert [match] = re |> regex.scan(str)

  let assert [x_str, y_str] = match.submatches

  let assert Ok(x) = x_str |> option.unwrap("0") |> int.parse
  let assert Ok(y) = y_str |> option.unwrap("0") |> int.parse

  MachineConfiguration(x: x, y: y)
}

pub fn calculate_button_press(machine: Machine) -> Option(ButtonPress) {
  let x_1 = machine.a.x
  let y_1 = machine.a.y

  let x_2 = machine.b.x
  let y_2 = machine.b.y

  let prize_x = machine.prize.x
  let prize_y = machine.prize.y

  let total_b = y_1 * x_2 - y_2 * x_1 |> int.absolute_value
  let sum_for_b = prize_x * y_1 - prize_y * x_1 |> int.absolute_value

  let b_presses = sum_for_b / total_b
  let b_rest = sum_for_b % total_b

  let total_a = x_1 * y_2 - x_2 * y_1 |> int.absolute_value
  let sum_for_a = prize_x * y_2 - prize_y * x_2 |> int.absolute_value

  let a_presses = sum_for_a / total_a
  let a_rest = sum_for_a % total_a

  case a_rest == 0, b_rest == 0 {
    True, True -> Some(ButtonPress(a: a_presses, b: b_presses))
    _, _ -> None
  }
}

pub fn calculate_total_tokens(press: Option(ButtonPress)) -> Int {
  case press {
    Some(ButtonPress(a, b)) -> 3 * a + b
    None -> 0
  }
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
