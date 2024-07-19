connection: "olympic_looker_estudos"

include: "/views/**/*.view.lkml"

datagroup: olympic_estudos_looker_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "168 hours"
}

persist_with: olympic_estudos_looker_default_datagroup

explore: athletes {
  sql_always_where: ${medals.athletes_by_discipline} IS NOT NULL ;;
  join: medals {
    type: inner
    sql_on: ${athletes.id} = ${medals.id_athlete} ;;
    relationship: one_to_many
  }
  join: calculations_age_medals {
    type: inner
    sql_on: ${medals.id_athlete} = ${calculations_age_medals.id} ;;
    relationship: one_to_many
  }
}

explore: athletes_extends {
  view_name: athletes
  sql_always_where: ${athletes.age} >= 18 AND ${athletes.age} <= 60 ;;
  always_filter: {
    filters: [athletes.gender: "Male"]
  }
  conditionally_filter: {
    filters: [medals.country: "United States of America"]
    unless: [medals.discipline, medals.medal_type]
  }
  extends: [athletes]
}
