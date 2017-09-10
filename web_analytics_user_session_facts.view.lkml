view: user_session_facts {
  derived_table: {
    sql: SELECT
        user_id
        , COUNT(*) AS count_sessions
      FROM ${sessions.SQL_TABLE_NAME} AS sessions
      GROUP BY 1
       ;;
    sql_trigger_value: select current_date ;;
    sortkeys: ["user_id"]
    distribution_style: "all"
  }

  dimension: user_id {
    type: string
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension: lifetime_sessions {
    type: number
    sql: ${TABLE}.count_sessions ;;
  }

}
