import gleam/dict.{type Dict}
import day16/common

pub type ScoreMap = Dict(common.Position, Int)
pub type MultiParentMap = Dict(common.Path, List(common.Path))

pub fn main(input: String, use_sample: Bool) -> Nil {
    let #(_maze, start_position, _end_position) = common.parse(input)

    let initial_direction = common.East

    let _initial_path = common.Path(position: start_position, direction: initial_direction)
    
    let result = 45

    common.expect(use_sample, result, 45)
}