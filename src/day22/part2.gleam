import day22/common
import gleam/dict.{type Dict}
import gleam/int
import gleam/iterator
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import simplifile

type PriceChange =
  Int

type PriceChangeIndexes =
  Dict(PriceChange, Set(Int))

pub fn main(_: String, use_sample: Bool) -> Nil {
  let assert Ok(input) = case use_sample {
    True -> simplifile.read("src/day22/sample-2.txt")
    False -> simplifile.read("src/day22/input.txt")
  }

  let values = common.parse(input)

  let iterations = 2000

  let prices_per_row =
    values
    |> list.map(fn(value) {
      let secrets =
        iterator.range(1, iterations)
        |> iterator.scan(value, fn(value, _) { common.iterate(value) })
      let secrets = iterator.single(value) |> iterator.append(secrets)

      secrets |> iterator.to_list |> list.map(get_price)
    })

  let price_changes_per_row = prices_per_row |> list.map(get_price_changes)

  // get all possible sequences
  let possible_sequences =
    price_changes_per_row
    |> list.flat_map(fn(price_changes) {
      price_changes
      |> list.window(4)
      |> list.filter(fn(x) {
        let assert [a, b, c, d] = x
        a != b && b != c && c != d
      })
    })
    |> set.from_list

  let price_change_indexes_list: List(PriceChangeIndexes) =
    price_changes_per_row
    |> list.map(fn(p) {
      p
      |> list.index_fold(dict.new(), fn(acc, price_change, index) {
        acc
        |> dict.upsert(price_change, fn(x) {
          case x {
            Some(set) -> set |> set.insert(index)
            None -> set.from_list([index])
          }
        })
      })
    })

  let prices_and_indexes =
    price_change_indexes_list
    |> list.zip(prices_per_row)

  // determine best sequence & get total bananas
  let possible_sells =
    possible_sequences
    |> set.to_list
    |> list.map(fn(sequence) {
      let assert [a, b, c, d] = sequence

      // find bananas sold in each row
      prices_and_indexes
      |> list.map(fn(p) {
        let #(price_change_indexes, prices) = p

        let first_indexes =
          price_change_indexes
          |> dict.get(a)
          |> result.unwrap(set.new())

        let second_indexes =
          price_change_indexes
          |> dict.get(b)
          |> result.unwrap(set.new())
          |> set.filter(fn(second_index) {
            first_indexes |> set.contains(second_index - 1)
          })

        let third_indexes =
          price_change_indexes
          |> dict.get(c)
          |> result.unwrap(set.new())
          |> set.filter(fn(third_index) {
            second_indexes |> set.contains(third_index - 1)
          })

        let fourth_indexes =
          price_change_indexes
          |> dict.get(d)
          |> result.unwrap(set.new())
          |> set.filter(fn(fourth_index) {
            third_indexes |> set.contains(fourth_index - 1)
          })

        let fourth_index = fourth_indexes |> set.to_list |> list.first

        case fourth_index {
          Ok(index) -> {
            let index = index + 1
            prices |> list.drop(index) |> list.first |> result.unwrap(0)
          }
          Error(Nil) -> 0
        }
      })
      |> list.fold(0, fn(acc, v) { acc + v })
    })

  let result =
    possible_sells
    |> list.sort(int.compare)
    |> list.last
    |> result.unwrap(0)

  common.expect(use_sample, result, 23)
}

fn get_price_changes(prices: List(Int)) -> List(Int) {
  prices
  |> list.window_by_2
  |> list.map(fn(x) {
    let #(a, b) = x
    b - a
  })
}

fn get_price(value: Int) -> Int {
  value
  |> int.digits(10)
  |> result.unwrap([])
  |> list.reverse
  |> list.first
  |> result.unwrap(0)
}
