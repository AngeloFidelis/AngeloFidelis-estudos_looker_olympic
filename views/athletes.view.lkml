include: details_olympic.view
view: athletes {
  extends: [details_olympic]
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

  dimension: country_code {
    type: string
    sql: ${TABLE}.country_code ;;
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

  ######################## edições ##########################

  measure: count {
    type: count
    drill_fields: [show_details*]
  }

  set: show_details {
    fields: [
      name,
      country,
      medals.medal_type,
      discipline,
      athletes.height,
      athletes.age
    ]
  }

  dimension: age_tier {
    type: tier
    tiers: [18, 25, 35, 45, 55, 65]
    style: integer
    sql: ${age} ;;
  }

  dimension: age_diff {
    type: number
    sql: DATE_DIFF(CURRENT_DATE, ${birth_date},YEAR) ;;
  }

  measure: avg_age {
    type: average
    sql: ${age} ;;
    value_format: "##.##"
  }
}
