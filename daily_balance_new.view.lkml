explore: daily_balance_new  {}

view: daily_balance_new {
#   sql_table_name: example_test.daily_balance_live ;;
derived_table: {
  sql: SELECT * FROM example_test.daily_balance_live ;;
  persist_for: "1 hours"
}


dimension: account {
  type: number
  sql: ${TABLE}.account ;;
}

dimension_group: date {
  type: time
  timeframes: [raw, date, week, month, quarter, year]
  sql: CAST(${TABLE}.date as timestamp) ;;
}


measure: end_of_day_balance {
  view_label: "Daily"
  type: sum
  hidden: yes
  sql: ${balance} ;;
}


measure: end_of_week_balance {
  view_label: "Weekly"
  hidden: yes
  type: sum
  sql: CASE WHEN ${end_of_week} THEN ${balance} END ;;
  drill_fields: [account, date_date, end_of_day_balance]
}


measure: end_of_month_balance {
  hidden: yes
  view_label: "Monthly"
  type: sum
  sql: CASE WHEN ${end_of_month} THEN ${balance} END ;;
  drill_fields: [account, date_date, end_of_day_balance]
}

measure: end_of_quarter_balance {
  view_label: "Quarterly"
  hidden: yes
  type: sum
  sql: CASE WHEN ${end_of_quarter} THEN ${balance} END ;;
  drill_fields: [account, date_month, end_of_month_balance]
}

measure: end_of_year_balance {
  view_label: "Yearly"
  hidden: yes
  type: sum
  sql: CASE WHEN ${end_of_year} THEN ${balance} END ;;
  drill_fields: [account, date_month, end_of_month_balance]
}

# HIDDEN

dimension_group: date_plus_1 {
  hidden: yes
  type: time
  sql: CAST(DATE_ADD(${date_date}, INTERVAL 1 day) as timestamp) ;;
}

dimension: end_of_week {
  hidden: yes
  view_label: "Weekly"
  type: yesno
  sql: ${date_week} != ${date_plus_1_week} ;;
}

dimension: end_of_month {
  hidden: yes
  view_label: "Monthly"
  type: yesno
  sql: ${date_month} != ${date_plus_1_month} ;;
}

dimension: end_of_quarter {
  hidden: yes
  view_label: "Quarter"
  type: yesno
  sql: ${date_quarter} != ${date_plus_1_quarter} ;;
}

dimension: end_of_year {
  hidden: yes
  view_label: "Year"
  type: yesno
  sql: ${date_year} != ${date_plus_1_year} ;;
}

dimension: balance {
  hidden: yes
  type: number
  value_format_name: usd
  sql: ${TABLE}.balance ;;
}


# DYNAMIC

measure: dynamic_end_balance {
  type: number
  sql: CASE
          WHEN {{ date_date._in_query }} THEN ${end_of_day_balance}
          WHEN {{ date_week._in_query }} THEN ${end_of_week_balance}
          WHEN {{ date_month._in_query }} THEN ${end_of_month_balance}
          WHEN {{ date_quarter._in_query }} THEN ${end_of_quarter_balance}
          WHEN {{ date_year._in_query }} THEN ${end_of_year_balance}
          ELSE NULL
        END;;
  drill_fields: [account, date_date, end_of_day_balance]
}




}
