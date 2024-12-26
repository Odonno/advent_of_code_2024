import day19/common
import gleam/dict.{type Dict}
import gleam/list
import gleam/string

pub type DesignsCacheCount =
  Dict(common.TowelDesign, Int)

pub fn main(input: String, use_sample: Bool) -> Nil {
  let #(patterns, designs) = common.parse(input)

  let result =
    designs
    |> list.map(fn(design) {
      count_design_possible(patterns, design, dict.new()).1
    })
    |> list.fold(0, fn(acc, v) { acc + v })

  common.expect(use_sample, result, 16)
}

fn count_design_possible(
  patterns: common.TowelPatterns,
  design: common.TowelDesign,
  cache: DesignsCacheCount,
) -> #(DesignsCacheCount, Int) {
  let cache_hit = cache |> dict.get(design)

  case cache_hit {
    Ok(count) -> #(cache, count)
    _ -> {
      patterns
      |> list.fold(#(cache, 0), fn(acc, pattern) {
        let #(cache, acc) = acc

        let first = design |> string.slice(0, pattern |> string.length)
        let rest =
          design
          |> string.slice(pattern |> string.length, design |> string.length)

        let #(cache, value) = case pattern == design, first == pattern {
          True, _ -> #(cache, 1)
          _, True -> count_design_possible(patterns, rest, cache)
          _, _ -> #(cache, 0)
        }

        let cache = cache |> dict.insert(design, acc + value)

        #(cache, acc + value)
      })
    }
  }
}
