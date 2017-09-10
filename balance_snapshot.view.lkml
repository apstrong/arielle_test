explore: balance_snapshot {}
view: balance_snapshot {
  derived_table: {
    sql: SELECT
      date as balance_date,
      account,
      balance,
      lag(balance, 1) over (partition by account order by date) previous_balance,
      COALESCE(balance - lag(balance, 1) over (partition by account order by date), balance) as net_balance

      FROM `looker-se.arielle.daily_balance` daily_balance

      WHERE {% condition balance_date %} date {% endcondition %}

    --  ORDER BY 2, 1
       ;;
  }

  dimension_group: balance {
    type: time
    timeframes: [raw, date, month, quarter, year]
    sql: cast(${TABLE}.balance_date as timestamp) ;;
  }

  dimension: account {
    type: number
    sql: ${TABLE}.account ;;
  }

  dimension: balance {
    type: number
    value_format_name: usd
    sql: ${TABLE}.balance ;;
  }

  dimension: previous_balance {
    type: number
    sql: ${TABLE}.previous_balance ;;
  }

  dimension: net_balance {
    type: number
    sql: ${TABLE}.net_balance ;;
  }

  measure: overall_balance {
    type: sum
    value_format_name: usd
    sql: ${net_balance} ;;

  }

#   set: detail {
#     fields: [date, account, balance, previous_balance, net_balance]
#   }
}
