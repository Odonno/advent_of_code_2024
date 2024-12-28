import day21/common

pub fn main(input: String, use_sample: Bool) -> Nil {
  let codes = common.parse(input)
  let max_level = 3

  let result = common.solve(codes, max_level)

  common.expect(use_sample, result, 126_384)
}
