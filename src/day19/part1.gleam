import day19/common
import gleam/list
import gleam/string

pub fn main(input: String, use_sample: Bool) -> Nil {
  let #(patterns, designs) = common.parse(input)

  let result =
    designs
    |> list.filter(fn(design) { is_design_possible(patterns, design) })
    |> list.length

  common.expect(use_sample, result, 6)
}

fn is_design_possible(
  patterns: common.TowelPatterns,
  design: common.TowelDesign,
) -> Bool {
  patterns
  |> list.any(fn(pattern) {
    let first = design |> string.slice(0, pattern |> string.length)
    let rest =
      design |> string.slice(pattern |> string.length, design |> string.length)

    case pattern == design, first == pattern {
      True, _ -> True
      _, True -> is_design_possible(patterns, rest)
      _, _ -> False
    }
  })
}
