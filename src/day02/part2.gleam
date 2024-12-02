import gleam/list
import day02/common

pub fn main(input: String, use_sample: Bool) -> Nil {
    let reports = common.parse(input)

    let safe_reports = reports
        |> list.filter(filter_safe_reports)
    
    let result = safe_reports |> list.length

    common.expect(use_sample, result, 4)
}

fn filter_safe_reports(report: common.Report) -> Bool {
    let len = report |> list.length 

    report
        |> list.combinations(len - 1)
        |> list.any(common.is_safe_report)
}