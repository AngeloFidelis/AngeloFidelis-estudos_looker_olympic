view: athletes {
  sql_table_name: `olympic_looker_dataset.athletes` ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: birth_country {
    type: string
    sql: ${TABLE}.birth_country ;;
  }

  dimension_group: birth {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.birth_date ;;
  }

  dimension: birth_place {
    type: string
    sql: ${TABLE}.birth_place ;;
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

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: height {
    type: string
    sql: ${TABLE}.height ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: residence_country {
    type: string
    sql: ${TABLE}.residence_country ;;
  }

  dimension: short_name {
    type: string
    sql: ${TABLE}.short_name ;;
  }
  measure: count {
    type: count
    drill_fields: [id, name, short_name]
  }
}
