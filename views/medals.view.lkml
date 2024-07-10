view: medals {
  sql_table_name: `olympic_looker_dataset.medals` ;;

  dimension: id_athlete {
    primary_key: yes
    type: number
    sql: ${TABLE}.id_athlete ;;
  }

  dimension: athlete_name {
    type: string
    sql: ${TABLE}.athlete_name ;;
  }

  dimension: athlete_short_name {
    type: string
    sql: ${TABLE}.athlete_short_name ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  dimension: country_code {
    type: string
    sql: ${TABLE}.country_code ;;
  }

  dimension: discipline {
    type: string
    sql: ${TABLE}.discipline ;;
  }

  dimension: discipline_code {
    type: string
    sql: ${TABLE}.discipline_code ;;
  }

  dimension: event {
    type: string
    sql: ${TABLE}.event ;;
  }

  dimension: medal_code {
    type: number
    sql: ${TABLE}.medal_code ;;
  }
  dimension_group: medal {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.medal_date ;;
  }

  dimension: medal_type {
    type: string
    sql: ${TABLE}.medal_type ;;
  }
  measure: count {
    type: count
    drill_fields: [show_details*]
  }
  set: show_details {
    fields: [
      athlete_name,
      country,
      medal_type,
      discipline,
      athletes.height,
      athletes.age
    ]
  }
}
