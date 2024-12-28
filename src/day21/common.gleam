import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub type Position =
  #(Int, Int)

pub type NumericKey {
  NumberKey(number: Int)
  NumericActivateKey
}

pub type NumericKeypad =
  Dict(Position, NumericKey)

pub type Direction {
  Up
  Left
  Down
  Right
}

pub type DirectionalKey {
  DirectionKey(direction: Direction)
  DirectionalActivateKey
}

pub type DirectionalKeypad =
  Dict(Position, DirectionalKey)

pub type Code =
  List(String)

pub type Sequence =
  List(DirectionalKey)

pub type Level =
  Int

pub type Cache =
  Dict(#(Sequence, Level), Int)

pub fn parse(input: String) -> List(Code) {
  input
  |> string.split("\r\n")
  |> list.map(fn(line) { line |> string.split("") })
}

fn create_numeric_keypad() -> NumericKeypad {
  dict.new()
  |> dict.insert(#(0, 0), NumberKey(7))
  |> dict.insert(#(1, 0), NumberKey(8))
  |> dict.insert(#(2, 0), NumberKey(9))
  |> dict.insert(#(0, 1), NumberKey(4))
  |> dict.insert(#(1, 1), NumberKey(5))
  |> dict.insert(#(2, 1), NumberKey(6))
  |> dict.insert(#(0, 2), NumberKey(1))
  |> dict.insert(#(1, 2), NumberKey(2))
  |> dict.insert(#(2, 2), NumberKey(3))
  |> dict.insert(#(1, 3), NumberKey(0))
  |> dict.insert(#(2, 3), NumericActivateKey)
}

fn create_directional_keypad() -> DirectionalKeypad {
  dict.new()
  |> dict.insert(#(1, 0), DirectionKey(Up))
  |> dict.insert(#(2, 0), DirectionalActivateKey)
  |> dict.insert(#(0, 1), DirectionKey(Left))
  |> dict.insert(#(1, 1), DirectionKey(Down))
  |> dict.insert(#(2, 1), DirectionKey(Right))
}

pub fn solve(codes: List(Code), max_level: Int) -> Int {
  let numeric_keypad = create_numeric_keypad()
  let directional_keypad = create_directional_keypad()

  let code_complexities =
    codes
    |> list.map(fn(code) {
      let first_robot_position = #(2, 3)

      let #(first_level_sequences, _) =
        code
        |> list.fold(#([[]], first_robot_position), fn(acc, char) {
          let #(acc, robot_position) = acc

          let target = get_numeric_key(char)
          let assert Ok(target_position) =
            numeric_keypad
            |> dict.filter(fn(_, value) { value == target })
            |> dict.keys
            |> list.first

          let moves =
            get_moves(
              robot_position,
              target_position,
              numeric_keypad |> dict.keys,
            )

          let acc =
            moves
            |> list.flat_map(fn(current_moves) {
              acc
              |> list.map(fn(previous_moves) {
                previous_moves |> list.append(current_moves)
              })
            })

          #(acc, target_position)
        })

      let #(_, possible_lengths) =
        first_level_sequences
        |> list.map_fold(dict.new(), fn(cache, sequence) {
          get_shortest_sequence_of_button_presses(
            sequence,
            cache,
            directional_keypad,
            directional_keypad |> dict.keys,
            1,
            max_level,
          )
        })

      let assert Ok(length) =
        possible_lengths
        |> list.sort(int.compare)
        |> list.first

      let numeric_value = get_numeric_value(code)

      length * numeric_value
    })

  code_complexities
  |> list.fold(0, fn(acc, v) { acc + v })
}

fn get_shortest_sequence_of_button_presses(
  sequence: Sequence,
  cache: Cache,
  directional_keypad: DirectionalKeypad,
  valid_positions: List(Position),
  level: Int,
  max_level: Int,
) -> #(Cache, Int) {
  case cache |> dict.get(#(sequence, level)) {
    Ok(value) -> #(cache, value)
    _ -> {
      case level == max_level {
        True -> {
          let value = sequence |> list.length
          let cache = cache |> dict.insert(#(sequence, level), value)

          #(cache, value)
        }
        False -> {
          let initial_position = #(2, 0)

          let #(value, cache, _) =
            sequence
            |> list.fold(#(0, cache, initial_position), fn(acc, key) {
              let #(acc, cache, position) = acc

              let assert Ok(target_position) =
                directional_keypad
                |> dict.filter(fn(_, value) { value == key })
                |> dict.keys
                |> list.first

              let inner_sequences =
                get_moves(position, target_position, valid_positions)

              let #(cache, valid_lengths) =
                inner_sequences
                |> list.map_fold(cache, fn(cache, s) {
                  get_shortest_sequence_of_button_presses(
                    s,
                    cache,
                    directional_keypad,
                    valid_positions,
                    level + 1,
                    max_level,
                  )
                })

              let assert Ok(min_length) =
                valid_lengths
                |> list.sort(int.compare)
                |> list.first

              let value = acc + min_length

              #(value, cache, target_position)
            })

          let cache = cache |> dict.insert(#(sequence, level), value)

          #(cache, value)
        }
      }
    }
  }
}

fn get_moves(
  from: Position,
  to: Position,
  valid_positions: List(Position),
) -> List(Sequence) {
  case from == to {
    True -> [[DirectionalActivateKey]]
    False -> {
      let diff_x = to.0 - from.0
      let diff_y = to.1 - from.1

      let horizontal_moves = case diff_x {
        0 -> []
        diff_x if diff_x < 0 -> list.repeat(Left, int.absolute_value(diff_x))
        _ -> list.repeat(Right, int.absolute_value(diff_x))
      }

      let vertical_moves = case diff_y {
        0 -> []
        diff_y if diff_y < 0 -> list.repeat(Up, int.absolute_value(diff_y))
        _ -> list.repeat(Down, int.absolute_value(diff_y))
      }

      let possible_moves = horizontal_moves |> list.append(vertical_moves)
      let possible_sequences =
        possible_moves
        |> list.map(fn(d) { DirectionKey(d) })
        |> list.permutations

      let valid_sequences =
        possible_sequences
        |> list.filter(fn(s) { is_valid_sequence(s, from, valid_positions) })

      valid_sequences
      |> list.map(fn(s) { s |> list.append([DirectionalActivateKey]) })
    }
  }
}

fn is_valid_sequence(
  sequence: Sequence,
  start: Position,
  valid_positions: List(Position),
) -> Bool {
  case sequence {
    [] -> True
    [first, ..rest] -> {
      let new_position = case first {
        DirectionKey(d) -> {
          case d {
            Left -> #(start.0 - 1, start.1)
            Right -> #(start.0 + 1, start.1)
            Up -> #(start.0, start.1 - 1)
            Down -> #(start.0, start.1 + 1)
          }
        }
        _ -> panic as "Unexpected key"
      }

      let is_valid = valid_positions |> list.contains(new_position)

      is_valid && is_valid_sequence(rest, new_position, valid_positions)
    }
  }
}

fn get_numeric_key(char: String) -> NumericKey {
  case char {
    "A" -> NumericActivateKey
    _ -> {
      case char |> int.parse {
        Ok(n) -> NumberKey(n)
        _ -> panic as "Unexpected target key"
      }
    }
  }
}

fn get_numeric_value(code: Code) -> Int {
  let str = code |> string.join("") |> string.replace("A", "")
  let assert Ok(value) = str |> int.parse

  value
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
