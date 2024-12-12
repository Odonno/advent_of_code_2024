import gleam/list
import gleam/set.{type Set}
import gleam/dict
import day12/common

pub fn main(input: String, use_sample: Bool) -> Nil {
    let map = common.parse(input)
    
    let regions = extract_regions(map)
    let result = common.calculate_result(regions)

    common.expect(use_sample, result, 1930)
}

fn extract_regions(map: common.GardenMap) -> List(common.Region) {
    let remaining_positions = map |> dict.keys |> set.from_list
    extract_regions_inner(map, remaining_positions)
}

fn extract_regions_inner(map: common.GardenMap, remaining_positions: Set(common.Position)) -> List(common.Region) {
    let assert Ok(random_position) = remaining_positions |> set.to_list |> list.first

    let assert Ok(plant) = map |> dict.get(random_position)
    let region_positions = common.extract_region_positions([random_position] |> set.from_list, plant, map)

    let perimeter = calculate_perimeter(plant, region_positions, map)

    let region = common.Region(area: region_positions |> set.size, perimeter: perimeter)

    let remaining_positions = 
        remaining_positions
        |> set.difference(region_positions)

    case remaining_positions |> set.size {
        0 -> [region]
        _ -> [region, ..extract_regions_inner(map, remaining_positions)]
    }
}

fn calculate_perimeter(plant: common.Plant, region_positions: Set(common.Position), map: common.GardenMap) -> Int {
    let edges = 
        region_positions
        |> set.to_list
        |> list.flat_map(fn(position) {
            [
                #(position.0 - 1, position.1),
                #(position.0 + 1, position.1),
                #(position.0, position.1 - 1),
                #(position.0, position.1 + 1),
            ]
        })
        |> list.filter(fn(position) {
            map |> dict.get(position) != Ok(plant)
        })

    edges |> list.length
}

