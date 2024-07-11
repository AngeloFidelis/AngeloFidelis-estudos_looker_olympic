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
  ######################## edições ##########################
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

  dimension: medal_usa_yesno{
    type: yesno
    hidden: yes
    sql: ${country} = "United States of America" ;;
  }

  measure: total_usa_medal {
    type: count
    label: "United States medals"
    filters: [medal_usa_yesno: "Yes"]
    drill_fields: [athlete_name,country,medal_type,discipline]
  }

  measure: total_medals {
    type: number
    sql: COUNT(${medal_type}) ;;
    drill_fields: [show_details*]
  }

  measure: count_country_frequency {
    type: number
    sql: COUNT(${country}) ;;
    drill_fields: [medal_type, count]
  }

  measure: count_winners {
    type: count_distinct
    sql: ${id_athlete} ;;
  }
}
