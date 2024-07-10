connection: "olympic_looker_estudos"

include: "/views/**/*.view.lkml"

datagroup: olympic_estudos_looker_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: olympic_estudos_looker_default_datagroup

explore: athletes {
  join: medals {
    type: left_outer
    sql_on: ${athletes.id} = ${medals.id_athlete} ;;
    relationship: one_to_many
  }
}
