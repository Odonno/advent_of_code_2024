import gleam/dict.{type Dict}
import gleam/list
import day11/common

type BlinkStep = Int
type StoneTotal = Int

type StonePart {
    StonePartStone(stone: common.Stone, remaining_blinks: BlinkStep)
    StonePartBlink(count: StoneTotal)
}

type MemoizedBlinks = Dict(#(common.Stone, BlinkStep), StoneTotal)

fn calculate_total_stones(stones_parts: List(StonePart), total: StoneTotal, memo: MemoizedBlinks) -> StoneTotal {
    case stones_parts {
        [StonePartStone(stone, remaining), ..rest] -> {
            case remaining == 0 {
                True -> {
                    let memo = memo |> dict.insert(#(stone, remaining), 1)
                    calculate_total_stones(rest, total + 1, memo)
                }
                False -> {
                    let new_stones = 
                        common.blink_stone(stone)
                        |> list.map(fn(s) {
                            case memo |> dict.get(#(s, remaining - 1)) {
                                Ok(count) -> StonePartBlink(count)
                                _ -> StonePartStone(s, remaining - 1)
                            }
                        })

                    let new_part_stones =
                        new_stones
                        |> list.filter_map(fn(p) {
                            case p {
                                StonePartStone(_, _) -> Ok(p)
                                _ -> Error(Nil)
                            }
                        })

                    let sub_total = 
                        new_stones
                        |> list.filter_map(fn(p) {
                            case p {
                                StonePartBlink(count) -> Ok(count)
                                _ -> Error(Nil)
                            }
                        })
                        |> list.fold(0, fn(acc, v) { acc + v })

                    let memo = case new_part_stones |> list.is_empty {
                        True -> memo |> dict.insert(#(stone, remaining), sub_total)
                        False -> memo
                    }

                    let stones = new_part_stones |> list.append(rest)

                    calculate_total_stones(stones, total + sub_total, memo)
                }
            }
        }
        _ -> total
    }
}

pub fn main(input: String, use_sample: Bool) -> Nil {
    let stones = common.parse(input)

    let stones_parts = 
        stones
        |> list.map(fn(s) { StonePartStone(s, 75) })

    let result = calculate_total_stones(stones_parts, 0, dict.new())

    common.expect(use_sample, result, 0)
}
