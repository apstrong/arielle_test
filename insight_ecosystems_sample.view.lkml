explore: insight_ecosystems_sample {}

view: insight_ecosystems_sample {
  sql_table_name: arielle.insight_sample_data ;;


##############################################################################################################################
# ATTRIBUTES
##############################################################################################################################

# defining the primary key as combination account ID + date
  dimension: pk {
    type: string
    hidden: yes
    primary_key: yes
    sql: concat(${account_id},${date_raw}) ;;
  }

  dimension: account_id {
    type: string
    sql: ${TABLE}.AccountID ;;
  }


# original balance field from the raw data table. hiding this so we only use the new semi-additive balance measure
  dimension: ending_balance {
    hidden: yes
    type: number
    sql: ${TABLE}.EndingBalance ;;
  }

  dimension_group: date {
    label: " "
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    sql: cast(${TABLE}.FullDate as timestamp);;
  }


##############################################################################################################################
# FLAGS (hidden from front end)
# used to determine if a given date is the last day of the week, month, quarter, etc
##############################################################################################################################

# this dimension adds one day to the date. this will be used in the following flags to determine if the date is the last day of the period
# example: on 1/30, the date_plus_1 will be 1/31, so the flag 'end_of_month' will evaluate to false
#          on 1/31, the date_plus_1 will be 2/1, so the flag 'end_of_month' will evaluate to true, and that record will be used in the aggregation
  dimension_group: date_plus_1 {
    hidden: yes
    type: time
    sql: CAST(DATE_ADD(${date_date}, INTERVAL 1 day) as timestamp) ;;
  }

  dimension: end_of_week {
    hidden: yes
    type: yesno
    sql: ${date_week} != ${date_plus_1_week} ;;
  }

  dimension: end_of_month {
    hidden: yes
    type: yesno
    sql: ${date_month} != ${date_plus_1_month} ;;
  }

  dimension: end_of_quarter {
    hidden: yes
    type: yesno
    sql: ${date_quarter} != ${date_plus_1_quarter} ;;
  }

  dimension: end_of_year {
    hidden: yes
    type: yesno
    sql: ${date_year} != ${date_plus_1_year} ;;
  }


##############################################################################################################################
# MEASURES (hidden from front end)
# uses flags (end_of_week, end_of_month, etc) to sum up the balance
# will only sum the dates that are at the end of the period
##############################################################################################################################
  measure: end_of_day_balance {
    type: sum
    hidden: yes
    sql: ${ending_balance} ;;
  }

  measure: end_of_week_balance {
    hidden: yes
    type: sum
    sql: CASE WHEN ${end_of_week} THEN ${ending_balance} END ;;
  }

  measure: end_of_month_balance {
    hidden: yes
    type: sum
    sql: CASE WHEN ${end_of_month} THEN ${ending_balance} END ;;
  }

  measure: end_of_quarter_balance {
    hidden: yes
    type: sum
    sql: CASE WHEN ${end_of_quarter} THEN ${ending_balance} END ;;
  }

  measure: end_of_year_balance {
    hidden: yes
    type: sum
    sql: CASE WHEN ${end_of_year} THEN ${ending_balance} END ;;
  }




##############################################################################################################################
# FINAL BALANCE CALCULATION
# uses the liquid variable _in_query to determine if the end user has selected to slice the data by day, week, month, quarter, or year
# if the user selects date, then use the end of day measure. if the user selects month, then use the end of month measure, etc.
##############################################################################################################################
  measure: balance {
    type: number
    sql: CASE
          WHEN {{ date_date._in_query }} THEN ${end_of_day_balance}
          WHEN {{ date_week._in_query }} THEN ${end_of_week_balance}
          WHEN {{ date_month._in_query }} THEN ${end_of_month_balance}
          WHEN {{ date_quarter._in_query }} THEN ${end_of_quarter_balance}
          WHEN {{ date_year._in_query }} THEN ${end_of_year_balance}
          ELSE ${end_of_day_balance}
        END;;
    value_format_name: usd
  }


}
